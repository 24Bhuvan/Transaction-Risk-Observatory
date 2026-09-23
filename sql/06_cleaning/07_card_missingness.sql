-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.8 — SECONDARY CARD MISSINGNESS
-- ============================================================
-- Purpose:
--   Capture the combined missingness pattern across:
--     card2, card3, card5, card6
--
-- Rules:
--   - Do not impute card values.
--   - Preserve original NULLs.
--   - Count missing card attributes.
--   - Flag partial missingness.
--
-- Expected Phase 3 pattern:
--   0 missing = 579,507
--   1–3 missing = 9,468
--   4 missing = 1,565
-- ============================================================


-- ============================================================
-- 1. Add derived fields
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card_attributes_missing_count INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS card_attributes_partial_missing_flag INTEGER;


-- ============================================================
-- 2. Calculate number of missing secondary card attributes
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET card_attributes_missing_count =
      CASE WHEN "card2" IS NULL THEN 1 ELSE 0 END
    + CASE WHEN "card3" IS NULL THEN 1 ELSE 0 END
    + CASE WHEN "card5" IS NULL THEN 1 ELSE 0 END
    + CASE WHEN "card6" IS NULL THEN 1 ELSE 0 END;


-- ============================================================
-- 3. Create partial-missingness flag
-- ============================================================
-- 1 = some, but not all, card attributes are missing
-- 0 = none missing OR all four missing
--
-- The distinction between partial and complete missingness
-- is retained by card_attributes_missing_count.
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET card_attributes_partial_missing_flag =
    CASE
        WHEN card_attributes_missing_count BETWEEN 1 AND 3
            THEN 1
        ELSE 0
    END;


-- ============================================================
-- 4. Validate missingness distribution
-- ============================================================

SELECT
    card_attributes_missing_count,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
GROUP BY card_attributes_missing_count
ORDER BY card_attributes_missing_count;


-- ============================================================
-- 5. Validate expected Phase 3 groups
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE card_attributes_missing_count = 0
    ) AS all_present,

    COUNT(*) FILTER (
        WHERE card_attributes_missing_count BETWEEN 1 AND 3
    ) AS partial_missing,

    COUNT(*) FILTER (
        WHERE card_attributes_missing_count = 4
    ) AS all_missing
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 6. Validate partial-missingness flag
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE card_attributes_partial_missing_flag <>
            CASE
                WHEN card_attributes_missing_count BETWEEN 1 AND 3
                    THEN 1
                ELSE 0
            END
    ) AS flag_mismatches
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 7. Validate allowed values
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE card_attributes_missing_count NOT BETWEEN 0 AND 4
    ) AS invalid_missing_count,

    COUNT(*) FILTER (
        WHERE card_attributes_partial_missing_flag NOT IN (0,1)
    ) AS invalid_partial_flags
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 8. Confirm original card NULLs remain unchanged
-- ============================================================

SELECT
    COUNT(*) FILTER (WHERE "card2" IS NULL) AS card2_nulls,
    COUNT(*) FILTER (WHERE "card3" IS NULL) AS card3_nulls,
    COUNT(*) FILTER (WHERE "card5" IS NULL) AS card5_nulls,
    COUNT(*) FILTER (WHERE "card6" IS NULL) AS card6_nulls
FROM analytics.fact_transaction_clean;