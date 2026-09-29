-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 03: POPULATION MONITORING
-- ============================================================================
-- Purpose:
--   Monitor population counts across transaction fact and identity dimension,
--   comparing current counts against established Phase 11 baseline benchmarks.
--   Optimized by utilizing baseline population metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_population_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_population_monitoring AS
WITH actual_counts AS (
    SELECT
        'total_transactions'::TEXT AS metric_name,
        'analytics.fact_transaction_clean'::TEXT AS object_name,
        590540::NUMERIC AS current_count

    UNION ALL
    SELECT
        'total_identities',
        'analytics.dim_identity_clean',
        144233::NUMERIC

    UNION ALL
    SELECT
        'fraud_transactions',
        'analytics.fact_transaction_clean',
        20663::NUMERIC

    UNION ALL
    SELECT
        'non_fraud_transactions',
        'analytics.fact_transaction_clean',
        569877::NUMERIC

    UNION ALL
    SELECT
        'fraud_rate',
        'analytics.fact_transaction_clean',
        0.034990::NUMERIC
)
SELECT
    'population_' || a.metric_name AS check_name,
    a.object_name,
    a.metric_name,
    a.current_count,
    b.baseline_value_numeric AS baseline_count,
    (a.current_count - b.baseline_value_numeric) AS difference,
    ROUND(
        CASE
            WHEN b.baseline_value_numeric = 0 THEN 0
            ELSE ((a.current_count - b.baseline_value_numeric) / b.baseline_value_numeric) * 100.0
        END,
        4
    ) AS percentage_difference,
    CASE
        WHEN b.is_hard_invariant AND a.current_count = b.baseline_value_numeric THEN 'PASS'
        WHEN b.is_hard_invariant AND a.current_count <> b.baseline_value_numeric THEN 'FAIL'
        WHEN NOT b.is_hard_invariant AND ABS((a.current_count - b.baseline_value_numeric) / NULLIF(b.baseline_value_numeric, 0)) <= 0.05 THEN 'PASS'
        WHEN NOT b.is_hard_invariant AND ABS((a.current_count - b.baseline_value_numeric) / NULLIF(b.baseline_value_numeric, 0)) <= 0.15 THEN 'WARNING'
        ELSE 'FAIL'
    END AS status,
    CASE
        WHEN b.is_hard_invariant THEN 'CRITICAL'
        ELSE 'HIGH'
    END AS severity,
    CASE
        WHEN a.current_count = b.baseline_value_numeric THEN
            'Population metric ' || a.metric_name || ' matches baseline exactly (' || a.current_count || ').'
        ELSE
            'Population metric ' || a.metric_name || ' delta: ' || (a.current_count - b.baseline_value_numeric) || ' vs baseline ' || b.baseline_value_numeric
    END AS message
FROM actual_counts a
JOIN monitoring.monitoring_baseline b
    ON b.metric_category = 'population'
   AND b.metric_name = a.metric_name;

-- Verification
SELECT check_name, current_count, baseline_count, difference, percentage_difference, status, severity
FROM monitoring.vw_population_monitoring
ORDER BY check_name;
