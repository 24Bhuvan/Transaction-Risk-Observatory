-- PHASE 8 - STEP 8.1 - OPTIMIZATION BASELINE
-- Read-only physical and population baseline.

SELECT version() AS postgresql_version, current_database() AS database_name, current_schema() AS current_schema;

WITH target_tables AS (
    SELECT 'analytics'::text AS schema_name, 'fact_transaction'::text AS table_name
    UNION ALL SELECT 'analytics', 'dim_identity'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean'
    UNION ALL SELECT 'analytics', 'dim_identity_clean'
    UNION ALL SELECT 'staging', 'raw_transactions'
    UNION ALL SELECT 'staging', 'raw_identity'
)
SELECT
    t.schema_name,
    t.table_name,
    CASE WHEN c.relkind = 'r' THEN c.reltuples::bigint END AS estimated_rows,
    CASE WHEN c.relkind = 'r' THEN pg_size_pretty(pg_table_size(c.oid)) END AS table_size,
    CASE WHEN c.relkind = 'r' THEN pg_size_pretty(pg_indexes_size(c.oid)) END AS index_size,
    COALESCE(s.n_live_tup, 0)::bigint AS n_live_tup,
    COALESCE(s.n_dead_tup, 0)::bigint AS n_dead_tup,
    s.last_analyze,
    s.last_autoanalyze,
    (SELECT COUNT(*) FROM pg_index i WHERE i.indrelid = c.oid) AS index_count
FROM target_tables t
JOIN pg_namespace n ON n.nspname = t.schema_name
JOIN pg_class c ON c.relnamespace = n.oid AND c.relname = t.table_name
LEFT JOIN pg_stat_user_tables s ON s.relid = c.oid
ORDER BY t.schema_name, t.table_name;

SELECT 'analytics.fact_transaction_clean' AS table_name, COUNT(*)::bigint AS actual_row_count FROM analytics.fact_transaction_clean
UNION ALL SELECT 'analytics.dim_identity_clean', COUNT(*)::bigint FROM analytics.dim_identity_clean
UNION ALL SELECT 'analytics.fact_transaction', COUNT(*)::bigint FROM analytics.fact_transaction
UNION ALL SELECT 'analytics.dim_identity', COUNT(*)::bigint FROM analytics.dim_identity
UNION ALL SELECT 'staging.raw_transactions', COUNT(*)::bigint FROM staging.raw_transactions
UNION ALL SELECT 'staging.raw_identity', COUNT(*)::bigint FROM staging.raw_identity;

SELECT
    COUNT(*) FILTER (WHERE "isFraud" = 0)::bigint AS fraud_zero_count,
    COUNT(*) FILTER (WHERE "isFraud" = 1)::bigint AS fraud_one_count,
    SUM("TransactionAmt")::numeric AS transaction_amount_sum,
    AVG("TransactionAmt")::numeric AS transaction_amount_avg,
    COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::bigint AS linked_count,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::bigint AS unlinked_count
FROM analytics.fact_transaction_clean;
