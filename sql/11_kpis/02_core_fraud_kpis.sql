-- ============================================================================
-- PHASE 11.3 — CORE FRAUD KPIs
-- ============================================================================
-- Purpose:
-- Calculate authoritative core transaction count and rate KPIs with safe division.
--
-- Reconciles against:
--   analytics.kpi_phase_11_baseline
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_fraud_summary CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_fraud_summary AS
SELECT
    total_transactions,
    fraud_transactions,
    non_fraud_transactions,
    fraud_rate,
    ROUND(non_fraud_transactions::numeric / NULLIF(total_transactions, 0), 6) AS non_fraud_rate
FROM analytics.kpi_phase_11_baseline;

-- Display Core Fraud KPIs
SELECT
    total_transactions,
    fraud_transactions,
    non_fraud_transactions,
    fraud_rate,
    non_fraud_rate
FROM analytics.kpi_fraud_summary;