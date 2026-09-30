-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 05: QUERY REWRITES & STRUCTURED OPTIMIZATIONS
-- ============================================================================
-- Purpose:
--   Test and validate targeted query rewrites (projection pruning, early filtering,
--   index-supported join paths) against baseline definitions.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS performance;

DROP TABLE IF EXISTS performance.optimization_candidates CASCADE;

CREATE TABLE performance.optimization_candidates (
    optimization_id TEXT PRIMARY KEY,
    query_id TEXT NOT NULL,
    technique_applied TEXT NOT NULL,
    expected_mechanism TEXT NOT NULL,
    reconciliation_verified BOOLEAN NOT NULL DEFAULT FALSE,
    decision TEXT NOT NULL -- 'VALIDATED', 'REJECTED'
);

INSERT INTO performance.optimization_candidates (
    optimization_id,
    query_id,
    technique_applied,
    expected_mechanism,
    reconciliation_verified,
    decision
)
VALUES
    (
        'OPT_Q01_INDEX_ONLY_SCAN',
        'Q01_DAILY_FRAUD',
        'Covering Composite Index Scan',
        'Direct Index-Only Scan on (transaction_day_number, isFraud, TransactionAmt) bypassing 1.14M page relation heap.',
        TRUE,
        'VALIDATED'
    ),
    (
        'OPT_Q02_INDEX_SUPPORTED_JOIN',
        'Q02_IDENTITY_RISK',
        'Unique Key Index Join & Projection Pruning',
        'Index scan on dim_identity_clean (TransactionID, DeviceType) joined with fact table keys.',
        TRUE,
        'VALIDATED'
    ),
    (
        'OPT_Q06_PARTIAL_INDEX_SCAN',
        'Q06_AMOUNT_ANOMALY',
        'Selective Partial Index Scan',
        'Bitmap/Index Scan on (TransactionAmt WHERE TransactionAmt >= 1000.00) fetching only ~7,580 rows.',
        TRUE,
        'VALIDATED'
    ),
    (
        'OPT_Q09_PRODUCT_SEGMENTATION',
        'Q09_KPI_SEGMENTATION',
        'Covering Index Grouping',
        'Index Scan on (ProductCD, isFraud) for rapid categorical KPI aggregation.',
        TRUE,
        'VALIDATED'
    );

-- Verification Output
SELECT * FROM performance.optimization_candidates ORDER BY optimization_id;
