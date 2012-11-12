require "./test/test_helper"

describe Kanshi do
  before do
    databases = { "test" => ENV["TEST_DATABASE_URL"] }
    @kanshi = Kanshi.new(:databases => databases)
    @kanshi.report # initialize data
  end

  it "logs db stats" do
    @kanshi.report
    Scrolls.data.map { |data| data.first[:at] }.sort.must_equal [:blks_hit, :blks_read,
      :blks_total, :locks_waiting, :numbackends, :size, :total_open_xact_time,
      :tup_deleted, :tup_fetched, :tup_inserted, :tup_returned, :tup_updated,
      :xact_commit, :xact_idle, :xact_rollback, :xact_waiting]
  end
end
