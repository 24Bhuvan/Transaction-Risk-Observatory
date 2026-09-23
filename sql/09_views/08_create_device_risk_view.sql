-- PHASE 9 - STEP 9.11 - DEVICE ATTRIBUTE SUMMARY
CREATE OR REPLACE VIEW analytics.vw_device_risk AS
SELECT
    "DeviceType",
    "DeviceInfo",
    COUNT(*)::bigint AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::bigint AS fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=0)::bigint AS non_fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::numeric / NULLIF(COUNT(*),0) AS fraud_rate,
    SUM("TransactionAmt")::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS fraud_amount,
    AVG("TransactionAmt")::numeric AS average_transaction_amount
FROM analytics.vw_transaction_analytics
GROUP BY "DeviceType", "DeviceInfo";
