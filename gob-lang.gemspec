# frozen_string_literal: true
# rubocop:disable all

require_relative "lib/gob/version"

if defined?(GemKit::Release)
  GemKit::Release.configure do |config|
    config.version_file = "lib/gob/version.rb"
    config.require_path = "gob"
  end
end

Gem::Specification.new do |spec|
  spec.name    = "gob-lang"
  spec.version = Gob::VERSION
  spec.authors = ["Nathan Kidd"]
  spec.email   = ["nathankidd@hey.com"]
  spec.license = "Apache-2.0"
  spec.summary     = "Gobble gobble, little turkey."
  spec.description = "Don't even worry about it... it's not for you."
  spec.homepage    = "https://github.com/n-at-han-k/gob"
  spec.required_ruby_version = ">= 3.3"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "#{spec.homepage}#readme"

  spec.platform = Gem::Platform.new(ENV["GOB_NATIVE_PLATFORM"]) if ENV["GOB_NATIVE_PLATFORM"]

  spec.files = Dir.glob(
    ["{lib,exe}/**/*", "{ext}/**/*", "LICENSE", "README.md", "gob-lang.gemspec"],
    File::FNM_DOTMATCH,
    base: __dir__
  )

  unless ENV["GOB_NATIVE_PLATFORM"]
    spec.files.reject! do |path|
      File.fnmatch?("*.{so,bundle,dll,dylib,o,a}", path, File::FNM_EXTGLOB)
    end
  end

  spec.bindir        = "exe"
  spec.executables   = Dir["exe/*"].map { |path| File.basename(path) }.sort
  spec.require_paths = ["lib"]
  spec.add_dependency "syntax_tree", "~> 6.3"
  spec.add_dependency "ffi", "~> 1.17"
  spec.add_dependency "thor", "~> 1.5"
  spec.add_dependency "gem_kit", "~> 0.2"
  spec.add_dependency "rubocop", "~> 1.92"
  spec.add_development_dependency "ast-crispr", "~> 7.1"
  spec.add_development_dependency "ast-crispr-ruby-prism", "~> 7.1"
  spec.add_development_dependency "unparser", "~> 0.9"
  spec.add_development_dependency "minitest", "~> 6.1"
  spec.add_development_dependency "minitest-reporters", "~> 1.8"
  spec.add_development_dependency "diff-lcs", "~> 2.0"
  spec.add_development_dependency "rubocop-nathank", "~> 2.1"
  spec.add_development_dependency "rubocop-disable_syntax", "~> 0.2"
  spec.add_development_dependency "gem_kit-release", "~> 0.4"
end
