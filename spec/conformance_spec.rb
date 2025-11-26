# frozen_string_literal: true

RSpec.describe "TOON Spec Conformance" do
  # NOTE: Official TOON spec test fixtures would be downloaded from:
  # https://github.com/toon-format/spec/tree/main/tests/fixtures
  # For now, we'll create basic conformance tests

  describe "primitive encoding" do
    it "encodes null correctly" do
      expect(ToonFormat.encode(nil)).to eq("null")
    end

    it "encodes booleans correctly" do
      expect(ToonFormat.encode(true)).to eq("true")
      expect(ToonFormat.encode(false)).to eq("false")
    end

    it "encodes numbers correctly" do
      expect(ToonFormat.encode(0)).to eq("0")
      expect(ToonFormat.encode(42)).to eq("42")
      expect(ToonFormat.encode(-10)).to eq("-10")
      expect(ToonFormat.encode(3.14)).to eq("3.14")
    end

    it "encodes strings correctly" do
      expect(ToonFormat.encode("hello")).to eq("hello")
      expect(ToonFormat.encode("")).to eq('""')
    end
  end

  describe "object encoding" do
    it "encodes simple objects" do
      data = { name: "Alice", age: 30 }
      result = ToonFormat.encode(data)
      expect(result).to include("name: Alice")
      expect(result).to include("age: 30")
    end

    it "encodes nested objects" do
      data = { user: { name: "Alice", age: 30 } }
      result = ToonFormat.encode(data)
      expect(result).to include("user:")
      expect(result).to include("  name: Alice")
      expect(result).to include("  age: 30")
    end
  end

  describe "array encoding" do
    it "encodes empty arrays" do
      expect(ToonFormat.encode([])).to eq("[]")
    end

    it "encodes tabular arrays" do
      data = [
        { id: 1, name: "Alice" },
        { id: 2, name: "Bob" }
      ]
      result = ToonFormat.encode(data)
      expect(result).to include("[2,]{id,name}:")
      expect(result).to include("1,Alice")
      expect(result).to include("2,Bob")
    end

    it "encodes list arrays" do
      data = [1, 2, 3]
      result = ToonFormat.encode(data)
      expect(result).to include("[3]:")
    end
  end

  describe "round-trip conformance" do
    it "maintains data fidelity for primitives" do
      [nil, true, false, 0, 42, -10, 3.14, "hello", ""].each do |value|
        encoded = ToonFormat.encode(value)
        decoded = ToonFormat.decode(encoded)
        expect(decoded).to eq(value)
      end
    end

    it "maintains data fidelity for objects" do
      data = { name: "Alice", age: 30, active: true, score: 95.5, notes: nil }
      encoded = ToonFormat.encode(data)
      decoded = ToonFormat.decode(encoded)
      expect(decoded).to eq(data)
    end

    it "maintains data fidelity for tabular arrays" do
      data = [
        { id: 1, name: "Alice", active: true },
        { id: 2, name: "Bob", active: false }
      ]
      encoded = ToonFormat.encode(data)
      decoded = ToonFormat.decode(encoded)
      expect(decoded).to eq(data)
    end

    it "maintains data fidelity for list arrays" do
      data = [1, 2, 3, 4, 5]
      encoded = ToonFormat.encode(data)
      decoded = ToonFormat.decode(encoded)
      expect(decoded).to eq(data)
    end
  end

  describe "spec compliance" do
    it "uses 2-space indentation by default" do
      data = { user: { name: "Alice" } }
      result = ToonFormat.encode(data)
      expect(result).to include("  name: Alice")
    end

    it "includes length markers by default" do
      data = [1, 2, 3]
      result = ToonFormat.encode(data)
      expect(result).to match(/\[\d+\]:/)
    end

    it "uses comma as default delimiter" do
      data = [{ id: 1, name: "Alice" }, { id: 2, name: "Bob" }]
      result = ToonFormat.encode(data)
      expect(result).to include("1,Alice")
    end
  end
end
