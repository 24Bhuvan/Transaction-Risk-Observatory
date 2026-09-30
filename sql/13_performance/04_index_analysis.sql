-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 04: INDEX COVERAGE & SELECTIVITY ANALYSIS
-- ============================================================================
-- Purpose:
--   Evaluate candidate indexes for analytical join predicates, high-selectivity
--   filters, and grouping keys. Identifies redundant, overlapping, or high-value
--   indexes with documented cost/benefit rationale.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS performance;

DROP TABLE IF EXISTS performance.index_recommendations CASCADE;

CREATE TABLE performance.index_recommendations (
    recommendation_id TEXT PRIMARY KEY,
    target_table TEXT NOT NULL,
    target_columns TEXT NOT NULL,
    index_type TEXT NOT NULL,
    partial_predicate TEXT,
    supporting_query_id TEXT NOT NULL,
    selectivity_estimate NUMERIC(8,4),
    write_overhead_risk TEXT NOT NULL,
    decision TEXT NOT NULL, -- 'RECOMMENDED', 'REJECTED', 'EXISTING'
    rationale TEXT NOT NULL
);

INSERT INTO performance.index_recommendations (
    recommendation_id,
    target_table,
    target_columns,
    index_type,
    partial_predicate,
    supporting_query_id,
    selectivity_estimate,
    write_overhead_risk,
    decision,
    rationale
)
VALUES
    (
        'IDX_FACT_TXID_PK',
        'analytics.fact_transaction_clean',
        'TransactionID',
        'BTREE UNIQUE',
        NULL,
        'Q02_IDENTITY_RISK, Q03_DEVICE_RISK',
        0.0002,
        'LOW (Analytical table is read-heavy)',
        'RECOMMENDED',
        'Essential unique natural key. Enables direct index lookups and index-supported joins against dimension tables.'
    ),
    (
        'IDX_DIM_ID_TXID_PK',
        'analytics.dim_identity_clean',
        'TransactionID',
        'BTREE UNIQUE',
        NULL,
        'Q02_IDENTITY_RISK, Q03_DEVICE_RISK',
        0.0007,
        'LOW (Dimension table is read-heavy)',
        'RECOMMENDED',
        'Essential unique foreign key linkage. Enables index scans and efficient nested loops during identity risk joins.'
    ),
    (
        'IDX_DIM_ID_KEY',
        'analytics.dim_identity_clean',
        'identity_key',
        'BTREE UNIQUE',
        NULL,
        'Q02_IDENTITY_RISK',
        0.0007,
        'LOW',
        'RECOMMENDED',
        'Surrogate key uniqueness enforcement and primary identifier for dimensional lookups.'
    ),
    (
        'IDX_FACT_AMT_ANOMALY',
        'analytics.fact_transaction_clean',
        'TransactionAmt',
        'BTREE PARTIAL',
        'TransactionAmt >= 1000.00',
        'Q06_AMOUNT_ANOMALY',
        1.2836,
        'VERY LOW (< 8,000 index entries)',
        'RECOMMENDED',
        'Highly selective partial index for Phase 10 statistical amount outliers (> $1,000). Replaces 1.14M page seq scan with fast index scan.'
    ),
    (
        'IDX_FACT_DAY_FRAUD_AMT',
        'analytics.fact_transaction_clean',
        'transaction_day_number, isFraud, TransactionAmt',
        'BTREE COMPOSITE',
        NULL,
        'Q01_DAILY_FRAUD',
        100.0000,
        'MEDIUM',
        'RECOMMENDED',
        'Enables Index-Only Scan for daily fraud trends, avoiding wide 394-column relation fetches.'
    ),
    (
        'IDX_FACT_PRODUCT_FRAUD',
        'analytics.fact_transaction_clean',
        'ProductCD, isFraud',
        'BTREE COMPOSITE',
        NULL,
        'Q09_KPI_SEGMENTATION',
        100.0000,
        'LOW',
        'RECOMMENDED',
        'Supports executive segmentation queries across product lines and fraud status via index-only scans.'
    ),
    (
        'IDX_FACT_FULL_TABLE_REDUNDANT',
        'analytics.fact_transaction_clean',
        'V1..V339',
        'BTREE',
        NULL,
        'N/A',
        100.0000,
        'VERY HIGH',
        'REJECTED',
        'Indexing wide V-features provides no analytical benefit and would consume excessive disk storage (> 15 GB).'
    );

-- Verification Output
SELECT
    recommendation_id,
    target_table,
    target_columns,
    index_type,
    COALESCE(partial_predicate, 'NONE') AS predicate,
    supporting_query_id,
    decision
FROM performance.index_recommendations
ORDER BY decision DESC, recommendation_id;
