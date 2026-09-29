-- ============================================================================
-- PHASE 11.4 — FINANCIAL EXPOSURE KPIs
-- ============================================================================
-- Purpose:
-- Calculate monetary exposure metrics, distribution stats (averages, medians,
-- min/max), fraud amount share, and fraud premium.
--
-- Reconciles against:
--   analytics.kpi_phase_11_baseline (Total Amount = 79,738,948.735)
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_amount_summary CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_amount_summary AS
SELECT
    COUNT(*) AS total_transactions,
    SUM("TransactionAmt") AS total_transaction_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_transaction_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 0) AS non_fraud_transaction_amount,

    ROUND(AVG("TransactionAmt"), 4) AS average_transaction_amount,
    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 1), 4) AS average_fraud_transaction_amount,
    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 0), 4) AS average_non_fraud_transaction_amount,

    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "TransactionAmt") AS median_transaction_amount,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "TransactionAmt") FILTER (WHERE "isFraud" = 1) AS median_fraud_transaction_amount,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "TransactionAmt") FILTER (WHERE "isFraud" = 0) AS median_non_fraud_transaction_amount,

    MIN("TransactionAmt") AS minimum_transaction_amount,
    MAX("TransactionAmt") AS maximum_transaction_amount,

    ROUND(SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) / NULLIF(SUM("TransactionAmt"), 0), 6) AS fraud_amount_share,

    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 1)
        - AVG("TransactionAmt") FILTER (WHERE "isFraud" = 0), 4) AS average_fraud_amount_premium,

    ROUND(SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1)
        / NULLIF(COUNT(*) FILTER (WHERE "isFraud" = 1), 0), 4) AS fraud_amount_per_fraud_transaction

FROM analytics.vw_transaction_analytics;

-- Display Financial Exposure KPIs
SELECT
    total_transaction_amount,
    fraud_transaction_amount,
    non_fraud_transaction_amount,
    average_transaction_amount,
    average_fraud_transaction_amount,
    average_non_fraud_transaction_amount,
    median_transaction_amount,
    median_fraud_transaction_amount,
    median_non_fraud_transaction_amount,
    minimum_transaction_amount,
    maximum_transaction_amount,
    fraud_amount_share,
    average_fraud_amount_premium
FROM analytics.kpi_amount_summary;