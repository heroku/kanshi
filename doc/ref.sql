-- Overview

SELECT
  d.datname,
  pg_size_pretty(pg_database_size(d.datname)) as size,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  blks_hit::float / ( blks_hit + blks_read ) * 100.0 as cache_hit_ratio,
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
  d.datname::text,
  100.0 * blks_hit / (blks_read + blks_hit)
FROM
  pg_stat_database d
RIGHT JOIN
  pg_database on d.datname = pg_database.datname
WHERE
 not datistemplate and d.datname != 'postgres';

SELECT
  SUM(seq_scan) / SUM(idx_scan),
  SUM(seq_tup_read) / SUM(idx_tup_fetch)
  FROM pg_stat_all_tables;

  --==  total database workload ==--

SELECT
 d.datname::text,
 case when
   (tup_returned + tup_inserted + tup_updated + tup_deleted) > 0
 then round(1000000.0 * tup_returned / (tup_returned + tup_inserted + tup_updated + tup_deleted)) / 10000
 else 0
 end::numeric(1000, 4) as select_pct,

 case when (tup_returned + tup_inserted + tup_updated + tup_deleted) > 0
 then
 round(1000000.0 * tup_inserted / (tup_returned + tup_inserted + tup_updated + tup_deleted)) / 10000
 else 0
 end::numeric(1000, 4) as insert_pct ,

 case when (tup_returned + tup_inserted + tup_updated + tup_deleted) > 0
 then
 round(1000000.0 * tup_updated / (tup_returned + tup_inserted + tup_updated + tup_deleted)) / 10000
 else 0
 end::numeric(1000, 4) as update_pct,

 case when (tup_returned + tup_inserted + tup_updated + tup_deleted) > 0
 then round(1000000.0 * tup_deleted / (tup_returned + tup_inserted + tup_updated + tup_deleted)) / 10000
 else 0
 end::numeric(1000, 4) as delete_pct
from
  pg_stat_database d
right join
  pg_database on d.datname=pg_database.datname
where
  not datistemplate and d.datname != 'postgres';

--==  table size with toast (top 50 for current database) ==--
-- This seems wrong, not MECE, because it adds index size to tables, but then shows indexes.

SELECT
  nspname as schemaname,
  c.relname::text,
  case
    when
      c.relkind='r'
    then
      'table'
    when
      c.relkind='i'
    then
      'index'
    else
      lower(c.relkind)
  end as "type",
  pg_size_pretty(pg_relation_size(c.oid)) as "size",
  pg_size_pretty
  (
   case when c.reltoastrelid > 0
   then
   pg_relation_size(c.reltoastrelid)
   else 0 end
   +
   case when t.reltoastidxid > 0
   then
   pg_relation_size(t.reltoastidxid)
   else 0 end
  ) as toast,
  pg_size_pretty(cast((
    SELECT
      coalesce(sum(pg_relation_size(i.indexrelid)), 0)
    FROM
      pg_index i
    WHERE
      i.indrelid = c.oid
  )
  as int8)) as associated_idx_size,
  pg_size_pretty(pg_total_relation_size(c.oid)) as "total"
FROM
 pg_class c
LEFT JOIN
 pg_namespace n ON (n.oid = c.relnamespace)
LEFT JOIN
  pg_class t on (c.reltoastrelid=t.oid)
WHERE
  nspname not in ('pg_catalog', 'information_schema') AND
  nspname !~ '^pg_toast' AND
  -- c.relkind in ('r','i')
  c.relkind in ('r')
ORDER BY
  pg_total_relation_size(c.oid) DESC
LIMIT
  100;

--== table & index hit %, hot tables (top 50) ==--
SELECT
 schemaname::text,
 relname::text,
 heap_blks_read,
 heap_blks_hit,

 case when (heap_blks_hit + heap_blks_read) > 0
 then
 round(100 * heap_blks_hit / (heap_blks_hit + heap_blks_read))
 else 0 end as hit_pct,

 idx_blks_read,
 idx_blks_hit,

 CASE WHEN (idx_blks_hit + idx_blks_read) > 0
 then
 round(100 * idx_blks_hit / (idx_blks_hit + idx_blks_read))
 else 0 end as idx_hit_pct
FROM
  pg_statio_user_tables
WHERE
  (heap_blks_hit + heap_blks_read + idx_blks_hit + idx_blks_read) > 0
ORDER BY
  (heap_blks_read + heap_blks_hit) DESC
limit
  100;

--== read activity by table (top 50) ==--

  /*
  	break down total read activity in the database on a per-table basis.
  	that's not completely fair because the size of the reads isn't considered,
  	but it does give a rough idea where activity is happening.
  */

SELECT
  schemaname::text,
  relname::text,
  seq_tup_read,
  idx_tup_fetch,
  seq_tup_read + idx_tup_fetch as total_reads,
  round(100 * idx_tup_fetch / (seq_tup_read + idx_tup_fetch)) as idx_read_pct,
  pg_size_pretty(pg_total_relation_size(relid)) as total_size
FROM
  pg_stat_user_tables
JOIN
  pg_stat_database ON datname = current_database()
WHERE
  (seq_tup_read + idx_tup_fetch > 0) AND
  tup_returned > 0
ORDER BY
  (seq_tup_read + idx_tup_fetch) desc -- A.K.A. "total_reads"
limit
  50;

  --== index usage counts - rank how much all indexes are used, looking for unused ones ==--
  			--== (ignore those that enforce uniqueness) ==--
SELECT
	schemaname::text,
	relname::text,
	indexrelname::text,
	idx_scan,
	pg_size_pretty(pg_relation_size(i.indexrelid)) as index_size

FROM
  pg_stat_user_indexes i
JOIN
  pg_index using (indexrelid)
WHERE
  indisunique is false
ORDER BY
  idx_scan, pg_relation_size(i.indexrelid) desc;
