-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.12 — VALIDATE CATEGORICAL FIELDS
-- ============================================================

SELECT
    'ProductCD_unexpected_whitespace' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.fact_transaction_clean
WHERE "ProductCD" IS NOT NULL AND "ProductCD" <> TRIM("ProductCD")

UNION ALL

SELECT
    'card4_unexpected_whitespace',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card4" IS NOT NULL AND "card4" <> TRIM("card4")

UNION ALL

SELECT
    'card6_unexpected_whitespace',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card6" IS NOT NULL AND "card6" <> TRIM("card6")

UNION ALL

SELECT
    'M1_to_M9_unexpected_whitespace',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE (
    ("M1" IS NOT NULL AND "M1" <> TRIM("M1")) OR
    ("M2" IS NOT NULL AND "M2" <> TRIM("M2")) OR
    ("M3" IS NOT NULL AND "M3" <> TRIM("M3")) OR
    ("M4" IS NOT NULL AND "M4" <> TRIM("M4")) OR
    ("M5" IS NOT NULL AND "M5" <> TRIM("M5")) OR
    ("M6" IS NOT NULL AND "M6" <> TRIM("M6")) OR
    ("M7" IS NOT NULL AND "M7" <> TRIM("M7")) OR
    ("M8" IS NOT NULL AND "M8" <> TRIM("M8")) OR
    ("M9" IS NOT NULL AND "M9" <> TRIM("M9"))
)

UNION ALL

SELECT
    'DeviceType_unexpected_whitespace',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE "DeviceType" IS NOT NULL AND "DeviceType" <> TRIM("DeviceType")

UNION ALL

SELECT
    'ProductCD_blank_values',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "ProductCD" = ''

UNION ALL

SELECT
    'card4_blank_values',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card4" = ''

UNION ALL

SELECT
    'card6_blank_values',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card6" = ''

UNION ALL

SELECT
    'DeviceType_blank_values',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE "DeviceType" = '';
