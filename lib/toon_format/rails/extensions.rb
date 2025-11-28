# frozen_string_literal: true

module ToonFormat
  module Rails
    # Extensions for ActiveRecord models and collections
    module Extensions
      # Convert model to TOON format
      #
      # @param options [Hash] Encoding options plus Rails-specific options
      # @option options [Array<Symbol>] :only Attributes to include
      # @option options [Array<Symbol>] :except Attributes to exclude
      # @option options [Hash] :include Associations to include
      # @option options [Hash] :methods Additional methods to include
      # @return [String] TOON formatted string
      def to_toon(**options)
        # Extract Rails-specific options for as_json
        rails_options = options.slice(:only, :except, :include, :methods, :root)
        # Extract TOON encoding options
        toon_options = options.except(:only, :except, :include, :methods, :root)

        json_data = rails_options.empty? ? as_json : as_json(rails_options)
        ToonFormat.encode(json_data, **toon_options)
      end
    end

    # Collection rendering helpers
    module CollectionHelpers
      # Efficiently render a collection to TOON format
      #
      # @param collection [Enumerable] Collection to render (ActiveRecord::Relation, Array, etc.)
      # @param options [Hash] Encoding options plus Rails-specific options
      # @return [String] TOON formatted string
      def render_collection(collection, **options)
        # Convert ActiveRecord::Relation to array if needed
        data = collection.respond_to?(:to_a) ? collection.to_a : collection

        # Extract Rails-specific options for as_json
        rails_options = options.slice(:only, :except, :include, :methods, :root)
        # Extract TOON encoding options
        toon_options = options.except(:only, :except, :include, :methods, :root)

        # Convert collection to JSON-compatible format
        json_data = if rails_options.empty?
                      data.map(&:as_json)
                    else
                      data.map { |item| item.as_json(rails_options) }
                    end

        ToonFormat.encode(json_data, **toon_options)
      end

      module_function :render_collection
    end
  end
end
