-- ============================================================================
-- PHASE 11.5 — TEMPORAL KPI ANALYSIS
-- ============================================================================
-- Purpose:
-- Produce daily, weekly, and hourly fraud KPIs using established derived fields
-- (transaction_day_number, transaction_week_number, transaction_hour).
--
-- Reuses existing Phase 9 views:
--   analytics.vw_daily_fraud_summary
--   analytics.vw_weekly_fraud_summary
--   analytics.vw_transaction_analytics
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_daily_fraud CASCADE;
DROP VIEW IF EXISTS analytics.kpi_weekly_fraud CASCADE;
DROP VIEW IF EXISTS analytics.kpi_hourly_fraud CASCADE;

-- 1. Daily Fraud KPIs
CREATE OR REPLACE VIEW analytics.kpi_daily_fraud AS
SELECT
    transaction_day_number AS day_number,
    total_transactions,
    fraud_transactions,
    fraud_rate,
    total_amount,
    fraud_amount,
    average_transaction_amount,
    average_fraud_amount
FROM analytics.vw_daily_fraud_summary;

-- 2. Weekly Fraud KPIs
CREATE OR REPLACE VIEW analytics.kpi_weekly_fraud AS
SELECT
    transaction_week_number AS week_number,
    total_transactions,
    fraud_transactions,
    fraud_rate,
    total_amount,
    fraud_amount
FROM analytics.vw_weekly_fraud_summary;

-- 3. Hourly Fraud KPIs
CREATE OR REPLACE VIEW analytics.kpi_hourly_fraud AS
SELECT
    transaction_hour,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_transactions,
    ROUND(COUNT(*) FILTER (WHERE "isFraud" = 1)::numeric / NULLIF(COUNT(*), 0), 6) AS fraud_rate,
    SUM("TransactionAmt") AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_amount,
    ROUND(AVG("TransactionAmt"), 4) AS average_transaction_amount,
    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 1), 4) AS average_fraud_amount
FROM analytics.vw_transaction_analytics
GROUP BY transaction_hour;

-- Temporal Partition Reconciliation Check
SELECT
    'daily' AS grain,
    COUNT(*) AS periods,
    SUM(total_transactions) AS total_transactions,
    SUM(fraud_transactions) AS total_fraud,
    SUM(total_amount) AS total_amount,
    SUM(fraud_amount) AS total_fraud_amount
FROM analytics.kpi_daily_fraud
UNION ALL
SELECT
    'weekly',
    COUNT(*),
    SUM(total_transactions),
    SUM(fraud_transactions),
    SUM(total_amount),
    SUM(fraud_amount)
FROM analytics.kpi_weekly_fraud
UNION ALL
SELECT
    'hourly',
    COUNT(*),
    SUM(total_transactions),
    SUM(fraud_transactions),
    SUM(total_amount),
    SUM(fraud_amount)
FROM analytics.kpi_hourly_fraud;