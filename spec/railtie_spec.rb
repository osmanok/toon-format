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

      File.write(File.join(rails_dir, "railtie.rb"), <<~'RUBY')
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
end
