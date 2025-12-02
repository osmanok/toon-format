# Quick Start Checklist for Adding Features

## 🚀 Quick Setup (First Time)

```bash
# 1. Clone your fork
git clone https://github.com/YOUR_USERNAME/toon-format.git
cd toon-format

# 2. Setup environment
bin/setup

# 3. Verify everything works
bundle exec rspec
```

## ✨ Adding a Feature (Every Time)

### Before You Start
- [ ] Understand the TOON format spec
- [ ] Review existing similar code
- [ ] Plan your feature location (Encoder/Decoder/Parser/Validator)

### Development
- [ ] Create feature branch: `git checkout -b feature/your-feature`
- [ ] Write tests first (TDD approach)
- [ ] Implement the feature
- [ ] Run tests: `bundle exec rspec`
- [ ] Check coverage: `COVERAGE=true bundle exec rspec` (need ≥93%)
- [ ] Fix style: `bundle exec rubocop -a`

### Documentation
- [ ] Add YARD docs to public methods
- [ ] Update README.md if public API changes
- [ ] Add CHANGELOG.md entry
- [ ] Update inline comments if needed

### Before PR
- [ ] All tests pass: `bundle exec rspec`
- [ ] RuboCop passes: `bundle exec rubocop`
- [ ] Coverage ≥93%
- [ ] No breaking changes (or version bumped)
- [ ] Branch synced with main: `git pull origin main`

### Commit & Push
```bash
git add .
git commit -m "Add feature: description"
git push origin feature/your-feature
```

## 📁 File Locations Quick Reference

| What | Where |
|------|-------|
| Main API | `lib/toon_format.rb` |
| Encoding | `lib/toon_format/encoder.rb` |
| Decoding | `lib/toon_format/decoder.rb` |
| Parsing | `lib/toon_format/parser.rb` |
| Validation | `lib/toon_format/validator.rb` |
| Errors | `lib/toon_format/errors.rb` |
| Rails | `lib/toon_format/rails/extensions.rb` |
| CLI | `exe/toon-format` |
| Tests | `spec/toon_format/*_spec.rb` |
| Version | `lib/toon_format/version.rb` |

## 🧪 Common Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/toon_format/encoder_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Auto-fix code style
bundle exec rubocop -a

# Check code style
bundle exec rubocop

# Run benchmarks
ruby benchmark/run_all_benchmarks.rb
```

## 📝 Code Template

```ruby
# frozen_string_literal: true

module ToonFormat
  # Brief class description
  class YourFeature
    # Public method with YARD docs
    #
    # @param data [Object] Description
    # @return [Type] Description
    def self.process(data)
      new.process(data)
    end

    private

    def process(data)
      # Implementation
    end
  end
end
```

## 🎯 Test Template

```ruby
RSpec.describe ToonFormat::YourFeature do
  describe ".method_name" do
    context "with valid input" do
      it "returns expected result" do
        expect(ToonFormat.your_method(data)).to eq(expected)
      end
    end

    context "with invalid input" do
      it "raises appropriate error" do
        expect { ToonFormat.your_method(invalid) }.to raise_error(ErrorClass)
      end
    end
  end
end
```

---

**Need more details?** See [FEATURE_DEVELOPMENT_GUIDE.md](FEATURE_DEVELOPMENT_GUIDE.md)
