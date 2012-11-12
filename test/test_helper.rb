require "minitest/spec"
require "minitest/autorun"
require "./lib/kanshi"

ENV["TEST_DATABASE_URL"] ||= "postgres://localhost/kanshi_test"

class MockReporter
  attr_accessor :data

  def initialize
    @data = []
  end

  def report(name, url, data)
    @data << data
  end
end
