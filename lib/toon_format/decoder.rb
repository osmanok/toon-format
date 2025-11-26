# frozen_string_literal: true

module ToonFormat
  # Decodes TOON format strings to Ruby objects
  class Decoder
    MAX_INPUT_SIZE = 10 * 1024 * 1024 # 10 MB

    # Decode TOON format string to Ruby object
    #
    # @param toon_string [String] TOON formatted string
    # @param strict [Boolean] Enable strict validation
    # @return [Object] Decoded Ruby object
    def self.decode(toon_string, strict: true)
      validate_input(toon_string)

      parser = Parser.new(toon_string, strict: strict)
      data = parser.parse

      Validator.validate!(toon_string, data) if strict

      data
    end

    def self.validate_input(toon_string)
      if toon_string.bytesize > MAX_INPUT_SIZE
        raise DecodeError, "Input exceeds maximum size of #{MAX_INPUT_SIZE} bytes"
      end

      return if toon_string.valid_encoding?

      raise DecodeError, "Invalid UTF-8 encoding"
    end

    private_class_method :validate_input
  end
end
