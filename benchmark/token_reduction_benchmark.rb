#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "toon_format"
require "json"

puts "=" * 80
puts "TOON Format Token Reduction Analysis"
puts "=" * 80
puts

# Various data structures to test
test_cases = {
  "Simple Object" => {
    name: "Alice Smith",
    age: 30,
    email: "alice@example.com",
    active: true
  },

  "User Records (10)" => Array.new(10) do |i|
    {
      id: i + 1,
      name: "User #{i + 1}",
      email: "user#{i + 1}@example.com",
      role: i.even? ? "admin" : "user",
      active: true
    }
  end,

  "User Records (100)" => Array.new(100) do |i|
    {
      id: i + 1,
      name: "User #{i + 1}",
      email: "user#{i + 1}@example.com",
      role: i.even? ? "admin" : "user",
      active: true
    }
  end,

  "Nested Structure" => {
    company: {
      name: "Acme Corp",
      employees: [
        { id: 1, name: "Alice", department: "Engineering" },
        { id: 2, name: "Bob", department: "Sales" },
        { id: 3, name: "Carol", department: "Marketing" }
      ],
      metadata: {
        founded: 2020,
        location: "San Francisco"
      }
    }
  },

  "Mixed Array" => [
    { type: "user", id: 1, name: "Alice" },
    { type: "post", id: 101, title: "Hello World" },
    { type: "comment", id: 501, text: "Great post!" }
  ]
}

test_cases.each do |name, data|
  puts name
  puts "-" * 80

  stats = ToonFormat.estimate_savings(data)

  puts "JSON:"
  puts "  Size: #{stats[:json_size]} bytes"
  puts "  Tokens: ~#{stats[:json_tokens]}"
  puts
  puts "TOON:"
  puts "  Size: #{stats[:toon_size]} bytes"
  puts "  Tokens: ~#{stats[:toon_tokens]}"
  puts
  puts "Savings:"
  puts "  Bytes: #{stats[:json_size] - stats[:toon_size]} (#{stats[:savings_percent]}%)"
  puts "  Tokens: ~#{stats[:json_tokens] - stats[:toon_tokens]} (#{stats[:savings_percent]}%)"
  puts
  puts "=" * 80
  puts
end

# Summary
puts "Summary"
puts "=" * 80
total_json_tokens = 0
total_toon_tokens = 0

test_cases.each do |name, data|
  stats = ToonFormat.estimate_savings(data)
  total_json_tokens += stats[:json_tokens]
  total_toon_tokens += stats[:toon_tokens]
  puts "#{name}: #{stats[:savings_percent]}% reduction"
end

puts
overall_savings = ((total_json_tokens - total_toon_tokens) / total_json_tokens.to_f * 100).round(1)
puts "Overall Average: #{overall_savings}% token reduction"
puts "Total JSON tokens: ~#{total_json_tokens}"
puts "Total TOON tokens: ~#{total_toon_tokens}"
puts "Total savings: ~#{total_json_tokens - total_toon_tokens} tokens"
