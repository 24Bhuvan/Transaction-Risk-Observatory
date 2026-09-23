-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.11 — VALIDATE TRANSACTION AMOUNT
-- ============================================================

SELECT
    'transaction_amount_row_count' AS check_name,
    COUNT(*)::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    0::BIGINT AS difference,
    'PASS' AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_amount_sum',
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::BIGINT,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean)::BIGINT,
    (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean)::BIGINT - (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction)::BIGINT,
    CASE WHEN (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction_clean) = (SELECT SUM("TransactionAmt") FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_avg',
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC,
    (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC - (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    CASE WHEN ABS((SELECT AVG("TransactionAmt") FROM analytics.fact_transaction_clean) - (SELECT AVG("TransactionAmt") FROM analytics.fact_transaction)) < 0.000000000001 THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_non_null_count',
    (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction)::BIGINT,
    (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction_clean)::BIGINT,
    (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction_clean)::BIGINT - (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction)::BIGINT,
    CASE WHEN (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction_clean) = (SELECT COUNT("TransactionAmt") FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_min',
    (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC,
    (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC - (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    CASE WHEN (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction_clean) = (SELECT MIN("TransactionAmt") FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_max',
    (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC,
    (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction_clean)::NUMERIC - (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction)::NUMERIC,
    CASE WHEN (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction_clean) = (SELECT MAX("TransactionAmt") FROM analytics.fact_transaction) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'transaction_amount_null_count',
    (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL)::BIGINT,
    (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL)::BIGINT - (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL)::BIGINT,
    CASE WHEN (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" IS NULL) = (SELECT COUNT(*) FROM analytics.fact_transaction WHERE "TransactionAmt" IS NULL) THEN 'PASS' ELSE 'FAIL' END

UNION ALL

SELECT
    'negative_amount_count',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "TransactionAmt" < 0

UNION ALL

SELECT
    'zero_amount_count',
    0::BIGINT,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE "TransactionAmt" = 0

UNION ALL

SELECT
    'transaction_amount_zero_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE transaction_amount_zero_flag <> CASE WHEN "TransactionAmt" = 0 THEN 1 ELSE 0 END

UNION ALL

SELECT
    'transaction_amount_log_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.fact_transaction_clean
WHERE ABS(transaction_amount_log - LN("TransactionAmt" + 1)) > 0.000000000001;
