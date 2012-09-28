Kanshi = Class.new

require 'kanshi/reporter'

class Kanshi

  def self.run(*args)
    self.new(*args).run
  end

  def initialize(options = {})
    @options = {
      :databases => [],
      :frequency => 300,
      :reporter => ScrollsReporter
    }
    @options.merge!(options)
  end

  def run
    loop do
      report
      sleep options[:frequency]
    end
  end

  def report
    @options[:databases].each do |name, database_url|
      reporter.report(
        name,
        Collector.new(database_url))
    end
  end

  def reporter
    @reporter ||= @options[:reporter].new
  end

end
