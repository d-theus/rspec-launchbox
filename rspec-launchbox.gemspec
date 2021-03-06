# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/launchbox/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-launchbox"
  spec.version       = Rspec::Launchbox::VERSION
  spec.authors       = ["d-theus"]
  spec.email         = ["slma0x02@gmail.com"]
  spec.summary       = %q{RSpec DSL extension for effortless process control}
  spec.description   = %q{Launchbox makes it easy to start or stop external service, manage timeouts.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'rspec'
  spec.add_dependency 'rspec-its'
end
