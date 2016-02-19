# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dogaws/version'

Gem::Specification.new do |spec|
  spec.name          = "dogaws"
  spec.version       = Dogaws::VERSION

  spec.authors       = ["Takumi Sakamoto"]
  spec.email         = ["takumi.saka@gmail.com"]
  spec.description   = %q{Yet another Datadog CloudWatch Integragion}
  spec.summary       = %q{Yet another Datadog CloudWatch Integragion}
  spec.homepage      = "https://github.com/takus/dogaws"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "dogapi"
  spec.add_dependency "parallel"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
