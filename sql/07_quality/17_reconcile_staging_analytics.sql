-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.17 — STAGING TO ANALYTICS RECONCILIATION
-- ============================================================
-- This script validates the lineage expected by the project.
-- It does not modify any data.
-- ============================================================

SELECT
    'staging_transaction_population' AS check_name,
    (SELECT COUNT(*) FROM staging.raw_transactions)::BIGINT AS expected_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction)::BIGINT AS actual_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction)::BIGINT - (SELECT COUNT(*) FROM staging.raw_transactions)::BIGINT AS difference,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction) = (SELECT COUNT(*) FROM staging.raw_transactions) THEN 'PASS' ELSE 'FAIL' END AS status

UNION ALL

SELECT
    'staging_identity_population',
    (SELECT COUNT(*) FROM staging.raw_identity)::BIGINT,
    (SELECT COUNT(*) FROM analytics.dim_identity)::BIGINT,
    (SELECT COUNT(*) FROM analytics.dim_identity)::BIGINT - (SELECT COUNT(*) FROM staging.raw_identity)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.dim_identity) = (SELECT COUNT(*) FROM staging.raw_identity) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'staging_transactionid_coverage',
    0,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_transactions
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x)::BIGINT,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_transactions
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_transactions
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x) = 0 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'staging_identity_transactionid_coverage',
    0,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_identity
        EXCEPT
        SELECT "TransactionID" FROM analytics.dim_identity
    ) x)::BIGINT,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_identity
        EXCEPT
        SELECT "TransactionID" FROM analytics.dim_identity
    ) x)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM staging.raw_identity
        EXCEPT
        SELECT "TransactionID" FROM analytics.dim_identity
    ) x) = 0 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fact_fraud_reconciliation',
    (SELECT COUNT(*) FROM staging.raw_transactions WHERE "isFraud" = 0)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0)::BIGINT - (SELECT COUNT(*) FROM staging.raw_transactions WHERE "isFraud" = 0)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0) = (SELECT COUNT(*) FROM staging.raw_transactions WHERE "isFraud" = 0) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fact_amount_sum_reconciliation',
    (SELECT SUM("TransactionAmt") FROM staging.raw_transactions)::NUMERIC,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC - (SELECT SUM("TransactionAmt") FROM staging.raw_transactions)::NUMERIC,
    CASE WHEN ABS((SELECT SUM("TransactionAmt") FROM analytics.fact_transaction) - (SELECT SUM("TransactionAmt") FROM staging.raw_transactions)) < 0.000000000001 THEN 'PASS' ELSE 'FAIL' END;
