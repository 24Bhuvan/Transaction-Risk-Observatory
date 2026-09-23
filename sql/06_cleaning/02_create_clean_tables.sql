-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.3 — CREATE CLEAN ANALYTICAL LAYER
-- ============================================================
-- Purpose:
--   Create Phase 6 clean analytical tables from the validated
--   Phase 5 analytical layer.
--
-- IMPORTANT:
--   Phase 5 tables are NOT modified.
--   Staging tables are NOT modified.
--   No cleaning/transformation is performed here.
--
-- Source:
--   analytics.fact_transaction
--   analytics.dim_identity
--
-- Target:
--   analytics.fact_transaction_clean
--   analytics.dim_identity_clean
-- ============================================================


-- ============================================================
-- 1. SAFETY CHECK — PHASE 5 FACT TABLE
-- ============================================================

SELECT
    'Phase 5 fact_transaction' AS source_table,
    COUNT(*) AS row_count
FROM analytics.fact_transaction;


-- ============================================================
-- 2. SAFETY CHECK — PHASE 5 IDENTITY TABLE
-- ============================================================

SELECT
    'Phase 5 dim_identity' AS source_table,
    COUNT(*) AS row_count
FROM analytics.dim_identity;


-- ============================================================
-- 3. REMOVE EXISTING PHASE 6 CLEAN TABLES IF THEY EXIST
-- ============================================================
-- This makes the script safely re-runnable.
--
-- These are Phase 6 tables only.
-- Phase 5 tables are NOT dropped.

DROP TABLE IF EXISTS analytics.fact_transaction_clean;

DROP TABLE IF EXISTS analytics.dim_identity_clean;


-- ============================================================
-- 4. CREATE CLEAN FACT TABLE
-- ============================================================
-- Copy the complete Phase 5 structure and data.
--
-- No columns are removed.
-- No values are transformed.
-- NULLs are preserved.
-- transaction_key is preserved.
-- identity_key is preserved.
-- TransactionID is preserved.
-- isFraud is preserved.

CREATE TABLE analytics.fact_transaction_clean
AS
SELECT *
FROM analytics.fact_transaction;


-- ============================================================
-- 5. CREATE CLEAN IDENTITY TABLE
-- ============================================================
-- Copy the complete Phase 5 structure and data.
--
-- No columns are removed.
-- No values are transformed.
-- NULLs are preserved.
-- identity_key is preserved.
-- TransactionID is preserved.
-- DeviceType and DeviceInfo are preserved.

CREATE TABLE analytics.dim_identity_clean
AS
SELECT *
FROM analytics.dim_identity;


-- ============================================================
-- 6. VERIFY CLEAN FACT POPULATION
-- ============================================================

SELECT
    'fact_transaction_clean' AS table_name,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 7. VERIFY CLEAN IDENTITY POPULATION
-- ============================================================

SELECT
    'dim_identity_clean' AS table_name,
    COUNT(*) AS row_count
FROM analytics.dim_identity_clean;


-- ============================================================
-- 8. VERIFY FACT GRAIN
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids,
    COUNT(*) - COUNT(DISTINCT "TransactionID") AS transaction_id_duplicates
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 9. VERIFY FACT SURROGATE KEY
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "transaction_key") AS distinct_transaction_keys,
    COUNT(*) - COUNT(DISTINCT "transaction_key") AS transaction_key_duplicates
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 10. VERIFY IDENTITY GRAIN
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "identity_key") AS distinct_identity_keys,
    COUNT(*) - COUNT(DISTINCT "identity_key") AS identity_key_duplicates
FROM analytics.dim_identity_clean;


-- ============================================================
-- 11. VERIFY FRAUD DISTRIBUTION
-- ============================================================

SELECT
    "isFraud",
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
GROUP BY "isFraud"
ORDER BY "isFraud";


-- ============================================================
-- 12. VERIFY IDENTITY COVERAGE
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE "identity_key" IS NOT NULL
    ) AS identity_linked,

    COUNT(*) FILTER (
        WHERE "identity_key" IS NULL
    ) AS identity_unlinked
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 13. VERIFY TRANSACTION AMOUNT
-- ============================================================

SELECT
    COUNT("TransactionAmt") AS transaction_amount_non_null_count,
    SUM("TransactionAmt") AS transaction_amount_sum,
    AVG("TransactionAmt") AS transaction_amount_average
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 14. FINAL STEP 6.3 ASSERTIONS
-- ============================================================

SELECT
    'fact_clean_row_count' AS test,
    CASE
        WHEN COUNT(*) = 590540
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    COUNT(*) AS actual_value,
    590540 AS expected_value
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_clean_row_count',
    CASE
        WHEN COUNT(*) = 144233
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*),
    144233
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'transaction_id_duplicates',
    CASE
        WHEN COUNT(*) - COUNT(DISTINCT "TransactionID") = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*) - COUNT(DISTINCT "TransactionID"),
    0
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_key_duplicates',
    CASE
        WHEN COUNT(*) - COUNT(DISTINCT "transaction_key") = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*) - COUNT(DISTINCT "transaction_key"),
    0
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_key_duplicates',
    CASE
        WHEN COUNT(*) - COUNT(DISTINCT "identity_key") = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*) - COUNT(DISTINCT "identity_key"),
    0
FROM analytics.dim_identity_clean

UNION ALL

SELECT
    'identity_linked',
    CASE
        WHEN COUNT(*) FILTER (
            WHERE "identity_key" IS NOT NULL
        ) = 144233
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*) FILTER (
        WHERE "identity_key" IS NOT NULL
    ),
    144233
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_unlinked',
    CASE
        WHEN COUNT(*) FILTER (
            WHERE "identity_key" IS NULL
        ) = 446307
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*) FILTER (
        WHERE "identity_key" IS NULL
    ),
    446307
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'fraud_zero',
    CASE
        WHEN COUNT(*) = 569877
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*),
    569877
FROM analytics.fact_transaction_clean
WHERE "isFraud" = 0

UNION ALL

SELECT
    'fraud_one',
    CASE
        WHEN COUNT(*) = 20663
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*),
    20663
FROM analytics.fact_transaction_clean
WHERE "isFraud" = 1

UNION ALL

SELECT
    'transaction_amount_sum',
    CASE
        WHEN SUM("TransactionAmt") = 79738948.735
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    SUM("TransactionAmt"),
    79738948.735
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_amount_average',
    CASE
        WHEN AVG("TransactionAmt") = 135.0271763724726521
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    AVG("TransactionAmt"),
    135.0271763724726521
FROM analytics.fact_transaction_clean;