-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.4 — VALIDATE IDENTITY GRAIN
-- ============================================================

SELECT
    'identity_row_count' AS check_name,
    144233::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT - 144233::BIGINT AS difference,
    CASE WHEN COUNT(*) = 144233 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_distinct_transactionid',
    144233::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT - 144233::BIGINT,
    CASE WHEN COUNT(DISTINCT "TransactionID") = 144233 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_distinct_identity_key',
    144233::BIGINT,
    COUNT(DISTINCT identity_key)::BIGINT,
    COUNT(DISTINCT identity_key)::BIGINT - 144233::BIGINT,
    CASE WHEN COUNT(DISTINCT identity_key) = 144233 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_transactionid_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    CASE WHEN COUNT(*) = COUNT(DISTINCT "TransactionID") THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_key_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT identity_key))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT identity_key))::BIGINT,
    CASE WHEN COUNT(*) = COUNT(DISTINCT identity_key) THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_transactionid_nulls',
    0::BIGINT,
    COUNT(*) FILTER (WHERE "TransactionID" IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE "TransactionID" IS NULL)::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE "TransactionID" IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_key_nulls',
    0::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE identity_key IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean;
