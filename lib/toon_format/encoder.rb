# frozen_string_literal: true

module ToonFormat
  # Encodes Ruby objects to TOON format strings
  class Encoder
    DEFAULT_OPTIONS = {
      delimiter: ",",
      indent: 2,
      length_marker: true
    }.freeze

    MAX_DEPTH = 100
    MAX_ARRAY_SIZE = 100_000

    # Encode Ruby object to TOON format string
    #
    # @param data [Object] Ruby object to encode
    # @param options [Hash] Encoding options
    # @return [String] TOON formatted string
    def self.encode(data, options = {})
      new(options).encode(data)
    end

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
      @indent_level = 0
      @visited = Set.new
    end

    # Main encode method
    def encode(data, depth = 0)
      check_depth(depth)
      encode_value(data, depth)
    end

    private

    def encode_value(data, depth)
      case data
      when NilClass then "null"
      when TrueClass, FalseClass then data.to_s
      when Numeric then encode_number(data)
      when String then encode_string(data)
      when Hash then encode_object(data, depth)
      when Array then encode_array(data, depth)
      else
        raise EncodeError, "Unsupported type: #{data.class}"
      end
    end

    def check_depth(depth)
      raise EncodeError, "Maximum nesting depth #{MAX_DEPTH} exceeded" if depth > MAX_DEPTH
    end

    def encode_number(num)
      return "0" if num.zero?
      return "null" if num.respond_to?(:nan?) && num.nan?
      return "null" if num.respond_to?(:infinite?) && num.infinite?

      num.to_s
    end

    def encode_string(str)
      return '""' if str.empty?
      return quote(str) if needs_quoting?(str)

      str
    end

    def encode_object(hash, depth)
      return "{}" if hash.empty?

      check_circular_reference(hash)

      lines = hash.map do |key, value|
        key_str = key.to_s

        # Temporarily increase indent for nested values
        @indent_level += 1
        value_str = encode(value, depth + 1)
        @indent_level -= 1

        # Handle multi-line values (nested structures)
        if value_str.include?("\n")
          "#{current_indent}#{key_str}:\n#{value_str}"
        else
          "#{current_indent}#{key_str}: #{value_str}"
        end
      end

      clear_circular_reference(hash)
      lines.join("\n")
    end

    def check_circular_reference(obj)
      obj_id = obj.object_id
      raise EncodeError, "Circular reference detected" if @visited.include?(obj_id)

      @visited.add(obj_id)
    end

    def clear_circular_reference(obj)
      @visited.delete(obj.object_id)
    end

    def current_indent
      " " * (@options[:indent] * @indent_level)
    end

    def indent_lines(text, additional_levels = 0)
      indent_str = " " * (@options[:indent] * (@indent_level + additional_levels))
      text.lines.map { |line| "#{indent_str}#{line}" }.join
    end

    def encode_array(array, depth)
      return "[]" if array.empty?

      check_array_size(array)
      check_circular_reference(array)

      result = if tabular?(array)
                 encode_tabular_array(array, depth)
               else
                 encode_list_array(array, depth)
               end

      clear_circular_reference(array)
      result
    end

    def check_array_size(array)
      return unless array.size > MAX_ARRAY_SIZE

      raise EncodeError, "Array size #{array.size} exceeds maximum #{MAX_ARRAY_SIZE}"
    end

    def primitive?(value)
      value.is_a?(String) ||
        value.is_a?(Numeric) ||
        value.is_a?(TrueClass) ||
        value.is_a?(FalseClass) ||
        value.nil?
    end

    def tabular?(array)
      return false unless array.all? { |el| el.is_a?(Hash) }
      return false if array.empty?

      keys = array.first.keys
      array.all? do |element|
        element.keys == keys &&
          element.values.all? { |v| primitive?(v) }
      end
    end

    def encode_tabular_array(array, _depth)
      keys = array.first.keys
      length_marker = @options[:length_marker] ? "[#{array.size},]" : ""
      fields = keys.map(&:to_s).join(@options[:delimiter])
      header = "#{current_indent}#{length_marker}{#{fields}}:"

      rows = array.map do |row|
        values = keys.map do |key|
          value = row[key]
          encode_primitive_value(value)
        end
        "#{current_indent}#{values.join(@options[:delimiter])}"
      end

      ([header] + rows).join("\n")
    end

    def encode_primitive_value(value)
      case value
      when NilClass then "null"
      when TrueClass, FalseClass then value.to_s
      when Numeric then encode_number(value)
      when String then encode_string(value)
      else
        raise EncodeError, "Non-primitive value in tabular array: #{value.class}"
      end
    end

    def encode_list_array(array, depth)
      length_marker = @options[:length_marker] ? "[#{array.size}]" : "[]"
      header = "#{current_indent}#{length_marker}:"

      @indent_level += 1
      elements = array.map do |item|
        encoded = encode(item, depth + 1)
        # If the encoded value doesn't already have indent (single line primitive), add it
        if encoded.include?("\n")
          encoded
        else
          "#{current_indent}#{encoded}"
        end
      end
      @indent_level -= 1

      ([header] + elements).join("\n")
    end

    QUOTE_PATTERN = /
      \A\s |                      # Leading whitespace
      \s\z |                      # Trailing whitespace
      \A(null|true|false)\z |     # TOON keywords
      \A-?\d+(\.\d+)?\z |         # Numeric pattern
      [:\[\]{},]                  # Structural characters
    /x

    def needs_quoting?(str)
      str.match?(QUOTE_PATTERN)
    end

    def quote(str)
      # Escape any double quotes in the string
      escaped = str.gsub('"', '\"')
      "\"#{escaped}\""
    end
  end
end
