# frozen_string_literal: true

require_relative "lib/envy/version"

Gem::Specification.new do |spec|
  spec.name = "envy"
  spec.version = Envy::VERSION
  spec.authors = ["akadusei"]
  spec.email = ["attakusiadusei@gmail.com"]

  spec.summary = "Load environment variables from YAML"
  spec.homepage = "https://github.com/GrottoPress/envy.rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://github.com/GrottoPress/envy.rb"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md"]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
