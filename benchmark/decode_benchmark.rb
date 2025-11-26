#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

puts "=" * 80
puts "TOON Format Decoding Benchmark"
puts "=" * 80
puts

# Test data sets
simple_object = { name: "Alice", age: 30, email: "alice@example.com" }
simple_json = JSON.generate(simple_object)
simple_toon = ToonFormat.encode(simple_object)

tabular_data = Array.new(100) do |i|
  { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
end
tabular_json = JSON.generate(tabular_data)
tabular_toon = ToonFormat.encode(tabular_data)

nested_object = {
  user: {
    id: 1,
    name: "Alice",
    profile: {
      age: 30,
      city: "NYC"
    }
  }
}
nested_json = JSON.generate(nested_object)
nested_toon = ToonFormat.encode(nested_object)

puts "Benchmark 1: Simple Object"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.parse") { JSON.parse(simple_json) }
  x.report("ToonFormat.decode") { ToonFormat.decode(simple_toon) }
  x.compare!
end
puts

puts "Benchmark 2: Tabular Data (100 records)"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.parse") { JSON.parse(tabular_json) }
  x.report("ToonFormat.decode") { ToonFormat.decode(tabular_toon) }
  x.compare!
end
puts

puts "Benchmark 3: Nested Object"
puts "-" * 80
Benchmark.ips do |x|
  x.report("JSON.parse") { JSON.parse(nested_json) }
  x.report("ToonFormat.decode") { ToonFormat.decode(nested_toon) }
  x.compare!
end
puts
