-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.18 — VALIDATE BUSINESS RULES
-- ============================================================

SELECT
    'isFraud_domain' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE "isFraud" NOT IN (0, 1)

UNION ALL

SELECT
    'binary_flags_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE (
    dist2_missing_flag NOT IN (0, 1)
    OR D7_missing_flag NOT IN (0, 1)
    OR R_emaildomain_missing_flag NOT IN (0, 1)
    OR card2_missing_flag NOT IN (0, 1)
    OR card3_missing_flag NOT IN (0, 1)
    OR card5_missing_flag NOT IN (0, 1)
    OR card6_missing_flag NOT IN (0, 1)
    OR identity_available_flag NOT IN (0, 1)
    OR email_domain_missing_flag NOT IN (0, 1)
    OR device_info_available_flag NOT IN (0, 1)
    OR card_attributes_partial_missing_flag NOT IN (0, 1)
    OR transaction_amount_zero_flag NOT IN (0, 1)
)

UNION ALL

SELECT
    'transaction_amount_non_negative',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "TransactionAmt" < 0

UNION ALL

SELECT
    'transaction_hour_valid_range',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE transaction_hour NOT BETWEEN 0 AND 23

UNION ALL

SELECT
    'card_missing_count_valid_range',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card_attributes_missing_count NOT BETWEEN 0 AND 4

UNION ALL

SELECT
    'identity_available_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE identity_available_flag NOT IN (0, 1)

UNION ALL

SELECT
    'missing_attribute_count_non_negative',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE missing_attribute_count < 0;
