-- R02 - AMOUNT ANOMALY. Thresholds are data-derived, not fraud probabilities.
CREATE OR REPLACE VIEW analytics.vw_amount_anomalies AS
WITH global AS (SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY "TransactionAmt") AS p99 FROM analytics.vw_transaction_analytics),
entity AS (SELECT identity_key, AVG("TransactionAmt") AS entity_avg, STDDEV_SAMP("TransactionAmt") AS entity_stddev FROM analytics.vw_transaction_analytics WHERE identity_key IS NOT NULL GROUP BY identity_key)
SELECT t."TransactionID", t.transaction_key, t.identity_key, t."TransactionAmt", t."isFraud",
       e.entity_avg, e.entity_stddev, g.p99,
       CASE WHEN t."TransactionAmt" >= g.p99 OR (e.entity_stddev IS NOT NULL AND t."TransactionAmt" > e.entity_avg + 3*e.entity_stddev) THEN 1 ELSE 0 END AS amount_anomaly_flag,
       CASE WHEN t."TransactionAmt" >= g.p99 THEN 'at or above global 99th percentile' WHEN e.entity_stddev IS NOT NULL AND t."TransactionAmt" > e.entity_avg + 3*e.entity_stddev THEN 'above identity mean plus three standard deviations' ELSE NULL END AS amount_anomaly_reason
FROM analytics.vw_transaction_analytics t CROSS JOIN global g LEFT JOIN entity e ON e.identity_key=t.identity_key;
