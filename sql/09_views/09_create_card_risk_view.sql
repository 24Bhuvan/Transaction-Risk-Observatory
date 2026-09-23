-- PHASE 9 - STEP 9.12 - CARD ATTRIBUTE SUMMARY
CREATE OR REPLACE VIEW analytics.vw_card_risk AS
SELECT
    card4,
    card6,
    COUNT(*)::bigint AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::bigint AS fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=0)::bigint AS non_fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::numeric / NULLIF(COUNT(*),0) AS fraud_rate,
    SUM("TransactionAmt")::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS fraud_amount
FROM analytics.vw_transaction_analytics
GROUP BY card4, card6;
