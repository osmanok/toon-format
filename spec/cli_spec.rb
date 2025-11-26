# frozen_string_literal: true

require "tempfile"
require "json"

RSpec.describe "CLI" do
  let(:cli_path) { File.expand_path("../exe/toon-format", __dir__) }
  let(:lib_path) { File.expand_path("../lib", __dir__) }

  def run_cli(*args)
    cmd = "ruby -I #{lib_path} #{cli_path} #{args.join(" ")}"
    output = `#{cmd} 2>&1`
    [output, $?.exitstatus]
  end

  describe "help command" do
    it "shows help with --help flag" do
      output, status = run_cli("--help")

      expect(status).to eq(0)
      expect(output).to include("Usage:")
      expect(output).to include("Commands:")
      expect(output).to include("encode")
      expect(output).to include("decode")
      expect(output).to include("stats")
    end

    it "shows help with -h flag" do
      output, status = run_cli("-h")

      expect(status).to eq(0)
      expect(output).to include("Usage:")
    end

    it "shows help when no command provided" do
      output, status = run_cli

      expect(status).to eq(0)
      expect(output).to include("Usage:")
    end
  end

  describe "encode command" do
    it "encodes JSON from stdin" do
      json_data = '{"name":"Alice","age":30}'
      output = `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} encode`

      expect(output).to include("name: Alice")
      expect(output).to include("age: 30")
    end

    it "encodes JSON from file" do
      Tempfile.create(["test", ".json"]) do |file|
        file.write('{"name":"Bob","age":25}')
        file.flush

        output, status = run_cli("encode", file.path)

        expect(status).to eq(0)
        expect(output).to include("name: Bob")
        expect(output).to include("age: 25")
      end
    end

    it "supports custom delimiter option" do
      json_data = '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]'
      output = `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} encode --delimiter '|'`

      expect(output).to include("|")
    end

    it "supports custom indent option" do
      json_data = '{"user":{"name":"Alice"}}'
      output = `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} encode --indent 4`

      expect(output).to include("    name: Alice")
    end
  end

  describe "decode command" do
    it "decodes TOON from stdin" do
      toon_data = "name: Alice\nage: 30"
      output = `echo '#{toon_data}' | ruby -I #{lib_path} #{cli_path} decode`

      parsed = JSON.parse(output)
      expect(parsed["name"]).to eq("Alice")
      expect(parsed["age"]).to eq(30)
    end

    it "decodes TOON from file" do
      Tempfile.create(["test", ".toon"]) do |file|
        file.write("name: Charlie\nage: 35")
        file.flush

        output, status = run_cli("decode", file.path)

        expect(status).to eq(0)
        parsed = JSON.parse(output)
        expect(parsed["name"]).to eq("Charlie")
        expect(parsed["age"]).to eq(35)
      end
    end

    it "supports --no-strict option" do
      toon_data = "name: Alice\nage: 30"
      output = `echo '#{toon_data}' | ruby -I #{lib_path} #{cli_path} decode --no-strict`

      parsed = JSON.parse(output)
      expect(parsed["name"]).to eq("Alice")
    end
  end

  describe "stats command" do
    it "shows token savings statistics" do
      json_data = '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]'
      output = `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} stats`

      expect(output).to include("JSON:")
      expect(output).to include("TOON:")
      expect(output).to include("Savings:")
      expect(output).to include("tokens")
    end

    it "calculates savings percentage" do
      json_data = '{"name":"Alice","age":30}'
      output = `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} stats`

      expect(output).to match(/Savings:.*%/)
    end
  end

  describe "output option" do
    it "writes to file with -o option" do
      Tempfile.create(["output", ".toon"]) do |output_file|
        json_data = '{"name":"Alice","age":30}'
        `echo '#{json_data}' | ruby -I #{lib_path} #{cli_path} encode -o #{output_file.path}`

        content = File.read(output_file.path)
        expect(content).to include("name: Alice")
        expect(content).to include("age: 30")
      end
    end
  end

  describe "error handling" do
    it "shows error for unknown command" do
      output, status = run_cli("unknown")

      expect(status).to eq(1)
      expect(output).to include("Unknown command")
    end

    it "handles invalid JSON gracefully" do
      output = `echo 'invalid json' | ruby -I #{lib_path} #{cli_path} encode 2>&1`

      expect(output).to include("Error:")
    end
  end
end
