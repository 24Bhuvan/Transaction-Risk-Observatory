-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.10 — TRANSACTION AMOUNT VALIDATION / FEATURES
-- ============================================================
-- Purpose:
--   Validate TransactionAmt and create controlled analytical
--   features without altering the authoritative amount.
--
-- Rules:
--   - Preserve TransactionAmt unchanged.
--   - Do not remove large transactions.
--   - Do not cap or winsorize.
--   - Do not convert zero amounts to NULL.
--   - Do not classify outliers as fraud.
--
-- Derived features:
--   transaction_amount_zero_flag
--   transaction_amount_log
--
-- transaction_amount_log:
--   LN(TransactionAmt + 1)
--   This safely handles TransactionAmt = 0.
-- ============================================================


-- ============================================================
-- 1. Add derived columns
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS transaction_amount_zero_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS transaction_amount_log NUMERIC;


-- ============================================================
-- 2. Create zero-amount flag
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET transaction_amount_zero_flag =
    CASE
        WHEN "TransactionAmt" = 0 THEN 1
        ELSE 0
    END;


-- ============================================================
-- 3. Create log-transformed amount
-- ============================================================
-- LN(amount + 1) preserves zero as 0 and is suitable for
-- positively skewed transaction amount distributions.
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET transaction_amount_log =
    LN("TransactionAmt" + 1);


-- ============================================================
-- 4. Validate original TransactionAmt
-- ============================================================

SELECT
    COUNT(*) AS fact_rows,
    MIN("TransactionAmt") AS min_transaction_amount,
    MAX("TransactionAmt") AS max_transaction_amount,
    SUM("TransactionAmt") AS transaction_amount_sum,
    AVG("TransactionAmt") AS transaction_amount_average
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 5. Validate zero-amount feature
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE "TransactionAmt" = 0
    ) AS zero_amount_rows,

    COUNT(*) FILTER (
        WHERE transaction_amount_zero_flag = 1
    ) AS zero_flag_rows,

    COUNT(*) FILTER (
        WHERE transaction_amount_zero_flag <>
              CASE
                  WHEN "TransactionAmt" = 0 THEN 1
                  ELSE 0
              END
    ) AS zero_flag_mismatches
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 6. Validate log feature
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(transaction_amount_log) AS non_null_log_rows,
    MIN(transaction_amount_log) AS min_log_amount,
    MAX(transaction_amount_log) AS max_log_amount
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 7. Validate log mathematical consistency
-- ============================================================

SELECT
    COUNT(*) AS log_mismatches
FROM analytics.fact_transaction_clean
WHERE transaction_amount_log <>
      LN("TransactionAmt" + 1);


-- ============================================================
-- 8. Validate invalid negative amounts
-- ============================================================

SELECT
    COUNT(*) AS negative_transaction_amounts
FROM analytics.fact_transaction_clean
WHERE "TransactionAmt" < 0;


-- ============================================================
-- 9. Validate row count
-- ============================================================

SELECT
    COUNT(*) AS fact_rows
FROM analytics.fact_transaction_clean;