Gem::Specification.new do |s|
  s.name        = "adamantite"
  s.version     = "0.0.4"
  s.summary     = "Yet another password manager."
  s.description = "A local password manager written in Ruby."
  s.authors     = ["Jake Bruemmer"]
  s.email       = "jakebruemmer@gmail.com"
  s.files       = Dir.glob('lib/**/*')
  s.executables << "adamantite"
  s.homepage    = "https://github.com/jakebruemmer/adamantite"
  s.license     = "MIT"
end