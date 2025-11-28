# frozen_string_literal: true

if defined?(Rails)
  require "rails/railtie"
  require "toon_format/rails/extensions"

  module ToonFormat
    class Railtie < ::Rails::Railtie
      # Register MIME type for TOON format
      initializer "toon_format.mime_type" do
        # Only register if Mime::Type is available (Rails 3+)
        if defined?(Mime::Type)
          Mime::Type.register "application/toon", :toon
        end
      end

      # Add ActiveRecord extensions
      initializer "toon_format.active_record" do
        ActiveSupport.on_load(:active_record) do
          include ToonFormat::Rails::Extensions
        end
      end

      # Add ActionController renderer
      initializer "toon_format.action_controller" do
        ActiveSupport.on_load(:action_controller) do
          # Make collection helpers available in controllers
          include ToonFormat::Rails::CollectionHelpers

          # Register TOON renderer only if ActionController::Renderers is available
          if defined?(ActionController::Renderers)
            ActionController::Renderers.add :toon do |obj, options|
              # Extract render options
              toon_options = options.slice(:delimiter, :indent, :length_marker)
              rails_options = options.slice(:only, :except, :include, :methods, :root)

              # Set content type
              if defined?(Mime) && Mime.respond_to?(:[])
                self.content_type ||= Mime[:toon]
              end

              # Handle different object types
              result = if obj.is_a?(String)
                         # Already encoded TOON string
                         obj
                       elsif obj.respond_to?(:to_ary) || obj.is_a?(Enumerable)
                         # Collection - use collection helper
                         ToonFormat::Rails::CollectionHelpers.render_collection(
                           obj,
                           **rails_options.merge(toon_options)
                         )
                       elsif obj.respond_to?(:to_toon)
                         # Single model with to_toon
                         obj.to_toon(**rails_options.merge(toon_options))
                       else
                         # Fallback to direct encoding
                         ToonFormat.encode(obj, **toon_options)
                       end

              result
            end
          end
        end
      end
    end
  end
end
