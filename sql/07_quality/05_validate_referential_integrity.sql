-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.5 — REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    'orphan_identity_links' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM (
    SELECT f.*
    FROM analytics.fact_transaction_clean f
    LEFT JOIN analytics.dim_identity_clean d
      ON f.identity_key = d.identity_key
    WHERE f.identity_key IS NOT NULL
      AND d.identity_key IS NULL
) x

UNION ALL

SELECT
    'orphan_identity_records',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT d.*
    FROM analytics.dim_identity_clean d
    LEFT JOIN analytics.fact_transaction_clean f
      ON d."TransactionID" = f."TransactionID"
    WHERE f."TransactionID" IS NULL
) x;
