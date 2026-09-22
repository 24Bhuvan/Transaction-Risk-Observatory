-- ============================================================
-- Phase 5 - ETL
-- Step 5.8 / 5.9 - Validate dim_identity Load
-- ============================================================
-- Purpose:
--   Validate that analytics.dim_identity was populated correctly
--   from staging.raw_identity.
--
-- Expected source rows : 144,233
-- Expected target rows : 144,233
-- Expected duplicate TransactionID : 0
-- Expected NULL identity_key : 0
-- ============================================================


-- ============================================================
-- 1. Row Count Validation
-- ============================================================

SELECT
    'SOURCE_ROW_COUNT' AS validation,
    COUNT(*) AS row_count,
    CASE
        WHEN COUNT(*) = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM staging.raw_identity

UNION ALL

SELECT
    'TARGET_ROW_COUNT' AS validation,
    COUNT(*) AS row_count,
    CASE
        WHEN COUNT(*) = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity;


-- ============================================================
-- 2. identity_key NULL Validation
-- ============================================================

SELECT
    'IDENTITY_KEY_NULL_CHECK' AS validation,
    COUNT(*) AS null_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity
WHERE identity_key IS NULL;


-- ============================================================
-- 3. identity_key Uniqueness Validation
-- ============================================================

SELECT
    'IDENTITY_KEY_DUPLICATE_CHECK' AS validation,
    COUNT(*) - COUNT(DISTINCT identity_key) AS duplicate_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT identity_key) THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity;


-- ============================================================
-- 4. TransactionID NULL Validation
-- ============================================================

SELECT
    'TRANSACTIONID_NULL_CHECK' AS validation,
    COUNT(*) AS null_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity
WHERE TransactionID IS NULL;


-- ============================================================
-- 5. TransactionID Uniqueness Validation
-- ============================================================

SELECT
    'TRANSACTIONID_DUPLICATE_CHECK' AS validation,
    COUNT(*) - COUNT(DISTINCT TransactionID) AS duplicate_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT TransactionID) THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity;


-- ============================================================
-- 6. Source -> Dimension Mapping Validation
-- ============================================================
-- Every source TransactionID must exist in the dimension.

SELECT
    'SOURCE_TO_DIM_MISSING' AS validation,
    COUNT(*) AS missing_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM staging.raw_identity s
LEFT JOIN analytics.dim_identity d
    ON s.TransactionID = d.TransactionID
WHERE d.TransactionID IS NULL;


-- ============================================================
-- 7. Dimension -> Source Mapping Validation
-- ============================================================
-- Every dimension TransactionID must exist in the source.

SELECT
    'DIM_TO_SOURCE_MISSING' AS validation,
    COUNT(*) AS missing_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.dim_identity d
LEFT JOIN staging.raw_identity s
    ON d.TransactionID = s.TransactionID
WHERE s.TransactionID IS NULL;


-- ============================================================
-- 8. Source and Target Distinct TransactionID Reconciliation
-- ============================================================

SELECT
    s.source_distinct_transactionid,
    d.target_distinct_transactionid,
    CASE
        WHEN s.source_distinct_transactionid =
             d.target_distinct_transactionid
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT COUNT(DISTINCT TransactionID) AS source_distinct_transactionid
    FROM staging.raw_identity
) s
CROSS JOIN
(
    SELECT COUNT(DISTINCT TransactionID) AS target_distinct_transactionid
    FROM analytics.dim_identity
) d;


-- ============================================================
-- 9. Source vs Target Row Count Reconciliation
-- ============================================================

SELECT
    s.source_count,
    d.target_count,
    d.target_count - s.source_count AS difference,
    CASE
        WHEN s.source_count = d.target_count THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT COUNT(*) AS source_count
    FROM staging.raw_identity
) s
CROSS JOIN
(
    SELECT COUNT(*) AS target_count
    FROM analytics.dim_identity
) d;


-- ============================================================
-- 10. Final Dimension Validation Summary
-- ============================================================

SELECT
    COUNT(*) AS target_rows,
    COUNT(DISTINCT identity_key) AS distinct_identity_keys,
    COUNT(DISTINCT TransactionID) AS distinct_transaction_ids,
    COUNT(*) FILTER (WHERE identity_key IS NULL) AS null_identity_keys,
    COUNT(*) FILTER (WHERE TransactionID IS NULL) AS null_transaction_ids,
    CASE
        WHEN COUNT(*) = 144233
         AND COUNT(*) = COUNT(DISTINCT identity_key)
         AND COUNT(*) = COUNT(DISTINCT TransactionID)
         AND COUNT(*) FILTER (WHERE identity_key IS NULL) = 0
         AND COUNT(*) FILTER (WHERE TransactionID IS NULL) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS overall_result
FROM analytics.dim_identity;