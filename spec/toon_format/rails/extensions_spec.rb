# frozen_string_literal: true

require "spec_helper"
require "toon_format/rails/extensions"

RSpec.describe ToonFormat::Rails::Extensions do
  # Test model class that includes the extension
  let(:test_model_class) do
    Class.new do
      include ToonFormat::Rails::Extensions

      attr_reader :id, :name, :email, :age

      def initialize(id:, name:, email:, age: nil)
        @id = id
        @name = name
        @email = email
        @age = age
      end

      def as_json(options = {})
        attrs = { id: id, name: name, email: email }
        attrs[:age] = age if age

        if options[:only]
          attrs.slice(*options[:only])
        elsif options[:except]
          attrs.except(*options[:except])
        else
          attrs
        end
      end
    end
  end

  let(:model_instance) { test_model_class.new(id: 1, name: "Test User", email: "test@example.com") }

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

    it "respects :only option" do
      result = model_instance.to_toon(only: [:id, :name])

      expect(result).to include("id: 1")
      expect(result).to include("name: Test User")
      expect(result).not_to include("email")
    end

    it "respects :except option" do
      result = model_instance.to_toon(except: [:email])

      expect(result).to include("id: 1")
      expect(result).to include("name: Test User")
      expect(result).not_to include("email")
    end

    it "combines Rails options with TOON encoding options" do
      result = model_instance.to_toon(only: [:id, :name], delimiter: "|")

      expect(result).to be_a(String)
      expect(result).to include("id: 1")
      expect(result).to include("name: Test User")
      expect(result).not_to include("email")
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

RSpec.describe ToonFormat::Rails::CollectionHelpers do
  # Test model class
  let(:test_model_class) do
    Class.new do
      attr_reader :id, :name, :email

      def initialize(id:, name:, email:)
        @id = id
        @name = name
        @email = email
      end

      def as_json(options = {})
        attrs = { id: id, name: name, email: email }

        if options[:only]
          attrs.slice(*options[:only])
        elsif options[:except]
          attrs.except(*options[:except])
        else
          attrs
        end
      end
    end
  end

  let(:collection) do
    [
      test_model_class.new(id: 1, name: "Alice", email: "alice@example.com"),
      test_model_class.new(id: 2, name: "Bob", email: "bob@example.com"),
      test_model_class.new(id: 3, name: "Charlie", email: "charlie@example.com")
    ]
  end

  describe ".render_collection" do
    it "renders a collection to TOON format" do
      result = described_class.render_collection(collection)

      expect(result).to be_a(String)
      expect(result).to include("{id,name,email}:")
      expect(result).to include("1,Alice,alice@example.com")
      expect(result).to include("2,Bob,bob@example.com")
      expect(result).to include("3,Charlie,charlie@example.com")
    end

    it "uses tabular format for uniform collections" do
      result = described_class.render_collection(collection)

      # Should use compact tabular format
      expect(result).to include("[3,]{id,name,email}:")
      expect(result.lines.count).to eq(4) # Header + 3 rows
    end

    it "respects :only option" do
      result = described_class.render_collection(collection, only: [:id, :name])

      expect(result).to include("Alice")
      expect(result).to include("Bob")
      expect(result).not_to include("email")
      expect(result).not_to include("@example.com")
    end

    it "respects :except option" do
      result = described_class.render_collection(collection, except: [:email])

      expect(result).to include("Alice")
      expect(result).to include("Bob")
      expect(result).not_to include("@example.com")
    end

    it "accepts TOON encoding options" do
      result = described_class.render_collection(collection, delimiter: "|", length_marker: false)

      expect(result).to include("{id|name|email}:")
      expect(result).not_to include("[3,]")
    end

    it "combines Rails and TOON options" do
      result = described_class.render_collection(
        collection,
        only: [:id, :name],
        delimiter: "|",
        length_marker: false
      )

      expect(result).to include("{id|name}:")
      expect(result).to include("Alice")
      expect(result).not_to include("email")
      expect(result).not_to include("[")
    end

    it "handles ActiveRecord::Relation-like objects" do
      # Mock an ActiveRecord::Relation
      relation = double("ActiveRecord::Relation", to_a: collection)

      result = described_class.render_collection(relation)

      expect(result).to be_a(String)
      expect(result).to include("Alice")
      expect(result).to include("Bob")
    end

    it "handles empty collections" do
      result = described_class.render_collection([])

      expect(result).to eq("[]")
    end

    it "handles single-item collections" do
      single = [collection.first]
      result = described_class.render_collection(single)

      expect(result).to include("Alice")
      expect(result).to include("[1,]{id,name,email}:")
    end
  end
end
