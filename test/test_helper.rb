require "minitest/spec"
require "minitest/autorun"
require "./lib/kanshi"

ENV["TEST_DATABASE_URL"] ||= "postgres://localhost/kanshi_test"

class MockLogger
  attr_accessor :data

  def initialize
    @data = []
  end

  def log(*a)
    data << a
  end
end
