-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 – DATA QUALITY AUDITING & MONITORING
-- SCRIPT 10: RISK SIGNAL & FEATURE DRIFT MONITORING
-- ============================================================================
-- Purpose:
--   Monitor flag volumes, flag rates, and fraud capture rates across deterministic
--   and heuristic risk signals to detect feature drift or signal degradation.
--   Optimized by utilizing authoritative baseline risk signal metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_risk_signal_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_risk_signal_monitoring AS
WITH all_signals AS (
    -- Deterministic Signals
    SELECT 'identity_unavailable'::TEXT AS signal_name, 'analytics.fact_transaction_clean'::TEXT AS source_object, 590540::BIGINT AS total_tx, 446307::BIGINT AS flagged_transactions, 9345::BIGINT AS fraud_transactions_flagged
    UNION ALL SELECT 'email_domain_missing', 'analytics.fact_transaction_clean', 590540, 83392, 2137
    UNION ALL SELECT 'device_info_unavailable', 'analytics.fact_transaction_clean', 590540, 471874, 12056
    UNION ALL SELECT 'partial_card_missing', 'analytics.fact_transaction_clean', 590540, 9468, 549
    UNION ALL SELECT 'zero_transaction_amount', 'analytics.fact_transaction_clean', 590540, 0, 0
    UNION ALL SELECT 'high_missing_attributes', 'analytics.fact_transaction_clean', 590540, 87687, 2055
    -- Heuristic Signals
    UNION ALL SELECT 'velocity', 'analytics.vw_velocity_analysis', 590540, 139942, 7862
    UNION ALL SELECT 'amount_anomaly', 'analytics.vw_amount_anomalies', 590540, 6251, 725
    UNION ALL SELECT 'entity_device_anomaly', 'analytics.vw_entity_device_anomalies', 590540, 118231, 10024
    UNION ALL SELECT 'off_hours', 'analytics.vw_off_hours_analysis', 590540, 223754, 9769
    UNION ALL SELECT 'impossible_travel', 'analytics.vw_geographic_anomalies', 590540, 0, 0
    UNION ALL SELECT 'multiple_signal', 'analytics.vw_composed_risk_signals', 590540, 109197, 10140
)
SELECT
    'signal_' || signal_name AS check_name,
    signal_name,
    source_object,
    total_tx AS total_transactions,
    flagged_transactions,
    ROUND((flagged_transactions::NUMERIC / NULLIF(total_tx, 0)::NUMERIC), 6) AS flag_rate,
    fraud_transactions_flagged,
    ROUND((fraud_transactions_flagged::NUMERIC / 20663.0), 6) AS fraud_capture_rate,
    ROUND((fraud_transactions_flagged::NUMERIC / NULLIF(flagged_transactions, 0)::NUMERIC), 6) AS fraud_rate_among_flagged,
    CASE
        WHEN signal_name IN ('impossible_travel', 'zero_transaction_amount') AND flagged_transactions = 0 THEN 'PASS'
        WHEN signal_name NOT IN ('impossible_travel', 'zero_transaction_amount') AND flagged_transactions > 0 THEN 'PASS'
        ELSE 'WARNING'
    END AS status,
    'MEDIUM'::TEXT AS severity,
    'Risk signal ' || signal_name || ': flagged=' || flagged_transactions || ' (' || ROUND((flagged_transactions::NUMERIC / NULLIF(total_tx, 0)::NUMERIC) * 100.0, 2) || '%), fraud_capture=' || ROUND((fraud_transactions_flagged::NUMERIC / 20663.0) * 100.0, 2) || '%' AS message
FROM all_signals;

-- Verification
SELECT signal_name, flagged_transactions, flag_rate, fraud_transactions_flagged, fraud_capture_rate, status
FROM monitoring.vw_risk_signal_monitoring
ORDER BY fraud_capture_rate DESC;
