-- ============================================================================
-- PHASE 11.8 — RISK-SCORE ANALYSIS
-- ============================================================================
-- Purpose:
-- Analyze distribution and fraud incidence across Phase 10 additive risk scores
-- and established risk bands (LOW: 0-1, MEDIUM: 2-4, HIGH: 5+).
--
-- Sources:
--   analytics.vw_risk_scoring
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_risk_score_statistics CASCADE;
DROP VIEW IF EXISTS analytics.kpi_risk_score_summary CASCADE;

-- 1. Risk Score Distribution Statistics
CREATE OR REPLACE VIEW analytics.kpi_risk_score_statistics AS
SELECT
    MIN(risk_score) AS minimum_risk_score,
    MAX(risk_score) AS maximum_risk_score,
    ROUND(AVG(risk_score), 4) AS average_risk_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY risk_score) AS median_risk_score,
    COUNT(DISTINCT risk_score) AS distinct_risk_scores,
    COUNT(*) FILTER (WHERE risk_score IS NULL) AS null_score_count
FROM analytics.vw_risk_scoring;

-- 2. Risk Score & Band Summary
CREATE OR REPLACE VIEW analytics.kpi_risk_score_summary AS
SELECT
    risk_band,
    risk_score,
    COUNT(*) AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_count,
    COUNT(*) FILTER (WHERE "isFraud" = 0) AS non_fraud_count,
    ROUND(COUNT(*) FILTER (WHERE "isFraud" = 1)::numeric / NULLIF(COUNT(*), 0), 6) AS fraud_rate,
    SUM("TransactionAmt") AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_amount,
    ROUND(AVG("TransactionAmt"), 4) AS average_transaction_amount
FROM analytics.vw_risk_scoring
GROUP BY risk_band, risk_score;

-- Display Statistics
SELECT * FROM analytics.kpi_risk_score_statistics;

-- Display Risk Band Summary
SELECT
    risk_band,
    SUM(transaction_count) AS total_transactions,
    SUM(fraud_count) AS total_fraud,
    SUM(non_fraud_count) AS total_non_fraud,
    ROUND(SUM(fraud_count)::numeric / NULLIF(SUM(transaction_count), 0), 6) AS fraud_rate,
    SUM(total_amount) AS total_amount,
    SUM(fraud_amount) AS fraud_amount,
    ROUND(AVG(average_transaction_amount), 4) AS avg_transaction_amount
FROM analytics.kpi_risk_score_summary
GROUP BY risk_band
ORDER BY
    CASE risk_band
        WHEN 'LOW' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'HIGH' THEN 3
        ELSE 4
    END;