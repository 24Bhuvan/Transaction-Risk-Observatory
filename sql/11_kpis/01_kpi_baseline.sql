-- ============================================================================
-- PHASE 11.1 — FREEZE PHASE 10 BASELINE
-- ============================================================================
-- Purpose:
-- Verify existence of required Phase 9/10 analytical views and establish the
-- authoritative population invariants for Phase 11 KPI reconciliation.
--
-- Known Project Invariants:
--   Total Transactions:          590,540
--   Fraud Transactions:           20,663
--   Non-Fraud Transactions:      569,877
--   Total Transaction Amount: 79,738,948.735
-- ============================================================================

DO $$
DECLARE
    required_objects text[] := ARRAY[
        'vw_transaction_analytics',
        'vw_velocity_analysis',
        'vw_amount_anomalies',
        'vw_entity_device_anomalies',
        'vw_off_hours_analysis',
        'vw_geographic_anomalies',
        'vw_composed_risk_signals',
        'vw_risk_scoring',
        'vw_suspicious_transactions',
        'vw_suspicious_entities'
    ];
    missing_objects text[];
BEGIN
    SELECT COALESCE(array_agg(required_object ORDER BY required_object), ARRAY[]::text[])
    INTO missing_objects
    FROM unnest(required_objects) AS required_object
    WHERE NOT EXISTS (
        SELECT 1
        FROM information_schema.views
        WHERE table_schema = 'analytics'
          AND table_name = required_object
    );

    IF cardinality(missing_objects) > 0 THEN
        RAISE EXCEPTION 'Phase 10 objects missing: %', array_to_string(missing_objects, ', ');
    END IF;
END $$;

DROP VIEW IF EXISTS analytics.kpi_phase_11_baseline CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_phase_11_baseline AS
WITH population AS (
    SELECT
        COUNT(*) AS total_transactions,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_transactions,
        COUNT(*) FILTER (WHERE "isFraud" = 0) AS non_fraud_transactions,
        SUM("TransactionAmt") AS total_transaction_amount,
        SUM("TransactionAmt") FILTER (WHERE "isFraud" = 1) AS fraud_transaction_amount,
        SUM("TransactionAmt") FILTER (WHERE "isFraud" = 0) AS non_fraud_transaction_amount
    FROM analytics.vw_transaction_analytics
)
SELECT
    total_transactions,
    fraud_transactions,
    non_fraud_transactions,
    total_transaction_amount,
    fraud_transaction_amount,
    non_fraud_transaction_amount,
    ROUND(fraud_transactions::numeric / NULLIF(total_transactions, 0), 6) AS fraud_rate,
    total_transactions = 590540 AS transaction_count_invariant_pass,
    fraud_transactions = 20663 AS fraud_count_invariant_pass,
    non_fraud_transactions = 569877 AS non_fraud_count_invariant_pass,
    total_transaction_amount = 79738948.735 AS amount_invariant_pass,
    EXISTS (SELECT 1 FROM analytics.vw_transaction_analytics) AS transaction_view_queryable,
    EXISTS (SELECT 1 FROM analytics.vw_risk_scoring) AS phase_10_score_view_queryable,
    EXISTS (SELECT 1 FROM analytics.vw_composed_risk_signals) AS phase_10_signal_view_queryable
FROM population;

-- Display baseline metrics and invariant status
SELECT
    total_transactions,
    fraud_transactions,
    non_fraud_transactions,
    total_transaction_amount,
    fraud_transaction_amount,
    non_fraud_transaction_amount,
    fraud_rate,
    transaction_count_invariant_pass,
    fraud_count_invariant_pass,
    non_fraud_count_invariant_pass,
    amount_invariant_pass
FROM analytics.kpi_phase_11_baseline;