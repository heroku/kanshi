Kanshi = Class.new

require 'kanshi/collector'
require 'kanshi/reporter'

class Kanshi

  def self.run(*args)
    self.new(*args).run
  end

  def initialize(options = {})
    @options = {
      :databases => {},
      :delay => 60,
      :logger => default_logger
    }
    @options.merge!(options)
    unless logger = @options[:logger]
      raise ArgumentError, "Could not find Scrolls. Make sure it's available, or pass your own :logger"
    end
    @reporter = Reporter.new(logger)
  end

  def default_logger
    return unless defined?(Scrolls)
    Scrolls
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
