-- ============================================================
-- Phase 5 - ETL
-- Step 5.15-5.23 - Validate fact_transaction Load
-- ============================================================
-- Purpose:
--   Validate that analytics.fact_transaction was populated
--   correctly from staging.raw_transactions.
--
-- Expected source rows : 590,540
-- Expected target rows : 590,540
-- Expected identity-linked rows : 144,233
-- Expected identity-unlinked rows : 446,307
-- Expected duplicate TransactionID : 0
-- Expected NULL transaction_key : 0
-- ============================================================


-- ============================================================
-- 1. Source Row Count
-- ============================================================

SELECT
    'SOURCE_ROW_COUNT' AS validation,
    COUNT(*) AS row_count,
    CASE
        WHEN COUNT(*) = 590540 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM staging.raw_transactions;


-- ============================================================
-- 2. Target Row Count
-- ============================================================

SELECT
    'TARGET_ROW_COUNT' AS validation,
    COUNT(*) AS row_count,
    CASE
        WHEN COUNT(*) = 590540 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction;


-- ============================================================
-- 3. transaction_key NULL Validation
-- ============================================================

SELECT
    'TRANSACTION_KEY_NULL_CHECK' AS validation,
    COUNT(*) AS null_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction
WHERE transaction_key IS NULL;


-- ============================================================
-- 4. transaction_key Uniqueness Validation
-- ============================================================

SELECT
    'TRANSACTION_KEY_DUPLICATE_CHECK' AS validation,
    COUNT(*) - COUNT(DISTINCT transaction_key) AS duplicate_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT transaction_key)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction;


-- ============================================================
-- 5. TransactionID NULL Validation
-- ============================================================

SELECT
    'TRANSACTIONID_NULL_CHECK' AS validation,
    COUNT(*) AS null_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction
WHERE TransactionID IS NULL;


-- ============================================================
-- 6. TransactionID Uniqueness Validation
-- ============================================================

SELECT
    'TRANSACTIONID_DUPLICATE_CHECK' AS validation,
    COUNT(*) - COUNT(DISTINCT TransactionID) AS duplicate_count,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT TransactionID)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction;


-- ============================================================
-- 7. Source -> Fact TransactionID Reconciliation
-- ============================================================
-- Every staging transaction must exist in the fact table.

SELECT
    'SOURCE_TO_FACT_MISSING' AS validation,
    COUNT(*) AS missing_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM staging.raw_transactions s
LEFT JOIN analytics.fact_transaction f
    ON s.TransactionID = f.TransactionID
WHERE f.TransactionID IS NULL;


-- ============================================================
-- 8. Fact -> Source TransactionID Reconciliation
-- ============================================================
-- Every fact transaction must exist in staging.

SELECT
    'FACT_TO_SOURCE_MISSING' AS validation,
    COUNT(*) AS missing_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction f
LEFT JOIN staging.raw_transactions s
    ON f.TransactionID = s.TransactionID
WHERE s.TransactionID IS NULL;


-- ============================================================
-- 9. Source vs Fact TransactionID Count Reconciliation
-- ============================================================

SELECT
    s.source_count,
    f.fact_count,
    f.fact_count - s.source_count AS difference,
    CASE
        WHEN s.source_count = f.fact_count THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT COUNT(DISTINCT TransactionID) AS source_count
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT COUNT(DISTINCT TransactionID) AS fact_count
    FROM analytics.fact_transaction
) f;


-- ============================================================
-- 10. Identity Key Coverage in Fact
-- ============================================================
-- Identity data is optional for transactions.
-- Expected:
--   With identity    = 144,233
--   Without identity = 446,307

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(identity_key) AS rows_with_identity,
    COUNT(*) FILTER (WHERE identity_key IS NULL) AS rows_without_identity,
    CASE
        WHEN COUNT(*) = 590540
         AND COUNT(identity_key) = 144233
         AND COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction;


-- ============================================================
-- 11. Foreign Key Integrity Validation
-- ============================================================
-- Every non-null identity_key in the fact must exist
-- in dim_identity.

SELECT
    'FACT_IDENTITY_FK_CHECK' AS validation,
    COUNT(*) AS orphan_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM analytics.fact_transaction f
LEFT JOIN analytics.dim_identity d
    ON f.identity_key = d.identity_key
WHERE f.identity_key IS NOT NULL
  AND d.identity_key IS NULL;


-- ============================================================
-- 12. Identity Mapping Reconciliation
-- ============================================================
-- Compare fact identity linkage against source identity coverage.

SELECT
    source_identity_count,
    fact_identity_count,
    fact_identity_count - source_identity_count AS difference,
    CASE
        WHEN source_identity_count = fact_identity_count
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT COUNT(*) AS source_identity_count
    FROM staging.raw_transactions t
    INNER JOIN staging.raw_identity i
        ON t.TransactionID = i.TransactionID
) s
CROSS JOIN
(
    SELECT COUNT(*) AS fact_identity_count
    FROM analytics.fact_transaction
    WHERE identity_key IS NOT NULL
) f;


-- ============================================================
-- 13. isFraud Distribution Reconciliation
-- ============================================================

WITH source_counts AS
(
    SELECT
        isFraud,
        COUNT(*) AS source_count
    FROM staging.raw_transactions
    GROUP BY isFraud
),
fact_counts AS
(
    SELECT
        isFraud,
        COUNT(*) AS fact_count
    FROM analytics.fact_transaction
    GROUP BY isFraud
)
SELECT
    COALESCE(s.isFraud, f.isFraud) AS isFraud,
    COALESCE(s.source_count, 0) AS source_count,
    COALESCE(f.fact_count, 0) AS fact_count,
    COALESCE(f.fact_count, 0)
        - COALESCE(s.source_count, 0) AS difference,
    CASE
        WHEN COALESCE(s.source_count, 0)
           = COALESCE(f.fact_count, 0)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM source_counts s
