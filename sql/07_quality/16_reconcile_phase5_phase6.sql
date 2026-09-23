-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.16 — PHASE 5 TO PHASE 6 RECONCILIATION
-- ============================================================

SELECT
    'phase5_fact_row_count' AS check_name,
    (SELECT COUNT(*) FROM analytics.fact_transaction)::BIGINT AS expected_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean)::BIGINT AS actual_value,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction)::BIGINT AS difference,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean) = (SELECT COUNT(*) FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END AS status

UNION ALL

SELECT
    'phase5_identity_row_count',
    (SELECT COUNT(*) FROM analytics.dim_identity)::BIGINT,
    (SELECT COUNT(*) FROM analytics.dim_identity_clean)::BIGINT,
    (SELECT COUNT(*) FROM analytics.dim_identity_clean)::BIGINT - (SELECT COUNT(*) FROM analytics.dim_identity)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.dim_identity_clean) = (SELECT COUNT(*) FROM analytics.dim_identity) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fact_transactionid_excluding_phase5',
    0,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x)::BIGINT,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction
    ) x) = 0 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'phase5_transactionid_excluding_clean',
    0,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
    ) x)::BIGINT,
    (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
    ) x)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM (
        SELECT "TransactionID" FROM analytics.fact_transaction
        EXCEPT
        SELECT "TransactionID" FROM analytics.fact_transaction_clean
    ) x) = 0 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fact_unchanged_fields_mismatch',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE p.transaction_key IS DISTINCT FROM c.transaction_key
   OR p.identity_key IS DISTINCT FROM c.identity_key
   OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
   OR p."isFraud" IS DISTINCT FROM c."isFraud"
   OR p."TransactionDT" IS DISTINCT FROM c."TransactionDT"
   OR p."TransactionAmt" IS DISTINCT FROM c."TransactionAmt"

UNION ALL

SELECT
    'identity_unchanged_fields_mismatch',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity p
JOIN analytics.dim_identity_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE p.identity_key IS DISTINCT FROM c.identity_key
   OR p."TransactionID" IS DISTINCT FROM c."TransactionID"

UNION ALL

SELECT
    'transaction_amount_sum_reconciliation',
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC - (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    CASE WHEN ABS((SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean) - (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)) < 0.000000000001 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_avg_reconciliation',
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC,
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC - (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    CASE WHEN ABS((SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean) - (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)) < 0.000000000001 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fraud_zero_reconciliation',
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 0)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 0)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 0) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 0) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'fraud_one_reconciliation',
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 1)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 1)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 1)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 1)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" = 1) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "isFraud" = 1) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'identity_relationship_reconciliation',
    (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction)::BIGINT,
    (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction_clean)::BIGINT,
    (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction_clean)::BIGINT - (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction_clean) = (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END;
