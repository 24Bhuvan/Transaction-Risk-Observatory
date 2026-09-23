-- PHASE 8 - STEP 8.5 - BEFORE PLANS
-- These six queries are identical to 09_explain_after.sql.

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*) AS result FROM analytics.fact_transaction_clean WHERE "isFraud" = 1;

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*), AVG("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "TransactionDT" BETWEEN 8000000 AND 10000000;

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*), AVG("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "TransactionAmt" >= 500;

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*) FROM analytics.fact_transaction_clean f JOIN analytics.dim_identity_clean d ON f.identity_key = d.identity_key WHERE f.identity_key IS NOT NULL;

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*), SUM("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "isFraud" = 1 AND "TransactionDT" BETWEEN 8000000 AND 10000000;

EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT COUNT(*), SUM("TransactionAmt") FROM analytics.fact_transaction_clean WHERE identity_key IS NOT NULL AND "isFraud" = 1;
