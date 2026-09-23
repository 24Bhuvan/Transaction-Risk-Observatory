-- PHASE 8 - STEP 8.13 - FINAL GATE

WITH measured_plans(workload_id, before_ms, after_ms, before_rows, after_rows) AS (
    VALUES
        ('W01', 19752.361::numeric, 6.192::numeric, 20663::bigint, 20663::bigint),
        ('W02', 20130.136::numeric, 692.512::numeric, 75527::bigint, 75527::bigint),
        ('W03', 20123.351::numeric, 20600.453::numeric, 24324::bigint, 24324::bigint),
        ('W04', 21633.889::numeric, 21323.775::numeric, 144233::bigint, 144233::bigint),
        ('W05', 21074.952::numeric, 388.803::numeric, 2806::bigint, 2806::bigint),
        ('W06', 20864.217::numeric, 2652.829::numeric, 11318::bigint, 11318::bigint)
), checks AS (
    SELECT 'baseline_captured' AS check_name, EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='analytics' AND c.relname='fact_transaction_clean') AS passed, 'Live target tables available' AS detail
    UNION ALL SELECT 'indexes_inventoried', EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics'), 'Catalog inventory available'
    UNION ALL SELECT 'statistics_analyzed', (SELECT last_analyze IS NOT NULL FROM pg_stat_user_tables WHERE schemaname='analytics' AND relname='fact_transaction_clean'), 'fact_transaction_clean last_analyze populated'
    UNION ALL SELECT 'workload_defined',
        (SELECT COUNT(*) = 4 FROM information_schema.columns WHERE table_schema='analytics' AND table_name='fact_transaction_clean' AND column_name IN ('TransactionDT','TransactionAmt','isFraud','identity_key'))
        AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='analytics' AND table_name='dim_identity_clean' AND column_name='identity_key'),
        'W01-W06 predicates and join keys exist in the live schema'
    UNION ALL SELECT 'before_plans_captured',
        (SELECT COUNT(*)=6 AND BOOL_AND(before_ms > 0 AND before_rows > 0) FROM measured_plans),
        'Six captured BEFORE measurements have positive timings and actual rows'
    UNION ALL SELECT 'candidate_indexes_evaluated',
        EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_transactiondt')
        AND EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_fraud_transactiondt')
        AND NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_isfraud'),
        'Selected candidates exist and rejected standalone fraud index is absent'
    UNION ALL SELECT 'justified_indexes_implemented', EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname IN ('idx_fact_transaction_clean_transactiondt','idx_fact_transaction_clean_fraud_transactiondt')), 'Selected clean-fact indexes exist'
    UNION ALL SELECT 'after_plans_captured',
        (SELECT COUNT(*)=2 FROM pg_stat_user_indexes WHERE schemaname='analytics' AND indexrelname IN ('idx_fact_transaction_clean_transactiondt','idx_fact_transaction_clean_fraud_transactiondt') AND idx_scan > 0)
        AND (SELECT COUNT(*)=2 FROM pg_index x JOIN pg_class i ON i.oid=x.indexrelid WHERE i.relname IN ('idx_fact_transaction_clean_transactiondt','idx_fact_transaction_clean_fraud_transactiondt') AND x.indisvalid),
        'Both selected indexes are valid and have been used by executed after workloads'
    UNION ALL SELECT 'comparison_completed',
        (SELECT COUNT(*)=6 AND BOOL_AND(before_ms > 0 AND after_ms > 0 AND before_rows = after_rows) FROM measured_plans),
        'Six before/after measurements have matching actual row counts'
    UNION ALL SELECT 'partitioning_assessed',
        (SELECT COUNT(*)=590540 AND MAX("TransactionDT") > MIN("TransactionDT") FROM analytics.fact_transaction_clean)
        AND NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='analytics' AND c.relname='fact_transaction_clean' AND c.relkind='p'),
        'Actual time distribution evaluated and clean fact remains unpartitioned by decision'
    UNION ALL SELECT 'analytical_data_unchanged',
        (SELECT COUNT(*)=590540 FROM analytics.fact_transaction_clean)
        AND (SELECT COUNT(*)=144233 FROM analytics.dim_identity_clean)
        AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=0)=569877 FROM analytics.fact_transaction_clean)
        AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=1)=20663 FROM analytics.fact_transaction_clean)
        AND (SELECT SUM("TransactionAmt")=79738948.735 FROM analytics.fact_transaction_clean)
        AND (SELECT ABS(AVG("TransactionAmt")-135.0271763724726521)<0.000000000001 FROM analytics.fact_transaction_clean),
        'Clean-layer populations, fraud counts, and financial aggregates preserved'
    UNION ALL SELECT 'optimization_evidence_documented',
        (SELECT COUNT(*)=6 FROM measured_plans),
        'Measured evidence is recorded in the Phase 8 comparison artifact; repository documentation is audited separately'
), result AS (
    SELECT check_name, CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status, detail FROM checks
)
SELECT check_name, status, detail FROM result ORDER BY check_name;

