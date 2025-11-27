# frozen_string_literal: true

if defined?(Rails)
  require "rails/railtie"
  require "toon_format/rails/extensions"

  module ToonFormat
    class Railtie < ::Rails::Railtie
      initializer "toon_format.active_record" do
        ActiveSupport.on_load(:active_record) do
          include ToonFormat::Rails::Extensions
        end
      end
    end
  end
end
