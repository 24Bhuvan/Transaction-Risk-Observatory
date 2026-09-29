-- ============================================================================
-- PHASE 11.7 — RISK-SIGNAL PERFORMANCE
-- ============================================================================
-- Purpose:
-- Evaluate descriptive performance of all Phase 10 signals against known isFraud:
--   - velocity_flag
--   - amount_anomaly_flag
--   - entity_device_anomaly_flag
--   - off_hours_risk_flag
--   - impossible_travel_flag
--   - multiple_signal_flag
--
-- Single-pass aggregation over analytics.vw_composed_risk_signals for optimal performance.
--
-- Metrics:
--   - Flagged Transactions, Fraudulent Flagged, Non-Fraud Flagged
--   - Fraud Rate Among Flagged = Fraudulent Flagged / Flagged Transactions
--   - Fraud Rate Among Unflagged = Fraudulent Unflagged / Unflagged Transactions
--   - Fraud Capture Rate = Fraudulent Flagged / Total Fraud Transactions (20,663)
--   - Flag Rate = Flagged Transactions / Total Transactions (590,540)
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_signal_performance CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_signal_performance AS
WITH base AS (
    SELECT
        COUNT(*) AS total_transactions,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS total_fraud_transactions,
        -- velocity
        COUNT(*) FILTER (WHERE velocity_flag = 1) AS vel_flagged,
        COUNT(*) FILTER (WHERE velocity_flag = 1 AND "isFraud" = 1) AS vel_fraud_flagged,
        COUNT(*) FILTER (WHERE velocity_flag = 1 AND "isFraud" = 0) AS vel_non_fraud_flagged,
        COUNT(*) FILTER (WHERE velocity_flag = 0 AND "isFraud" = 1) AS vel_fraud_unflagged,
        COUNT(*) FILTER (WHERE velocity_flag = 0) AS vel_unflagged,
        -- amount_anomaly
        COUNT(*) FILTER (WHERE amount_anomaly_flag = 1) AS amt_flagged,
        COUNT(*) FILTER (WHERE amount_anomaly_flag = 1 AND "isFraud" = 1) AS amt_fraud_flagged,
        COUNT(*) FILTER (WHERE amount_anomaly_flag = 1 AND "isFraud" = 0) AS amt_non_fraud_flagged,
        COUNT(*) FILTER (WHERE amount_anomaly_flag = 0 AND "isFraud" = 1) AS amt_fraud_unflagged,
        COUNT(*) FILTER (WHERE amount_anomaly_flag = 0) AS amt_unflagged,
        -- entity_device_anomaly
        COUNT(*) FILTER (WHERE entity_device_anomaly_flag = 1) AS dev_flagged,
        COUNT(*) FILTER (WHERE entity_device_anomaly_flag = 1 AND "isFraud" = 1) AS dev_fraud_flagged,
        COUNT(*) FILTER (WHERE entity_device_anomaly_flag = 1 AND "isFraud" = 0) AS dev_non_fraud_flagged,
        COUNT(*) FILTER (WHERE entity_device_anomaly_flag = 0 AND "isFraud" = 1) AS dev_fraud_unflagged,
        COUNT(*) FILTER (WHERE entity_device_anomaly_flag = 0) AS dev_unflagged,
        -- off_hours
        COUNT(*) FILTER (WHERE off_hours_risk_flag = 1) AS off_flagged,
        COUNT(*) FILTER (WHERE off_hours_risk_flag = 1 AND "isFraud" = 1) AS off_fraud_flagged,
        COUNT(*) FILTER (WHERE off_hours_risk_flag = 1 AND "isFraud" = 0) AS off_non_fraud_flagged,
        COUNT(*) FILTER (WHERE off_hours_risk_flag = 0 AND "isFraud" = 1) AS off_fraud_unflagged,
        COUNT(*) FILTER (WHERE off_hours_risk_flag = 0) AS off_unflagged,
        -- impossible_travel
        COUNT(*) FILTER (WHERE impossible_travel_flag = 1) AS geo_flagged,
        COUNT(*) FILTER (WHERE impossible_travel_flag = 1 AND "isFraud" = 1) AS geo_fraud_flagged,
        COUNT(*) FILTER (WHERE impossible_travel_flag = 1 AND "isFraud" = 0) AS geo_non_fraud_flagged,
        COUNT(*) FILTER (WHERE impossible_travel_flag = 0 AND "isFraud" = 1) AS geo_fraud_unflagged,
        COUNT(*) FILTER (WHERE impossible_travel_flag = 0) AS geo_unflagged,
        -- multiple_signal
        COUNT(*) FILTER (WHERE multiple_signal_flag = 1) AS mult_flagged,
        COUNT(*) FILTER (WHERE multiple_signal_flag = 1 AND "isFraud" = 1) AS mult_fraud_flagged,
        COUNT(*) FILTER (WHERE multiple_signal_flag = 1 AND "isFraud" = 0) AS mult_non_fraud_flagged,
        COUNT(*) FILTER (WHERE multiple_signal_flag = 0 AND "isFraud" = 1) AS mult_fraud_unflagged,
        COUNT(*) FILTER (WHERE multiple_signal_flag = 0) AS mult_unflagged
    FROM analytics.vw_composed_risk_signals
), unpivoted AS (
    SELECT 'velocity'::text AS signal_name, total_transactions, total_fraud_transactions, vel_flagged AS flagged_transactions, vel_fraud_flagged AS fraudulent_flagged_transactions, vel_non_fraud_flagged AS non_fraud_flagged_transactions, vel_fraud_unflagged AS unflagged_fraud_transactions, vel_unflagged AS unflagged_transactions FROM base
    UNION ALL SELECT 'amount_anomaly', total_transactions, total_fraud_transactions, amt_flagged, amt_fraud_flagged, amt_non_fraud_flagged, amt_fraud_unflagged, amt_unflagged FROM base
    UNION ALL SELECT 'entity_device_anomaly', total_transactions, total_fraud_transactions, dev_flagged, dev_fraud_flagged, dev_non_fraud_flagged, dev_fraud_unflagged, dev_unflagged FROM base
    UNION ALL SELECT 'off_hours', total_transactions, total_fraud_transactions, off_flagged, off_fraud_flagged, off_non_fraud_flagged, off_fraud_unflagged, off_unflagged FROM base
    UNION ALL SELECT 'impossible_travel', total_transactions, total_fraud_transactions, geo_flagged, geo_fraud_flagged, geo_non_fraud_flagged, geo_fraud_unflagged, geo_unflagged FROM base
    UNION ALL SELECT 'multiple_signal', total_transactions, total_fraud_transactions, mult_flagged, mult_fraud_flagged, mult_non_fraud_flagged, mult_fraud_unflagged, mult_unflagged FROM base
)
SELECT
    signal_name,
    total_transactions,
    flagged_transactions,
    fraudulent_flagged_transactions,
    non_fraud_flagged_transactions,
    ROUND(fraudulent_flagged_transactions::numeric / NULLIF(flagged_transactions, 0), 6) AS fraud_rate_among_flagged,
    ROUND(unflagged_fraud_transactions::numeric / NULLIF(unflagged_transactions, 0), 6) AS fraud_rate_among_unflagged,
    ROUND(fraudulent_flagged_transactions::numeric / NULLIF(total_fraud_transactions, 0), 6) AS fraud_capture_rate,
    ROUND(flagged_transactions::numeric / NULLIF(total_transactions, 0), 6) AS flag_rate
FROM unpivoted;

-- Display Signal Performance ranked by Fraud Capture Rate
SELECT
    signal_name,
    flagged_transactions,
    fraudulent_flagged_transactions,
    non_fraud_flagged_transactions,
    fraud_rate_among_flagged,
    fraud_rate_among_unflagged,
    fraud_capture_rate,
    flag_rate
FROM analytics.kpi_signal_performance
ORDER BY fraud_capture_rate DESC;