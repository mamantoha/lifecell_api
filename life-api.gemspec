# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'life-api/version'

Gem::Specification.new do |gem|
  gem.name          = "life-api"
  gem.version       = Life::API::VERSION
  gem.authors       = ["Anton Maminov"]
  gem.email         = ["anton.linux@gmail.com"]
  gem.description   = %q{A Ruby interface to the life:) API}
  gem.summary       = %q{The Life::API library is used for interactions with a api.life.com.ua website}
  gem.homepage      = "https://github.com/mamantoha/life-api"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('xml-simple', '~> 1.1.2')
  gem.add_development_dependency('byebug')
end
