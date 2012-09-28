require 'scrolls'

class Kanshi::ScrollsReporter

  def report(name, url, data)
    Scrolls.context(:name => name, :measure => true) do
      data.each do |k, v|
        Scrolls.log(:at => k, :last => v)
      end
    end
  end

end
