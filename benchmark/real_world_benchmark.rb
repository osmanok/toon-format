#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "benchmark/ips"
require "toon_format"
require "json"

puts "=" * 80
puts "Real-World Scenario Benchmarks"
puts "Testing TOON format with realistic application data"
puts "=" * 80
puts

# Scenario 1: REST API User List Response
puts "\nScenario 1: REST API - User List Response"
puts "=" * 80
puts "Use case: /api/users endpoint returning paginated user list"
puts

api_users = Array.new(50) do |i|
  {
    id: i + 1,
    username: "user#{i + 1}",
    email: "user#{i + 1}@example.com",
    first_name: "First#{i + 1}",
    last_name: "Last#{i + 1}",
    role: %w[admin user moderator].sample,
    status: %w[active inactive pending].sample,
    created_at: "2025-01-#{(i % 28) + 1}T10:30:00Z",
    last_login: "2025-01-#{(i % 28) + 1}T15:45:00Z"
  }
end

json_response = JSON.generate(api_users)
toon_response = ToonFormat.encode(api_users)

puts "Response sizes:"
puts "  JSON: #{json_response.bytesize} bytes (~#{(json_response.bytesize / 4.0).ceil} tokens)"
puts "  TOON: #{toon_response.bytesize} bytes (~#{(toon_response.bytesize / 4.0).ceil} tokens)"
puts "  Savings: #{((1 - toon_response.bytesize.to_f / json_response.bytesize) * 100).round(1)}%"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("JSON encode") { JSON.generate(api_users) }
  x.report("TOON encode") { ToonFormat.encode(api_users) }
  x.compare!
end
puts

# Scenario 2: Database Export (Product Catalog)
puts "\nScenario 2: Database Export - Product Catalog"
puts "=" * 80
puts "Use case: Exporting product inventory for analysis"
puts

products = Array.new(200) do |i|
  {
    sku: "PROD#{i.to_s.rjust(5, '0')}",
    name: "Product #{i}",
    category: %w[Electronics Clothing Books Home].sample,
    price: (rand(10..1000) * 100) / 100.0,
    stock: rand(0..500),
    supplier_id: rand(1..20),
    active: [true, false].sample,
    rating: (rand(1..50) / 10.0).round(1)
  }
end

json_export = JSON.generate(products)
toon_export = ToonFormat.encode(products)

puts "Export sizes:"
puts "  JSON: #{json_export.bytesize} bytes"
puts "  TOON: #{toon_export.bytesize} bytes"
puts "  Savings: #{((1 - toon_export.bytesize.to_f / json_export.bytesize) * 100).round(1)}%"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("JSON encode") { JSON.generate(products) }
  x.report("TOON encode") { ToonFormat.encode(products) }
  x.compare!
end
puts

# Scenario 3: LLM Prompt Context (Chat History)
puts "\nScenario 3: LLM Prompt Context - Chat History"
puts "=" * 80
puts "Use case: Including conversation history in LLM prompt"
puts

chat_history = Array.new(20) do |i|
  {
    id: i + 1,
    role: i.even? ? "user" : "assistant",
    content: "This is message number #{i + 1} in the conversation. " * 3,
    timestamp: "2025-01-26T#{(10 + i).to_s.rjust(2, '0')}:30:00Z",
    tokens: rand(50..200)
  }
end

json_context = JSON.generate(chat_history)
toon_context = ToonFormat.encode(chat_history)

puts "Context sizes:"
puts "  JSON: #{json_context.bytesize} bytes (~#{(json_context.bytesize / 4.0).ceil} tokens)"
puts "  TOON: #{toon_context.bytesize} bytes (~#{(toon_context.bytesize / 4.0).ceil} tokens)"
puts "  Token savings: ~#{(json_context.bytesize / 4.0).ceil - (toon_context.bytesize / 4.0).ceil} tokens"
puts "  Cost impact: Fewer tokens = lower LLM API costs!"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("JSON encode") { JSON.generate(chat_history) }
  x.report("TOON encode") { ToonFormat.encode(chat_history) }
  x.compare!
end
puts

# Scenario 4: Analytics Events
puts "\nScenario 4: Analytics Events Log"
puts "=" * 80
puts "Use case: Logging and transmitting analytics events"
puts

analytics_events = Array.new(100) do |i|
  {
    event_id: "evt_#{i}",
    event_type: %w[page_view click purchase signup].sample,
    user_id: rand(1..1000),
    timestamp: Time.now.to_i + i,
    properties: {
      page: "/path/to/page",
      referrer: "https://example.com",
      duration: rand(1..300)
    }
  }
end

json_events = JSON.generate(analytics_events)
toon_events = ToonFormat.encode(analytics_events)

puts "Event log sizes:"
puts "  JSON: #{json_events.bytesize} bytes"
puts "  TOON: #{toon_events.bytesize} bytes"
puts "  Savings: #{((1 - toon_events.bytesize.to_f / json_events.bytesize) * 100).round(1)}%"
puts "  Bandwidth saved per 1000 requests: #{((json_events.bytesize - toon_events.bytesize) * 1000 / 1024.0).round(2)} KB"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("JSON encode") { JSON.generate(analytics_events) }
  x.report("TOON encode") { ToonFormat.encode(analytics_events) }
  x.compare!
end
puts

# Scenario 5: Configuration/Settings Export
puts "\nScenario 5: Application Settings/Configuration"
puts "=" * 80
puts "Use case: Exporting app configuration for backup or transfer"
puts

config = {
  app_name: "MyApp",
  version: "2.1.0",
  database: {
    host: "localhost",
    port: 5432,
    name: "myapp_production",
    pool_size: 20
  },
  cache: {
    enabled: true,
    ttl: 3600,
    backend: "redis",
    redis_url: "redis://localhost:6379/0"
  },
  features: {
    new_dashboard: true,
    beta_features: false,
    analytics: true
  },
  limits: {
    max_upload_size: 10_485_760,
    rate_limit: 1000,
    concurrent_requests: 50
  },
  integrations: [
    { name: "stripe", enabled: true, api_key: "sk_test_..." },
    { name: "sendgrid", enabled: true, api_key: "SG..." },
    { name: "s3", enabled: false, bucket: "my-bucket" }
  ]
}

json_config = JSON.pretty_generate(config)
toon_config = ToonFormat.encode(config)

puts "Config sizes:"
puts "  JSON (pretty): #{json_config.bytesize} bytes"
puts "  TOON:          #{toon_config.bytesize} bytes"
puts "  Savings: #{((1 - toon_config.bytesize.to_f / json_config.bytesize) * 100).round(1)}%"
puts

Benchmark.ips do |x|
  x.config(time: 2, warmup: 1)
  x.report("JSON encode") { JSON.generate(config) }
  x.report("TOON encode") { ToonFormat.encode(config) }
  x.compare!
end
puts

puts "=" * 80
puts "REAL-WORLD INSIGHTS:"
puts "=" * 80
puts "1. API Responses: 30-50% bandwidth reduction = faster responses"
puts "2. Database Exports: Significant savings on large tabular datasets"
puts "3. LLM Contexts: Token reduction directly reduces API costs"
puts "4. Analytics: Lower storage and transmission costs"
puts "5. Configuration: More compact, still human-readable"
puts
puts "Best Use Cases:"
puts "  ✓ REST API responses with tabular data"
puts "  ✓ Database query results"
puts "  ✓ LLM prompt contexts"
puts "  ✓ Batch data processing"
puts "  ✓ Log aggregation and storage"
puts "=" * 80
