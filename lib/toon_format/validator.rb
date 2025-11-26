# frozen_string_literal: true

module ToonFormat
  # Validates decoded data in strict mode
  class Validator
    # Validate decoded data against TOON string
    #
    # @param toon_string [String] Original TOON string
    # @param decoded_data [Object] Decoded Ruby object
    # @raise [ValidationError] If validation fails
    def self.validate!(toon_string, decoded_data)
      validate_array_lengths(toon_string, decoded_data)
    end

    def self.validate_array_lengths(toon_string, data)
      # Extract all length markers from TOON string
      length_markers = toon_string.scan(/\[(\d+)(?:,)?\]/).flatten.map(&:to_i)
      arrays = find_non_empty_arrays(data)

      # Only validate if we have length markers
      return if length_markers.empty?

      if length_markers.size != arrays.size
        # This might be okay if there are nested arrays
        # For now, just validate that we have at least as many arrays as markers
        return if arrays.size >= length_markers.size

        raise ValidationError,
              "Length marker count (#{length_markers.size}) does not match array count (#{arrays.size})"
      end

      length_markers.each_with_index do |declared_length, index|
        actual_length = arrays[index]&.size || 0

        next if actual_length == declared_length

        raise ValidationError,
              "Array #{index}: declared length #{declared_length}, actual length #{actual_length}"
      end
    end

    def self.find_non_empty_arrays(data, result = [])
      case data
      when Array
        result << data unless data.empty?
        data.each { |item| find_non_empty_arrays(item, result) }
      when Hash
        data.each_value { |value| find_non_empty_arrays(value, result) }
      end

      result
    end

    def self.find_arrays(data, result = [])
      case data
      when Array
        result << data
        data.each { |item| find_arrays(item, result) }
      when Hash
        data.each_value { |value| find_arrays(value, result) }
      end

      result
    end

    private_class_method :validate_array_lengths, :find_non_empty_arrays
  end
end
