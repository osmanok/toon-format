# Feature Development Guide for TOON Format Gem

This guide outlines everything you need to know to add a new feature to the TOON Format gem.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Development Setup](#development-setup)
3. [Architecture Overview](#architecture-overview)
4. [Adding a New Feature - Step by Step](#adding-a-new-feature---step-by-step)
5. [Testing Requirements](#testing-requirements)
6. [Code Style Guidelines](#code-style-guidelines)
7. [Documentation Requirements](#documentation-requirements)
8. [Common Feature Types](#common-feature-types)

---

## Prerequisites

Before adding a feature, ensure you have:

- **Ruby 3.2+** (check with `ruby -v`)
- **Bundler** installed (`gem install bundler`)
- **Git** for version control
- Understanding of the [TOON Format Specification](https://github.com/toon-format/spec)

---

## Development Setup

### 1. Clone and Setup

```bash
# Fork the repository first on GitHub, then:
git clone https://github.com/YOUR_USERNAME/toon-format.git
cd toon-format

# Install dependencies
bin/setup

# Verify setup
bundle exec rspec
```

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates

---

## Architecture Overview

### Core Components

```
lib/toon_format/
├── version.rb          # Version management
├── errors.rb           # Custom error classes
├── encoder.rb          # Ruby → TOON encoding
├── decoder.rb          # TOON → Ruby decoding
├── parser.rb           # TOON string parsing
├── validator.rb        # Validation logic
└── rails/              # Rails integration
    ├── extensions.rb   # ActiveRecord extensions
    └── railtie.rb      # Rails initialization
```

### Entry Point

`lib/toon_format.rb` - Main module with public API:
- `ToonFormat.encode(data, **options)`
- `ToonFormat.decode(toon_string, strict: true)`
- `ToonFormat.estimate_savings(data)`

### Data Flow

```
Encoding: Ruby Object → Encoder → TOON String
Decoding: TOON String → Parser → Validator → Decoder → Ruby Object
```

---

## Adding a New Feature - Step by Step

### Step 1: Plan Your Feature

Before coding, answer:

1. **What problem does it solve?**
2. **Does it fit the TOON format spec?**
3. **Where does it belong?** (Encoder, Decoder, Parser, Validator, or new module?)
4. **What's the public API?** (New method? New option?)
5. **Breaking change?** (If yes, consider version bump)

### Step 2: Write Tests First (TDD)

Create or update specs in `spec/toon_format/`:

```ruby
# spec/toon_format/your_feature_spec.rb
RSpec.describe ToonFormat::YourFeature do
  describe ".your_method" do
    it "does something" do
      expect(ToonFormat.your_method(data)).to eq(expected_result)
    end
  end
end
```

**Run tests:**
```bash
bundle exec rspec spec/toon_format/your_feature_spec.rb
```

### Step 3: Implement the Feature

#### Option A: Adding to Existing Module

If adding to `Encoder`, `Decoder`, etc.:

```ruby
# lib/toon_format/encoder.rb
module ToonFormat
  class Encoder
    # Add your method here
    def your_method
      # Implementation
    end
  end
end
```

#### Option B: Creating New Module

1. Create new file: `lib/toon_format/your_feature.rb`
2. Add require in `lib/toon_format.rb`:
   ```ruby
   require_relative "toon_format/your_feature"
   ```
3. Expose public API if needed:
   ```ruby
   module ToonFormat
     class << self
       def your_public_method
         YourFeature.method
       end
     end
   end
   ```

### Step 4: Update Public API (if needed)

If adding a new public method, update `lib/toon_format.rb`:

```ruby
module ToonFormat
  class << self
    # Add YARD documentation
    # @param data [Object] Description
    # @return [Type] Description
    def your_new_method(data, **options)
      YourFeature.process(data, options)
    end
  end
end
```

### Step 5: Run Full Test Suite

```bash
# Run all tests
bundle exec rspec

# Check coverage (should be 93%+)
COVERAGE=true bundle exec rspec
```

### Step 6: Code Style

```bash
# Auto-fix style issues
bundle exec rubocop -a

# Check for remaining issues
bundle exec rubocop
```

### Step 7: Update Documentation

1. **README.md** - Add usage examples if public API changes
2. **CHANGELOG.md** - Add entry under "Unreleased" or version section
3. **Inline docs** - Add YARD comments for public methods

### Step 8: Update Version (if needed)

If breaking change or major feature:
```ruby
# lib/toon_format/version.rb
module ToonFormat
  VERSION = "0.2.0"  # or appropriate version
end
```

### Step 9: Commit and Push

```bash
git add .
git commit -m "Add feature: brief description

- Detailed explanation
- What it does
- Why it's useful"

git push origin feature/your-feature-name
```

### Step 10: Create Pull Request

- Fill out PR template
- Link related issues
- Ensure CI passes
- Request review

---

## Testing Requirements

### Test Structure

```
spec/
├── spec_helper.rb              # Test configuration
├── toon_format/
│   ├── encoder_spec.rb         # Encoder tests
│   ├── decoder_spec.rb         # Decoder tests
│   ├── parser_spec.rb          # Parser tests
│   └── validator_spec.rb       # Validator tests
├── integration/                # Integration tests
└── support/                    # Test helpers
```

### Test Coverage Requirements

- **Minimum: 93%** coverage (enforced by SimpleCov)
- **New features: 95%+** coverage expected
- Test both **happy paths** and **error cases**
- Include **edge cases** and **boundary conditions**

### Example Test Structure

```ruby
RSpec.describe ToonFormat::YourFeature do
  describe ".method_name" do
    context "with valid input" do
      it "returns expected result" do
        # Test happy path
      end
    end

    context "with invalid input" do
      it "raises appropriate error" do
        # Test error handling
      end
    end

    context "edge cases" do
      it "handles empty input" do
        # Test edge case
      end
    end
  end
end
```

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/toon_format/encoder_spec.rb

# Specific test
bundle exec rspec spec/toon_format/encoder_spec.rb:42

# With coverage
COVERAGE=true bundle exec rspec
```

---

## Code Style Guidelines

### RuboCop Configuration

The project uses RuboCop (`.rubocop.yml`). Run before committing:

```bash
bundle exec rubocop -a  # Auto-fix
bundle exec rubocop     # Check only
```

### Ruby Style

- Use **frozen string literals**: `# frozen_string_literal: true`
- Follow **Ruby 3.2+** conventions
- Use **meaningful variable names**
- Keep methods **focused** (single responsibility)
- Add **YARD documentation** for public methods

### Example Code Style

```ruby
# frozen_string_literal: true

module ToonFormat
  # Brief description of the class
  class YourFeature
    # Class-level method with YARD docs
    #
    # @param data [Object] Description
    # @param options [Hash] Options hash
    # @return [String] Description
    def self.process(data, options = {})
      new(options).process(data)
    end

    def initialize(options = {})
      @options = options
    end

    private

    def process(data)
      # Implementation
    end
  end
end
```

---

## Documentation Requirements

### 1. Inline Documentation (YARD)

All public methods need YARD comments:

```ruby
# Encode Ruby object to TOON format
#
# @param data [Object] Ruby object to encode
# @param options [Hash] Encoding options
# @option options [String] :delimiter (',') Field delimiter
# @return [String] TOON formatted string
# @raise [ToonFormat::EncodeError] If encoding fails
def encode(data, **options)
  # ...
end
```

### 2. README.md Updates

If adding public API:
- Add to "Quick Start" or "Advanced Usage"
- Include code examples
- Update feature list if applicable

### 3. CHANGELOG.md

Add entry following format:

```markdown
## [Unreleased]

### Added
- New feature: Description of what was added

### Changed
- Modified behavior: Description

### Fixed
- Bug fix: Description
```

### 4. Architecture Documentation

If adding new module or significant changes, update:
- Architecture diagram in README.md
- CLAUDE.md (if exists)

---

## Common Feature Types

### 1. New Encoding Option

**Location:** `lib/toon_format/encoder.rb`

**Steps:**
1. Add option to `DEFAULT_OPTIONS`
2. Use option in encoding logic
3. Add tests for new option
4. Update `encode` method documentation
5. Add example to README

**Example:**
```ruby
DEFAULT_OPTIONS = {
  delimiter: ",",
  indent: 2,
  length_marker: true,
  new_option: false  # Add here
}.freeze
```

### 2. New Decoding Option

**Location:** `lib/toon_format/decoder.rb`

**Steps:**
1. Add parameter to `decode` method
2. Pass to decoder logic
3. Add tests
4. Update documentation

### 3. New Validation Rule

**Location:** `lib/toon_format/validator.rb`

**Steps:**
1. Add validation method
2. Call from `validate` method
3. Add custom error if needed (`errors.rb`)
4. Write comprehensive tests

### 4. Rails Integration Feature

**Location:** `lib/toon_format/rails/extensions.rb`

**Steps:**
1. Add ActiveRecord extension method
2. Add tests in `spec/toon_format/rails/extensions_spec.rb`
3. Update Rails integration section in README

### 5. CLI Feature

**Location:** `exe/toon-format`

**Steps:**
1. Add command/subcommand
2. Add tests in `spec/cli_spec.rb`
3. Update CLI section in README

---

## Checklist Before Submitting PR

- [ ] All tests pass (`bundle exec rspec`)
- [ ] Code coverage ≥ 93% (`COVERAGE=true bundle exec rspec`)
- [ ] RuboCop passes (`bundle exec rubocop`)
- [ ] Feature works as expected
- [ ] Tests written for new feature
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] Documentation updated (README, CHANGELOG, inline docs)
- [ ] No breaking changes (or version bumped)
- [ ] Branch is up to date with main
- [ ] Commits are well-described

---

## Getting Help

- Review existing code in `lib/`
- Check test examples in `spec/`
- Read [CONTRIBUTING.md](CONTRIBUTING.md)
- Open an issue for discussion
- Check [TOON Format Spec](https://github.com/toon-format/spec)

---

## Example: Adding a Custom Delimiter Feature

Here's a complete example of adding a feature:

### 1. Write Test

```ruby
# spec/toon_format/encoder_spec.rb
RSpec.describe ToonFormat::Encoder do
  describe "custom delimiter" do
    it "uses pipe delimiter when specified" do
      data = { a: 1, b: 2 }
      result = ToonFormat.encode(data, delimiter: "|")
      expect(result).to include("|")
    end
  end
end
```

### 2. Implement (Already exists, but example)

```ruby
# lib/toon_format/encoder.rb
def encode_object(obj, depth)
  # Use @options[:delimiter] instead of hardcoded ","
end
```

### 3. Update Docs

```ruby
# lib/toon_format.rb
# @option options [String] :delimiter (',') Field delimiter
```

### 4. Run Tests

```bash
bundle exec rspec spec/toon_format/encoder_spec.rb
```

### 5. Commit

```bash
git commit -m "Add custom delimiter option

- Allow users to specify custom delimiter
- Default remains comma for compatibility"
```

---

## Summary

To add a new feature:

1. ✅ **Plan** - Understand what and where
2. ✅ **Test** - Write tests first (TDD)
3. ✅ **Code** - Implement feature
4. ✅ **Test** - Ensure all tests pass
5. ✅ **Style** - Run RuboCop
6. ✅ **Docs** - Update documentation
7. ✅ **Commit** - Well-described commits
8. ✅ **PR** - Create pull request

**Remember:** Quality over speed. Well-tested, documented features are easier to maintain and merge! 🚀
