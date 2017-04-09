# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dux/version'

Gem::Specification.new do |spec|
  spec.name          = "dux"
  spec.version       = Dux::VERSION
  spec.authors       = ["Alexa Grey"]
  spec.email         = ["devel@mouse.vc"]

  spec.summary       = %q{Swiss-army knife gem for duck-type matching and utility methods}
  spec.homepage      = "https://github.com/scryptmouse/dux"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata["yard.run"] = "yri"

  spec.add_dependency "yard_types"

  spec.add_development_dependency "bundler",    "~> 1.9"
  spec.add_development_dependency "rspec",      "~> 3.5"
  spec.add_development_dependency "rake",       "~> 12.0"
  spec.add_development_dependency "pry",        "~> 0.10.1"
  spec.add_development_dependency "simplecov",  "~> 0.14.1"
  spec.add_development_dependency "yard",       "~> 0.9.8"
end
