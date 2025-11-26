# Contributing to TOON Format

Thank you for your interest in contributing to TOON Format! 🎉

## Getting Started

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/toon-format.git
   cd toon-format
   ```
3. **Set up** the development environment:
   ```bash
   bin/setup
   ```

## Development Workflow

### Running Tests
```bash
# Run full test suite
bundle exec rspec

# Run specific test file
bundle exec rspec spec/toon_format/encoder_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Code Style
```bash
# Auto-fix style issues
bundle exec rubocop -a

# Check for issues
bundle exec rubocop
```

### Benchmarks
```bash
# Run all benchmarks
ruby benchmark/run_all_benchmarks.rb

# Run specific benchmark
ruby benchmark/scalability_benchmark.rb
```

## Making Changes

1. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

2. **Make your changes** and write tests

3. **Run tests and linting**:
   ```bash
   bundle exec rspec
   bundle exec rubocop -a
   ```

4. **Commit your changes**:
   ```bash
   git commit -m "Add feature: brief description"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/my-awesome-feature
   ```

6. **Create a Pull Request** on GitHub

## Code Guidelines

- **Ruby 3.0+** required
- Follow the existing code style (enforced by RuboCop)
- Add tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

## Testing Requirements

- All tests must pass
- New features need test coverage
- Aim for 95%+ coverage on new code
- Test on multiple Ruby versions (3.0-3.4)

## Documentation

When adding features:
- Update README.md if needed
- Add CHANGELOG.md entry
- Include inline documentation (YARD format)
- Update benchmarks if performance-related

## Reporting Bugs

Found a bug? Please open an issue with:
- Ruby version
- Gem version
- Steps to reproduce
- Expected vs actual behavior
- Sample code if possible

## Feature Requests

Have an idea? Open an issue describing:
- The problem it solves
- Proposed solution
- Alternatives considered
- Willing to implement?

## Questions?

- Check the [architecture guide](CLAUDE.md)
- Review existing code in `lib/`
- Look at test examples in `spec/`
- Open an issue for discussion

## Code Review Process

1. Maintainer reviews PR
2. Feedback provided (if needed)
3. Tests must pass on CI
4. Code style must pass
5. Merge when approved

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for making TOON Format better! 💎
