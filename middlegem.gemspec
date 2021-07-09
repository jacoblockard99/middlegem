# frozen_string_literal: true

require_relative 'lib/middlegem/version'

Gem::Specification.new do |spec|
  spec.name          = 'middlegem'
  spec.version       = Middlegem::VERSION
  spec.authors       = ['Jacob']
  spec.email         = ['jacoblockard99@gmail.com']

  spec.summary       = 'Simple one-way middleware.'
  spec.description   = <<~DESC
    Middlegem is a ruby gem that provides simple middleware chains with goals of simplicity and
    reliability.
  DESC
  spec.homepage      = 'https://github.com/jacoblockard99/middlegem'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jacoblockard99/middlegem'
  spec.metadata['changelog_uri'] = 'https://github.com/jacoblockard99/middlegem/CHANGELOG.md'
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.18'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4'
  spec.add_development_dependency 'simplecov', '0.17'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
