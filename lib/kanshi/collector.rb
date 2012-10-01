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
    yield db
  ensure
    db.disconnect if db
  end

  def collect
    data = {}
    with_db do |db|
      ::Kanshi::Queries.each do |query|
        data.merge! db[query, @db_name].first
      end
    end
    data
  end

end
