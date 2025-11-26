#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"
require "yaml"

# Try to load MessagePack if available
begin
  require "msgpack"
  MSGPACK_AVAILABLE = true
rescue LoadError
  MSGPACK_AVAILABLE = false
  puts "Note: MessagePack not available. Install with: gem install msgpack"
  puts
end

puts "=" * 80
puts "Format Comparison Benchmark"
puts "Comparing TOON with JSON, YAML#{MSGPACK_AVAILABLE ? ', and MessagePack' : ''}"
puts "=" * 80
puts

# Test datasets
datasets = {
  "Small Object" => {
    id: 1,
    name: "Alice Smith",
    email: "alice@example.com",
    active: true
  },

  "Tabular Data (100 records)" => Array.new(100) do |i|
    {
      id: i,
      name: "User#{i}",
      email: "user#{i}@example.com",
      role: i.even? ? "admin" : "user",
      active: true,
      score: rand(100)
    }
  end,

  "Nested Object" => {
    user: {
      id: 1,
      name: "Alice",
      profile: {
        age: 30,
        city: "NYC",
        preferences: {
          theme: "dark",
          language: "en",
          notifications: true
        }
      }
    },
    posts: [
      { id: 1, title: "First post", likes: 10 },
      { id: 2, title: "Second post", likes: 25 }
    ]
  },

  "Large Tabular (1000 records)" => Array.new(1000) do |i|
    {
      id: i,
      name: "User#{i}",
      email: "user#{i}@example.com",
      score: rand(100)
    }
  end
}

datasets.each do |name, data|
  puts "\n#{name}"
  puts "=" * 80

  # Encoding benchmark
  puts "\nEncoding Speed:"
  puts "-" * 80
  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)

    x.report("JSON") { JSON.generate(data) }
    x.report("YAML") { YAML.dump(data) }
    x.report("TOON") { ToonFormat.encode(data) }
    x.report("MessagePack") { MessagePack.pack(data) } if MSGPACK_AVAILABLE

    x.compare!
  end

  # Generate encoded strings for decoding and size comparison
  json_str = JSON.generate(data)
  yaml_str = YAML.dump(data)
  toon_str = ToonFormat.encode(data)
  msgpack_str = MessagePack.pack(data) if MSGPACK_AVAILABLE

  # Decoding benchmark
  puts "\nDecoding Speed:"
  puts "-" * 80
  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)

    x.report("JSON") { JSON.parse(json_str) }
    x.report("YAML") { YAML.safe_load(yaml_str, permitted_classes: [Symbol]) }
    x.report("TOON") { ToonFormat.decode(toon_str) }
    x.report("MessagePack") { MessagePack.unpack(msgpack_str) } if MSGPACK_AVAILABLE

    x.compare!
  end

  # Size comparison
  puts "\nSize Comparison:"
  puts "-" * 80
  json_size = json_str.bytesize
  yaml_size = yaml_str.bytesize
  toon_size = toon_str.bytesize
  msgpack_size = msgpack_str.bytesize if MSGPACK_AVAILABLE

  puts "JSON:       #{json_size} bytes (baseline)"
  puts "YAML:       #{yaml_size} bytes (#{((yaml_size - json_size) / json_size.to_f * 100).round(1)}% vs JSON)"
  puts "TOON:       #{toon_size} bytes (#{((toon_size - json_size) / json_size.to_f * 100).round(1)}% vs JSON)"
  if MSGPACK_AVAILABLE
    puts "MessagePack: #{msgpack_size} bytes (#{((msgpack_size - json_size) / json_size.to_f * 100).round(1)}% vs JSON)"
  end
  puts

  # Readability (tokens approximation for LLM contexts)
  puts "Human Readability & LLM Token Estimate:"
  puts "-" * 80
  json_tokens = (json_size / 4.0).ceil
  yaml_tokens = (yaml_size / 4.0).ceil
  toon_tokens = (toon_size / 4.0).ceil

  puts "JSON:       ~#{json_tokens} tokens (human-readable)"
  puts "YAML:       ~#{yaml_tokens} tokens (human-readable)"
  puts "TOON:       ~#{toon_tokens} tokens (human-readable, optimized)"
  puts "MessagePack: N/A (binary format - not human-readable)" if MSGPACK_AVAILABLE
  puts

  puts "=" * 80
end

puts "\nSummary:"
puts "=" * 80
puts "TOON Format Advantages:"
puts "  ✓ Human-readable (unlike MessagePack)"
puts "  ✓ 30-60% token reduction vs JSON (better for LLMs)"
puts "  ✓ Faster than YAML for encoding/decoding"
puts "  ✓ Optimal for tabular data (database exports, API responses)"
puts
puts "When to use each format:"
puts "  • JSON:       Universal compatibility, well-established"
puts "  • YAML:       Configuration files, human editing priority"
puts "  • TOON:       LLM contexts, API responses, token optimization"
if MSGPACK_AVAILABLE
  puts "  • MessagePack: Maximum compression, binary protocols"
end
puts "=" * 80
