# frozen_string_literal: true

RSpec.describe ToonFormat::Parser do
  describe "#parse" do
    context "with primitives" do
      it "parses null" do
        parser = described_class.new("null")
        expect(parser.parse).to be_nil
      end

      it "parses true" do
        parser = described_class.new("true")
        expect(parser.parse).to eq(true)
      end

      it "parses false" do
        parser = described_class.new("false")
        expect(parser.parse).to eq(false)
      end

      it "parses integers" do
        parser = described_class.new("42")
        expect(parser.parse).to eq(42)

        parser = described_class.new("-10")
        expect(parser.parse).to eq(-10)
      end

      it "parses floats" do
        parser = described_class.new("3.14")
        expect(parser.parse).to eq(3.14)

        parser = described_class.new("-2.5")
        expect(parser.parse).to eq(-2.5)
      end

      it "parses quoted strings" do
        parser = described_class.new('"hello world"')
        expect(parser.parse).to eq("hello world")
      end

      it "parses unquoted strings" do
        parser = described_class.new("hello")
        expect(parser.parse).to eq("hello")
      end
    end

    context "with objects" do
      it "parses simple key-value pairs" do
        toon = "name: Alice\nage: 30"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result).to eq({ name: "Alice", age: 30 })
      end

      it "parses objects with various types" do
        toon = "name: Bob\nactive: true\nscore: 95\nnotes: null"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result[:name]).to eq("Bob")
        expect(result[:active]).to eq(true)
        expect(result[:score]).to eq(95)
        expect(result[:notes]).to be_nil
      end

      it "parses empty arrays and objects" do
        toon = "empty_array: []\nempty_hash: {}"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result[:empty_array]).to eq([])
        expect(result[:empty_hash]).to eq({})
      end
    end

    context "with tabular arrays" do
      it "parses tabular array header and data" do
        toon = "[2,]{id,name}:\n1,Alice\n2,Bob"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to eq({ id: 1, name: "Alice" })
        expect(result[1]).to eq({ id: 2, name: "Bob" })
      end

      it "parses tabular arrays with multiple fields" do
        toon = "[2,]{id,name,role}:\n1,Alice,admin\n2,Bob,user"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result[0][:role]).to eq("admin")
        expect(result[1][:role]).to eq("user")
      end

      it "parses tabular arrays with null values" do
        toon = "[2,]{id,name,email}:\n1,Alice,null\n2,Bob,null"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result[0][:email]).to be_nil
        expect(result[1][:email]).to be_nil
      end

      it "handles quoted values in tabular arrays" do
        toon = "[2,]{id,name}:\n1,\"Alice Smith\"\n2,\"Bob Jones\""
        parser = described_class.new(toon)
        result = parser.parse

        expect(result[0][:name]).to eq("Alice Smith")
        expect(result[1][:name]).to eq("Bob Jones")
      end
    end

    context "with list arrays" do
      it "parses empty arrays" do
        toon = "[]"
        parser = described_class.new(toon)
        expect(parser.parse).to eq([])
      end

      it "parses arrays of primitives" do
        toon = "[3]:\n  1\n  2\n  3"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result).to eq([1, 2, 3])
      end

      it "parses arrays of strings" do
        toon = "[2]:\n  hello\n  world"
        parser = described_class.new(toon)
        result = parser.parse

        expect(result).to eq(%w[hello world])
      end
    end

    context "with strict mode" do
      it "validates field count in tabular arrays" do
        toon = "[2,]{id,name}:\n1,Alice\n2,Bob,extra"
        parser = described_class.new(toon, strict: true)

        expect do
          parser.parse
        end.to raise_error(ToonFormat::ParseError, /Field count mismatch/)
      end

      it "allows mismatched fields in lenient mode" do
        toon = "[2,]{id,name}:\n1,Alice\n2,Bob,extra"
        parser = described_class.new(toon, strict: false)

        expect { parser.parse }.not_to raise_error
      end
    end

    context "with error handling" do
      it "raises ParseError on unexpected end of input" do
        toon = "[3,]{id,name}:\n1,Alice"
        parser = described_class.new(toon, strict: true)

        expect do
          parser.parse
        end.to raise_error(ToonFormat::ParseError, /Unexpected end of input/)
      end

      it "includes line numbers in error messages" do
        toon = "[2,]{id,name}:\n1,Alice\n2,Bob,extra"
        parser = described_class.new(toon, strict: true)

        expect do
          parser.parse
        end.to raise_error(ToonFormat::ParseError, /line 3/)
      end
    end
  end
end
