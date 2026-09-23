-- PHASE 9 - STEP 9.9 - FRAUD COMPARISON
CREATE OR REPLACE VIEW analytics.vw_fraud_comparison AS
SELECT
    "isFraud",
    COUNT(*)::bigint AS transaction_count,
    SUM("TransactionAmt")::numeric AS total_amount,
    AVG("TransactionAmt")::numeric AS average_amount,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "TransactionAmt")::numeric AS median_amount,
    MIN("TransactionAmt")::numeric AS min_amount,
    MAX("TransactionAmt")::numeric AS max_amount
FROM analytics.vw_transaction_analytics
GROUP BY "isFraud";
