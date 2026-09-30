-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 03: BASELINE WORKLOAD BENCHMARKING
-- ============================================================================
-- Purpose:
--   Execute transparent, standalone EXPLAIN (ANALYZE, BUFFERS) profiling for
--   representative Phase 8–12 analytical workloads.
--
-- Methodological Constraints:
--   - No procedural DO blocks or automated transaction batching.
--   - No loops or autonomous monitoring wrappers.
--   - No state-modifying procedures.
--   - No hardcoded plan nodes, row counts, or buffer metrics.
--   - All benchmark evidence is captured directly from PostgreSQL execution plans.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- WORKLOAD Q01: Daily Fraud Trend Summary (Phase 9 Temporal Aggregation)
-- Target: analytics.fact_transaction_clean
-- Purpose: Evaluate temporal grouping, row filtering, and exposure aggregation.
-- ----------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    transaction_day_number,
    COUNT(*),
    COUNT(*) FILTER (WHERE "isFraud" = 1),
    SUM("TransactionAmt")
FROM analytics.fact_transaction_clean
GROUP BY transaction_day_number;

-- ----------------------------------------------------------------------------
-- WORKLOAD Q02: Amount Outlier Detection (Phase 10 Statistical Filtering)
-- Target: analytics.fact_transaction_clean
-- Purpose: Evaluate selective filtering (> $1,000) over transaction amounts.
-- ----------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    "TransactionID",
    "TransactionAmt",
    "isFraud"
FROM analytics.fact_transaction_clean
WHERE "TransactionAmt" >= 1000.00;

-- ----------------------------------------------------------------------------
-- WORKLOAD Q03: Identity Risk by Device Type (Phase 9 Dimensional Join)
-- Target: analytics.fact_transaction_clean JOIN analytics.dim_identity_clean
-- Purpose: Evaluate natural key join performance between fact and identity dim.
-- ----------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    d."DeviceType",
    COUNT(*),
    COUNT(*) FILTER (WHERE f."isFraud" = 1)
FROM analytics.fact_transaction_clean f
JOIN analytics.dim_identity_clean d
    ON f."TransactionID" = d."TransactionID"
GROUP BY d."DeviceType";

-- ----------------------------------------------------------------------------
-- WORKLOAD Q04: Card Network Risk Analysis (Phase 9 Categorical Aggregation)
-- Target: analytics.fact_transaction_clean
-- Purpose: Evaluate multi-attribute categorical grouping and fraud rates.
-- ----------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    card4,
    card6,
    COUNT(*) AS total_tx,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_tx,
    ROUND(
        COUNT(*) FILTER (WHERE "isFraud" = 1)::NUMERIC
        / NULLIF(COUNT(*), 0),
        6
    ) AS fraud_rate
FROM analytics.fact_transaction_clean
GROUP BY card4, card6;

-- ----------------------------------------------------------------------------
-- WORKLOAD Q05: Executive KPI Segmentation Summary (Phase 11 KPI Aggregation)
-- Target: analytics.kpi_segmentation_summary
-- Purpose: Evaluate multi-dimensional segmented fraud volumes and averages.
-- ----------------------------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    dimension_name,
    segment_value,
    transaction_count,
    fraud_count,
    fraud_rate,
    total_amount,
    fraud_amount,
    average_amount,
    average_fraud_amount
FROM analytics.kpi_segmentation_summary;
