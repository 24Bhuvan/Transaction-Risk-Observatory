-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.6 — VALIDATE IDENTITY RELATIONSHIP
-- ============================================================

SELECT
    'total_transactions' AS check_name,
    590540::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT - 590540::BIGINT AS difference,
    CASE WHEN COUNT(*) = 590540 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'linked_transactions',
    144233::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NOT NULL)::BIGINT - 144233::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE identity_key IS NOT NULL) = 144233 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'unlinked_transactions',
    446307::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT,
    COUNT(*) FILTER (WHERE identity_key IS NULL)::BIGINT - 446307::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'linked_plus_unlinked_matches_total',
    590540::BIGINT,
    (COUNT(*) FILTER (WHERE identity_key IS NOT NULL) + COUNT(*) FILTER (WHERE identity_key IS NULL))::BIGINT,
    (COUNT(*) FILTER (WHERE identity_key IS NOT NULL) + COUNT(*) FILTER (WHERE identity_key IS NULL))::BIGINT - 590540::BIGINT,
    CASE
        WHEN (COUNT(*) FILTER (WHERE identity_key IS NOT NULL) + COUNT(*) FILTER (WHERE identity_key IS NULL)) = 590540
        THEN 'PASS' ELSE 'FAIL'
    END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'multiple_identity_records_per_transaction',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT "TransactionID", COUNT(*) AS cnt
    FROM analytics.dim_identity_clean
    GROUP BY "TransactionID"
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'transaction_to_identity_one_to_zero_or_one',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM (
    SELECT f."TransactionID"
    FROM analytics.fact_transaction_clean f
    LEFT JOIN analytics.dim_identity_clean d
      ON f."TransactionID" = d."TransactionID"
    GROUP BY f."TransactionID"
    HAVING COUNT(d."TransactionID") > 1
) x;
