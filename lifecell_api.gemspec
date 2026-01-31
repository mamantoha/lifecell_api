# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lifecell_api/version'

Gem::Specification.new do |gem|
  gem.name = 'lifecell_api'
  gem.version = Lifecell::API::VERSION
  gem.authors = ['Anton Maminov']
  gem.email = ['anton.maminov@gmail.com']
  gem.description = 'A Ruby interface to the lifecell API'
  gem.summary = <<-SUMMARY
    The Lifecell::API library is used for interactions
    with api.lifecell.com.ua
  SUMMARY
  gem.homepage = 'https://github.com/mamantoha/lifecell_api'
  gem.license = 'MIT'

  gem.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 3.3'
  gem.add_dependency('xml-simple', '~> 1.1.2')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
