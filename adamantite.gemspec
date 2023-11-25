# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.1.0'
  s.name        = 'adamantite'
  s.version     = '0.0.8'
  s.summary     = 'Yet another password manager.'
  s.description = 'A local password manager written in Ruby.'
  s.authors     = ['Jake Bruemmer']
  s.email       = 'jakebruemmer@gmail.com'
  s.files       = Dir.glob('lib/**/*')
  s.executables << 'adamantite'
  s.homepage    = 'https://jakebruemmer.github.io/adamantite-info/'
  s.license     = 'MIT'
end
