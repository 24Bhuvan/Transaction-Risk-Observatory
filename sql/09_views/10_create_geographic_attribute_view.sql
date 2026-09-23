-- PHASE 9 - STEP 9.13 - ADDRESS-RELATED ATTRIBUTE SUMMARY
-- addr/dist fields are anonymized source attributes, not geographic coordinates.
CREATE OR REPLACE VIEW analytics.vw_geographic_attribute_risk AS
SELECT
    addr1,
    addr2,
    dist1,
    dist2,
    COUNT(*)::bigint AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::bigint AS fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=0)::bigint AS non_fraud_count,
    COUNT(*) FILTER (WHERE "isFraud"=1)::numeric / NULLIF(COUNT(*),0) AS fraud_rate,
    SUM("TransactionAmt")::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud"=1)::numeric AS fraud_amount
FROM analytics.vw_transaction_analytics
GROUP BY addr1, addr2, dist1, dist2;
