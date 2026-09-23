-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.11 — CATEGORICAL VALUE STANDARDIZATION VALIDATION
-- ============================================================
-- Purpose:
--   Validate categorical/text standardization performed in
--   previous cleaning steps.
--
-- IMPORTANT:
--   This is a validation step.
--   Do not collapse rare categories.
--   Do not invent mappings.
--   Do not alter legitimate observed source values.
--
-- Fields:
--   Fact:
--     ProductCD
--     card4
--     card6
--     M1-M9
--     P_emaildomain
--     R_emaildomain
--
--   Identity:
--     DeviceType
-- ============================================================


-- ============================================================
-- 1. Check remaining leading/trailing whitespace
-- ============================================================

SELECT
    'ProductCD' AS field,
    COUNT(*) AS whitespace_rows
FROM analytics.fact_transaction_clean
WHERE "ProductCD" IS NOT NULL
  AND "ProductCD" <> TRIM("ProductCD")

UNION ALL

SELECT
    'card4',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card4" IS NOT NULL
  AND "card4" <> TRIM("card4")

UNION ALL

SELECT
    'card6',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card6" IS NOT NULL
  AND "card6" <> TRIM("card6")

UNION ALL

SELECT
    'M1-M9',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE
    ("M1" IS NOT NULL AND "M1" <> TRIM("M1"))
 OR ("M2" IS NOT NULL AND "M2" <> TRIM("M2"))
 OR ("M3" IS NOT NULL AND "M3" <> TRIM("M3"))
 OR ("M4" IS NOT NULL AND "M4" <> TRIM("M4"))
 OR ("M5" IS NOT NULL AND "M5" <> TRIM("M5"))
 OR ("M6" IS NOT NULL AND "M6" <> TRIM("M6"))
 OR ("M7" IS NOT NULL AND "M7" <> TRIM("M7"))
 OR ("M8" IS NOT NULL AND "M8" <> TRIM("M8"))
 OR ("M9" IS NOT NULL AND "M9" <> TRIM("M9"))

UNION ALL

SELECT
    'DeviceType',
    COUNT(*)
FROM analytics.dim_identity_clean
WHERE "DeviceType" IS NOT NULL
  AND "DeviceType" <> TRIM("DeviceType");


-- ============================================================
-- 2. Validate blank categorical values
-- ============================================================

SELECT
    'ProductCD' AS field,
    COUNT(*) AS blank_rows
FROM analytics.fact_transaction_clean
WHERE "ProductCD" = ''

UNION ALL

SELECT
    'card4',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card4" = ''

UNION ALL

SELECT
    'card6',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card6" = ''

UNION ALL

SELECT
    'DeviceType',
    COUNT(*)
FROM analytics.dim_identity_clean
WHERE "DeviceType" = '';


-- ============================================================
-- 3. Validate observed card6 rare categories
-- ============================================================
-- These must NOT be removed or collapsed.
-- ============================================================

SELECT
    "card6",
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
WHERE "card6" IN ('charge card', 'debit or credit')
GROUP BY "card6"
ORDER BY "card6";


-- ============================================================
-- 4. Validate M1-M9 observed categories
-- ============================================================

SELECT
    field,
    value,
    row_count
FROM (
    SELECT 'M1' AS field, "M1" AS value, COUNT(*) AS row_count
    FROM analytics.fact_transaction_clean
    GROUP BY "M1"

    UNION ALL

    SELECT 'M2', "M2", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M2"

    UNION ALL

    SELECT 'M3', "M3", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M3"

    UNION ALL

    SELECT 'M4', "M4", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M4"

    UNION ALL

    SELECT 'M5', "M5", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M5"

    UNION ALL

    SELECT 'M6', "M6", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M6"

    UNION ALL

    SELECT 'M7', "M7", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M7"

    UNION ALL

    SELECT 'M8', "M8", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M8"

    UNION ALL

    SELECT 'M9', "M9", COUNT(*)
    FROM analytics.fact_transaction_clean
    GROUP BY "M9"
) x
ORDER BY field, value;


-- ============================================================
-- 5. Validate email-domain formatting
-- ============================================================
-- Email normalization is validated here only.
-- No semantic domain grouping is performed.
-- ============================================================

SELECT
    'P_emaildomain' AS field,
    COUNT(*) AS whitespace_rows
FROM analytics.fact_transaction_clean
WHERE "P_emaildomain" IS NOT NULL
  AND "P_emaildomain" <> TRIM("P_emaildomain")

UNION ALL

SELECT
    'R_emaildomain',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "R_emaildomain" IS NOT NULL
  AND "R_emaildomain" <> TRIM("R_emaildomain");


-- ============================================================
-- 6. Validate case consistency for key categorical fields
-- ============================================================
-- Any returned rows require inspection rather than automatic
-- category collapsing.
-- ============================================================

SELECT
    "card4" AS value,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
WHERE "card4" IS NOT NULL
GROUP BY "card4"
ORDER BY "card4";


SELECT
    "card6" AS value,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
WHERE "card6" IS NOT NULL
GROUP BY "card6"
ORDER BY "card6";


SELECT
    "DeviceType" AS value,
    COUNT(*) AS row_count
FROM analytics.dim_identity_clean
WHERE "DeviceType" IS NOT NULL
GROUP BY "DeviceType"
ORDER BY "DeviceType";


-- ============================================================
-- 7. Core row-count validation
-- ============================================================

SELECT
    COUNT(*) AS fact_rows
FROM analytics.fact_transaction_clean;

SELECT
    COUNT(*) AS identity_rows
FROM analytics.dim_identity_clean;