# frozen_string_literal: true

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.1.0'
  s.name        = 'adamantite'
  s.version     = '0.0.13'
  s.summary     = 'Yet another password manager.'
  s.description = 'A local password manager written in Ruby.'
  s.authors     = ['Jake Bruemmer']
  s.email       = 'jakebruemmer@gmail.com'
  s.files       = Dir.glob('lib/**/*')
  s.executables << 'adamantite'
  s.homepage    = 'https://jakebruemmer.github.io/adamantite/'
  s.license     = 'MIT'
  s.add_runtime_dependency 'glimmer-dsl-libui', '0.11.5'
  s.add_runtime_dependency 'httparty', '0.21.0'
  s.add_runtime_dependency 'rbnacl', '~> 7.1'
  s.post_install_message = <<-TEXT
    Thank you for installing Adamantite. Please visit the project's
    homepage https://jakebruemmer.github.io/adamantite/ if you
    run into any issues when installing or running the gem.

    You can run the gem by running 'adamantite' in your terminal.
  TEXT
end
