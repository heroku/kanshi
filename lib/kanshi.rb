class Kanshi; end

require 'kanshi/queries'

class Kanshi

  def self.run
    self.new.run
  end

  def initialize
  end

  def databases
    ENV.values.select { |v| v =~ %r{^postgres://} }
  end

  def run
  end

end
