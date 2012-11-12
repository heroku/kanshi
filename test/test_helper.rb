require "minitest/spec"
require "minitest/autorun"
require "./lib/kanshi"

ENV["TEST_DATABASE_URL"] ||= "postgres://localhost/kanshi_test"

module Scrolls
  extend self

  def data
    @@data ||= []
  end

  def log(*a)
    data << a
  end
end
