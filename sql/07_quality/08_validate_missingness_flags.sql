-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.8 — VALIDATE MISSINGNESS FLAGS
-- ============================================================

SELECT
    'dist2_missing_flag_domain' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE dist2_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'D7_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE D7_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'R_emaildomain_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE R_emaildomain_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'card2_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card2_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'card3_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card3_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'card5_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card5_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'card6_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card6_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'deviceinfo_missing_flag_domain',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE deviceinfo_missing_flag NOT IN (0, 1)

UNION ALL

SELECT
    'dist2_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE dist2_missing_flag <> CASE WHEN "dist2" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'D7_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE D7_missing_flag <> CASE WHEN "D7" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'R_emaildomain_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE R_emaildomain_missing_flag <> CASE WHEN "R_emaildomain" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'card2_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card2_missing_flag <> CASE WHEN "card2" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'card3_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card3_missing_flag <> CASE WHEN "card3" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'card5_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card5_missing_flag <> CASE WHEN "card5" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'card6_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE card6_missing_flag <> CASE WHEN "card6" IS NULL THEN 1 ELSE 0 END

UNION ALL

SELECT
    'deviceinfo_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE deviceinfo_missing_flag <> CASE WHEN "DeviceInfo" IS NULL THEN 1 ELSE 0 END;
