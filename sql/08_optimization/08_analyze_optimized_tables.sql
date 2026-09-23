-- PHASE 8 - STEP 8.8 - REFRESH OPTIMIZED TABLE STATISTICS
-- ANALYZE refreshes planner metadata; it is not itself a performance claim.

ANALYZE analytics.fact_transaction_clean;
ANALYZE analytics.dim_identity_clean;

SELECT schemaname, relname AS table_name, n_live_tup, n_dead_tup, last_analyze, last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'analytics'
  AND relname IN ('fact_transaction_clean', 'dim_identity_clean')
ORDER BY relname;

SELECT tablename, attname AS column_name, n_distinct, null_frac, most_common_vals, most_common_freqs
FROM pg_stats
WHERE schemaname = 'analytics'
  AND tablename IN ('fact_transaction_clean', 'dim_identity_clean')
  AND attname IN ('identity_key', 'TransactionDT', 'TransactionAmt', 'isFraud')
ORDER BY tablename, attname;
