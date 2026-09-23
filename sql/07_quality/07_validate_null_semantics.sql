-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.7 — VALIDATE NULL SEMANTICS
-- ============================================================

SELECT
    'TransactionAmt_nulls' AS check_name,
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL)::BIGINT AS expected_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL)::BIGINT AS actual_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL)::BIGINT AS difference,
    CASE
        WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL)
        THEN 'PASS' ELSE 'FAIL'
    END AS status

UNION ALL

SELECT
    'TransactionDT_nulls',
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionDT" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionDT" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionDT" IS NULL)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionDT" IS NULL)::BIGINT,
    CASE
        WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionDT" IS NULL) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionDT" IS NULL)
        THEN 'PASS' ELSE 'FAIL'
    END

UNION ALL

SELECT
    'ProductCD_nulls',
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "ProductCD" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "ProductCD" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "ProductCD" IS NULL)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "ProductCD" IS NULL)::BIGINT,
    CASE
        WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "ProductCD" IS NULL) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "ProductCD" IS NULL)
        THEN 'PASS' ELSE 'FAIL'
    END

UNION ALL

SELECT
    'ProductCD_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "ProductCD" = ''

UNION ALL

SELECT
    'ProductCD_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "ProductCD" IS NOT NULL AND TRIM("ProductCD") = ''

UNION ALL

SELECT
    'card4_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card4" = ''

UNION ALL

SELECT
    'card4_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card4" IS NOT NULL AND TRIM("card4") = ''

UNION ALL

SELECT
    'card6_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card6" = ''

UNION ALL

SELECT
    'card6_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "card6" IS NOT NULL AND TRIM("card6") = ''

UNION ALL

SELECT
    'M1_to_M9_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE (
    ("M1" IS NOT NULL AND TRIM("M1") = '') OR
    ("M2" IS NOT NULL AND TRIM("M2") = '') OR
    ("M3" IS NOT NULL AND TRIM("M3") = '') OR
    ("M4" IS NOT NULL AND TRIM("M4") = '') OR
    ("M5" IS NOT NULL AND TRIM("M5") = '') OR
    ("M6" IS NOT NULL AND TRIM("M6") = '') OR
    ("M7" IS NOT NULL AND TRIM("M7") = '') OR
    ("M8" IS NOT NULL AND TRIM("M8") = '') OR
    ("M9" IS NOT NULL AND TRIM("M9") = '')
)

UNION ALL

SELECT
    'DeviceType_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE "DeviceType" = ''

UNION ALL

SELECT
    'DeviceType_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE "DeviceType" IS NOT NULL AND TRIM("DeviceType") = ''

UNION ALL

SELECT
    'P_emaildomain_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "P_emaildomain" = ''

UNION ALL

SELECT
    'P_emaildomain_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "P_emaildomain" IS NOT NULL AND TRIM("P_emaildomain") = ''

UNION ALL

SELECT
    'R_emaildomain_blank_strings',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "R_emaildomain" = ''

UNION ALL

SELECT
    'R_emaildomain_whitespace_only',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "R_emaildomain" IS NOT NULL AND TRIM("R_emaildomain") = '';
