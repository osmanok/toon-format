# frozen_string_literal: true

RSpec.describe ToonFormat::Encoder do
  describe ".encode" do
    context "with primitives" do
      it "encodes nil as null" do
        expect(described_class.encode(nil)).to eq("null")
      end

      it "encodes true as true" do
        expect(described_class.encode(true)).to eq("true")
      end

      it "encodes false as false" do
        expect(described_class.encode(false)).to eq("false")
      end

      it "encodes integers" do
        expect(described_class.encode(42)).to eq("42")
        expect(described_class.encode(-10)).to eq("-10")
        expect(described_class.encode(0)).to eq("0")
      end

      it "encodes floats" do
        expect(described_class.encode(3.14)).to eq("3.14")
        expect(described_class.encode(-2.5)).to eq("-2.5")
      end

      it "encodes simple strings without quotes" do
        expect(described_class.encode("hello")).to eq("hello")
        expect(described_class.encode("world123")).to eq("world123")
      end
    end

    context "with string quoting" do
      it "quotes empty strings" do
        expect(described_class.encode("")).to eq('""')
      end

      it "quotes strings with delimiters" do
        expect(described_class.encode("a,b")).to eq('"a,b"')
      end

      it "quotes strings with leading whitespace" do
        expect(described_class.encode(" hello")).to eq('" hello"')
      end

      it "quotes strings with trailing whitespace" do
        expect(described_class.encode("hello ")).to eq('"hello "')
      end

      it "quotes keyword-like strings" do
        expect(described_class.encode("null")).to eq('"null"')
        expect(described_class.encode("true")).to eq('"true"')
        expect(described_class.encode("false")).to eq('"false"')
      end

      it "quotes numeric-like strings" do
        expect(described_class.encode("123")).to eq('"123"')
        expect(described_class.encode("-45")).to eq('"-45"')
        expect(described_class.encode("3.14")).to eq('"3.14"')
      end

      it "quotes strings with structural characters" do
        expect(described_class.encode("a:b")).to eq('"a:b"')
        expect(described_class.encode("a[b]")).to eq('"a[b]"')
        expect(described_class.encode("a{b}")).to eq('"a{b}"')
      end
    end

    context "with objects (hashes)" do
      it "encodes simple hash" do
        data = { name: "Alice", age: 30 }
        result = described_class.encode(data)
        expect(result).to eq("name: Alice\nage: 30")
      end

      it "encodes hash with various types" do
        data = { name: "Bob", active: true, score: 95, notes: nil }
        result = described_class.encode(data)
        expect(result).to include("name: Bob")
        expect(result).to include("active: true")
        expect(result).to include("score: 95")
        expect(result).to include("notes: null")
      end

      it "encodes nested objects with indentation" do
        data = { user: { name: "Alice", age: 30 } }
        result = described_class.encode(data)
        expect(result).to include("user:")
        expect(result).to include("  name: Alice")
        expect(result).to include("  age: 30")
      end
    end

    context "with tabular arrays" do
      it "detects uniform arrays" do
        data = [
          { id: 1, name: "Alice" },
          { id: 2, name: "Bob" }
        ]
        result = described_class.encode(data)
        expect(result).to include("[2,]{id,name}:")
        expect(result).to include("1,Alice")
        expect(result).to include("2,Bob")
      end

      it "encodes tabular arrays with multiple fields" do
        data = [
          { id: 1, name: "Alice", role: "admin" },
          { id: 2, name: "Bob", role: "user" }
        ]
        result = described_class.encode(data)
        expect(result).to include("[2,]{id,name,role}:")
        expect(result).to include("1,Alice,admin")
        expect(result).to include("2,Bob,user")
      end

      it "handles tabular arrays with null values" do
        data = [
          { id: 1, name: "Alice", email: nil },
          { id: 2, name: "Bob", email: nil }
        ]
        result = described_class.encode(data)
        expect(result).to include("1,Alice,null")
        expect(result).to include("2,Bob,null")
      end
    end

    context "with list arrays" do
      it "encodes empty arrays" do
        expect(described_class.encode([])).to eq("[]")
      end

      it "encodes arrays of primitives" do
        data = [1, 2, 3]
        result = described_class.encode(data)
        expect(result).to include("[3]:")
        expect(result).to include("  1")
        expect(result).to include("  2")
        expect(result).to include("  3")
      end

      it "encodes mixed arrays" do
        data = [
          { id: 1 },
          { name: "Bob" }
        ]
        result = described_class.encode(data)
        expect(result).to include("[2]:")
      end

      it "encodes arrays with nested structures" do
        data = [
          { name: "Alice", tags: %w[ruby python] },
          { name: "Bob", tags: ["java"] }
        ]
        result = described_class.encode(data)
        expect(result).to include("[2]:")
      end
    end

    context "with custom options" do
      it "uses custom delimiter" do
        data = [
          { id: 1, name: "Alice" },
          { id: 2, name: "Bob" }
        ]
        result = described_class.encode(data, delimiter: "|")
        expect(result).to include("{id|name}:")
        expect(result).to include("1|Alice")
      end

      it "uses custom indentation" do
        data = { user: { name: "Alice" } }
        result = described_class.encode(data, indent: 4)
        expect(result).to include("    name: Alice")
      end

      it "disables length markers" do
        data = [1, 2, 3]
        result = described_class.encode(data, length_marker: false)
        expect(result).to include("[]:")
        expect(result).not_to include("[3]:")
      end
    end

    context "with security limits" do
      it "raises error on deep nesting" do
        data = { a: {} }
        current = data[:a]
        101.times do
          current[:b] = {}
          current = current[:b]
        end

        expect do
          described_class.encode(data)
        end.to raise_error(ToonFormat::EncodeError, /Maximum nesting depth/)
      end

      it "raises error on large arrays" do
        data = Array.new(100_001, 1)

        expect do
          described_class.encode(data)
        end.to raise_error(ToonFormat::EncodeError, /Array size.*exceeds maximum/)
      end

      it "detects circular references" do
        data = { a: {} }
        data[:a][:b] = data

        expect do
          described_class.encode(data)
        end.to raise_error(ToonFormat::EncodeError, /Circular reference/)
      end
    end

    context "with unsupported types" do
      it "raises error for unsupported types" do
        expect do
          described_class.encode(Object.new)
        end.to raise_error(ToonFormat::EncodeError, /Unsupported type/)
      end
    end
  end
end
