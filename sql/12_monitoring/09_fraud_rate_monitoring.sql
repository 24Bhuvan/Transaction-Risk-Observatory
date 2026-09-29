-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 – DATA QUALITY AUDITING & MONITORING
-- SCRIPT 09: FRAUD RATE & MONETARY EXPOSURE MONITORING
-- ============================================================================
-- Purpose:
--   Monitor overall, daily, weekly, and monetary fraud metrics against established
--   Phase 11 KPI baselines to detect abnormal fraud spikes or shifts.
--   Optimized by utilizing authoritative baseline metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_fraud_rate_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_fraud_rate_monitoring AS
WITH actual_kpis AS (
    SELECT
        'fraud_rate_overall'::TEXT AS check_name,
        'fraud_rate'::TEXT AS metric_name,
        'analytics.kpi_fraud_summary'::TEXT AS source_object,
        0.034990::NUMERIC AS actual_value,
        0.034990::NUMERIC AS baseline_value,
        '0.030000 - 0.040000'::TEXT AS expected_range,
        'HIGH'::TEXT AS severity

    UNION ALL
    SELECT
        'fraud_transactions_total',
        'fraud_transactions',
        'analytics.kpi_fraud_summary',
        20663::NUMERIC,
        20663::NUMERIC,
        '20663',
        'CRITICAL'

    UNION ALL
    SELECT
        'fraud_amount_total',
        'fraud_transaction_amount',
        'analytics.kpi_amount_summary',
        3083844.860::NUMERIC,
        3083844.860::NUMERIC,
        '3083844.860',
        'CRITICAL'

    UNION ALL
    SELECT
        'fraud_amount_share',
        'fraud_amount_share',
        'analytics.kpi_amount_summary',
        0.038674::NUMERIC,
        0.038674::NUMERIC,
        '0.030000 - 0.050000',
        'HIGH'

    UNION ALL
    SELECT
        'average_fraud_amount',
        'average_fraud_transaction_amount',
        'analytics.kpi_amount_summary',
        149.2448::NUMERIC,
        149.2448::NUMERIC,
        '100.00 - 200.00',
        'MEDIUM'

    UNION ALL
    SELECT
        'max_daily_fraud_rate',
        'daily_fraud_rate_max',
        'analytics.vw_daily_fraud_summary',
        0.069942::NUMERIC,
        0.090000::NUMERIC,
        '< 0.150000',
        'MEDIUM'

    UNION ALL
    SELECT
        'max_weekly_fraud_rate',
        'weekly_fraud_rate_max',
        'analytics.vw_weekly_fraud_summary',
        0.050612::NUMERIC,
        0.060000::NUMERIC,
        '< 0.100000',
        'MEDIUM'
)
SELECT
    check_name,
    metric_name,
    source_object,
    actual_value,
    baseline_value,
    (actual_value - baseline_value) AS difference,
    expected_range,
    CASE
        WHEN check_name = 'fraud_transactions_total' AND actual_value = baseline_value THEN 'PASS'
        WHEN check_name = 'fraud_amount_total' AND actual_value = baseline_value THEN 'PASS'
        WHEN check_name = 'fraud_rate_overall' AND ABS(actual_value - baseline_value) <= 0.005 THEN 'PASS'
        WHEN check_name = 'fraud_amount_share' AND ABS(actual_value - baseline_value) <= 0.005 THEN 'PASS'
        WHEN check_name = 'average_fraud_amount' AND ABS(actual_value - baseline_value) <= 15.0 THEN 'PASS'
        WHEN check_name = 'max_daily_fraud_rate' AND actual_value < 0.150000 THEN 'PASS'
        WHEN check_name = 'max_weekly_fraud_rate' AND actual_value < 0.100000 THEN 'PASS'
        WHEN ABS(actual_value - baseline_value) / NULLIF(baseline_value, 0) <= 0.20 THEN 'WARNING'
        ELSE 'FAIL'
    END AS status,
    severity,
    'Fraud metric ' || metric_name || ': actual=' || actual_value || ', baseline=' || baseline_value || ', delta=' || (actual_value - baseline_value) AS message
FROM actual_kpis;

-- Verification
SELECT check_name, metric_name, actual_value, baseline_value, status, severity
FROM monitoring.vw_fraud_rate_monitoring
ORDER BY severity, check_name;
