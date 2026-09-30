-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 01: PERFORMANCE BASELINE AUDIT
-- ============================================================================
-- Purpose:
--   Document the foundational PostgreSQL database environment, table sizes,
--   existing index footprint, table statistics, and runtime configuration.
-- ============================================================================

-- 1. Database Version & Environment
SELECT
    version() AS postgresql_version,
    CURRENT_DATABASE() AS database_name,
    CURRENT_USER AS current_user,
    CURRENT_TIMESTAMP AS audit_timestamp;

-- 2. Core Analytical Table Sizing & Populations
SELECT
    t.schemaname,
    t.tablename,
    c.reltuples::BIGINT AS estimated_rows,
    pg_size_pretty(pg_relation_size(format('%I.%I', t.schemaname, t.tablename)::regclass)) AS table_size,
    pg_size_pretty(pg_indexes_size(format('%I.%I', t.schemaname, t.tablename)::regclass)) AS index_size,
    pg_size_pretty(pg_total_relation_size(format('%I.%I', t.schemaname, t.tablename)::regclass)) AS total_size
FROM pg_tables t
JOIN pg_class c ON c.relname = t.tablename
JOIN pg_namespace n ON n.oid = c.relnamespace AND n.nspname = t.schemaname
WHERE t.schemaname IN ('analytics', 'monitoring')
ORDER BY pg_total_relation_size(format('%I.%I', t.schemaname, t.tablename)::regclass) DESC;

-- 3. Exact Row Counts for Core Tables
SELECT
    'analytics.fact_transaction_clean' AS table_name,
    COUNT(*) AS exact_row_count
FROM analytics.fact_transaction_clean
UNION ALL
SELECT
    'analytics.dim_identity_clean',
    COUNT(*)
FROM analytics.dim_identity_clean
UNION ALL
SELECT
    'monitoring.monitoring_results',
    COUNT(*)
FROM monitoring.monitoring_results;

-- 4. Existing Index Inventory
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(format('%I.%I', schemaname, indexname)::regclass)) AS index_size,
    indexdef
FROM pg_indexes
WHERE schemaname IN ('analytics', 'monitoring')
ORDER BY schemaname, tablename, indexname;

-- 5. Runtime Configuration & Resource Allocation
SELECT
    name AS parameter_name,
    setting AS current_value,
    unit,
    source,
    boot_val AS default_value
FROM pg_settings
WHERE name IN (
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'effective_cache_size',
    'random_page_cost',
    'seq_page_cost',
    'effective_io_concurrency',
    'max_parallel_workers_per_gather',
    'max_parallel_workers',
    'default_statistics_target'
)
ORDER BY name;

-- 6. Table I/O Statistics Snapshot
SELECT
    schemaname,
    relname AS table_name,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname IN ('analytics', 'monitoring')
ORDER BY schemaname, relname;
