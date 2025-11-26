# frozen_string_literal: true

require_relative "toon_format/version"
require_relative "toon_format/errors"
require_relative "toon_format/encoder"
require_relative "toon_format/parser"
require_relative "toon_format/decoder"
require_relative "toon_format/validator"

require_relative "toon_format/rails/extensions" if defined?(ActiveRecord::Base)
require_relative "toon_format/railtie" if defined?(Rails)

require "json"

module ToonFormat
  class << self
    # Encode Ruby object to TOON format string
    #
    # @param data [Object] Ruby object to encode
    # @param options [Hash] Encoding options
    # @option options [String] :delimiter (',') Field delimiter
    # @option options [Integer] :indent (2) Indentation spaces
    # @option options [Boolean] :length_marker (true) Include array lengths
    #
    # @return [String] TOON formatted string
    #
    # @raise [ToonFormat::EncodeError] If data cannot be encoded
    def encode(data, **options)
      Encoder.encode(data, options)
    end

    # Decode TOON format string to Ruby object
    #
    # @param toon_string [String] TOON formatted string
    # @param strict [Boolean] Enable strict validation (default: true)
    #
    # @return [Object] Decoded Ruby object
    #
    # @raise [ToonFormat::DecodeError] If decoding fails
    # @raise [ToonFormat::ValidationError] If strict validation fails
    def decode(toon_string, strict: true)
      Decoder.decode(toon_string, strict: strict)
    end

    # Estimate token savings compared to JSON
    #
    # @param data [Object] Ruby object to analyze
    #
    # @return [Hash] Statistics including token counts and savings percentage
    def estimate_savings(data)
      json_str = JSON.generate(data)
      toon_str = encode(data)

      json_size = json_str.bytesize
      toon_size = toon_str.bytesize

      {
        json_tokens: estimate_tokens(json_str),
        toon_tokens: estimate_tokens(toon_str),
        savings_percent: ((json_size - toon_size) / json_size.to_f * 100).round(1),
        json_size: json_size,
        toon_size: toon_size
      }
    end

    private

    def estimate_tokens(text)
      # Simple approximation: ~4 characters per token
      (text.bytesize / 4.0).ceil
    end
  end
end
