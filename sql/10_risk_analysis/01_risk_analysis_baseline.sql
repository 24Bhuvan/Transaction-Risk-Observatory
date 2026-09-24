-- PHASE 10 - STEP 10.1 - BASELINE AND SOURCE MAPPING
SELECT 'analytics.vw_transaction_analytics' AS source_object, COUNT(*) AS rows, COUNT(DISTINCT "TransactionID") AS distinct_transactions, COUNT(*) FILTER (WHERE "isFraud"=1) AS fraud_rows, MIN("TransactionDT") AS min_transactiondt, MAX("TransactionDT") AS max_transactiondt, SUM("TransactionAmt") AS amount_sum FROM analytics.vw_transaction_analytics;
SELECT COUNT(DISTINCT identity_key) FILTER (WHERE identity_key IS NOT NULL) AS identities, COUNT(DISTINCT NULLIF(deviceinfo_normalized,'')) AS devices, COUNT(DISTINCT card4) AS card4_values, COUNT(DISTINCT card6) AS card6_values, COUNT(DISTINCT "P_emaildomain") AS purchaser_email_domains, COUNT(DISTINCT "R_emaildomain") AS recipient_email_domains FROM analytics.vw_transaction_analytics;
SELECT 'R01 velocity' AS rule_id, 'identity_key + TransactionDT' AS source_fields, 'LAG and RANGE 86400-second window' AS technique, 'analytics.vw_velocity_analysis' AS output
UNION ALL SELECT 'R02 amount anomaly', 'TransactionAmt + identity baseline', 'PERCENTILE_CONT and entity aggregates', 'analytics.vw_amount_anomalies'
UNION ALL SELECT 'R03 entity/device anomaly', 'identity_key + deviceinfo_normalized', 'conditional aggregation', 'analytics.vw_entity_device_anomalies'
UNION ALL SELECT 'R04 off-hours', 'transaction_hour + TransactionDT', 'relative-hour rule', 'analytics.vw_off_hours_analysis'
UNION ALL SELECT 'R05 geographic anomaly', 'addr1/addr2/dist1/dist2 only', 'capability assessment; no coordinates', 'analytics.vw_geographic_anomalies'
UNION ALL SELECT 'R06 multi-signal', 'R01-R05 flags', 'CTE composition', 'analytics.vw_composed_risk_signals'
UNION ALL SELECT 'R07 rule score', 'composed flags', 'transparent additive score', 'analytics.vw_risk_scoring';
