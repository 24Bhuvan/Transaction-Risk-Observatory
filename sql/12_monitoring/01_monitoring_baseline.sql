-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 01: MONITORING BASELINE CAPTURE
-- ============================================================================
-- Purpose:
--   Establish and persist the authoritative analytical baseline metrics and
--   data-quality invariants against which future monitoring runs are evaluated.
--
-- Invariants (Hard Constraints):
--   - Fact Row Count: 590,540
--   - Identity Row Count: 144,233
--   - Duplicate Keys: 0
--   - Critical NULLs: 0
--   - Invalid isFraud: 0
--   - Negative Amounts: 0
--   - Invalid Transaction Hour: 0
--   - Orphan Identity Records: 0
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS monitoring;

CREATE TABLE IF NOT EXISTS monitoring.monitoring_baseline (
    metric_category TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    source_object TEXT NOT NULL,
    baseline_value_numeric NUMERIC,
    baseline_value_text TEXT,
    is_hard_invariant BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_monitoring_baseline PRIMARY KEY (metric_category, metric_name)
);

-- Populate or refresh baseline metrics
INSERT INTO monitoring.monitoring_baseline (
    metric_category,
    metric_name,
    source_object,
    baseline_value_numeric,
    baseline_value_text,
    is_hard_invariant,
    created_at
)
VALUES
    -- Population Baseline
    ('population', 'total_transactions', 'analytics.fact_transaction_clean', 590540, '590540', TRUE, CURRENT_TIMESTAMP),
    ('population', 'total_identities', 'analytics.dim_identity_clean', 144233, '144233', TRUE, CURRENT_TIMESTAMP),
    ('population', 'fraud_transactions', 'analytics.fact_transaction_clean', 20663, '20663', TRUE, CURRENT_TIMESTAMP),
    ('population', 'non_fraud_transactions', 'analytics.fact_transaction_clean', 569877, '569877', TRUE, CURRENT_TIMESTAMP),
    ('population', 'fraud_rate', 'analytics.fact_transaction_clean', 0.034990, '3.4990%', FALSE, CURRENT_TIMESTAMP),

    -- Monetary Baseline
    ('monetary', 'total_transaction_amount', 'analytics.fact_transaction_clean', 79738948.735, '$79,738,948.735', TRUE, CURRENT_TIMESTAMP),
    ('monetary', 'fraud_transaction_amount', 'analytics.fact_transaction_clean', 3083844.860, '$3,083,844.860', TRUE, CURRENT_TIMESTAMP),
    ('monetary', 'non_fraud_transaction_amount', 'analytics.fact_transaction_clean', 76655103.875, '$76,655,103.875', TRUE, CURRENT_TIMESTAMP),
    ('monetary', 'average_transaction_amount', 'analytics.fact_transaction_clean', 135.0272, '$135.0272', FALSE, CURRENT_TIMESTAMP),
    ('monetary', 'average_fraud_amount', 'analytics.fact_transaction_clean', 149.2448, '$149.2448', FALSE, CURRENT_TIMESTAMP),
    ('monetary', 'average_non_fraud_amount', 'analytics.fact_transaction_clean', 134.5117, '$134.5117', FALSE, CURRENT_TIMESTAMP),
    ('monetary', 'median_transaction_amount', 'analytics.fact_transaction_clean', 68.790, '$68.790', FALSE, CURRENT_TIMESTAMP),
    ('monetary', 'fraud_amount_share', 'analytics.fact_transaction_clean', 0.038674, '3.8674%', FALSE, CURRENT_TIMESTAMP),

    -- Linkage / Referential Integrity Baseline
    ('linkage', 'identity_linked_transactions', 'analytics.fact_transaction_clean', 144233, '144233', TRUE, CURRENT_TIMESTAMP),
    ('linkage', 'identity_unlinked_transactions', 'analytics.fact_transaction_clean', 446307, '446307', TRUE, CURRENT_TIMESTAMP),
    ('linkage', 'identity_linkage_rate', 'analytics.fact_transaction_clean', 0.244239, '24.4239%', FALSE, CURRENT_TIMESTAMP),
    ('linkage', 'orphan_identity_count', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),

    -- Integrity Invariants
    ('integrity', 'fact_duplicate_transaction_id', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'fact_duplicate_transaction_key', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'dim_duplicate_identity_key', 'analytics.dim_identity_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'dim_duplicate_transaction_id', 'analytics.dim_identity_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'critical_null_transaction_id', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'critical_null_transaction_dt', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'critical_null_transaction_amt', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('integrity', 'critical_null_isfraud', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),

    -- Business Rule Invariants
    ('business_rule', 'invalid_isfraud_domain', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('business_rule', 'negative_transaction_amount', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('business_rule', 'invalid_transaction_hour', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('business_rule', 'invalid_identity_available_flag', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('business_rule', 'invalid_missing_attribute_count', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),
    ('business_rule', 'invalid_card_missing_count', 'analytics.fact_transaction_clean', 0, '0', TRUE, CURRENT_TIMESTAMP),

    -- Risk Signals Baseline (Phase 10 & 11)
    ('risk_signals', 'signal_velocity_flagged_count', 'analytics.vw_velocity_analysis', 139942, '139942', FALSE, CURRENT_TIMESTAMP),
    ('risk_signals', 'signal_amount_anomaly_flagged_count', 'analytics.vw_amount_anomalies', 6251, '6251', FALSE, CURRENT_TIMESTAMP),
    ('risk_signals', 'signal_entity_device_flagged_count', 'analytics.vw_entity_device_anomalies', 118231, '118231', FALSE, CURRENT_TIMESTAMP),
    ('risk_signals', 'signal_off_hours_flagged_count', 'analytics.vw_off_hours_analysis', 223754, '223754', FALSE, CURRENT_TIMESTAMP),
    ('risk_signals', 'signal_impossible_travel_flagged_count', 'analytics.vw_geographic_anomalies', 0, '0', FALSE, CURRENT_TIMESTAMP),
    ('risk_signals', 'signal_multiple_signals_flagged_count', 'analytics.vw_composed_risk_signals', 109197, '109197', FALSE, CURRENT_TIMESTAMP),

    -- Risk Score Distribution Baseline
    ('risk_score', 'risk_band_high_count', 'analytics.vw_risk_scoring', 14859, '14859', FALSE, CURRENT_TIMESTAMP),
    ('risk_score', 'risk_band_medium_count', 'analytics.vw_risk_scoring', 213393, '213393', FALSE, CURRENT_TIMESTAMP),
    ('risk_score', 'risk_band_low_count', 'analytics.vw_risk_scoring', 362288, '362288', FALSE, CURRENT_TIMESTAMP)

ON CONFLICT (metric_category, metric_name)
DO UPDATE SET
    source_object = EXCLUDED.source_object,
    baseline_value_numeric = EXCLUDED.baseline_value_numeric,
    baseline_value_text = EXCLUDED.baseline_value_text,
    is_hard_invariant = EXCLUDED.is_hard_invariant,
    created_at = CURRENT_TIMESTAMP;

-- Verification query
SELECT
    metric_category,
    COUNT(*) AS metric_count,
    COUNT(*) FILTER (WHERE is_hard_invariant) AS invariant_count
FROM monitoring.monitoring_baseline
GROUP BY metric_category
ORDER BY metric_category;
