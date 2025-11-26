# frozen_string_literal: true

module ToonFormat
  # Base error class for all ToonFormat errors
  class Error < StandardError; end

  # Raised when encoding fails
  class EncodeError < Error; end

  # Raised when decoding fails
  class DecodeError < Error; end

  # Raised when strict mode validation fails
  class ValidationError < Error; end

  # Raised when parsing encounters syntax errors
  class ParseError < DecodeError
    attr_reader :line_number, :column

    def initialize(message, line: nil, column: nil)
      @line_number = line
      @column = column
      super(format_message(message))
    end

    private

    def format_message(message)
      return message unless @line_number

      location = " at line #{@line_number}"
      location += ", column #{@column}" if @column
      "#{message}#{location}"
    end
  end
end
