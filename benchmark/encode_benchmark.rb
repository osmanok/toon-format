#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

puts "=" * 80
puts "TOON Format Encoding Benchmark"
puts "=" * 80
puts

# Test data sets
simple_object = { name: "Alice", age: 30, email: "alice@example.com" }

tabular_data = Array.new(100) do |i|
  { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
end

nested_object = {
  user: {
    id: 1,
    name: "Alice",
    profile: {
      age: 30,
      city: "NYC",
      interests: %w[ruby python javascript]
    }
  },
  metadata: {
    created_at: "2025-01-01",
    updated_at: "2025-01-15"
  }
}

puts "Benchmark 1: Simple Object (#{simple_object.size} fields)"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.generate") { JSON.generate(simple_object) }
  x.report("ToonFormat.encode") { ToonFormat.encode(simple_object) }
  x.compare!
end
puts

puts "Benchmark 2: Tabular Data (#{tabular_data.size} records)"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.generate") { JSON.generate(tabular_data) }
  x.report("ToonFormat.encode") { ToonFormat.encode(tabular_data) }
  x.compare!
end
puts

puts "Benchmark 3: Nested Object"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.generate") { JSON.generate(nested_object) }
  x.report("ToonFormat.encode") { ToonFormat.encode(nested_object) }
  x.compare!
end
puts

puts "=" * 80
puts "Size Comparison"
puts "=" * 80

[
  ["Simple Object", simple_object],
  ["Tabular Data", tabular_data],
  ["Nested Object", nested_object]
].each do |name, data|
  json_size = JSON.generate(data).bytesize
  toon_size = ToonFormat.encode(data).bytesize
  savings = ((json_size - toon_size) / json_size.to_f * 100).round(1)

  puts "#{name}:"
  puts "  JSON: #{json_size} bytes"
  puts "  TOON: #{toon_size} bytes"
  puts "  Savings: #{savings}%"
  puts
end
