# frozen_string_literal: true

require File.expand_path('lib/ip_contact_finder/version', __dir__)

Gem::Specification.new do |s|
  s.name          = 'ip_contact_finder'
  s.description   = 'A Ruby library to resolve IP addresses and AS numbers to responsible email addressses'
  s.summary       = s.description
  s.homepage      = 'https://github.com/krystal/ip_contact_finder'
  s.licenses      = ['MIT']
  s.version       = IPContactFinder::VERSION
  s.files         = Dir.glob('{lib,db}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['adam@krystal.uk']

  s.add_dependency 'json'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rubocop', '1.17.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'simplecov-console'
  s.add_development_dependency 'solargraph'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
end
