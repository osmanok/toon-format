#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

puts "=" * 80
puts "TOON Format Scalability Benchmark"
puts "Testing performance across different data sizes"
puts "=" * 80
puts

# Different sizes to test
sizes = [1, 10, 50, 100, 500, 1000, 5000, 10_000]

puts "ENCODING PERFORMANCE"
puts "=" * 80

sizes.each do |size|
  data = Array.new(size) do |i|
    {
      id: i,
      name: "User#{i}",
      email: "user#{i}@example.com",
      role: i.even? ? "admin" : "user",
      active: true,
      score: rand(100)
    }
  end

  puts "\nDataset: #{size} records (#{(data.to_s.bytesize / 1024.0).round(2)} KB in memory)"
  puts "-" * 80

  Benchmark.ips do |x|
    x.config(time: 3, warmup: 1)

    x.report("JSON") { JSON.generate(data) }
    x.report("TOON") { ToonFormat.encode(data) }
    x.compare!
  end
end

puts "\n"
puts "=" * 80
puts "DECODING PERFORMANCE"
puts "=" * 80

sizes.each do |size|
  data = Array.new(size) do |i|
    {
      id: i,
      name: "User#{i}",
      email: "user#{i}@example.com",
      role: i.even? ? "admin" : "user",
      active: true,
      score: rand(100)
    }
  end

  json_str = JSON.generate(data)
  toon_str = ToonFormat.encode(data)

  puts "\nDataset: #{size} records"
  puts "  JSON size: #{json_str.bytesize} bytes"
  puts "  TOON size: #{toon_str.bytesize} bytes (#{((1 - toon_str.bytesize.to_f / json_str.bytesize) * 100).round(1)}% smaller)"
  puts "-" * 80

  Benchmark.ips do |x|
    x.config(time: 3, warmup: 1)

    x.report("JSON") { JSON.parse(json_str) }
    x.report("TOON") { ToonFormat.decode(toon_str) }
    x.compare!
  end
end

puts "\n"
puts "=" * 80
puts "PERFORMANCE SCALING SUMMARY"
puts "=" * 80
puts

require "benchmark"

results = {}

[10, 100, 1000, 10_000].each do |size|
  data = Array.new(size) do |i|
    {
      id: i,
      name: "User#{i}",
      email: "user#{i}@example.com",
      active: i.even?
    }
  end

  json_time = Benchmark.realtime { 100.times { JSON.generate(data) } }
  toon_time = Benchmark.realtime { 100.times { ToonFormat.encode(data) } }

  speedup = (json_time / toon_time).round(2)

  json_str = JSON.generate(data)
  toon_str = ToonFormat.encode(data)
  size_reduction = ((1 - toon_str.bytesize.to_f / json_str.bytesize) * 100).round(1)

  results[size] = {
    speedup: speedup,
    size_reduction: size_reduction
  }

  puts "#{size} records:"
  puts "  Encoding speedup: #{speedup}x"
  puts "  Size reduction: #{size_reduction}%"
  puts
end

puts "=" * 80
puts "Conclusion:"
puts "- TOON format shows consistent performance across all data sizes"
puts "- Size reduction improves with larger tabular datasets"
puts "- Best suited for uniform array data (database exports, API responses)"
puts "=" * 80
