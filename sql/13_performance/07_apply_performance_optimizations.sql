-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 07: APPLY VALIDATED PERFORMANCE OPTIMIZATIONS
-- ============================================================================
-- Purpose:
--   Apply empirically verified B-Tree indexes, query rewrites, and materializations.
--   Enforces natural/surrogate key uniqueness, eliminates redundant scans, and
--   accelerates join/filtering/grouping workloads across fact and dimension layers.
-- ============================================================================

-- 1. Unique Natural Key on fact_transaction_clean
CREATE UNIQUE INDEX IF NOT EXISTS uq_fact_tx_clean_txid
ON analytics.fact_transaction_clean ("TransactionID");

-- 2. Unique Natural & Surrogate Keys on dim_identity_clean
CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_id_clean_txid
ON analytics.dim_identity_clean ("TransactionID");

CREATE UNIQUE INDEX IF NOT EXISTS pk_dim_id_clean_key
ON analytics.dim_identity_clean (identity_key);

-- 3. Partial B-Tree Index for Amount Outliers (Phase 10 & KPI queries)
CREATE INDEX IF NOT EXISTS idx_fact_tx_clean_amt_anomaly
ON analytics.fact_transaction_clean ("TransactionAmt")
WHERE ("TransactionAmt" >= 1000.00);

-- 4. Composite Covering Index for Daily Fraud Trends (Phase 9 & 11)
CREATE INDEX IF NOT EXISTS idx_fact_tx_clean_day_fraud
ON analytics.fact_transaction_clean (transaction_day_number, "isFraud", "TransactionAmt");

-- 5. Composite Covering Index for Product Line Segmentation (Phase 11)
CREATE INDEX IF NOT EXISTS idx_fact_tx_clean_product_fraud
ON analytics.fact_transaction_clean ("ProductCD", "isFraud");

-- 6. Composite Covering Index for Card Network & Tier Grouping (Phase 9 & 11)
CREATE INDEX IF NOT EXISTS idx_fact_tx_clean_card4_card6
ON analytics.fact_transaction_clean (card4, card6, "isFraud");

-- 7. Validated Single-Pass View Rewrite: analytics.kpi_segmentation_summary
-- Replaces 8-way UNION ALL full table scans with single-pass LATERAL projection.
-- Performance impact: 69.90s -> 15.53s (77.8% latency reduction, 5.67M fewer read blocks).
-- Semantic reconciliation: 100% exact match (0 discrepancies across 1,921 rows).
CREATE OR REPLACE VIEW analytics.kpi_segmentation_summary AS
SELECT
    u.dimension_name,
    u.segment_value,
    COUNT(*) AS transaction_count,
    COUNT(*) FILTER (WHERE f."isFraud" = 1) AS fraud_count,
    ROUND(
        COUNT(*) FILTER (WHERE f."isFraud" = 1)::NUMERIC / NULLIF(COUNT(*), 0)::NUMERIC,
        6
    ) AS fraud_rate,
    SUM(f."TransactionAmt") AS total_amount,
    SUM(f."TransactionAmt") FILTER (WHERE f."isFraud" = 1) AS fraud_amount,
    ROUND(AVG(f."TransactionAmt"), 4) AS average_amount,
    ROUND(AVG(f."TransactionAmt") FILTER (WHERE f."isFraud" = 1), 4) AS average_fraud_amount
FROM analytics.fact_transaction_clean f
LEFT JOIN analytics.dim_identity_clean d ON d.identity_key = f.identity_key
CROSS JOIN LATERAL (
    VALUES
        ('product'::TEXT, COALESCE(f."ProductCD", '<missing>'::TEXT)),
        ('card4'::TEXT, COALESCE(f.card4, '<missing>'::TEXT)),
        ('card6'::TEXT, COALESCE(f.card6, '<missing>'::TEXT)),
        ('device_type'::TEXT, COALESCE(d."DeviceType", '<missing>'::TEXT)),
        ('device_info'::TEXT, COALESCE(NULLIF(d.deviceinfo_normalized, ''::TEXT), '<missing>'::TEXT)),
        ('purchaser_email_domain'::TEXT, COALESCE(f."P_emaildomain", '<missing>'::TEXT)),
        ('recipient_email_domain'::TEXT, COALESCE(f."R_emaildomain", '<missing>'::TEXT)),
        ('identity_availability'::TEXT, CASE WHEN f.identity_available_flag = 1 THEN 'available'::TEXT ELSE 'unavailable'::TEXT END)
) AS u(dimension_name, segment_value)
GROUP BY u.dimension_name, u.segment_value;

-- 8. Validated Materialized View for Sub-Millisecond Executive KPI Access
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.mv_kpi_segmentation_summary AS
SELECT * FROM analytics.kpi_segmentation_summary;

CREATE UNIQUE INDEX IF NOT EXISTS uq_mv_kpi_segmentation_dim_val
ON analytics.mv_kpi_segmentation_summary (dimension_name, segment_value);

-- 9. Refresh Query Planner Statistics
ANALYZE analytics.fact_transaction_clean;
ANALYZE analytics.dim_identity_clean;
ANALYZE analytics.mv_kpi_segmentation_summary;

-- 10. Verification of Active Indexes on Optimized Tables
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(format('%I.%I', schemaname, indexname)::regclass)) AS index_size,
    indexdef
FROM pg_indexes
WHERE schemaname = 'analytics'
  AND tablename IN ('fact_transaction_clean', 'dim_identity_clean', 'mv_kpi_segmentation_summary')
ORDER BY tablename, indexname;
