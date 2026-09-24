-- R07 - RULE-BASED SCORE. Heuristic additive prioritization, not probability.
CREATE OR REPLACE VIEW analytics.vw_risk_scoring AS
SELECT *,
       velocity_flag*2 + amount_anomaly_flag*2 + entity_device_anomaly_flag*2 + off_hours_risk_flag + impossible_travel_flag*3 AS risk_score,
       CASE WHEN velocity_flag*2 + amount_anomaly_flag*2 + entity_device_anomaly_flag*2 + off_hours_risk_flag + impossible_travel_flag*3 >= 5 THEN 'HIGH' WHEN velocity_flag*2 + amount_anomaly_flag*2 + entity_device_anomaly_flag*2 + off_hours_risk_flag + impossible_travel_flag*3 >= 2 THEN 'MEDIUM' ELSE 'LOW' END AS risk_band
FROM analytics.vw_composed_risk_signals;
