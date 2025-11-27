#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "toon_format"
require "json"

# Memory profiling helper
def measure_memory
  GC.start
  GC.disable
  memory_before = `ps -o rss= -p #{Process.pid}`.to_i
  yield
  GC.start
  memory_after = `ps -o rss= -p #{Process.pid}`.to_i
  GC.enable
  memory_after - memory_before
end

puts "=" * 80
puts "TOON Format Memory Usage Benchmark"
puts "=" * 80
puts

# Test data sets with varying sizes
data_sets = {
  "Small (10 records)" => Array.new(10) do |i|
    { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
  end,
  "Medium (100 records)" => Array.new(100) do |i|
    { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
  end,
  "Large (1,000 records)" => Array.new(1000) do |i|
    { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
  end,
  "Very Large (10,000 records)" => Array.new(10_000) do |i|
    { id: i, name: "User#{i}", email: "user#{i}@example.com", active: i.even? }
  end
}

data_sets.each do |name, data|
  puts name
  puts "-" * 80

  # Measure JSON encoding memory
  json_memory = measure_memory do
    1000.times { JSON.generate(data) }
  end

  # Measure TOON encoding memory
  toon_memory = measure_memory do
    1000.times { ToonFormat.encode(data) }
  end

  puts "JSON encoding (1000 iterations): #{json_memory} KB"
  puts "TOON encoding (1000 iterations): #{toon_memory} KB"

  diff = json_memory - toon_memory
  if diff.positive?
    puts "Memory saved: #{diff} KB (#{((diff / json_memory.to_f) * 100).round(1)}%)"
  elsif diff.negative?
    puts "Memory overhead: #{diff.abs} KB (#{((diff.abs / json_memory.to_f) * 100).round(1)}%)"
  else
    puts "Memory usage: equivalent"
  end
  puts

  # Measure decoding memory
  json_str = JSON.generate(data)
  toon_str = ToonFormat.encode(data)

  json_decode_memory = measure_memory do
    1000.times { JSON.parse(json_str) }
  end

  toon_decode_memory = measure_memory do
    1000.times { ToonFormat.decode(toon_str) }
  end

  puts "JSON decoding (1000 iterations): #{json_decode_memory} KB"
  puts "TOON decoding (1000 iterations): #{toon_decode_memory} KB"

  diff = json_decode_memory - toon_decode_memory
  if diff.positive?
    puts "Memory saved: #{diff} KB (#{((diff / json_decode_memory.to_f) * 100).round(1)}%)"
  elsif diff.negative?
    puts "Memory overhead: #{diff.abs} KB (#{((diff.abs / json_decode_memory.to_f) * 100).round(1)}%)"
  else
    puts "Memory usage: equivalent"
  end
  puts
  puts "=" * 80
  puts
end

puts "Note: Memory measurements show RSS (Resident Set Size) difference"
puts "Actual memory usage may vary based on Ruby GC behavior and system state"
