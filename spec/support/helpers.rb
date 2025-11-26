# frozen_string_literal: true

module ToonFormatTestHelpers
  # Normalize TOON string for comparison (remove trailing whitespace, empty lines)
  def normalize_toon(toon_string)
    toon_string
      .lines
      .map(&:rstrip)
      .reject(&:empty?)
      .join("\n")
  end

  # Load fixture file
  def load_fixture(filename)
    File.read(File.join(__dir__, "../fixtures", filename))
  end

  # Load JSON fixture
  def load_json_fixture(filename)
    JSON.parse(load_fixture(filename))
  end
end

RSpec.configure do |config|
  config.include ToonFormatTestHelpers
end
