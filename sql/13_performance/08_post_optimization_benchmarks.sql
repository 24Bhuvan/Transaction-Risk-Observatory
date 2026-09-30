-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 08: POST-OPTIMIZATION BENCHMARK & COMPARISON
-- ============================================================================
-- Purpose:
--   Maintain persistent, empirically measured benchmark metrics and compute
--   exact latency reduction percentages and efficiency gains against verified
--   baseline measurements without hardcoded values.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS performance;

-- Table definition for benchmark results persistence
CREATE TABLE IF NOT EXISTS performance.benchmark_results (
    benchmark_id SERIAL PRIMARY KEY,
    query_id TEXT NOT NULL,
    query_name TEXT NOT NULL,
    benchmark_stage TEXT NOT NULL, -- 'BASELINE_VERIFIED', 'POST_OPTIMIZATION'
    planning_time_ms NUMERIC(10,3),
    execution_time_ms NUMERIC(10,3) NOT NULL,
    actual_rows BIGINT,
    shared_hit_blocks BIGINT DEFAULT 0,
    shared_read_blocks BIGINT DEFAULT 0,
    primary_scan_type TEXT,
    notes TEXT,
    benchmark_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Note: Historical verified baselines (Q01-Q05) and measured post-optimization
-- timings are stored in performance.benchmark_results.

-- Query: Empirical Before vs. After Benchmark Comparison
SELECT
    b.query_id,
    b.query_name,
    b.execution_time_ms AS baseline_execution_ms,
    o.execution_time_ms AS optimized_execution_ms,
    ROUND(b.execution_time_ms - o.execution_time_ms, 3) AS absolute_reduction_ms,
    ROUND(((b.execution_time_ms - o.execution_time_ms) / b.execution_time_ms) * 100.0, 2) AS latency_improvement_pct,
    b.notes AS baseline_notes,
    o.primary_scan_type AS optimized_scan_type,
    o.notes AS optimized_notes
FROM performance.benchmark_results b
JOIN performance.benchmark_results o
  ON b.query_id = o.query_id
WHERE b.benchmark_stage = 'BASELINE_VERIFIED'
  AND o.benchmark_stage = 'POST_OPTIMIZATION'
ORDER BY latency_improvement_pct DESC;

-- Detailed Buffer and Resource Comparison for Measured Optimization
SELECT
    query_id,
    query_name,
    benchmark_stage,
    planning_time_ms,
    execution_time_ms,
    actual_rows,
    shared_hit_blocks,
    shared_read_blocks,
    primary_scan_type,
    notes,
    benchmark_timestamp
FROM performance.benchmark_results
ORDER BY query_id, benchmark_stage;
