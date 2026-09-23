-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.1 — QUALITY BASELINE
-- ============================================================
-- Purpose:
--   Validate the established clean-layer baseline without modifying
--   data. This script provides a read-only QA baseline for the
--   expected Phase 6 invariants.
-- ============================================================

SELECT
    'fact_row_count' AS check_name,
    590540::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT - 590540::BIGINT AS difference,
    CASE
        WHEN COUNT(*) = 590540 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_distinct_transactionid',
    590540::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT - 590540::BIGINT,
    CASE
        WHEN COUNT(DISTINCT "TransactionID") = 590540 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transactionid_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT "TransactionID") THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fact_transaction_key_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT transaction_key))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT transaction_key))::BIGINT,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT transaction_key) THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_row_count',
    144233::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT - 144233::BIGINT,
    CASE
        WHEN COUNT(*) = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_distinct_transactionid',
    144233::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT,
    COUNT(DISTINCT "TransactionID")::BIGINT - 144233::BIGINT,
    CASE
        WHEN COUNT(DISTINCT "TransactionID") = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_transactionid_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT "TransactionID"))::BIGINT,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT "TransactionID") THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_key_duplicates',
    0::BIGINT,
    (COUNT(*) - COUNT(DISTINCT identity_key))::BIGINT,
    (COUNT(*) - COUNT(DISTINCT identity_key))::BIGINT,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT identity_key) THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_linked',
    144233::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT - 144233::BIGINT,
    CASE
        WHEN COUNT(*) FILTER (WHERE identity_key IS NOT NULL) = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_unlinked',
    446307::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT - 446307::BIGINT,
    CASE
        WHEN COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fraud_zero_count',
    569877::BIGINT,
    COUNT(*) FILTER (WHERE "isFraud" = 0)::BIGINT,
    COUNT(*) FILTER (WHERE "isFraud" = 0)::BIGINT - 569877::BIGINT,
    CASE
        WHEN COUNT(*) FILTER (WHERE "isFraud" = 0) = 569877 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fraud_one_count',
    20663::BIGINT,
    COUNT(*) FILTER (WHERE "isFraud" = 1)::BIGINT,
    COUNT(*) FILTER (WHERE "isFraud" = 1)::BIGINT - 20663::BIGINT,
    CASE
        WHEN COUNT(*) FILTER (WHERE "isFraud" = 1) = 20663 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_amount_sum',
    79738948.735::NUMERIC,
    COALESCE(SUM("TransactionAmt")::NUMERIC, 0),
    COALESCE(SUM("TransactionAmt")::NUMERIC, 0) - 79738948.735::NUMERIC,
    CASE
        WHEN COALESCE(SUM("TransactionAmt")::NUMERIC, 0) = 79738948.735::NUMERIC THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_amount_avg',
    135.0271763724726521::NUMERIC,
    COALESCE(AVG("TransactionAmt")::NUMERIC, 0),
    COALESCE(AVG("TransactionAmt")::NUMERIC, 0) - 135.0271763724726521::NUMERIC,
    CASE
        WHEN COALESCE(AVG("TransactionAmt")::NUMERIC, 0) = 135.0271763724726521::NUMERIC THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean;
