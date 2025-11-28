# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "open3"

RSpec.describe "Railtie loading" do
  it "loads ToonFormat::Railtie when Rails is defined" do
    Dir.mktmpdir do |tmpdir|
      rails_dir = File.join(tmpdir, "rails")
      FileUtils.mkdir_p(rails_dir)

      File.write(File.join(rails_dir, "railtie.rb"), <<~RUBY)
        module ActiveSupport
          def self.on_load(*)
          end
        end

        module Rails
          class Railtie
            def self.initializer(*)
              yield if block_given?
            end
          end
        end
      RUBY

      lib_path = File.expand_path("../lib", __dir__)

      script = <<~RUBY
        $LOAD_PATH.unshift #{tmpdir.inspect}
        $LOAD_PATH.unshift #{lib_path.inspect}
        require "rails/railtie"
        require "toon-format"
        print [defined?(ToonFormat::Railtie), ToonFormat::Railtie < ::Rails::Railtie]
      RUBY

      stdout, status = Open3.capture2("ruby", stdin_data: script)

      expect(status.success?).to be(true)
      expect(stdout).to eq("[\"constant\", true]")
    end
  end

  it "registers MIME type and ActionController renderer when Rails is present" do
    Dir.mktmpdir do |tmpdir|
      lib_path = File.expand_path("../lib", __dir__)

      # Create mock rails/railtie.rb
      rails_dir = File.join(tmpdir, "rails")
      FileUtils.mkdir_p(rails_dir)
      File.write(File.join(rails_dir, "railtie.rb"), <<~RUBY)
        module Rails
          class Railtie
            @@initializers = []

            def self.initializer(name)
              @@initializers << name
              yield if block_given?
            end

            def self.initializers
              @@initializers
            end
          end
        end
      RUBY

      # Mock Rails, ActionController, and Mime modules
      File.write(File.join(tmpdir, "test_rails_integration.rb"), <<~RUBY)
        # Add mock rails dir to load path first
        $LOAD_PATH.unshift("#{tmpdir}")

        # Pre-load rails/railtie to define Rails module
        require "rails/railtie"

        # Mock Mime::Type
        module Mime
          class Type
            @@registered_types = []

            def self.register(type, symbol)
              @@registered_types << { type: type, symbol: symbol }
            end

            def self.registered_types
              @@registered_types
            end

            def self.[](symbol)
              @@registered_types.find { |t| t[:symbol] == symbol }
            end
          end
        end

        # Mock ActiveSupport
        module ActiveSupport
          @@on_load_blocks = {}

          def self.on_load(component, &block)
            @@on_load_blocks[component] ||= []
            @@on_load_blocks[component] << block if block
          end

          def self.run_load_hooks(component, base = Object)
            (@@on_load_blocks[component] || []).each do |block|
              base.instance_eval(&block)
            end
          end
        end

        # Mock ActionController
        module ActionController
          module Renderers
            @@renderers = {}

            def self.add(format, &block)
              @@renderers[format] = block
            end

            def self.has_renderer?(format)
              @@renderers.key?(format)
            end
          end
        end

        # Now require toon-format
        $LOAD_PATH.unshift("#{lib_path}")
        require "toon-format"

        # Check initializers were registered
        puts "Initializers: \#{Rails::Railtie.initializers.join(', ')}"

        # Check MIME type was registered
        toon_mime = Mime::Type.registered_types.find { |t| t[:symbol] == :toon }
        puts "MIME registered: \#{!toon_mime.nil?}"
        puts "MIME type: \#{toon_mime[:type]}" if toon_mime

        # Trigger ActionController load hooks
        ActiveSupport.run_load_hooks(:action_controller)

        # Check renderer was registered
        puts "Renderer registered: \#{ActionController::Renderers.has_renderer?(:toon)}"
      RUBY

      stdout, stderr, status = Open3.capture3("ruby", File.join(tmpdir, "test_rails_integration.rb"))

      expect(status.success?).to be(true), "Script failed with stderr: #{stderr}"
      expect(stdout).to include("Initializers: toon_format.mime_type, toon_format.active_record, toon_format.action_controller")
      expect(stdout).to include("MIME registered: true")
      expect(stdout).to include("MIME type: application/toon")
      expect(stdout).to include("Renderer registered: true")
    end
  end
end
