Kanshi::Queries = <<EOF.split(/\s*;\s*/)
SELECT
  pg_database_size(d.datname) AS size,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  blks_read + blks_hit AS blks_total,
  tup_fetched,
  tup_returned,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM
  pg_stat_database d
WHERE
  d.datname = ?;

SELECT
  SUM(seq_scan)::bigint AS seq_scan,
  SUM(seq_tup_read)::bigint AS seq_tup_read,
  SUM(idx_scan)::bigint AS idx_scan,
  SUM(idx_tup_fetch)::bigint AS idx_tup_fetch
FROM
  pg_stat_user_tables;

SELECT
  SUM(heap_blks_read)::bigint AS heap_blks_read,
  SUM(heap_blks_hit)::bigint AS heap_blks_hit,
  SUM(idx_blks_read)::bigint AS idx_blks_read,
  SUM(idx_blks_hit)::bigint AS idx_blks_hit
FROM
  pg_statio_user_tables;
EOF
