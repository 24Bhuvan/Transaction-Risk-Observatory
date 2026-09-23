-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.7 — NULL HANDLING
-- ============================================================
-- Purpose:
--   Preserve source NULLs and create targeted missingness
--   indicators for analytically meaningful fields.
--
-- IMPORTANT:
--   - No blanket imputation.
--   - No COALESCE across the dataset.
--   - Original NULL values are preserved.
--   - No artificial values such as 0, -1, or 'UNKNOWN'.
--   - DeviceInfo_missing_flag was created in Step 6.6.
-- ============================================================


-- ============================================================
-- 1. Add targeted missingness indicators
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS dist2_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS D7_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS R_emaildomain_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card2_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card3_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card5_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card6_missing_flag INTEGER;


-- ============================================================
-- 2. Populate missingness indicators
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET
    dist2_missing_flag =
        CASE
            WHEN "dist2" IS NULL THEN 1
            ELSE 0
        END,

    D7_missing_flag =
        CASE
            WHEN "D7" IS NULL THEN 1
            ELSE 0
        END,

    R_emaildomain_missing_flag =
        CASE
            WHEN "R_emaildomain" IS NULL THEN 1
            ELSE 0
        END,

    card2_missing_flag =
        CASE
            WHEN "card2" IS NULL THEN 1
            ELSE 0
        END,

    card3_missing_flag =
        CASE
            WHEN "card3" IS NULL THEN 1
            ELSE 0
        END,

    card5_missing_flag =
        CASE
            WHEN "card5" IS NULL THEN 1
            ELSE 0
        END,

    card6_missing_flag =
        CASE
            WHEN "card6" IS NULL THEN 1
            ELSE 0
        END;


-- ============================================================
-- 3. Validate missingness indicators
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE dist2_missing_flag = 1
    ) AS dist2_missing,

    COUNT(*) FILTER (
        WHERE D7_missing_flag = 1
    ) AS D7_missing,

    COUNT(*) FILTER (
        WHERE R_emaildomain_missing_flag = 1
    ) AS R_emaildomain_missing,

    COUNT(*) FILTER (
        WHERE card2_missing_flag = 1
    ) AS card2_missing,

    COUNT(*) FILTER (
        WHERE card3_missing_flag = 1
    ) AS card3_missing,

    COUNT(*) FILTER (
        WHERE card5_missing_flag = 1
    ) AS card5_missing,

    COUNT(*) FILTER (
        WHERE card6_missing_flag = 1
    ) AS card6_missing

FROM analytics.fact_transaction_clean;


-- ============================================================
-- 4. Validate indicator correctness
-- ============================================================

SELECT
    'dist2_missing_flag' AS field,
    COUNT(*) FILTER (
        WHERE dist2_missing_flag <>
              CASE WHEN "dist2" IS NULL THEN 1 ELSE 0 END
    ) AS mismatches
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'D7_missing_flag',
    COUNT(*) FILTER (
        WHERE D7_missing_flag <>
              CASE WHEN "D7" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'R_emaildomain_missing_flag',
    COUNT(*) FILTER (
        WHERE R_emaildomain_missing_flag <>
              CASE WHEN "R_emaildomain" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card2_missing_flag',
    COUNT(*) FILTER (
        WHERE card2_missing_flag <>
              CASE WHEN "card2" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card3_missing_flag',
    COUNT(*) FILTER (
        WHERE card3_missing_flag <>
              CASE WHEN "card3" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card5_missing_flag',
    COUNT(*) FILTER (
        WHERE card5_missing_flag <>
              CASE WHEN "card5" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'card6_missing_flag',
    COUNT(*) FILTER (
        WHERE card6_missing_flag <>
              CASE WHEN "card6" IS NULL THEN 1 ELSE 0 END
    )
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 5. Validate flag domains
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE dist2_missing_flag NOT IN (0,1)
           OR D7_missing_flag NOT IN (0,1)
           OR R_emaildomain_missing_flag NOT IN (0,1)
           OR card2_missing_flag NOT IN (0,1)
           OR card3_missing_flag NOT IN (0,1)
           OR card5_missing_flag NOT IN (0,1)
           OR card6_missing_flag NOT IN (0,1)
    ) AS invalid_flag_rows
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 6. Confirm original NULLs remain NULL
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE "dist2" IS NULL
    ) AS dist2_nulls,

    COUNT(*) FILTER (
        WHERE "D7" IS NULL
    ) AS D7_nulls,

    COUNT(*) FILTER (
        WHERE "R_emaildomain" IS NULL
    ) AS R_emaildomain_nulls,

    COUNT(*) FILTER (
        WHERE "card2" IS NULL
    ) AS card2_nulls,

    COUNT(*) FILTER (
        WHERE "card3" IS NULL
    ) AS card3_nulls,

    COUNT(*) FILTER (
        WHERE "card5" IS NULL
    ) AS card5_nulls,

    COUNT(*) FILTER (
        WHERE "card6" IS NULL
    ) AS card6_nulls

FROM analytics.fact_transaction_clean;