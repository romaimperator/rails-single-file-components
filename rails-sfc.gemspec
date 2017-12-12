$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails/sfc/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-sfc"
  s.version     = Rails::Sfc::VERSION
  s.authors     = ["Daniel Fox"]
  s.email       = ["romaimperator@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Rails::Sfc."
  s.description = "TODO: Description of Rails::Sfc."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end
