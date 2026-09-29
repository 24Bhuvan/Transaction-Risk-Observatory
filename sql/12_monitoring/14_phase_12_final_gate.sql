-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 14: PHASE 12 FINAL GATE VALIDATION
-- ============================================================================
-- Purpose:
--   Comprehensive final validation gate for Phase 12. Validates existence and
--   functionality of all Phase 12 database structures, invariants, and monitoring
--   outcomes without hardcoded pass flags.
-- ============================================================================

WITH gate_checks AS (
    -- 1. Schema Existence
    SELECT
        '01_monitoring_schema_exists'::TEXT AS check_name,
        EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'monitoring') AS passed,
        'monitoring schema is registered in database'::TEXT AS details

    UNION ALL
    -- 2. Baseline Table & Content
    SELECT
        '02_monitoring_baseline_populated',
        (SELECT COUNT(*) >= 25 FROM monitoring.monitoring_baseline),
        'monitoring.monitoring_baseline contains authoritative metrics'

    UNION ALL
    -- 3. Schema Monitoring View
    SELECT
        '03_schema_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_schema_monitoring'),
        'monitoring.vw_schema_monitoring is queryable'

    UNION ALL
    -- 4. Population Monitoring View
    SELECT
        '04_population_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_population_monitoring'),
        'monitoring.vw_population_monitoring is queryable'

    UNION ALL
    -- 5. Duplicate Monitoring View
    SELECT
        '05_duplicate_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_duplicate_monitoring'),
        'monitoring.vw_duplicate_monitoring is queryable'

    UNION ALL
    -- 6. NULL Monitoring View
    SELECT
        '06_null_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_null_monitoring'),
        'monitoring.vw_null_monitoring is queryable'

    UNION ALL
    -- 7. Referential Integrity View
    SELECT
        '07_referential_integrity_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_referential_integrity_monitoring'),
        'monitoring.vw_referential_integrity_monitoring is queryable'

    UNION ALL
    -- 8. Business Rule Monitoring View
    SELECT
        '08_business_rule_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_business_rule_monitoring'),
        'monitoring.vw_business_rule_monitoring is queryable'

    UNION ALL
    -- 9. Distribution Monitoring View & Snapshot Table
    SELECT
        '09_distribution_monitoring_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_distribution_monitoring')
        AND EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'monitoring' AND table_name = 'distribution_snapshot'),
        'distribution monitoring view and snapshot table are active'

    UNION ALL
    -- 10. Fraud Rate Monitoring View
    SELECT
        '10_fraud_rate_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_fraud_rate_monitoring'),
        'monitoring.vw_fraud_rate_monitoring is queryable'

    UNION ALL
    -- 11. Risk Signal Monitoring View
    SELECT
        '11_risk_signal_monitoring_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_risk_signal_monitoring'),
        'monitoring.vw_risk_signal_monitoring is queryable'

    UNION ALL
    -- 12. Anomaly Alert Rules View
    SELECT
        '12_anomaly_alert_rules_view_exists',
        EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_anomaly_alert_rules'),
        'monitoring.vw_anomaly_alert_rules is queryable'

    UNION ALL
    -- 13. Persistent Monitoring Results Table
    SELECT
        '13_monitoring_results_table_exists',
        EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'monitoring' AND table_name = 'monitoring_results'),
        'monitoring.monitoring_results table is active'

    UNION ALL
    -- 14. Monitoring Execution Records Exist
    SELECT
        '14_monitoring_runs_recorded',
        (SELECT COUNT(*) > 0 FROM monitoring.monitoring_results),
        'monitoring audit log contains recorded runs'

    UNION ALL
    -- 15. Zero Critical Invariant Failures
    SELECT
        '15_zero_critical_failures',
        (SELECT COUNT(*) = 0 FROM monitoring.vw_anomaly_alert_rules WHERE severity = 'CRITICAL' AND status = 'FAIL'),
        'No critical invariant failures detected across data-quality checks'
)
SELECT
    check_name,
    CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status,
    details
FROM gate_checks
ORDER BY check_name;

-- Final Derived Verdict
WITH gate_summary AS (
    SELECT
        COUNT(*) AS total_gate_checks,
        COUNT(*) FILTER (WHERE passed) AS passed_gate_checks,
        BOOL_AND(passed) AS all_passed
    FROM (
        SELECT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'monitoring') AS passed
        UNION ALL SELECT (SELECT COUNT(*) >= 25 FROM monitoring.monitoring_baseline)
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_schema_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_population_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_duplicate_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_null_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_referential_integrity_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_business_rule_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_distribution_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_fraud_rate_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_risk_signal_monitoring')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'monitoring' AND table_name = 'vw_anomaly_alert_rules')
        UNION ALL SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'monitoring' AND table_name = 'monitoring_results')
        UNION ALL SELECT (SELECT COUNT(*) > 0 FROM monitoring.monitoring_results)
        UNION ALL SELECT (SELECT COUNT(*) = 0 FROM monitoring.vw_anomaly_alert_rules WHERE severity = 'CRITICAL' AND status = 'FAIL')
    ) sub
)
SELECT
    CASE
        WHEN all_passed THEN 'PHASE 12 STATUS: PASS'
        ELSE 'PHASE 12 STATUS: FAIL'
    END AS phase_12_final_gate,
    passed_gate_checks || '/' || total_gate_checks || ' checks passed' AS score
FROM gate_summary;
