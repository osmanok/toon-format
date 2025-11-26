# frozen_string_literal: true

module ToonFormat
  # Parses TOON format strings into Ruby objects
  class Parser
    def initialize(input, strict: true)
      @input = input
      @lines = input.split("\n")
      @position = 0
      @strict = strict
    end

    def parse
      return nil if @lines.empty?

      # Check if the entire input is an object (multiple key-value pairs at root level)
      if looks_like_root_object?
        parse_root_object
      else
        parse_value
      end
    end

    def looks_like_root_object?
      # If we have multiple lines and they all look like key-value pairs at the same indent level
      return false if @lines.size < 2

      @lines.all? do |line|
        line.strip.empty? || line =~ KEY_VALUE_PATTERN || line =~ KEY_ONLY_PATTERN
      end
    end

    def parse_root_object
      result = {}

      while current_line
        line = current_line

        if line.strip.empty?
          advance
          next
        end

        if line =~ KEY_VALUE_PATTERN
          key = ::Regexp.last_match(1)
          value_str = ::Regexp.last_match(2).strip
          advance
          # Check if value is an empty array or empty object
          value = if value_str == "[]"
                    []
                  elsif value_str == "{}"
                    {}
                  else
                    parse_primitive(value_str)
                  end
          result[key.to_sym] = value
        elsif line =~ KEY_ONLY_PATTERN
          key = ::Regexp.last_match(1)
          advance
          result[key.to_sym] = parse_nested_value
        else
          break
        end
      end

      result
    end

    private

    def current_line
      @lines[@position]
    end

    def advance
      @position += 1
    end

    def peek_line(offset = 1)
      @lines[@position + offset]
    end

    TABULAR_ARRAY_PATTERN = /\A\s*\[(\d+),\]\{(.+)\}:/
    LIST_ARRAY_PATTERN = /\A\s*\[(\d+)\]:/
    EMPTY_ARRAY_PATTERN = /\A\s*\[\]/
    KEY_VALUE_PATTERN = /\A\s*(\w+):\s*(.+)/
    KEY_ONLY_PATTERN = /\A\s*(\w+):\s*$/

    def parse_value
      line = current_line
      return nil if line.nil?

      case line
      when TABULAR_ARRAY_PATTERN
        length = ::Regexp.last_match(1).to_i
        fields = ::Regexp.last_match(2).split(",").map(&:strip)
        advance
        parse_tabular_array(length, fields)
      when LIST_ARRAY_PATTERN
        length = ::Regexp.last_match(1).to_i
        advance
        parse_list_array(length)
      when EMPTY_ARRAY_PATTERN
        advance
        []
      when KEY_ONLY_PATTERN
        ::Regexp.last_match(1)
        advance
        parse_nested_value
      when KEY_VALUE_PATTERN
        key = ::Regexp.last_match(1)
        value_str = ::Regexp.last_match(2).strip
        advance
        # Check if value is an empty array or empty object
        value = if value_str == "[]"
                  []
                elsif value_str == "{}"
                  {}
                else
                  parse_primitive(value_str)
                end
        { key.to_sym => value }
      else
        advance
        parse_primitive(line.strip)
      end
    end

    def parse_nested_value
      # Parse a nested value (could be object or array)
      line = current_line
      return nil if line.nil?

      case line
      when TABULAR_ARRAY_PATTERN
        length = ::Regexp.last_match(1).to_i
        fields = ::Regexp.last_match(2).split(",").map(&:strip)
        advance
        parse_tabular_array(length, fields)
      when LIST_ARRAY_PATTERN
        length = ::Regexp.last_match(1).to_i
        advance
        parse_list_array(length)
      when EMPTY_ARRAY_PATTERN
        advance
        []
      else
        parse_object_lines
      end
    end

    def parse_object_lines
      result = {}
      base_indent = get_indent(current_line)

      while current_line && get_indent(current_line) >= base_indent
        if current_line =~ KEY_VALUE_PATTERN
          key = ::Regexp.last_match(1)
          value_str = ::Regexp.last_match(2)
          advance
          result[key.to_sym] = parse_primitive(value_str)
        elsif current_line =~ KEY_ONLY_PATTERN
          key = ::Regexp.last_match(1)
          advance
          result[key.to_sym] = parse_nested_value
        else
          break
        end
      end

      result
    end

    def get_indent(line)
      return 0 if line.nil?

      line.match(/\A(\s*)/)[1].length
    end

    def parse_primitive(value)
      stripped = value.strip

      case stripped
      when "null" then nil
      when "true" then true
      when "false" then false
      when /\A-?\d+\z/ then stripped.to_i
      when /\A-?\d+\.\d+\z/ then stripped.to_f
      when /\A"(.*)"\z/ then unescape_string(::Regexp.last_match(1))
      else stripped
      end
    end

    def unescape_string(str)
      # Unescape double quotes
      str.gsub('\"', '"')
    end

    def parse_tabular_array(length, fields)
      result = []

      length.times do
        line = current_line
        raise ParseError.new("Unexpected end of input in tabular array", line: @position + 1) if line.nil?

        values = split_row(line.strip)

        if @strict && values.size != fields.size
          raise ParseError.new(
            "Field count mismatch: expected #{fields.size}, got #{values.size}",
            line: @position + 1
          )
        end

        row = {}
        fields.each_with_index do |field, index|
          row[field.to_sym] = parse_primitive(values[index] || "")
        end

        result << row
        advance
      end

      result
    end

    def split_row(line)
      # Split by comma, respecting quoted strings
      values = []
      current = ""
      in_quotes = false

      line.each_char do |char|
        case char
        when '"'
          in_quotes = !in_quotes
          current += char
        when ","
          if in_quotes
            current += char
          else
            values << current
            current = ""
          end
        else
          current += char
        end
      end

      values << current unless current.empty?
      values.map(&:strip)
    end

    def parse_list_array(length)
      result = []
      get_indent(current_line)

      length.times do
        raise ParseError.new("Unexpected end of input in list array", line: @position + 1) if current_line.nil?

        # Parse each element
        element = parse_value
        result << element
      end

      result
    end
  end
end
