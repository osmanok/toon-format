# frozen_string_literal: true

require "spec_helper"
require "toon_format/rails/extensions"

RSpec.describe ToonFormat::Rails::Extensions do
  # Test model class that includes the extension
  let(:test_model_class) do
    Class.new do
      include ToonFormat::Rails::Extensions

      def as_json(_options = {})
        { id: 1, name: "Test User", email: "test@example.com" }
      end
    end
  end

  let(:model_instance) { test_model_class.new }

  describe "#to_toon" do
    it "converts model to TOON format" do
      result = model_instance.to_toon

      expect(result).to be_a(String)
      expect(result).to include("id: 1")
      expect(result).to include("name: Test User")
      expect(result).to include("email: test@example.com")
    end

    it "accepts encoding options" do
      result = model_instance.to_toon(delimiter: "|")

      expect(result).to be_a(String)
    end

    it "uses as_json for serialization" do
      expect(model_instance).to receive(:as_json).and_call_original

      model_instance.to_toon
    end
  end

  describe "module definition" do
    it "defines the extension module" do
      expect(ToonFormat::Rails::Extensions).to be_a(Module)
    end

    it "provides to_toon method" do
      expect(model_instance).to respond_to(:to_toon)
    end
  end

  # Railtie integration tested manually in Rails app or full integration suite
  # (requires Rails env - skips in unit specs)

  describe "graceful loading without Rails" do
    it "loads without errors" do
      expect { require "toon_format" }.not_to raise_error
    end

    it "does not require Rails to use core features" do
      expect(ToonFormat).to respond_to(:encode)
      expect(ToonFormat).to respond_to(:decode)
    end
  end
end
