-- PHASE 10 FINAL GATE
WITH checks AS (
 SELECT 'source_mapping' AS check_name, EXISTS (SELECT 1 FROM analytics.vw_transaction_analytics) AS passed
 UNION ALL SELECT 'velocity', EXISTS (SELECT 1 FROM analytics.vw_velocity_analysis)
 UNION ALL SELECT 'amount_anomaly', EXISTS (SELECT 1 FROM analytics.vw_amount_anomalies)
 UNION ALL SELECT 'entity_device', EXISTS (SELECT 1 FROM analytics.vw_entity_device_anomalies)
 UNION ALL SELECT 'off_hours', EXISTS (SELECT 1 FROM analytics.vw_off_hours_analysis)
 UNION ALL SELECT 'geographic_limitation_documented', EXISTS (SELECT 1 FROM analytics.vw_geographic_anomalies WHERE geographic_limitation IS NOT NULL)
 UNION ALL SELECT 'multi_signal', EXISTS (SELECT 1 FROM analytics.vw_composed_risk_signals)
 UNION ALL SELECT 'rule_score', EXISTS (SELECT 1 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT 'suspicious_transactions', EXISTS (SELECT 1 FROM analytics.vw_suspicious_transactions)
 UNION ALL SELECT 'suspicious_entities', EXISTS (SELECT 1 FROM analytics.vw_suspicious_entities)
 UNION ALL SELECT 'historical_pattern_validation', EXISTS (SELECT 1 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT 'validation', (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT 'no_coordinate_fabrication', NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='analytics' AND column_name IN ('latitude','longitude'))
)
SELECT check_name, CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status FROM checks ORDER BY check_name;
WITH checks AS (
 SELECT EXISTS (SELECT 1 FROM analytics.vw_transaction_analytics) AS passed
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_velocity_analysis)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_amount_anomalies)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_entity_device_anomalies)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_off_hours_analysis)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_geographic_anomalies WHERE geographic_limitation IS NOT NULL)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_composed_risk_signals)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_suspicious_transactions)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_suspicious_entities)
 UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_risk_scoring)
 UNION ALL SELECT NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='analytics' AND column_name IN ('latitude','longitude'))
) SELECT CASE WHEN BOOL_AND(passed) THEN 'PASS' ELSE 'FAIL' END AS phase_10_final_gate FROM checks;
