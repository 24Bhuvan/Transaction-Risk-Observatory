-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 11: UNIFIED ANOMALY & ALERT RULES
-- ============================================================================
-- Purpose:
--   Unify all monitoring checks across schema, population, duplicates, nulls,
--   referential integrity, business rules, distributions, fraud rate, and risk signals
--   into a standardized alert rules engine with PASS, WARNING, FAIL statuses.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_anomaly_alert_rules CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_anomaly_alert_rules AS
-- 1. Schema Checks
SELECT
    'schema'::TEXT AS check_category,
    check_name,
    object_name AS source_object,
    'structure'::TEXT AS metric_name,
    expected_state AS expected_value,
    actual_state AS actual_value,
    CASE WHEN actual_state <> expected_state THEN 'MISMATCH' ELSE '0' END AS difference,
    'EXACT_MATCH'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_schema_monitoring

UNION ALL

-- 2. Population Checks
SELECT
    'population'::TEXT AS check_category,
    check_name,
    object_name AS source_object,
    metric_name,
    baseline_count::TEXT AS expected_value,
    current_count::TEXT AS actual_value,
    difference::TEXT AS difference,
    'DELTA <= 5%'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_population_monitoring

UNION ALL

-- 3. Duplicate Checks
SELECT
    'duplicate'::TEXT AS check_category,
    check_name,
    table_name AS source_object,
    key_column AS metric_name,
    '0'::TEXT AS expected_value,
    duplicate_keys::TEXT AS actual_value,
    duplicate_keys::TEXT AS difference,
    'duplicate_keys = 0'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_duplicate_monitoring

UNION ALL

-- 4. Null & Missingness Checks
SELECT
    'null'::TEXT AS check_category,
    check_name,
    table_name AS source_object,
    column_name AS metric_name,
    expected_null_rate::TEXT AS expected_value,
    null_rate::TEXT AS actual_value,
    (null_rate - expected_null_rate)::TEXT AS difference,
    CASE WHEN is_critical THEN 'null_count = 0' ELSE 'delta <= 5%' END AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_null_monitoring

UNION ALL

-- 5. Referential Integrity Checks
SELECT
    'referential_integrity'::TEXT AS check_category,
    check_name,
    'analytics.fact_transaction_clean <-> analytics.dim_identity_clean' AS source_object,
    check_name AS metric_name,
    expected_count::TEXT AS expected_value,
    actual_count::TEXT AS actual_value,
    difference::TEXT AS difference,
    'difference = 0'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_referential_integrity_monitoring

UNION ALL

-- 6. Business Rule Checks
SELECT
    'business_rule'::TEXT AS check_category,
    rule_name AS check_name,
    table_name AS source_object,
    expected_condition AS metric_name,
    '0'::TEXT AS expected_value,
    violating_rows::TEXT AS actual_value,
    violating_rows::TEXT AS difference,
    'violating_rows = 0'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_business_rule_monitoring

UNION ALL

-- 7. Distribution Checks
SELECT
    'distribution'::TEXT AS check_category,
    check_name,
    table_name AS source_object,
    column_name || ' (' || category_value || ')' AS metric_name,
    'VALID_DISTRIBUTION'::TEXT AS expected_value,
    row_count::TEXT AS actual_value,
    '0'::TEXT AS difference,
    'row_count > 0'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_distribution_monitoring

UNION ALL

-- 8. Fraud Rate Checks
SELECT
    'fraud_rate'::TEXT AS check_category,
    check_name,
    source_object,
    metric_name,
    baseline_value::TEXT AS expected_value,
    actual_value::TEXT AS actual_value,
    difference::TEXT AS difference,
    expected_range AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_fraud_rate_monitoring

UNION ALL

-- 9. Risk Signal Checks
SELECT
    'risk_signals'::TEXT AS check_category,
    check_name,
    source_object,
    signal_name AS metric_name,
    'OPERATIONAL'::TEXT AS expected_value,
    flagged_transactions::TEXT AS actual_value,
    '0'::TEXT AS difference,
    'flag_rate > 0'::TEXT AS threshold,
    severity,
    status,
    message
FROM monitoring.vw_risk_signal_monitoring;

-- Verification
SELECT check_category, status, severity, COUNT(*) AS check_count
FROM monitoring.vw_anomaly_alert_rules
GROUP BY check_category, status, severity
ORDER BY check_category, status, severity;
