require 'scrolls'

class Kanshi::ScrollsReporter

  def report(name, url, data)
    Scrolls.context(:name => name) do
      Scrolls.log(data)
    end
  end

end
