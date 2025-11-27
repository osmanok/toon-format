# frozen_string_literal: true

require_relative "lib/toon_format/version"

Gem::Specification.new do |spec|
  spec.name = "toon-format"
  spec.version = ToonFormat::VERSION
  spec.authors = ["Osman Okuyan"]
  spec.email = ["ookuyan@protel.com.tr"]

  spec.summary = "TOON format serialization for Ruby"
  spec.description = "Compact serialization format optimized for LLM contexts " \
                     "with 30-60% token reduction compared to JSON"
  spec.homepage = "https://github.com/osmanok/toon-format"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/osmanokuyan/toon-format"
  spec.metadata["changelog_uri"] = "https://github.com/osmanokuyan/toon-format/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
