-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.1 — FREEZE PHASE 5 BASELINE
-- ============================================================
-- Purpose:
--   Capture the validated Phase 5 analytical-layer baseline
--   before any Phase 6 transformation.
--
-- IMPORTANT:
--   READ-ONLY SCRIPT.
--   No INSERT / UPDATE / DELETE / ALTER / DROP.
--   Staging tables are not modified.
-- ============================================================


-- ============================================================
-- 1. FACT TRANSACTION ROW COUNT
-- ============================================================

SELECT
    'fact_transaction_row_count' AS metric,
    COUNT(*) AS value
FROM analytics.fact_transaction;


-- ============================================================
-- 2. DIM IDENTITY ROW COUNT
-- ============================================================

SELECT
    'dim_identity_row_count' AS metric,
    COUNT(*) AS value
FROM analytics.dim_identity;


-- ============================================================
-- 3. TRANSACTION KEY UNIQUENESS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids,
    COUNT(*) - COUNT(DISTINCT "TransactionID") AS transaction_id_duplicates
FROM analytics.fact_transaction;


-- ============================================================
-- 4. IDENTITY KEY UNIQUENESS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "identity_key") AS distinct_identity_keys,
    COUNT(*) - COUNT(DISTINCT "identity_key") AS identity_key_duplicates
FROM analytics.dim_identity;


-- ============================================================
-- 5. TRANSACTION KEY UNIQUENESS
-- ============================================================
-- transaction_key is the Phase 5 analytical surrogate key.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT "transaction_key") AS distinct_transaction_keys,
    COUNT(*) - COUNT(DISTINCT "transaction_key") AS transaction_key_duplicates
FROM analytics.fact_transaction;


-- ============================================================
-- 6. IDENTITY COVERAGE
-- ============================================================
-- A transaction is identity-linked when identity_key is present.

SELECT
    COUNT(*) FILTER (
        WHERE "identity_key" IS NOT NULL
    ) AS identity_linked,

    COUNT(*) FILTER (
        WHERE "identity_key" IS NULL
    ) AS identity_unlinked
FROM analytics.fact_transaction;


-- ============================================================
-- 7. FRAUD DISTRIBUTION
-- ============================================================

SELECT
    "isFraud",
    COUNT(*) AS row_count
FROM analytics.fact_transaction
GROUP BY "isFraud"
ORDER BY "isFraud";


-- ============================================================
-- 8. TRANSACTION AMOUNT RECONCILIATION
-- ============================================================

SELECT
    COUNT("TransactionAmt") AS transaction_amount_non_null_count,
    SUM("TransactionAmt") AS transaction_amount_sum,
    AVG("TransactionAmt") AS transaction_amount_average,
    MIN("TransactionAmt") AS transaction_amount_min,
    MAX("TransactionAmt") AS transaction_amount_max
FROM analytics.fact_transaction;


-- ============================================================
-- 9. NULL PROFILE — FACT TRANSACTION
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE "TransactionID" IS NULL
    ) AS transactionid_nulls,

    COUNT(*) FILTER (
        WHERE "TransactionDT" IS NULL
    ) AS transactiondt_nulls,

    COUNT(*) FILTER (
        WHERE "TransactionAmt" IS NULL
    ) AS transactionamt_nulls,

    COUNT(*) FILTER (
        WHERE "ProductCD" IS NULL
    ) AS productcd_nulls,

    COUNT(*) FILTER (
        WHERE "card2" IS NULL
    ) AS card2_nulls,

    COUNT(*) FILTER (
        WHERE "card3" IS NULL
    ) AS card3_nulls,

    COUNT(*) FILTER (
        WHERE "card4" IS NULL
    ) AS card4_nulls,

    COUNT(*) FILTER (
        WHERE "card5" IS NULL
    ) AS card5_nulls,

    COUNT(*) FILTER (
        WHERE "card6" IS NULL
    ) AS card6_nulls,

    COUNT(*) FILTER (
        WHERE "P_emaildomain" IS NULL
    ) AS p_emaildomain_nulls,

    COUNT(*) FILTER (
        WHERE "R_emaildomain" IS NULL
    ) AS r_emaildomain_nulls,

    COUNT(*) FILTER (
        WHERE "dist2" IS NULL
    ) AS dist2_nulls,

    COUNT(*) FILTER (
        WHERE "D7" IS NULL
    ) AS d7_nulls,

    COUNT(*) FILTER (
        WHERE "V1" IS NULL
    ) AS v1_nulls
FROM analytics.fact_transaction;


-- ============================================================
-- 10. NULL PROFILE — IDENTITY
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE "identity_key" IS NULL
    ) AS identity_key_nulls,

    COUNT(*) FILTER (
        WHERE "TransactionID" IS NULL
    ) AS transactionid_nulls,

    COUNT(*) FILTER (
        WHERE "DeviceType" IS NULL
    ) AS devicetype_nulls,

    COUNT(*) FILTER (
        WHERE "DeviceInfo" IS NULL
    ) AS deviceinfo_nulls
FROM analytics.dim_identity;


-- ============================================================
-- 11. FINAL BASELINE ASSERTIONS
-- ============================================================
-- Every test below must return PASS.


SELECT
    'fact_transaction_row_count' AS test,
    CASE
        WHEN COUNT(*) = 590540
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result,
    COUNT(*) AS actual_value,
    590540 AS expected_value
FROM analytics.fact_transaction

UNION ALL

SELECT
    'dim_identity_row_count',
    CASE
        WHEN COUNT(*) = 144233
        THEN 'PASS'
        ELSE 'FAIL'
    END,
    COUNT(*),
    144233
FROM analytics.dim_identity

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
FROM analytics.fact_transaction

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
FROM analytics.dim_identity

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
FROM analytics.fact_transaction

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
FROM analytics.fact_transaction

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
FROM analytics.fact_transaction

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
FROM analytics.fact_transaction
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
FROM analytics.fact_transaction
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
FROM analytics.fact_transaction

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
FROM analytics.fact_transaction;