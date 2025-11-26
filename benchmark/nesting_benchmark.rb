#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

puts "=" * 80
puts "Deep Nesting Performance Benchmark"
puts "Testing performance with various nesting depths"
puts "=" * 80
puts

# Helper to create nested structure
def create_nested_object(depth)
  if depth <= 1
    { id: 1, name: "Leaf", value: rand(100) }
  else
    {
      id: depth,
      name: "Level#{depth}",
      value: rand(100),
      children: [
        create_nested_object(depth - 1),
        create_nested_object(depth - 1)
      ]
    }
  end
end

# Helper to create nested array structure
def create_nested_array(depth)
  if depth <= 1
    [1, 2, 3, 4, 5]
  else
    [
      { level: depth, data: create_nested_array(depth - 1) },
      { level: depth, data: create_nested_array(depth - 1) }
    ]
  end
end

# Test different nesting depths
depths = [1, 3, 5, 7, 10]

puts "NESTED OBJECT PERFORMANCE"
puts "=" * 80
puts

depths.each do |depth|
  data = create_nested_object(depth)

  json_str = JSON.generate(data)
  toon_str = ToonFormat.encode(data)

  puts "Nesting Depth: #{depth}"
  puts "-" * 80
  puts "JSON size: #{json_str.bytesize} bytes"
  puts "TOON size: #{toon_str.bytesize} bytes (#{((1 - toon_str.bytesize.to_f / json_str.bytesize) * 100).round(1)}% difference)"
  puts

  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)

    x.report("JSON encode") { JSON.generate(data) }
    x.report("TOON encode") { ToonFormat.encode(data) }

    x.compare!
  end

  puts "\nDecoding:"
  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)

    x.report("JSON decode") { JSON.parse(json_str) }
    x.report("TOON decode") { ToonFormat.decode(toon_str) }

    x.compare!
  end

  puts "\n"
end

puts "=" * 80
puts "NESTED ARRAY PERFORMANCE"
puts "=" * 80
puts

[1, 3, 5, 7].each do |depth|
  data = create_nested_array(depth)

  json_str = JSON.generate(data)
  toon_str = ToonFormat.encode(data)

  puts "Array Nesting Depth: #{depth}"
  puts "-" * 80
  puts "JSON size: #{json_str.bytesize} bytes"
  puts "TOON size: #{toon_str.bytesize} bytes"
  puts

  Benchmark.ips do |x|
    x.config(time: 2, warmup: 1)

    x.report("JSON encode") { JSON.generate(data) }
    x.report("TOON encode") { ToonFormat.encode(data) }

    x.compare!
  end

  puts "\n"
end

# Wide vs Deep structures
puts "=" * 80
puts "WIDE VS DEEP STRUCTURES"
puts "=" * 80
puts

wide_structure = {
  data: Array.new(100) { |i|
    { id: i, name: "Item#{i}", value: rand(100) }
  }
}

deep_structure = create_nested_object(15)

puts "Wide Structure (flat array of 100 items):"
puts "-" * 80
json_wide = JSON.generate(wide_structure)
toon_wide = ToonFormat.encode(wide_structure)
puts "JSON: #{json_wide.bytesize} bytes"
puts "TOON: #{toon_wide.bytesize} bytes (#{((1 - toon_wide.bytesize.to_f / json_wide.bytesize) * 100).round(1)}% difference)"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)

  x.report("JSON encode") { JSON.generate(wide_structure) }
  x.report("TOON encode") { ToonFormat.encode(wide_structure) }

  x.compare!
end

puts "\nDeep Structure (15 levels of nesting):"
puts "-" * 80
json_deep = JSON.generate(deep_structure)
toon_deep = ToonFormat.encode(deep_structure)
puts "JSON: #{json_deep.bytesize} bytes"
puts "TOON: #{toon_deep.bytesize} bytes"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)

  x.report("JSON encode") { JSON.generate(deep_structure) }
  x.report("TOON encode") { ToonFormat.encode(deep_structure) }

  x.compare!
end

puts "\n"
puts "=" * 80
puts "COMPLEX NESTING: Arrays in Objects in Arrays"
puts "=" * 80
puts

complex_data = {
  users: Array.new(20) { |i|
    {
      id: i,
      name: "User#{i}",
      posts: Array.new(5) { |j|
        {
          id: j,
          title: "Post #{j}",
          comments: Array.new(3) { |k|
            { id: k, text: "Comment #{k}", likes: rand(10) }
          }
        }
      }
    }
  }
}

json_complex = JSON.generate(complex_data)
toon_complex = ToonFormat.encode(complex_data)

puts "20 users × 5 posts × 3 comments = 300 total items"
puts "-" * 80
puts "JSON size: #{json_complex.bytesize} bytes"
puts "TOON size: #{toon_complex.bytesize} bytes"
puts "Savings: #{((1 - toon_complex.bytesize.to_f / json_complex.bytesize) * 100).round(1)}%"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)

  x.report("JSON encode") { JSON.generate(complex_data) }
  x.report("TOON encode") { ToonFormat.encode(complex_data) }

  x.compare!
end

puts "\n"
puts "=" * 80
puts "INSIGHTS:"
puts "=" * 80
puts "• TOON performs consistently across nesting depths"
puts "• Wide structures (tabular data) see 30-60% size reduction"
puts "• Deep structures have similar performance to JSON"
puts "• Complex mixed nesting maintains good performance"
puts "• Security limit: MAX_DEPTH = 100 levels"
puts
puts "RECOMMENDATIONS:"
puts "  Best for:     Wide tabular data (database results)"
puts "  Good for:     Moderate nesting (3-5 levels)"
puts "  Acceptable:   Deep nesting (up to 100 levels)"
puts "  Avoid:        Extremely irregular nested structures"
puts "=" * 80
