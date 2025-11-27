# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe "require 'toon-format'" do
  it "loads ToonFormat constant in a clean process" do
    lib_path = File.expand_path("../lib", __dir__)

    script = <<~RUBY
      $LOAD_PATH.unshift #{lib_path.inspect}
      require "toon-format"
      print ToonFormat::VERSION
    RUBY

    stdout, status = Open3.capture2("ruby", stdin_data: script)

    expect(status.success?).to be(true)
    expect(stdout).to eq(ToonFormat::VERSION)
  end
end
