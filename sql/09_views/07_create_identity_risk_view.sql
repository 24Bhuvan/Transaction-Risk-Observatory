-- PHASE 9 - STEP 9.10 - IDENTITY RISK SUMMARY
CREATE OR REPLACE VIEW analytics.vw_identity_risk AS
SELECT
    identity_key,
    COUNT(*)::bigint AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::bigint AS fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=0)::bigint AS non_fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::numeric / NULLIF(COUNT(*),0) AS fraud_rate,
    SUM("TransactionAmt")::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS fraud_amount,
    AVG("TransactionAmt")::numeric AS average_amount
FROM analytics.vw_transaction_analytics
WHERE identity_key IS NOT NULL
GROUP BY identity_key;
