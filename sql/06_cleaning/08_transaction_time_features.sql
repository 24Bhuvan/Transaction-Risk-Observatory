-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.9 — TRANSACTION TIME FEATURES
-- ============================================================
-- Purpose:
--   Derive relative time features from TransactionDT.
--
-- IMPORTANT:
--   TransactionDT is source-relative elapsed time.
--
--   We DO NOT create:
--     transaction_date
--     calendar_date
--     year
--     month
--
--   No calendar reference date has been established.
--
--   TransactionDT itself remains unchanged.
--
-- Relative features:
--   transaction_day_number
--   transaction_hour
--   transaction_week_number
--
-- Definitions:
--   day  = floor(TransactionDT / 86400)
--   hour = hour within relative day (0–23)
--   week = floor(TransactionDT / 604800)
-- ============================================================


-- ============================================================
-- 1. Add derived columns
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS transaction_day_number INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS transaction_hour INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS transaction_week_number INTEGER;


-- ============================================================
-- 2. Calculate relative day number
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET transaction_day_number =
    FLOOR("TransactionDT" / 86400.0)::INTEGER;


-- ============================================================
-- 3. Calculate relative hour
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET transaction_hour =
    FLOOR(
        MOD("TransactionDT", 86400) / 3600.0
    )::INTEGER;


-- ============================================================
-- 4. Calculate relative week number
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET transaction_week_number =
    FLOOR("TransactionDT" / 604800.0)::INTEGER;


-- ============================================================
-- 5. Validate feature ranges
-- ============================================================

SELECT
    MIN("TransactionDT") AS min_transaction_dt,
    MAX("TransactionDT") AS max_transaction_dt,
    MIN(transaction_day_number) AS min_day_number,
    MAX(transaction_day_number) AS max_day_number,
    MIN(transaction_hour) AS min_hour,
    MAX(transaction_hour) AS max_hour,
    MIN(transaction_week_number) AS min_week_number,
    MAX(transaction_week_number) AS max_week_number
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 6. Validate hour range
-- ============================================================

SELECT
    COUNT(*) AS invalid_hour_rows
FROM analytics.fact_transaction_clean
WHERE transaction_hour NOT BETWEEN 0 AND 23;


-- ============================================================
-- 7. Validate mathematical consistency
-- ============================================================

SELECT
    COUNT(*) AS day_mismatches
FROM analytics.fact_transaction_clean
WHERE transaction_day_number <>
      FLOOR("TransactionDT" / 86400.0)::INTEGER;


SELECT
    COUNT(*) AS hour_mismatches
FROM analytics.fact_transaction_clean
WHERE transaction_hour <>
      FLOOR(
          MOD("TransactionDT", 86400) / 3600.0
      )::INTEGER;


SELECT
    COUNT(*) AS week_mismatches
FROM analytics.fact_transaction_clean
WHERE transaction_week_number <>
      FLOOR("TransactionDT" / 604800.0)::INTEGER;


-- ============================================================
-- 8. Validate row count
-- ============================================================

SELECT
    COUNT(*) AS fact_rows
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 9. Confirm TransactionDT remains populated and unchanged
-- ============================================================

SELECT
    COUNT(*) AS transactiondt_non_null,
    COUNT(DISTINCT "TransactionDT") AS distinct_transactiondt
FROM analytics.fact_transaction_clean;