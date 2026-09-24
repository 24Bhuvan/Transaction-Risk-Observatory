-- PHASE 10 VALIDATION
SELECT 'source_rows' AS check_name, 590540 AS expected_value, COUNT(*) AS actual_value, CASE WHEN COUNT(*)=590540 THEN 'PASS' ELSE 'FAIL' END AS status FROM analytics.vw_risk_scoring
UNION ALL SELECT 'unique_transactions', 590540, COUNT(DISTINCT "TransactionID"), CASE WHEN COUNT(DISTINCT "TransactionID")=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_risk_scoring
UNION ALL SELECT 'velocity_flags_binary', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_velocity_analysis WHERE velocity_flag NOT IN (0,1)
UNION ALL SELECT 'amount_flags_binary', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_amount_anomalies WHERE amount_anomaly_flag NOT IN (0,1)
UNION ALL SELECT 'entity_flags_binary', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_entity_device_anomalies WHERE entity_device_anomaly_flag NOT IN (0,1)
UNION ALL SELECT 'off_hours_flags_binary', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_off_hours_analysis WHERE off_hours_risk_flag NOT IN (0,1)
UNION ALL SELECT 'geographic_flags_binary', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_geographic_anomalies WHERE impossible_travel_flag NOT IN (0,1)
UNION ALL SELECT 'scores_nonnegative', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_risk_scoring WHERE risk_score < 0
UNION ALL SELECT 'valid_risk_bands', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_risk_scoring WHERE risk_band NOT IN ('LOW','MEDIUM','HIGH')
UNION ALL SELECT 'no_duplicate_suspicious_transactions', 0, COUNT(*)-COUNT(DISTINCT "TransactionID"), CASE WHEN COUNT(*)=COUNT(DISTINCT "TransactionID") THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_suspicious_transactions;

SELECT 'geography_limitation' AS check_name, COUNT(*) AS transaction_rows_without_coordinate_analysis FROM analytics.vw_geographic_anomalies WHERE impossible_travel_flag=0;
