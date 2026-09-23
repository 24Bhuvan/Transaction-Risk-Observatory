-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.15 — VALIDATE RISK SIGNALS
-- ============================================================

SELECT
    'identity_available_flag_logic' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE identity_available_flag <> CASE WHEN identity_key IS NOT NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'email_domain_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE email_domain_missing_flag <> CASE WHEN "P_emaildomain" IS NULL AND "R_emaildomain" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'device_info_available_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean f
LEFT JOIN analytics.dim_identity_clean d ON f.identity_key = d.identity_key
WHERE device_info_available_flag <> CASE WHEN d."DeviceInfo" IS NOT NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'missing_attribute_count_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE missing_attribute_count <> (
    CASE WHEN identity_available_flag = 0 THEN 1 ELSE 0 END +
    CASE WHEN email_domain_missing_flag = 1 THEN 1 ELSE 0 END +
    CASE WHEN device_info_available_flag = 0 THEN 1 ELSE 0 END +
    CASE WHEN card_attributes_partial_missing_flag = 1 THEN 1 ELSE 0 END +
    CASE WHEN transaction_amount_zero_flag = 1 THEN 1 ELSE 0 END
)

UNION ALL

SELECT
    'invalid_signal_domains',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE identity_available_flag NOT IN (0, 1)
   OR email_domain_missing_flag NOT IN (0, 1)
   OR device_info_available_flag NOT IN (0, 1)
   OR card_attributes_partial_missing_flag NOT IN (0, 1)
   OR transaction_amount_zero_flag NOT IN (0, 1)
   OR missing_attribute_count < 0;
