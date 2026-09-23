-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.13 — VALIDATE EMAIL FIELDS
-- ============================================================

SELECT
    'P_emaildomain_reconciliation' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE NULLIF(TRIM(p."P_emaildomain"), '') IS DISTINCT FROM c."P_emaildomain"

UNION ALL

SELECT
    'R_emaildomain_reconciliation',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE NULLIF(TRIM(p."R_emaildomain"), '') IS DISTINCT FROM c."R_emaildomain";
