-- R06 - MULTI-SIGNAL COMPOSITION. Signals are descriptive, not proof of fraud.
CREATE OR REPLACE VIEW analytics.vw_composed_risk_signals AS
SELECT t."TransactionID", t.transaction_key, t.identity_key, t."isFraud", t."TransactionAmt", t."TransactionDT",
 v.velocity_flag, a.amount_anomaly_flag, e.entity_device_anomaly_flag, o.off_hours_risk_flag, g.impossible_travel_flag,
 (v.velocity_flag+a.amount_anomaly_flag+e.entity_device_anomaly_flag+o.off_hours_risk_flag+g.impossible_travel_flag) AS signal_count,
 CASE WHEN (v.velocity_flag+a.amount_anomaly_flag+e.entity_device_anomaly_flag+o.off_hours_risk_flag+g.impossible_travel_flag) >= 2 THEN 1 ELSE 0 END AS multiple_signal_flag
FROM analytics.vw_transaction_analytics t JOIN analytics.vw_velocity_analysis v USING ("TransactionID") JOIN analytics.vw_amount_anomalies a USING ("TransactionID") JOIN analytics.vw_entity_device_anomalies e USING ("TransactionID") JOIN analytics.vw_off_hours_analysis o USING ("TransactionID") JOIN analytics.vw_geographic_anomalies g USING ("TransactionID");
