#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"

puts "=" * 80
puts "TOON Format - Complete Benchmark Suite"
puts "=" * 80
puts "Running all performance benchmarks..."
puts "Started at: #{Time.now}"
puts "=" * 80
puts

# List of all benchmarks
benchmarks = [
  ["encode_benchmark.rb", "Basic Encoding Performance"],
  ["decode_benchmark.rb", "Basic Decoding Performance"],
  ["token_reduction_benchmark.rb", "Token Reduction Analysis"],
  ["scalability_benchmark.rb", "Scalability Tests"],
  ["format_comparison_benchmark.rb", "Format Comparison (JSON/YAML/MessagePack)"],
  ["real_world_benchmark.rb", "Real-World Scenarios"],
  ["validation_benchmark.rb", "Validation Overhead"],
  ["nesting_benchmark.rb", "Deep Nesting Performance"],
  ["round_trip_benchmark.rb", "Round-Trip Fidelity"],
  ["memory_benchmark.rb", "Memory Usage"],
  ["csv_vs_toon_benchmark.rb", "CSV Comparison"]
]

# Output directory for results
output_dir = File.join(__dir__, "results")
FileUtils.mkdir_p(output_dir)

timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
summary_file = File.join(output_dir, "summary_#{timestamp}.txt")

# Run each benchmark
results = []

benchmarks.each_with_index do |(file, description), index|
  benchmark_path = File.join(__dir__, file)

  unless File.exist?(benchmark_path)
    puts "⚠️  Skipping #{file} (not found)"
    puts
    next
  end

  puts "\n"
  puts "=" * 80
  puts "#{index + 1}/#{benchmarks.size}: #{description}"
  puts "File: #{file}"
  puts "=" * 80
  puts

  start_time = Time.now

  begin
    # Run the benchmark
    system("ruby #{benchmark_path}")
    status = $?.success? ? "✓ SUCCESS" : "✗ FAILED"
    elapsed = Time.now - start_time

    results << {
      file: file,
      description: description,
      status: status,
      elapsed: elapsed
    }

    puts
    puts "Completed in #{elapsed.round(2)}s"
  rescue StandardError => e
    puts "✗ Error running benchmark: #{e.message}"
    results << {
      file: file,
      description: description,
      status: "✗ ERROR",
      elapsed: 0,
      error: e.message
    }
  end

  puts
end

# Generate summary
puts "\n\n"
puts "=" * 80
puts "BENCHMARK SUITE SUMMARY"
puts "=" * 80
puts

total_time = results.sum { |r| r[:elapsed] }
successful = results.count { |r| r[:status] == "✓ SUCCESS" }
failed = results.count { |r| r[:status] != "✓ SUCCESS" }

summary = []
summary << "TOON Format Benchmark Suite Results"
summary << "=" * 80
summary << "Run Date: #{Time.now}"
summary << "Total Time: #{total_time.round(2)}s"
summary << "Total Benchmarks: #{results.size}"
summary << "Successful: #{successful}"
summary << "Failed: #{failed}"
summary << ""
summary << "Individual Results:"
summary << "-" * 80

results.each_with_index do |result, index|
  line = "#{index + 1}. #{result[:description]}"
  line += " " * [50 - result[:description].length, 1].max
  line += "#{result[:status]} (#{result[:elapsed].round(2)}s)"
  summary << line

  if result[:error]
    summary << "   Error: #{result[:error]}"
  end
end

summary << ""
summary << "=" * 80

# Print summary
summary.each { |line| puts line }

# Save summary to file
File.write(summary_file, summary.join("\n"))
puts
puts "Summary saved to: #{summary_file}"
puts

# Quick benchmark comparison table
puts "=" * 80
puts "QUICK REFERENCE: When to Use TOON Format"
puts "=" * 80
puts
puts "Best Performance:"
puts "  ✓ Tabular data (database results, CSV-like)"
puts "  ✓ Uniform array structures"
puts "  ✓ API responses with repeated field patterns"
puts
puts "Good Performance:"
puts "  ✓ Nested objects (up to 5-10 levels)"
puts "  ✓ Mixed data types"
puts "  ✓ Small to medium datasets (< 10MB)"
puts
puts "Token Savings:"
puts "  • Simple objects: 10-30%"
puts "  • Tabular arrays: 30-60%"
puts "  • Nested structures: 20-40%"
puts "  • Large datasets: 40-70%"
puts
puts "Speed vs JSON:"
puts "  • Encoding: 0.5x - 2x (often faster)"
puts "  • Decoding: 0.3x - 1.5x (competitive)"
puts "  • Round-trip: Similar to JSON"
puts
puts "Memory Usage:"
puts "  • Similar to JSON in most cases"
puts "  • Slightly lower for large tabular data"
puts
puts "=" * 80
puts "Complete! Check individual benchmark outputs above for details."
puts "=" * 80
