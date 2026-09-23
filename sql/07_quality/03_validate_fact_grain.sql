-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.3 — VALIDATE FACT GRAIN
-- ============================================================

SELECT
    'fact_row_count' AS check_name,
    590540::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT - 590540::BIGINT AS difference,
    CASE WHEN COUNT(*) = 590540 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_distinct_transactionid',
    590540::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT - 590540::BIGINT,
    CASE WHEN COUNT(DISTINCT "TransactionID") = 590540 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_distinct_transaction_key',
    590540::BIGINT,
    COUNT(DISTINCT transaction_key)::BIGINT,
    COUNT(DISTINCT transaction_key)::BIGINT - 590540::BIGINT,
    CASE WHEN COUNT(DISTINCT transaction_key) = 590540 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transactionid_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    CASE WHEN COUNT(*) = COUNT(DISTINCT "TransactionID") THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transaction_key_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT transaction_key))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT transaction_key))::BIGINT,
    CASE WHEN COUNT(*) = COUNT(DISTINCT transaction_key) THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transactionid_nulls',
    0::BIGINT,
    COUNT(*) FILTER (WHERE "TransactionID" IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE "TransactionID" IS NULL)::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE "TransactionID" IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transaction_key_nulls',
    0::BIGINT,
    COUNT(*) FILTER (WHERE transaction_key IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE transaction_key IS NULL)::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE transaction_key IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean;
