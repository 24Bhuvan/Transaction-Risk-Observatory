-- PHASE 9 - STEP 9.8 - WEEKLY FRAUD SUMMARY
CREATE OR REPLACE VIEW analytics.vw_weekly_fraud_summary AS
SELECT
    transaction_week_number,
    COUNT(*)::bigint AS total_transactions,
    COUNT(*) FILTER (WHERE "isFraud"=1)::bigint AS fraud_transactions,
    COUNT(*) FILTER (WHERE "isFraud"=0)::bigint AS non_fraud_transactions,
    COUNT(*) FILTER (WHERE "isFraud"=1)::numeric / NULLIF(COUNT(*),0) AS fraud_rate,
    SUM("TransactionAmt")::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS fraud_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=0)::numeric AS non_fraud_amount,
    AVG("TransactionAmt")::numeric AS average_transaction_amount,
    AVG("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS average_fraud_amount
FROM analytics.vw_transaction_analytics
GROUP BY transaction_week_number;
