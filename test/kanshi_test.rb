require "./test/test_helper"

describe Kanshi do
  before do
    databases = { "test" => ENV["TEST_DATABASE_URL"] }
    @reporter = MockReporter.new
    @kanshi = Kanshi.new(:reporter => @reporter, :databases => databases)
  end

  it "sucks" do
    @kanshi.report
    @reporter.data.first.keys.sort.must_equal [:blks_hit, :blks_read,
      :blks_total, :heap_blks_hit, :heap_blks_read, :idx_blks_hit,
      :idx_blks_read, :idx_scan, :idx_tup_fetch, :locks_waiting, :numbackends,
      :seq_scan, :seq_tup_read, :size, :total_open_xact_time, :tup_deleted,
      :tup_fetched, :tup_inserted, :tup_returned, :tup_updated, :xact_commit,
      :xact_idle, :xact_rollback, :xact_waiting]
  end
end
