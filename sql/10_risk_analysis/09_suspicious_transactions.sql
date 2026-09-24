-- R08 - SUSPICIOUS TRANSACTIONS. Review prioritization only.
CREATE OR REPLACE VIEW analytics.vw_suspicious_transactions AS
SELECT *, concat_ws('; ', CASE WHEN velocity_flag=1 THEN 'velocity' END, CASE WHEN amount_anomaly_flag=1 THEN 'amount anomaly' END, CASE WHEN entity_device_anomaly_flag=1 THEN 'entity/device anomaly' END, CASE WHEN off_hours_risk_flag=1 THEN 'off-hours' END, CASE WHEN impossible_travel_flag=1 THEN 'impossible travel' END) AS risk_reason
FROM analytics.vw_risk_scoring WHERE risk_score >= 2;
