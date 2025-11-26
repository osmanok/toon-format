# frozen_string_literal: true

RSpec.describe ToonFormat::Validator do
  describe ".validate!" do
    it "passes when array lengths match" do
      toon_string = "[2]:\n  1\n  2"
      decoded_data = [1, 2]

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.not_to raise_error
    end

    it "raises ValidationError when array length mismatches" do
      toon_string = "[3]:\n  1\n  2"
      decoded_data = [1, 2]

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.to raise_error(ToonFormat::ValidationError, /declared length 3, actual length 2/)
    end

    it "validates tabular arrays" do
      toon_string = "[2,]{id,name}:\n1,Alice\n2,Bob"
      decoded_data = [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }]

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.not_to raise_error
    end

    it "handles empty arrays" do
      toon_string = "data: []"
      decoded_data = { data: [] }

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.not_to raise_error
    end

    it "validates nested structures" do
      toon_string = "items: [2]:\n  1\n  2"
      decoded_data = { items: [1, 2] }

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.not_to raise_error
    end

    it "provides detailed error messages" do
      toon_string = "[2]:\n  1\n  2\n  3"
      decoded_data = [1, 2, 3]

      expect do
        described_class.validate!(toon_string, decoded_data)
      end.to raise_error(ToonFormat::ValidationError, /Array 0.*declared length 2, actual length 3/)
    end
  end
end
