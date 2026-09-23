-- PHASE 9 - STEP 9.14 - DETERMINISTIC RISK SIGNAL SUMMARY
CREATE OR REPLACE VIEW analytics.vw_risk_signal_summary AS
WITH signals AS (
    SELECT 'identity_unavailable'::text AS signal_name, (identity_available_flag=0)::integer AS signal_flag, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'email_domains_missing', email_domain_missing_flag, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'device_information_unavailable', (device_info_available_flag=0)::integer, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'partial_card_information_missing', card_attributes_partial_missing_flag, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'zero_transaction_amount', transaction_amount_zero_flag, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'high_missing_attribute_count', (missing_attribute_count >= 3)::integer, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
)
SELECT
    signal_name,
    COUNT(*) FILTER (WHERE signal_flag=1)::bigint AS flagged_transactions,
    COUNT(*) FILTER (WHERE signal_flag=1)::numeric / NULLIF(COUNT(*),0) AS flagged_percentage,
    COUNT(*) FILTER (WHERE signal_flag=1 AND "isFraud"=1)::bigint AS fraud_transactions,
    COUNT(*) FILTER (WHERE signal_flag=1 AND "isFraud"=1)::numeric / NULLIF(COUNT(*) FILTER (WHERE signal_flag=1),0) AS fraud_rate,
    SUM("TransactionAmt") FILTER (WHERE signal_flag=1)::numeric AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE signal_flag=1 AND "isFraud"=1)::numeric AS fraud_amount
FROM signals
GROUP BY signal_name;
