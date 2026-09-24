-- R03 - ENTITY/DEVICE ANOMALY. DeviceInfo is an attribute, not a canonical device identity.
CREATE OR REPLACE VIEW analytics.vw_entity_device_anomalies AS
WITH device_stats AS (
 SELECT deviceinfo_normalized, COUNT(*) AS transaction_count, COUNT(DISTINCT identity_key) FILTER (WHERE identity_key IS NOT NULL) AS identity_count,
        COUNT(*) FILTER (WHERE "isFraud"=1) AS fraud_count
 FROM analytics.vw_transaction_analytics WHERE NULLIF(deviceinfo_normalized,'') IS NOT NULL GROUP BY deviceinfo_normalized
), identity_stats AS (
 SELECT AVG(identity_count) AS avg_identity_count, STDDEV_SAMP(identity_count) AS sd_identity_count FROM device_stats
)
SELECT t."TransactionID", t.transaction_key, t.identity_key, t.deviceinfo_normalized, t."isFraud", s.transaction_count AS device_transaction_count, s.identity_count AS device_identity_count, s.fraud_count AS device_fraud_count,
 CASE WHEN s.identity_count > 1 OR (i.sd_identity_count IS NOT NULL AND s.identity_count > i.avg_identity_count + 2*i.sd_identity_count) THEN 1 ELSE 0 END AS entity_device_anomaly_flag,
 CASE WHEN s.identity_count > 1 THEN 'device attribute observed across multiple identities' ELSE NULL END AS entity_device_anomaly_reason
FROM analytics.vw_transaction_analytics t LEFT JOIN device_stats s ON s.deviceinfo_normalized=t.deviceinfo_normalized CROSS JOIN identity_stats i;
