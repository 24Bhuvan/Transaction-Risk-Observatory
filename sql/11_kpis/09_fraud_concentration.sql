-- ============================================================================
-- PHASE 11.10 — FRAUD CONCENTRATION BY OBSERVABLE DIMENSION
-- ============================================================================
-- Purpose:
-- Analyze fraud count and financial amount concentration across key observable dimensions:
--   product (ProductCD), device_type (DeviceType), card4, card6,
--   identity_availability, transaction_hour, transaction_day.
--
-- Measures:
--   - fraud_count, fraud_count_share, cumulative_fraud_count_share
--   - fraud_amount, fraud_amount_share, cumulative_fraud_amount_share
--   - concentration_rank (ordered by fraud_count DESC)
--
-- Sources:
--   analytics.vw_transaction_analytics
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_fraud_concentration CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_fraud_concentration AS
WITH grouped AS (
    SELECT 'product'::text AS dimension_name, COALESCE("ProductCD", '<missing>')::text AS dimension_value, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'device_type', COALESCE("DeviceType", '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'card4', COALESCE(card4, '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'card6', COALESCE(card6, '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'identity_availability', CASE WHEN identity_available_flag = 1 THEN 'available' ELSE 'unavailable' END, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'transaction_hour', transaction_hour::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'transaction_day', transaction_day_number::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
), summary AS (
    SELECT
        dimension_name,
        dimension_value,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_count,
        SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_amount
    FROM grouped
    GROUP BY dimension_name, dimension_value
), ranked AS (
    SELECT
        dimension_name,
        dimension_value,
        fraud_count,
        fraud_amount,
        ROUND(fraud_count::numeric / NULLIF(SUM(fraud_count) OVER (PARTITION BY dimension_name), 0), 6) AS fraud_count_share,
        ROUND(fraud_amount / NULLIF(SUM(fraud_amount) OVER (PARTITION BY dimension_name), 0), 6) AS fraud_amount_share,
        ROW_NUMBER() OVER (PARTITION BY dimension_name ORDER BY fraud_count DESC, dimension_value) AS concentration_rank
    FROM summary
)
SELECT
    dimension_name,
    dimension_value,
    concentration_rank,
    fraud_count,
    fraud_count_share,
    fraud_amount,
    fraud_amount_share,
    ROUND(SUM(fraud_count_share) OVER (PARTITION BY dimension_name ORDER BY concentration_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 6) AS cumulative_fraud_count_share,
    ROUND(SUM(fraud_amount_share) OVER (PARTITION BY dimension_name ORDER BY concentration_rank ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 6) AS cumulative_fraud_amount_share
FROM ranked;

-- Display Top-1 Concentrated Value per Dimension
SELECT
    dimension_name,
    dimension_value,
    concentration_rank,
    fraud_count,
    fraud_count_share,
    fraud_amount,
    fraud_amount_share,
    cumulative_fraud_count_share
FROM analytics.kpi_fraud_concentration
WHERE concentration_rank = 1
ORDER BY dimension_name;