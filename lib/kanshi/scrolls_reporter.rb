class Kanshi::ScrollsReporter

  def report(name, data)
    Scrolls.context(name: name) do
      Scrolls.log(data)
    end
  end

end
