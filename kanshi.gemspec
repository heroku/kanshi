Gem::Specification.new do |s|
  s.name        = 'kanshi'
  s.version     = '0.0.2'
  s.date        = '2012-10-01'
  s.summary     = "Monitors a Postgres database"
  s.description = "Prints Postgres database metrics to your log stream"
  s.authors     = ["Jonathan Dance"]
  s.email       = 'jd@heroku.com'
  s.license     = 'MIT'
  s.files       = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(License|README|bin/|data/|ext/|lib/|spec/|test/)} }
  s.homepage    = 'https://github.com/heroku/kanshi'
  s.executables = 'kanshi'

  s.add_dependency 'sequel', "~> 3.0"
  s.add_dependency 'scrolls', "~> 0.2"
  s.add_dependency 'pg'
end
