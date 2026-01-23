require 'sequel'
require 'kanshi/queries'

class Kanshi::Collector

  def self.collect(*args)
    new(*args).collect
  end

  def initialize(database_url)
    @url = database_url
    @db_name = URI.parse(@url).path[1..-1]
  end

  def with_db(&block)
    db = Sequel.connect(@url)
    yield db, version(db)
  ensure
    db.disconnect if db
  end

  def version(db)
    raw = db["SELECT version()"].first[:version]
    return unless version = raw.match(/\APostgreSQL (\d+\.\d+)/)
    version[1].to_s
  end

  def collect
    data = {}
    with_db do |db, version|
      queries(version).each do |query|
        data.merge! db[query, @db_name].first
      end
    end
    data
  end

  def queries(version)
    Kanshi::Queries[version] || Kanshi::Queries[:default]
  end

end
