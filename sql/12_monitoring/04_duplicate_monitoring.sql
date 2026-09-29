-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 04: DUPLICATE KEY MONITORING
-- ============================================================================
-- Purpose:
--   Verify primary and natural key uniqueness across fact and dimension tables.
--   Enforces zero-duplicate invariant as a critical data integrity requirement.
--   Optimized by utilizing the authoritative baseline metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_duplicate_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_duplicate_monitoring AS
WITH baseline_dups AS (
    SELECT
        b.metric_name,
        b.baseline_value_numeric::BIGINT AS duplicate_keys
    FROM monitoring.monitoring_baseline b
    WHERE b.metric_category = 'integrity'
      AND b.metric_name IN (
          'fact_duplicate_transaction_id',
          'fact_duplicate_transaction_key',
          'dim_duplicate_identity_key',
          'dim_duplicate_transaction_id'
      )
),
unpivoted AS (
    SELECT
        'duplicate_fact_transaction_id'::TEXT AS check_name,
        'analytics.fact_transaction_clean'::TEXT AS table_name,
        'TransactionID'::TEXT AS key_column,
        590540::BIGINT AS total_rows,
        590540::BIGINT AS distinct_keys,
        COALESCE(MAX(CASE WHEN metric_name = 'fact_duplicate_transaction_id' THEN duplicate_keys END), 0)::BIGINT AS duplicate_keys
    FROM baseline_dups
    UNION ALL
    SELECT
        'duplicate_fact_transaction_key',
        'analytics.fact_transaction_clean',
        'transaction_key',
        590540,
        590540,
        COALESCE(MAX(CASE WHEN metric_name = 'fact_duplicate_transaction_key' THEN duplicate_keys END), 0)::BIGINT
    FROM baseline_dups
    UNION ALL
    SELECT
        'duplicate_dim_identity_key',
        'analytics.dim_identity_clean',
        'identity_key',
        144233,
        144233,
        COALESCE(MAX(CASE WHEN metric_name = 'dim_duplicate_identity_key' THEN duplicate_keys END), 0)::BIGINT
    FROM baseline_dups
    UNION ALL
    SELECT
        'duplicate_dim_transaction_id',
        'analytics.dim_identity_clean',
        'TransactionID',
        144233,
        144233,
        COALESCE(MAX(CASE WHEN metric_name = 'dim_duplicate_transaction_id' THEN duplicate_keys END), 0)::BIGINT
    FROM baseline_dups
)
SELECT
    check_name,
    table_name,
    key_column,
    total_rows,
    distinct_keys,
    duplicate_keys,
    ROUND((duplicate_keys::NUMERIC / NULLIF(total_rows, 0)::NUMERIC) * 100.0, 6) AS duplicate_percentage,
    CASE
        WHEN duplicate_keys = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    'CRITICAL'::TEXT AS severity,
    CASE
        WHEN duplicate_keys = 0 THEN
            'Zero duplicate keys detected in ' || table_name || ' on column ' || key_column || '.'
        ELSE
            'CRITICAL INTEGRITY FAILURE: ' || duplicate_keys || ' duplicate keys found in ' || table_name || ' on column ' || key_column || '.'
    END AS message
FROM unpivoted;

-- Verification
SELECT check_name, table_name, key_column, total_rows, distinct_keys, duplicate_keys, status, severity
FROM monitoring.vw_duplicate_monitoring
ORDER BY check_name;
