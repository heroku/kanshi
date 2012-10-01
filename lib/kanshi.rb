Kanshi = Class.new

require 'kanshi/collector'
require 'kanshi/scrolls_reporter'

class Kanshi

  def self.run(*args)
    self.new(*args).run
  end

  def initialize(options = {})
    @options = {
      :databases => [],
      :delay => 300,
      :reporter => ScrollsReporter
    }
    @options.merge!(options)
  end

  def run
    loop do
      report
      sleep(@options[:delay])
    end
  end

  def report
    @options[:databases].each do |name, database_url|
      reporter.report(
        name,
        database_url,
        Collector.collect(database_url))
    end
  end

  def reporter
    @reporter ||= @options[:reporter].new
  end

end
