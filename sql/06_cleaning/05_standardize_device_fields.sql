-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.6 — STANDARDIZE DEVICE FIELDS
-- ============================================================
-- Purpose:
--   Create controlled derived fields from DeviceInfo.
--
-- Rules:
--   - Preserve original DeviceInfo.
--   - Do not delete DeviceInfo.
--   - Do not impute missing DeviceInfo.
--   - Do not assign unsupported semantic categories.
--   - Create deterministic normalized and missing-flag fields.
-- ============================================================


-- ============================================================
-- 1. Add derived columns
-- ============================================================

ALTER TABLE analytics.dim_identity_clean
ADD COLUMN IF NOT EXISTS deviceinfo_normalized TEXT;

ALTER TABLE analytics.dim_identity_clean
ADD COLUMN IF NOT EXISTS deviceinfo_missing_flag INTEGER;


-- ============================================================
-- 2. Populate normalized DeviceInfo
-- ============================================================
-- Deterministic operations:
--   TRIM
--   whitespace normalization
--   controlled lowercase normalization
--
-- Original DeviceInfo remains unchanged.
-- ============================================================

UPDATE analytics.dim_identity_clean
SET deviceinfo_normalized =
    CASE
        WHEN "DeviceInfo" IS NULL THEN NULL
        ELSE LOWER(
            REGEXP_REPLACE(
                TRIM("DeviceInfo"),
                '[[:space:]]+',
                ' ',
                'g'
            )
        )
    END;


-- ============================================================
-- 3. Create missingness flag
-- ============================================================
-- 1 = DeviceInfo missing
-- 0 = DeviceInfo present
--
-- No missing values are imputed.
-- ============================================================

UPDATE analytics.dim_identity_clean
SET deviceinfo_missing_flag =
    CASE
        WHEN "DeviceInfo" IS NULL THEN 1
        ELSE 0
    END;


-- ============================================================
-- 4. Validation summary
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT("DeviceInfo") AS original_non_null_deviceinfo,
    COUNT(deviceinfo_normalized) AS normalized_non_null_deviceinfo,
    COUNT(*) FILTER (
        WHERE deviceinfo_missing_flag = 1
    ) AS deviceinfo_missing,
    COUNT(*) FILTER (
        WHERE deviceinfo_missing_flag = 0
    ) AS deviceinfo_present,
    COUNT(DISTINCT "DeviceInfo") AS original_distinct_deviceinfo,
    COUNT(DISTINCT deviceinfo_normalized) AS normalized_distinct_deviceinfo
FROM analytics.dim_identity_clean;


-- ============================================================
-- 5. Validate missing flag
-- ============================================================

SELECT
    COUNT(*) AS invalid_missing_flags
FROM analytics.dim_identity_clean
WHERE
    deviceinfo_missing_flag IS NULL
    OR deviceinfo_missing_flag NOT IN (0, 1);


-- ============================================================
-- 6. Validate original DeviceInfo was preserved
-- ============================================================
-- Expected:
--   total rows     = 144233
--   non-null       = 25567
--   distinct       = 1786
--
-- These values should remain unchanged from the Step 6.4
-- clean-layer baseline.
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT("DeviceInfo") AS non_null_deviceinfo,
    COUNT(DISTINCT "DeviceInfo") AS distinct_deviceinfo
FROM analytics.dim_identity_clean;


-- ============================================================
-- 7. Sample derived values
-- ============================================================

SELECT
    "DeviceInfo",
    deviceinfo_normalized,
    deviceinfo_missing_flag
FROM analytics.dim_identity_clean
WHERE "DeviceInfo" IS NOT NULL
ORDER BY identity_key
LIMIT 20;