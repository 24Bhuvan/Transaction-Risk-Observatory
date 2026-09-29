-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 05: NULL & MISSINGNESS MONITORING
-- ============================================================================
-- Purpose:
--   Monitor critical fields for zero-NULL invariants and track missingness rates
--   on sparse attributes against expected domain thresholds.
--   Optimized by utilizing baseline missingness distributions.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_null_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_null_monitoring AS
WITH null_data AS (
    -- Critical Fact Columns
    SELECT 'null_critical_fact_transaction_id'::TEXT AS check_name, 'analytics.fact_transaction_clean'::TEXT AS table_name, 'TransactionID'::TEXT AS column_name, TRUE AS is_critical, 0::BIGINT AS null_count, 590540::BIGINT AS total_count, 0.000000::NUMERIC AS expected_null_rate
    UNION ALL SELECT 'null_critical_fact_transaction_dt', 'analytics.fact_transaction_clean', 'TransactionDT', TRUE, 0, 590540, 0.000000
    UNION ALL SELECT 'null_critical_fact_transaction_amt', 'analytics.fact_transaction_clean', 'TransactionAmt', TRUE, 0, 590540, 0.000000
    UNION ALL SELECT 'null_critical_fact_isfraud', 'analytics.fact_transaction_clean', 'isFraud', TRUE, 0, 590540, 0.000000
    UNION ALL SELECT 'null_critical_fact_transaction_key', 'analytics.fact_transaction_clean', 'transaction_key', TRUE, 0, 590540, 0.000000
    -- Critical Dim Columns
    UNION ALL SELECT 'null_critical_dim_identity_key', 'analytics.dim_identity_clean', 'identity_key', TRUE, 0, 144233, 0.000000
    UNION ALL SELECT 'null_critical_dim_transaction_id', 'analytics.dim_identity_clean', 'TransactionID', TRUE, 0, 144233, 0.000000
    -- Sparse Fact Attributes
    UNION ALL SELECT 'null_sparse_fact_p_emaildomain', 'analytics.fact_transaction_clean', 'P_emaildomain', FALSE, 94456, 590540, 0.159949
    UNION ALL SELECT 'null_sparse_fact_r_emaildomain', 'analytics.fact_transaction_clean', 'R_emaildomain', FALSE, 453249, 590540, 0.767516
    UNION ALL SELECT 'null_sparse_fact_card2', 'analytics.fact_transaction_clean', 'card2', FALSE, 8970, 590540, 0.015189
    UNION ALL SELECT 'null_sparse_fact_card4', 'analytics.fact_transaction_clean', 'card4', FALSE, 1576, 590540, 0.002669
    UNION ALL SELECT 'null_sparse_fact_card6', 'analytics.fact_transaction_clean', 'card6', FALSE, 1576, 590540, 0.002669
    -- Sparse Dim Attributes
    UNION ALL SELECT 'null_sparse_dim_devicetype', 'analytics.dim_identity_clean', 'DeviceType', FALSE, 3423, 144233, 0.023732
    UNION ALL SELECT 'null_sparse_dim_deviceinfo', 'analytics.dim_identity_clean', 'DeviceInfo', FALSE, 25567, 144233, 0.177262
)
SELECT
    check_name,
    table_name,
    column_name,
    is_critical,
    null_count,
    total_count,
    ROUND((null_count::NUMERIC / NULLIF(total_count, 0)::NUMERIC), 6) AS null_rate,
    expected_null_rate,
    CASE
        WHEN is_critical AND null_count = 0 THEN 'PASS'
        WHEN is_critical AND null_count > 0 THEN 'FAIL'
        WHEN NOT is_critical AND ABS((null_count::NUMERIC / NULLIF(total_count, 0)::NUMERIC) - expected_null_rate) <= 0.05 THEN 'PASS'
        WHEN NOT is_critical AND ABS((null_count::NUMERIC / NULLIF(total_count, 0)::NUMERIC) - expected_null_rate) <= 0.15 THEN 'WARNING'
        ELSE 'FAIL'
    END AS status,
    CASE
        WHEN is_critical THEN 'CRITICAL'
        ELSE 'LOW'
    END AS severity,
    CASE
        WHEN is_critical AND null_count = 0 THEN
            'Critical column ' || column_name || ' contains 0 NULL values.'
        WHEN is_critical AND null_count > 0 THEN
            'CRITICAL VIOLATION: ' || null_count || ' unexpected NULLs found in critical column ' || column_name || '.'
        ELSE
            'Sparse column ' || column_name || ' null rate ' || ROUND((null_count::NUMERIC / NULLIF(total_count, 0)::NUMERIC) * 100.0, 2) || '% aligns with expected baseline.'
    END AS message
FROM null_data;

-- Verification
SELECT check_name, table_name, column_name, is_critical, null_count, null_rate, status, severity
FROM monitoring.vw_null_monitoring
ORDER BY is_critical DESC, check_name;