FULL OUTER JOIN fact_counts f
    ON s.isFraud = f.isFraud
ORDER BY isFraud;


-- ============================================================
-- 14. TransactionAmt Count / SUM / AVG Reconciliation
-- ============================================================

SELECT
    s.amount_count AS source_amount_count,
    f.amount_count AS fact_amount_count,
    s.amount_sum AS source_amount_sum,
    f.amount_sum AS fact_amount_sum,
    s.amount_avg AS source_amount_avg,
    f.amount_avg AS fact_amount_avg,

    f.amount_count - s.amount_count AS count_difference,
    f.amount_sum - s.amount_sum AS sum_difference,
    f.amount_avg - s.amount_avg AS avg_difference,

    CASE
        WHEN s.amount_count = f.amount_count
         AND s.amount_sum = f.amount_sum
         AND s.amount_avg = f.amount_avg
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM
(
    SELECT
        COUNT(TransactionAmt) AS amount_count,
        SUM(TransactionAmt) AS amount_sum,
        AVG(TransactionAmt) AS amount_avg
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT
        COUNT(TransactionAmt) AS amount_count,
        SUM(TransactionAmt) AS amount_sum,
        AVG(TransactionAmt) AS amount_avg
    FROM analytics.fact_transaction
) f;


-- ============================================================
-- 15. TransactionDT Reconciliation
-- ============================================================

SELECT
    s.min_transactiondt AS source_min,
    f.min_transactiondt AS fact_min,
    s.max_transactiondt AS source_max,
    f.max_transactiondt AS fact_max,
    CASE
        WHEN s.min_transactiondt = f.min_transactiondt
         AND s.max_transactiondt = f.max_transactiondt
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT
        MIN(TransactionDT) AS min_transactiondt,
        MAX(TransactionDT) AS max_transactiondt
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT
        MIN(TransactionDT) AS min_transactiondt,
        MAX(TransactionDT) AS max_transactiondt
    FROM analytics.fact_transaction
) f;


-- ============================================================
-- 16. Selected NULL Preservation Validation
-- ============================================================
-- Validate that ETL did not unexpectedly convert NULLs
-- into non-NULL values for selected source fields.

SELECT
    'TransactionAmt' AS column_name,
    s.source_nulls,
    f.fact_nulls,
    f.fact_nulls - s.source_nulls AS difference,
    CASE
        WHEN s.source_nulls = f.fact_nulls THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
(
    SELECT COUNT(*) FILTER (WHERE TransactionAmt IS NULL) AS source_nulls
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT COUNT(*) FILTER (WHERE TransactionAmt IS NULL) AS fact_nulls
    FROM analytics.fact_transaction
) f

UNION ALL

SELECT
    'ProductCD',
    s.source_nulls,
    f.fact_nulls,
    f.fact_nulls - s.source_nulls,
    CASE
        WHEN s.source_nulls = f.fact_nulls THEN 'PASS'
        ELSE 'FAIL'
    END
FROM
(
    SELECT COUNT(*) FILTER (WHERE ProductCD IS NULL) AS source_nulls
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT COUNT(*) FILTER (WHERE ProductCD IS NULL) AS fact_nulls
    FROM analytics.fact_transaction
) f

UNION ALL

SELECT
    'card1',
    s.source_nulls,
    f.fact_nulls,
    f.fact_nulls - s.source_nulls,
    CASE
        WHEN s.source_nulls = f.fact_nulls THEN 'PASS'
        ELSE 'FAIL'
    END
FROM
(
    SELECT COUNT(*) FILTER (WHERE card1 IS NULL) AS source_nulls
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT COUNT(*) FILTER (WHERE card1 IS NULL) AS fact_nulls
    FROM analytics.fact_transaction
) f

UNION ALL

SELECT
    'P_emaildomain',
    s.source_nulls,
    f.fact_nulls,
    f.fact_nulls - s.source_nulls,
    CASE
        WHEN s.source_nulls = f.fact_nulls THEN 'PASS'
        ELSE 'FAIL'
    END
FROM
(
    SELECT COUNT(*) FILTER (WHERE P_emaildomain IS NULL) AS source_nulls
    FROM staging.raw_transactions
) s
CROSS JOIN
(
    SELECT COUNT(*) FILTER (WHERE P_emaildomain IS NULL) AS fact_nulls
    FROM analytics.fact_transaction
) f;


-- ============================================================
-- 17. Final Fact Validation Summary
-- ============================================================

SELECT
    COUNT(*) AS target_rows,
    COUNT(DISTINCT transaction_key) AS distinct_transaction_keys,
    COUNT(DISTINCT TransactionID) AS distinct_transaction_ids,
    COUNT(identity_key) AS rows_with_identity,
    COUNT(*) FILTER (WHERE identity_key IS NULL)
        AS rows_without_identity,
    COUNT(*) FILTER (WHERE transaction_key IS NULL)
        AS null_transaction_keys,
    COUNT(*) FILTER (WHERE TransactionID IS NULL)
        AS null_transaction_ids,

    CASE
        WHEN COUNT(*) = 590540
         AND COUNT(*) = COUNT(DISTINCT transaction_key)
         AND COUNT(*) = COUNT(DISTINCT TransactionID)
         AND COUNT(*) FILTER (WHERE transaction_key IS NULL) = 0
         AND COUNT(*) FILTER (WHERE TransactionID IS NULL) = 0
         AND COUNT(identity_key) = 144233
         AND COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307
        THEN 'PASS'
        ELSE 'FAIL'
    END AS overall_result

FROM analytics.fact_transaction;