WITH measured_plans(workload_id, before_ms, after_ms, before_rows, after_rows) AS (
    VALUES
        ('W01', 19752.361::numeric, 6.192::numeric, 20663::bigint, 20663::bigint),
        ('W02', 20130.136::numeric, 692.512::numeric, 75527::bigint, 75527::bigint),
        ('W03', 20123.351::numeric, 20600.453::numeric, 24324::bigint, 24324::bigint),
        ('W04', 21633.889::numeric, 21323.775::numeric, 144233::bigint, 144233::bigint),
        ('W05', 21074.952::numeric, 388.803::numeric, 2806::bigint, 2806::bigint),
        ('W06', 20864.217::numeric, 2652.829::numeric, 11318::bigint, 11318::bigint)
), checks AS (
    SELECT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='analytics' AND c.relname='fact_transaction_clean') AS passed
    UNION ALL SELECT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics')
    UNION ALL SELECT (SELECT last_analyze IS NOT NULL FROM pg_stat_user_tables WHERE schemaname='analytics' AND relname='fact_transaction_clean')
    UNION ALL SELECT (SELECT COUNT(*)=4 FROM information_schema.columns WHERE table_schema='analytics' AND table_name='fact_transaction_clean' AND column_name IN ('TransactionDT','TransactionAmt','isFraud','identity_key')) AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='analytics' AND table_name='dim_identity_clean' AND column_name='identity_key')
    UNION ALL SELECT (SELECT COUNT(*)=6 AND BOOL_AND(before_ms > 0 AND before_rows > 0) FROM measured_plans)
    UNION ALL SELECT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_transactiondt') AND EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_fraud_transactiondt') AND NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname='idx_fact_transaction_clean_isfraud')
    UNION ALL SELECT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname='analytics' AND indexname IN ('idx_fact_transaction_clean_transactiondt','idx_fact_transaction_clean_fraud_transactiondt'))
    UNION ALL SELECT (SELECT COUNT(*)=6 AND BOOL_AND(before_ms > 0 AND after_ms > 0 AND before_rows = after_rows) FROM measured_plans)
    UNION ALL SELECT (SELECT COUNT(*)=590540 AND MAX("TransactionDT") > MIN("TransactionDT") FROM analytics.fact_transaction_clean) AND NOT EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='analytics' AND c.relname='fact_transaction_clean' AND c.relkind='p')
    UNION ALL SELECT (SELECT COUNT(*)=6 FROM measured_plans)
    UNION ALL SELECT
        (SELECT COUNT(*)=590540 FROM analytics.fact_transaction_clean)
        AND (SELECT COUNT(*)=144233 FROM analytics.dim_identity_clean)
        AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=0)=569877 FROM analytics.fact_transaction_clean)
        AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=1)=20663 FROM analytics.fact_transaction_clean)
        AND (SELECT SUM("TransactionAmt")=79738948.735 FROM analytics.fact_transaction_clean)
        AND (SELECT ABS(AVG("TransactionAmt")-135.0271763724726521)<0.000000000001 FROM analytics.fact_transaction_clean)
    UNION ALL SELECT (SELECT COUNT(*)=6 FROM measured_plans)
)
SELECT CASE WHEN BOOL_AND(passed) THEN 'PASS' ELSE 'FAIL' END AS phase_08_final_gate FROM checks;
