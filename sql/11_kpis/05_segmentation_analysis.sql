-- ============================================================================
-- PHASE 11.6 — FRAUD SEGMENTATION ANALYSIS
-- ============================================================================
-- Purpose:
-- Segment observed transaction fraud and amounts across key observable attributes:
--   ProductCD, card4, card6, DeviceType, device_info (deviceinfo_normalized),
--   P_emaildomain, R_emaildomain, identity_availability.
--
-- Notes:
--   - NULL / empty values are standardized as '<missing>'.
--   - Partitions that cover the full population (ProductCD, identity_availability)
--     reconcile to 590,540 total transactions and 20,663 fraud transactions.
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_segmentation_summary CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_segmentation_summary AS
WITH segmented AS (
    SELECT 'product'::text AS dimension_name, COALESCE("ProductCD", '<missing>')::text AS segment_value, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'card4', COALESCE(card4, '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'card6', COALESCE(card6, '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'device_type', COALESCE("DeviceType", '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'device_info', COALESCE(NULLIF(deviceinfo_normalized, ''), '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'purchaser_email_domain', COALESCE("P_emaildomain", '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'recipient_email_domain', COALESCE("R_emaildomain", '<missing>')::text, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
    UNION ALL SELECT 'identity_availability', CASE WHEN identity_available_flag = 1 THEN 'available' ELSE 'unavailable' END, "isFraud", "TransactionAmt" FROM analytics.vw_transaction_analytics
)
SELECT
    dimension_name,
    segment_value,
    COUNT(*) AS transaction_count,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_count,
    ROUND(COUNT(*) FILTER (WHERE "isFraud" = 1)::numeric / NULLIF(COUNT(*), 0), 6) AS fraud_rate,
    SUM("TransactionAmt") AS total_amount,
    SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_amount,
    ROUND(AVG("TransactionAmt"), 4) AS average_amount,
    ROUND(AVG("TransactionAmt") FILTER (WHERE "isFraud" = 1), 4) AS average_fraud_amount
FROM segmented
GROUP BY dimension_name, segment_value;

-- Reconciliation summary by dimension
SELECT
    dimension_name,
    COUNT(*) AS segment_count,
    SUM(transaction_count) AS total_transactions,
    SUM(fraud_count) AS total_fraud,
    SUM(total_amount) AS total_amount,
    SUM(fraud_amount) AS total_fraud_amount
FROM analytics.kpi_segmentation_summary
GROUP BY dimension_name
ORDER BY dimension_name;