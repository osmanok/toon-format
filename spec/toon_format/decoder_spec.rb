# frozen_string_literal: true

RSpec.describe ToonFormat::Decoder do
  describe ".decode" do
    it "decodes simple TOON strings" do
      toon = "name: Alice\nage: 30"
      result = described_class.decode(toon)

      expect(result).to eq({ name: "Alice", age: 30 })
    end

    it "validates input size" do
      large_input = "x" * (10 * 1024 * 1024 + 1)

      expect do
        described_class.decode(large_input)
      end.to raise_error(ToonFormat::DecodeError, /exceeds maximum size/)
    end

    it "validates UTF-8 encoding" do
      invalid_utf8 = "name: \xFF\xFE"

      expect do
        described_class.decode(invalid_utf8)
      end.to raise_error(ToonFormat::DecodeError, /Invalid UTF-8/)
    end

    context "with strict mode" do
      it "enables validation by default" do
        toon = "[2]:\n  1\n  2"

        # Should not raise error when lengths match
        expect do
          described_class.decode(toon, strict: true)
        end.not_to raise_error
      end

      it "skips validation in lenient mode" do
        toon = "[2]:\n  1\n  2"

        result = described_class.decode(toon, strict: false)
        expect(result).to eq([1, 2])
      end
    end

    it "delegates to Parser for parsing" do
      toon = "test: value"
      parser_double = instance_double(ToonFormat::Parser)
      allow(ToonFormat::Parser).to receive(:new).and_return(parser_double)
      allow(parser_double).to receive(:parse).and_return({ test: "value" })

      result = described_class.decode(toon, strict: false)

      expect(result).to eq({ test: "value" })
      expect(ToonFormat::Parser).to have_received(:new).with(toon, strict: false)
    end
  end
end
