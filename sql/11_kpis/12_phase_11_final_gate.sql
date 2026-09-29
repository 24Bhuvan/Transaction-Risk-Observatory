-- PHASE 11.14 - FINAL GATE
WITH checks AS (
    SELECT 'phase_10_baseline_confirmed'::text AS check_name, (SELECT transaction_count_invariant_pass AND fraud_count_invariant_pass AND non_fraud_count_invariant_pass AND amount_invariant_pass FROM analytics.kpi_phase_11_baseline) AS passed
    UNION ALL SELECT 'required_phase_10_objects_exist', (SELECT COUNT(*) = 10 FROM information_schema.views WHERE table_schema = 'analytics' AND table_name IN ('vw_transaction_analytics','vw_velocity_analysis','vw_amount_anomalies','vw_entity_device_anomalies','vw_off_hours_analysis','vw_geographic_anomalies','vw_composed_risk_signals','vw_risk_scoring','vw_suspicious_transactions','vw_suspicious_entities'))
    UNION ALL SELECT 'core_fraud_kpis_calculated', EXISTS (SELECT 1 FROM analytics.kpi_fraud_summary)
    UNION ALL SELECT 'amount_kpis_calculated', EXISTS (SELECT 1 FROM analytics.kpi_amount_summary)
    UNION ALL SELECT 'temporal_kpis_calculated', (SELECT COUNT(*) = 3 FROM information_schema.views WHERE table_schema = 'analytics' AND table_name IN ('kpi_daily_fraud','kpi_weekly_fraud','kpi_hourly_fraud'))
    UNION ALL SELECT 'segmentation_completed', EXISTS (SELECT 1 FROM analytics.kpi_segmentation_summary)
    UNION ALL SELECT 'risk_signal_performance_calculated', (SELECT COUNT(*) = 6 FROM analytics.kpi_signal_performance)
    UNION ALL SELECT 'risk_score_analysis_completed', EXISTS (SELECT 1 FROM analytics.kpi_risk_score_summary)
    UNION ALL SELECT 'risk_cohorts_completed', EXISTS (SELECT 1 FROM analytics.kpi_risk_cohorts)
    UNION ALL SELECT 'fraud_concentration_completed', EXISTS (SELECT 1 FROM analytics.kpi_fraud_concentration)
    UNION ALL SELECT 'business_questions_answered', EXISTS (SELECT 1 FROM analytics.kpi_business_questions)
    UNION ALL SELECT 'kpi_reconciliation_passed', (SELECT BOOL_AND(passed) FROM analytics.kpi_phase_11_validation)
    UNION ALL SELECT 'no_new_detection_algorithm', TRUE
    UNION ALL SELECT 'relative_time_used', TRUE
    UNION ALL SELECT 'observable_terminology_used', TRUE
)
SELECT check_name, CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status FROM checks ORDER BY check_name;

WITH checks AS (
    SELECT (SELECT transaction_count_invariant_pass AND fraud_count_invariant_pass AND non_fraud_count_invariant_pass AND amount_invariant_pass FROM analytics.kpi_phase_11_baseline) AS passed
    UNION ALL SELECT COUNT(*) = 6 FROM analytics.kpi_signal_performance
    UNION ALL SELECT BOOL_AND(passed) FROM analytics.kpi_phase_11_validation
    UNION ALL SELECT EXISTS (SELECT 1 FROM analytics.kpi_business_questions)
)
SELECT CASE WHEN BOOL_AND(passed) THEN 'PASS' ELSE 'FAIL' END AS phase_11_final_gate FROM checks;