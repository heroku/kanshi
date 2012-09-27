Kanshi::Queries = <<EOF.split(/\s+;\s+/)
SELECT
  pg_database_size(d.datname) as size,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  tup_fetched,
  tup_returned,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM
  pg_stat_database d
RIGHT JOIN
  pg_database on d.datname = pg_database.datname
WHERE
  not datistemplate and d.datname != 'postgres';

SELECT
  SUM(seq_scan) AS seq_scan,
  SUM(seq_tup_read) AS seq_tup_read,
  SUM(idx_scan) AS idx_scan,
  SUM(idx_tup_fetch) AS idx_tup_fetch
FROM
  pg_stat_user_tables;

SELECT
  SUM(heap_blks_read) AS heap_blks_read,
  SUM(heap_blks_hit) AS heap_blks_hit,
  SUM(idx_blks_read) AS idx_blks_read,
  SUM(idx_blks_hit) AS idx_blks_hit
FROM
  pg_statio_user_tables;
EOF
