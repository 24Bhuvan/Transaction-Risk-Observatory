-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 02: ANALYTICAL QUERY INVENTORY
-- ============================================================================
-- Purpose:
--   Catalog and document the primary analytical workloads across Phases 9–12,
--   detailing their business purpose, schema dependencies, structural complexity,
--   and candidate status for empirical benchmarking.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS performance;

DROP TABLE IF EXISTS performance.query_inventory CASCADE;

CREATE TABLE performance.query_inventory (
    query_id TEXT PRIMARY KEY,
    phase_origin TEXT NOT NULL,
    query_name TEXT NOT NULL,
    source_object TEXT NOT NULL,
    workload_type TEXT NOT NULL,
    business_purpose TEXT NOT NULL,
    complexity TEXT NOT NULL,
    priority TEXT NOT NULL,
    candidate_for_benchmark BOOLEAN NOT NULL DEFAULT TRUE,
    selection_rationale TEXT NOT NULL
);

INSERT INTO performance.query_inventory (
    query_id,
    phase_origin,
    query_name,
    source_object,
    workload_type,
    business_purpose,
    complexity,
    priority,
    candidate_for_benchmark,
    selection_rationale
)
VALUES
    (
        'Q01_DAILY_FRAUD',
        'Phase 9',
        'Daily Fraud Trend Summary',
        'analytics.vw_daily_fraud_summary',
        'Temporal Aggregation',
        'Tracks day-by-day fraud volume, fraud rates, and exposure amounts for operational dashboards.',
        'Medium',
        'HIGH',
        TRUE,
        'Heavy temporal grouping over 590k fact rows requiring aggregation across isFraud and TransactionAmt.'
    ),
    (
        'Q02_IDENTITY_RISK',
        'Phase 9',
        'Identity Risk Analysis',
        'analytics.vw_identity_risk_analysis',
        'Dimensional Join & Aggregation',
        'Analyzes fraud concentration by identity availability, device info presence, and network characteristics.',
        'High',
        'HIGH',
        TRUE,
        'Cross-table join between fact_transaction_clean (590k) and dim_identity_clean (144k) on TransactionID key linkage.'
    ),
    (
        'Q03_DEVICE_RISK',
        'Phase 9',
        'Device Risk Analysis',
        'analytics.vw_device_risk_analysis',
        'Categorical Grouping & Filtering',
        'Evaluates fraud rate differentials across DeviceType and normalized device categories.',
        'High',
        'MEDIUM',
        TRUE,
        'Joins fact and identity dimensions; filters wide dimension rows with frequency thresholds.'
    ),
    (
        'Q04_CARD_RISK',
        'Phase 9',
        'Card Network Risk Analysis',
        'analytics.vw_card_risk_analysis',
        'Categorical Aggregation',
        'Evaluates fraud risk distribution across card issuers (card4) and card funding types (card6).',
        'Low',
        'MEDIUM',
        TRUE,
        'Evaluates multi-attribute categorical grouping directly over fact table.'
    ),
    (
        'Q05_VELOCITY_ANOMALY',
        'Phase 10',
        'Velocity Anomaly Detection',
        'analytics.vw_velocity_analysis',
        'Sliding Window Aggregation',
        'Detects high-frequency transaction bursts within entity windows.',
        'High',
        'HIGH',
        TRUE,
        'Sliding window partition aggregations over fact table transaction series.'
    ),
    (
        'Q06_AMOUNT_ANOMALY',
        'Phase 10',
        'Amount Anomaly Detection',
        'analytics.vw_amount_anomalies',
        'Statistical Filtering',
        'Identifies statistical amount outliers (> $1,000 and threshold transactions).',
        'Medium',
        'HIGH',
        TRUE,
        'Selective filtering on TransactionAmt; candidate for partial btree index scan.'
    ),
    (
        'Q07_ENTITY_DEVICE_ANOMALY',
        'Phase 10',
        'Entity Device Mismatch Anomaly',
        'analytics.vw_entity_device_anomalies',
        'Multi-attribute Aggregation',
        'Flags identity-device mismatches and multiple browser/device hops per user entity.',
        'High',
        'HIGH',
        TRUE,
        'Multi-column entity grouping and join with identity dimension.'
    ),
    (
        'Q08_RISK_SCORING',
        'Phase 10',
        'Composite Multi-Signal Risk Scoring',
        'analytics.vw_risk_scoring',
        'Weighted Composite Scoring',
        'Combines deterministic and heuristic signals into composite score (0-100) and risk tiers.',
        'High',
        'HIGH',
        TRUE,
        'Core Phase 10 engine uniting multiple anomaly detection risk components.'
    ),
    (
        'Q09_KPI_SEGMENTATION',
        'Phase 11',
        'Executive Product & Card Segmentation',
        'analytics.kpi_segmentation_summary',
        'Multi-dimensional Aggregation',
        'Produces executive breakdown of fraud volumes by ProductCD and payment networks.',
        'Medium',
        'MEDIUM',
        TRUE,
        'Multi-level aggregation supporting executive KPI reporting.'
    ),
    (
        'Q10_MONITORING_RULES',
        'Phase 12',
        'Automated Anomaly Alert Rules Evaluation',
        'monitoring.vw_anomaly_alert_rules',
        'Read-Only Quality Metric Scan',
        'Evaluates platform anomaly rules against monitoring baseline and results.',
        'Medium',
        'HIGH',
        TRUE,
        'Read-only validation of active monitoring alert thresholds across observed checks.'
    );

-- Verification Output
SELECT
    query_id,
    phase_origin,
    query_name,
    workload_type,
    complexity,
    priority,
    candidate_for_benchmark
FROM performance.query_inventory
ORDER BY query_id;
