class Kanshi::Reporter
  attr_accessor :logger

  def initialize(logger)
    @logger = logger
    @last_value = {}
  end

  ABSOLUTE = [:size, :numbackends, :locks_waiting, :total_open_xact_time, :xact_waiting, :xact_idle]

  def report(name, url, data)
    data = calculate_hit_rate(record_and_diff(name, data))
    if data
      data.each do |k, v|
        logger.log(:app => name, :measure => true, :at => k, :last => v)
      end
    end
  end

private

  def record_and_diff(name, data)
    diff = nil
    if @last_value[name]
      diff = Hash.new
      data.keys.each do |key|
        next unless data[key]
        if ABSOLUTE.include?(key)
          diff[key] = data[key]
        else
          diff[key] = data[key] - @last_value[name][key]
        end
      end
    end
    @last_value[name] = data
    diff
  end

  def calculate_hit_rate(data)
    return nil unless data
    hit = data[:blks_hit] || 0
    read = data[:blks_read] || 0
    if hit + read > 0
      data[:blks_hit_ratio] = 100.0 * hit / (hit + read)
    end
    hit = data[:heap_blks_hit] || 0
    read = data[:heap_blks_read] || 0
    if hit > 0
      data[:heap_hit_ratio] = 100.0 * (hit - read) / hit
    end
    data
  end

end
