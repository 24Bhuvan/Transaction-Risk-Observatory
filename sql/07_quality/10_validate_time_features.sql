-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.10 — VALIDATE TIME FEATURES
-- ============================================================

SELECT
    'transaction_day_number_mismatches' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE transaction_day_number <> FLOOR("TransactionDT" / 86400.0)::INTEGER

UNION ALL

SELECT
    'transaction_hour_mismatches',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE transaction_hour <> FLOOR(MOD("TransactionDT", 86400) / 3600.0)::INTEGER

UNION ALL

SELECT
    'transaction_week_number_mismatches',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE transaction_week_number <> FLOOR("TransactionDT" / 604800.0)::INTEGER

UNION ALL

SELECT
    'invalid_transaction_hours',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE transaction_hour NOT BETWEEN 0 AND 23;
