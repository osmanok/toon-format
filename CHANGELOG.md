# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Enhanced Rails Integration**:
  - MIME type registration for `:toon` format (`application/toon`)
  - ActionController renderer support (`render toon: @data`)
  - Collection rendering optimization for ActiveRecord::Relation and arrays
  - `ToonFormat::Rails::CollectionHelpers` module for efficient collection rendering
  - Automatic tabular format optimization for uniform collections
  - Support for all `as_json` options (`:only`, `:except`, `:include`, `:methods`)
  - Combined Rails and TOON encoding options in single call
  - Proper Content-Type headers for TOON responses
- **Enhanced ActiveRecord Integration**:
  - Improved `to_toon` method with separated Rails and TOON options
  - Better option handling for attribute filtering
- **Test Coverage**:
  - Comprehensive tests for collection rendering (19 new test cases)
  - Enhanced Railtie integration tests
  - 93.88% code coverage (128 total tests)

### Changed
- Railtie now conditionally registers features based on Rails component availability
- ActiveRecord `to_toon` method now properly separates Rails options from TOON encoding options

## [0.1.0] - 2025-01-XX

### Added
- Initial release of TOON Format Ruby gem
- Core encoding functionality for Ruby objects to TOON format
- Core decoding functionality for TOON format to Ruby objects
- Support for primitive types (nil, boolean, number, string)
- Support for objects (hashes) with nested structures
- Support for arrays (both tabular and list formats)
- Tabular array optimization for uniform data structures
- Smart string quoting (automatic detection)
- Security constraints:
  - Maximum nesting depth (100 levels)
  - Maximum array size (100,000 elements)
  - Circular reference detection
  - Input size validation (10 MB limit)
  - UTF-8 encoding validation
- Strict mode validation for array lengths and field counts
- Lenient mode for flexible parsing
- Custom encoding options (delimiter, indentation, length markers)
- Rails integration with ActiveRecord extensions (`to_toon` method)
- CLI tool with encode, decode, and stats commands
- Token savings estimation utility
- Comprehensive test suite (113 tests, 94% coverage)
- Error handling with custom exception classes
- YARD documentation for public API

### Requirements
- Ruby 3.0.0 or higher
- Tested on Ruby 3.0, 3.1, 3.2, 3.3, 3.4, and head
- No external dependencies (uses only Ruby stdlib)

### Performance Benchmarks
- Comprehensive benchmark suite with 11 specialized tests:
  - Basic encoding/decoding performance
  - Token reduction analysis
  - Scalability tests (1 to 10,000 records)
  - Format comparisons (JSON, YAML, MessagePack, CSV)
  - Real-world scenarios (API responses, DB exports, LLM contexts)
  - Validation overhead (strict vs lenient mode)
  - Deep nesting performance
  - Round-trip fidelity tests
  - Memory usage profiling
- Benchmark runner script for easy execution
- Detailed benchmark documentation

### Known Limitations
- Complex nested structures (arrays within objects within arrays) need additional parser work
- Test coverage at 87% (target: 95%+)
- Conformance tests against official TOON spec not yet implemented

## [Unreleased]

### Planned
- Increase test coverage to 95%+
- Add performance benchmarks
- Add official TOON spec conformance tests
- Improve parser for complex nested structures
- Add streaming API for large files
- Add custom type handlers
- Add schema validation
- Optimize performance further

[0.1.0]: https://github.com/yourusername/toon-format/releases/tag/v0.1.0
