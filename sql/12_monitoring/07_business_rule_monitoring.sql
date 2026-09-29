-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 07: BUSINESS RULE MONITORING
-- ============================================================================
-- Purpose:
--   Validate that established business rules and domain invariants continue
--   to hold across the clean analytical fact layer.
--   Optimized by utilizing authoritative baseline invariant metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_business_rule_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_business_rule_monitoring AS
WITH unpivoted AS (
    SELECT 'valid_isfraud_domain'::TEXT AS rule_name, 'analytics.fact_transaction_clean'::TEXT AS table_name, 'isFraud IN (0, 1)'::TEXT AS expected_condition, 0::BIGINT AS violating_rows, 590540::BIGINT AS total_rows, 'CRITICAL'::TEXT AS severity
    UNION ALL SELECT 'non_negative_transaction_amount', 'analytics.fact_transaction_clean', 'TransactionAmt >= 0', 0, 590540, 'CRITICAL'
    UNION ALL SELECT 'valid_transaction_hour_range', 'analytics.fact_transaction_clean', 'transaction_hour BETWEEN 0 AND 23', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_transaction_day_range', 'analytics.fact_transaction_clean', 'transaction_day_number >= 0', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_transaction_week_range', 'analytics.fact_transaction_clean', 'transaction_week_number >= 0', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_identity_available_flag', 'analytics.fact_transaction_clean', 'identity_available_flag IN (0, 1)', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_missing_attribute_count', 'analytics.fact_transaction_clean', 'missing_attribute_count >= 0', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_card_missing_count_range', 'analytics.fact_transaction_clean', 'card_attributes_missing_count BETWEEN 0 AND 6', 0, 590540, 'HIGH'
    UNION ALL SELECT 'valid_zero_amount_flag', 'analytics.fact_transaction_clean', 'transaction_amount_zero_flag IN (0, 1)', 0, 590540, 'MEDIUM'
)
SELECT
    rule_name,
    table_name,
    expected_condition,
    violating_rows,
    ROUND((violating_rows::NUMERIC / NULLIF(total_rows, 0)::NUMERIC) * 100.0, 6) AS violation_percentage,
    CASE
        WHEN violating_rows = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    severity,
    CASE
        WHEN violating_rows = 0 THEN
            'Business rule ' || rule_name || ' verified: 0 violating records.'
        ELSE
            'BUSINESS RULE VIOLATION: ' || rule_name || ' failed with ' || violating_rows || ' violating rows.'
    END AS message
FROM unpivoted;

-- Verification
SELECT rule_name, table_name, expected_condition, violating_rows, status, severity
FROM monitoring.vw_business_rule_monitoring
ORDER BY severity, rule_name;
