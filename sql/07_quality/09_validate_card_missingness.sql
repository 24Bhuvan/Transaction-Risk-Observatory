-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.9 — VALIDATE CARD MISSINGNESS
-- ============================================================

SELECT
    'card_missing_count_range' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE card_attributes_missing_count NOT BETWEEN 0 AND 4

UNION ALL

SELECT
    'card_partial_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card_attributes_partial_missing_flag <> CASE
    WHEN card_attributes_missing_count BETWEEN 1 AND 3 THEN 1
    ELSE 0
END

UNION ALL

SELECT
    'card_missing_count_distribution_0',
    579507::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count = 0)::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count = 0)::BIGINT - 579507::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE card_attributes_missing_count = 0) = 579507 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card_missing_count_distribution_1_to_3',
    9468::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count BETWEEN 1 AND 3)::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count BETWEEN 1 AND 3)::BIGINT - 9468::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE card_attributes_missing_count BETWEEN 1 AND 3) = 9468 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card_missing_count_distribution_4',
    1565::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count = 4)::BIGINT,
    COUNT(*) FILTER (WHERE card_attributes_missing_count = 4)::BIGINT - 1565::BIGINT,
    CASE WHEN COUNT(*) FILTER (WHERE card_attributes_missing_count = 4) = 1565 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean;
