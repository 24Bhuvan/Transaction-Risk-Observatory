-- ============================================================================
-- PHASE 11.9 — RISK COHORT ANALYSIS
-- ============================================================================
-- Purpose:
-- Analyze transaction counts, fraud counts, fraud rates, and financial exposure
-- across established Phase 10 risk dimensions and cohorts:
--   - risk_band (LOW, MEDIUM, HIGH)
--   - signal_count (0, 1, 2, 3, 4, 5)
--   - velocity_flag (0, 1)
--   - multiple_signal_flag (0, 1)
--
-- Single-pass GROUPING SETS aggregation over analytics.vw_risk_scoring for optimal performance.
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_risk_cohorts CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_risk_cohorts AS
SELECT
    CASE
        WHEN risk_band IS NOT NULL AND signal_count IS NULL AND velocity_flag IS NULL AND multiple_signal_flag IS NULL THEN 'risk_band'
        WHEN signal_count IS NOT NULL AND risk_band IS NULL AND velocity_flag IS NULL AND multiple_signal_flag IS NULL THEN 'signal_count'
        WHEN velocity_flag IS NOT NULL AND risk_band IS NULL AND signal_count IS NULL AND multiple_signal_flag IS NULL THEN 'velocity_flag'
        WHEN multiple_signal_flag IS NOT NULL AND risk_band IS NULL AND signal_count IS NULL AND velocity_flag IS NULL THEN 'multiple_signal_flag'
    END AS cohort_dimension,
    COALESCE(risk_band, signal_count::text, velocity_flag::text, multiple_signal_flag::text) AS cohort_value,
    COUNT(*) AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_count,
    ROUND(COUNT(*) FILTER (WHERE "isFraud" = 1)::numeric / NULLIF(COUNT(*), 0), 6) AS fraud_rate,
    SUM("TransactionAmt") AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_amount,
    ROUND(AVG("TransactionAmt"), 4) AS average_transaction_amount,
    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 1), 4) AS average_fraud_amount
FROM analytics.vw_risk_scoring
GROUP BY GROUPING SETS ((risk_band), (signal_count), (velocity_flag), (multiple_signal_flag));

-- Display Cohort Reconciliation Summary
SELECT
    cohort_dimension,
    COUNT(*) AS cohort_levels,
    SUM(transaction_count) AS total_transactions,
    SUM(fraud_count) AS total_fraud,
    SUM(total_amount) AS total_amount,
    SUM(fraud_amount) AS total_fraud_amount
FROM analytics.kpi_risk_cohorts
GROUP BY cohort_dimension
ORDER BY cohort_dimension;