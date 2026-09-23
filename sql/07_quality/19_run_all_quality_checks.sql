-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.19 — UNIFIED QA FRAMEWORK
-- ============================================================
-- This script provides a standard QA result structure that can be
-- consumed by the final gate. It is read-only and does not alter data.
-- ============================================================

WITH checks AS (
    SELECT 'fact_row_count' AS check_name, 590540::BIGINT AS expected_value, COUNT(*)::BIGINT AS actual_value, COUNT(*)::BIGINT - 590540::BIGINT AS difference,
           CASE WHEN COUNT(*) = 590540 THEN 'PASS' ELSE 'FAIL' END AS status
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'identity_row_count', 144233::BIGINT, COUNT(*)::BIGINT, COUNT(*)::BIGINT - 144233::BIGINT,
           CASE WHEN COUNT(*) = 144233 THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.dim_identity_clean

    UNION ALL
    SELECT 'identity_linked', 144233::BIGINT, COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT, COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT - 144233::BIGINT,
           CASE WHEN COUNT(*) FILTER (WHERE identity_key IS NOT NULL) = 144233 THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'identity_unlinked', 446307::BIGINT, COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT, COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT - 446307::BIGINT,
           CASE WHEN COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307 THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'fraud_zero_count', 569877::BIGINT, COUNT(*) FILTER (WHERE "isFraud" = 0)::BIGINT, COUNT(*) FILTER (WHERE "isFraud" = 0)::BIGINT - 569877::BIGINT,
           CASE WHEN COUNT(*) FILTER (WHERE "isFraud" = 0) = 569877 THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'fraud_one_count', 20663::BIGINT, COUNT(*) FILTER (WHERE "isFraud" = 1)::BIGINT, COUNT(*) FILTER (WHERE "isFraud" = 1)::BIGINT - 20663::BIGINT,
           CASE WHEN COUNT(*) FILTER (WHERE "isFraud" = 1) = 20663 THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'transaction_amount_sum', 79738948.735::NUMERIC, COALESCE(SUM("TransactionAmt")::NUMERIC, 0), COALESCE(SUM("TransactionAmt")::NUMERIC, 0) - 79738948.735::NUMERIC,
           CASE WHEN COALESCE(SUM("TransactionAmt")::NUMERIC, 0) = 79738948.735::NUMERIC THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean

    UNION ALL
    SELECT 'transaction_amount_avg', 135.0271763724726521::NUMERIC, COALESCE(AVG("TransactionAmt")::NUMERIC, 0), COALESCE(AVG("TransactionAmt")::NUMERIC, 0) - 135.0271763724726521::NUMERIC,
           CASE WHEN COALESCE(AVG("TransactionAmt")::NUMERIC, 0) = 135.0271763724726521::NUMERIC THEN 'PASS' ELSE 'FAIL' END
    FROM analytics.fact_transaction_clean
)
SELECT check_name, expected_value, actual_value, difference, status
FROM checks
ORDER BY check_name;
