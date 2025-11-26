#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "toon_format"
require "json"
require "csv"

puts "=" * 80
puts "TOON vs. CSV Token Comparison"
puts "=" * 80
puts

# Data structure for testing
data = Array.new(100) do |i|
  {
    id: i + 1,
    name: "User \#{i + 1}",
    email: "user\#{i + 1}@example.com",
    role: i.even? ? "admin" : "user",
    active: true
  }
end

# Convert to JSON
json_string = JSON.pretty_generate(data)
json_tokens = json_string.length

# Convert to TOON
toon_string = ToonFormat.encode(data)
toon_tokens = toon_string.length

# Convert to CSV
csv_string = CSV.generate do |csv|
  csv << data.first.keys
  data.each do |row|
    csv << row.values
  end
end
csv_tokens = csv_string.length

# Output results
puts "Comparison for 100 User Records"
puts "--------------------------------------------------------------------------------"

puts "JSON:"
puts "  Size: #{json_tokens} bytes"
puts "  Tokens: ~#{json_tokens}"
puts

puts "TOON:"
puts "  Size: #{toon_tokens} bytes"
puts "  Tokens: ~#{toon_tokens}"
puts

puts "CSV:"
puts "  Size: #{csv_tokens} bytes"
puts "  Tokens: ~#{csv_tokens}"
puts

puts "Savings:"
json_minus_toon = json_tokens - toon_tokens
toon_savings_percent = (json_minus_toon / json_tokens.to_f * 100).round(1)
puts "  TOON vs. JSON: #{json_minus_toon} bytes (#{toon_savings_percent}%)"

json_minus_csv = json_tokens - csv_tokens
csv_savings_percent = (json_minus_csv / json_tokens.to_f * 100).round(1)
puts "  CSV vs. JSON: #{json_minus_csv} bytes (#{csv_savings_percent}%)"
puts

puts "================================================================================"
