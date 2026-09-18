-- Phase 2.20 — Staging Ingestion Validation
-- Reusable validation queries for the PostgreSQL staging layer.
-- These checks validate ingestion only; they do not clean or transform data.


-- ==========================================
-- 1. Row Count Validation
-- ==========================================

SELECT
    590540 AS expected_transaction_rows,
    COUNT(*) AS actual_transaction_rows,
    590540 - COUNT(*) AS transaction_difference
FROM staging.raw_transactions;


SELECT
    144233 AS expected_identity_rows,
    COUNT(*) AS actual_identity_rows,
    144233 - COUNT(*) AS identity_difference
FROM staging.raw_identity;


-- ==========================================
-- 2. Column Validation
-- ==========================================

SELECT
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
GROUP BY table_name
ORDER BY table_name;


-- ==========================================
-- 3. TransactionID Validation
-- ==========================================

SELECT
    'raw_transactions' AS table_name,
    COUNT(*) AS total_rows,
    COUNT("TransactionID") AS non_null_transaction_ids,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids
FROM staging.raw_transactions;


SELECT
    'raw_identity' AS table_name,
    COUNT(*) AS total_rows,
    COUNT("TransactionID") AS non_null_transaction_ids,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids
FROM staging.raw_identity;


-- ==========================================
-- 4. NULL / Load Validation
-- ==========================================

SELECT
    'raw_transactions' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE "TransactionID" IS NULL
    ) AS null_transaction_id
FROM staging.raw_transactions;


SELECT
    'raw_identity' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE "TransactionID" IS NULL
    ) AS null_transaction_id
FROM staging.raw_identity;


-- ==========================================
-- 5. Target Label Validation
-- ==========================================

SELECT
    "isFraud",
    COUNT(*) AS transaction_count
FROM staging.raw_transactions
GROUP BY "isFraud"
ORDER BY "isFraud";


-- ==========================================
-- 6. Sample Inspection
-- ==========================================

SELECT *
FROM staging.raw_transactions
WHERE "TransactionID" BETWEEN 2987000 AND 2987004
ORDER BY "TransactionID";


SELECT *
FROM staging.raw_identity
WHERE "TransactionID" IN (
    2987004,
    2987008,
    2987010,
    2987011,
    2987016
)
ORDER BY "TransactionID";