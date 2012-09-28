require 'sequel'

class Kanshi::Collector

  def initialize(database_url)
    @url = database_url
  end

  def with_db(&block)
    db = Sequel.connect(@url)
    yield db
  ensure
    db.disconnect
  end

  def collect
    data = {}
    with_db do |db|
      Queries.each do |query|
        data.merge! db[query].first
      end
    end
    data
  end

end
