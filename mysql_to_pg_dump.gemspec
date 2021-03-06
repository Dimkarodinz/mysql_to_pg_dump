$:.push File.expand_path("../lib", __FILE__)

require "mysql_to_pg_dump/version"

Gem::Specification.new do |s|
  s.name        = "mysql_to_pg_dump"
  s.version     = MysqlToPgDump::VERSION
  s.authors     = ["Dimkarodinz"]
  s.email       = ["dimkarodin@gmail.com"]
  s.homepage    = "https://github.com/Dimkarodinz/mysql_to_pg_dump.git"
  s.summary     = "Almost mysql to postgres dump"
  s.description = "Loads mysql db data from the remote server to local postgres db"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2.5"

  s.add_dependency 'colorize', "~> 0.8.1"
  s.add_dependency 'rake-progressbar', "~> 0.0.5"
end
