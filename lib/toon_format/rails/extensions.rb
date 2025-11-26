# frozen_string_literal: true

module ToonFormat
  module Rails
    # Extensions for ActiveRecord models
    module Extensions
      # Convert model to TOON format
      #
      # @param options [Hash] Encoding options
      # @return [String] TOON formatted string
      def to_toon(**options)
        ToonFormat.encode(as_json, **options)
      end
    end
  end
end
