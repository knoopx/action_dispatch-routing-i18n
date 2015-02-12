# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_dispatch/routing/i18n/version'

Gem::Specification.new do |spec|
  spec.name          = "action_dispatch-routing-i18n"
  spec.version       = ActionDispatch::Routing::I18n::VERSION
  spec.authors       = ["Victor Martinez"]
  spec.email         = ["knoopx@gmail.com"]
  spec.summary       = %q{Minimalist I18n for Rails routes}
  spec.homepage      = "https://github.com/knoopx/action_dispatch-routing-i18n/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "railties", "~> 4.2"
end
