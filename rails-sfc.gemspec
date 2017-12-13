$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails/sfc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-sfc"
  s.version     = Rails::Sfc::VERSION
  s.authors     = ["Daniel Fox"]
  s.email       = ["romaimperator@gmail.com"]
  s.homepage    = "http://localhost"
  s.summary     = "Provides single file components ala VueJS."
  s.description = "Provides single file components ala VueJS."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end