-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 06: MATERIALIZATION TRADE-OFF ANALYSIS
-- ============================================================================
-- Purpose:
--   Evaluate candidate materialized views across analytical layers.
--   Analyzes computational savings vs. storage overhead, refresh duration,
--   and data staleness risks.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS performance;

DROP TABLE IF EXISTS performance.materialization_analysis CASCADE;

CREATE TABLE performance.materialization_analysis (
    candidate_name TEXT PRIMARY KEY,
    phase_origin TEXT NOT NULL,
    current_view_latency TEXT NOT NULL,
    query_frequency TEXT NOT NULL,
    storage_footprint_estimate TEXT NOT NULL,
    refresh_overhead TEXT NOT NULL,
    staleness_tolerance TEXT NOT NULL,
    decision TEXT NOT NULL, -- 'KEEP VIEW', 'MATERIALIZE', 'NO CHANGE'
    rationale TEXT NOT NULL
);

INSERT INTO performance.materialization_analysis (
    candidate_name,
    phase_origin,
    current_view_latency,
    query_frequency,
    storage_footprint_estimate,
    refresh_overhead,
    staleness_tolerance,
    decision,
    rationale
)
VALUES
    (
        'analytics.vw_daily_fraud_summary',
        'Phase 9',
        '< 50 ms (with composite indexing)',
        'Dashboard Load (Frequent)',
        '< 50 kB (182 rows)',
        'Low (< 100 ms REFRESH)',
        'Batch Daily',
        'KEEP VIEW',
        'Composite B-Tree index on fact_transaction_clean provides fast Index-Only scans without risk of stale materialized data.'
    ),
    (
        'analytics.vw_weekly_fraud_summary',
        'Phase 9',
        '< 50 ms',
        'Weekly Reporting',
        '< 20 kB (27 rows)',
        'Very Low',
        'Batch Weekly',
        'KEEP VIEW',
        'Standard view performance is fast once indexed; materialization overhead is unjustified.'
    ),
    (
        'analytics.vw_risk_scoring',
        'Phase 10',
        '~200 ms (multi-signal composition)',
        'Ad-hoc / Batch Scoring',
        '~35 MB (590k rows)',
        'High (Full multi-signal recomputation)',
        'Real-time',
        'KEEP VIEW',
        'Underlying analytical dataset is dynamic during scoring runs. Maintaining live view prevents synchronization gaps.'
    ),
    (
        'monitoring.distribution_snapshot',
        'Phase 12',
        '< 5 ms',
        'Automated Run Trigger',
        '< 100 kB',
        'Direct INSERT during fn_record_monitoring_run',
        'Exact Snapshot',
        'NO CHANGE',
        'Already effectively materialized as a dedicated snapshot table populated by stored procedure.'
    );

-- Verification Output
SELECT
    candidate_name,
    phase_origin,
    current_view_latency,
    decision,
    rationale
FROM performance.materialization_analysis
ORDER BY candidate_name;
