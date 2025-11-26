# TOON Format Benchmarks

Comprehensive performance benchmarks for the TOON Format Ruby gem.

## Quick Start

Run all benchmarks:
```bash
ruby benchmark/run_all_benchmarks.rb
```

Run individual benchmarks:
```bash
# Basic performance
ruby benchmark/encode_benchmark.rb
ruby benchmark/decode_benchmark.rb

# Analysis
ruby benchmark/token_reduction_benchmark.rb
ruby benchmark/scalability_benchmark.rb

# Comparisons
ruby benchmark/format_comparison_benchmark.rb
ruby benchmark/csv_vs_toon_benchmark.rb

# Advanced tests
ruby benchmark/validation_benchmark.rb
ruby benchmark/nesting_benchmark.rb
ruby benchmark/round_trip_benchmark.rb
ruby benchmark/memory_benchmark.rb
ruby benchmark/real_world_benchmark.rb
```

## Benchmark Categories

### 1. **Basic Performance**
- **encode_benchmark.rb** - Basic encoding speed tests
- **decode_benchmark.rb** - Basic decoding speed tests

Tests fundamental encode/decode operations with simple, tabular, and nested data.

### 2. **Token Reduction**
- **token_reduction_benchmark.rb** - Token savings analysis

Measures the core value proposition: how much TOON reduces token usage vs JSON for LLM contexts.

### 3. **Scalability**
- **scalability_benchmark.rb** - Performance across data sizes

Tests with datasets from 1 to 10,000 records to show how performance scales.

### 4. **Format Comparisons**
- **format_comparison_benchmark.rb** - vs JSON, YAML, MessagePack
- **csv_vs_toon_benchmark.rb** - vs CSV format

Compares TOON against other serialization formats for encoding/decoding speed, size, and readability.

### 5. **Real-World Scenarios**
- **real_world_benchmark.rb** - Practical use cases

Tests realistic scenarios:
- REST API responses
- Database exports
- LLM prompt contexts
- Analytics events
- Application configuration

### 6. **Advanced Testing**
- **validation_benchmark.rb** - Strict vs lenient mode overhead
- **nesting_benchmark.rb** - Deep nesting performance
- **round_trip_benchmark.rb** - Encode → decode fidelity
- **memory_benchmark.rb** - Memory usage profiling

## Requirements

```ruby
# Gemfile
gem 'benchmark-ips'  # For performance testing
gem 'msgpack'        # Optional, for format comparison
```

Install dependencies:
```bash
bundle install
```

## Understanding Results

### Benchmark-IPS Output
```
TOON encode:  50000 i/s
JSON encode:  25000 i/s
```
Higher is better. "i/s" = iterations per second.

### Comparison Output
```
Comparison:
TOON encode:     50000.0 i/s
JSON encode:     25000.0 i/s - 2.00x slower
```
TOON is 2x faster than JSON in this example.

### Size Comparison
```
JSON: 1000 bytes
TOON: 650 bytes
Savings: 35.0%
```
Negative percentages mean TOON is larger (rare, usually for small objects).

## Expected Results

Based on typical runs:

| Scenario | Encoding Speed | Decoding Speed | Size Savings |
|----------|---------------|----------------|--------------|
| Small objects | 1-2x faster | Similar | 10-30% |
| Tabular arrays | 2-3x faster | 1.5-2x faster | 30-60% |
| Nested objects | Similar | Similar | 20-40% |
| Large datasets | 1.5-2x faster | 1-1.5x faster | 40-70% |

**Note**: Results vary by Ruby version, CPU, and data characteristics.

## Interpreting Performance

### When TOON Excels
- ✅ **Tabular data** (uniform arrays of hashes)
- ✅ **Large datasets** (> 100 records)
- ✅ **Repeated field names** (database results)
- ✅ **API responses** (consistent structure)

### When TOON is Similar to JSON
- 🟡 **Small objects** (< 10 fields)
- 🟡 **Highly irregular data** (varying structures)
- 🟡 **Deep nesting** (> 10 levels)

### Key Metrics

1. **Token Reduction**: Most important for LLM contexts
   - Directly reduces API costs
   - Smaller prompts = faster processing

2. **Encoding Speed**: Important for API responses
   - Faster = lower server latency
   - Scales with request volume

3. **Decoding Speed**: Important for data ingestion
   - Critical for high-throughput pipelines

4. **Memory Usage**: Important for large datasets
   - Lower = more scalable

## Custom Benchmarks

Create your own benchmark:

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

# Your data
data = { your: "data" }

Benchmark.ips do |x|
  x.report("JSON") { JSON.generate(data) }
  x.report("TOON") { ToonFormat.encode(data) }
  x.compare!
end
```

## Contributing

When adding benchmarks:
1. Use `benchmark/ips` for speed tests
2. Include size comparisons
3. Test with realistic data
4. Add to `run_all_benchmarks.rb`
5. Document in this README

## Results Storage

Benchmark results are saved to `benchmark/results/` with timestamps:
```
benchmark/results/summary_20250126_143022.txt
```

This allows tracking performance changes over time.

## CI/CD Integration

Run benchmarks in CI:
```yaml
# .github/workflows/benchmark.yml
- name: Run benchmarks
  run: ruby benchmark/run_all_benchmarks.rb
```

## Questions?

- Check [main README](../README.md) for usage
- See [CLAUDE.md](../CLAUDE.md) for architecture
- Open an issue for benchmark requests
