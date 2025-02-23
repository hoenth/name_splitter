# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'name_splitter/version'

Gem::Specification.new do |spec|
  spec.name          = "name_splitter"
  spec.version       = NameSplitter::VERSION
  spec.authors       = ["Tom Hoen"]
  spec.email         = ["thoen@edgevaleinteractive.com"]

  spec.summary       = %q{Gem for splitting full names into the component parts}
  spec.description   = %q{Takes a full name and gives back an object with salutation, first name, middle name, last name and prefix}
  spec.homepage      = "https://github.com/hoenth/name_splitter"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
