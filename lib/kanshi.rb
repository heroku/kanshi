Kanshi = Class.new

require 'kanshi/collector'
require 'kanshi/reporter'
require 'scrolls'

class Kanshi

  def self.run(*args)
    self.new(*args).run
  end

  def initialize(options = {})
    @options = {
      :databases => {},
      :delay => 60,
      :logger => Scrolls
    }
    @options.merge!(options)
    @reporter = Reporter.new(@options[:logger])
  end

  def run
    loop do
      report
      sleep(@options[:delay])
    end
  end

  def report
    @options[:databases].each do |name, database_url|
      @reporter.report(
        name,
        database_url,
        Collector.collect(database_url))
    end
  end

end
