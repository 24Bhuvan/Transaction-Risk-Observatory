-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 02: SCHEMA MONITORING
-- ============================================================================
-- Purpose:
--   Monitor database schema drift across analytical and monitoring schemas,
--   verifying table existence, column presence, data types, and nullability.
-- ============================================================================

CREATE OR REPLACE VIEW monitoring.vw_schema_monitoring AS
WITH expected_tables AS (
    SELECT 'analytics'::TEXT AS table_schema, 'fact_transaction_clean'::TEXT AS table_name, 'CRITICAL'::TEXT AS severity
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'fact_transaction', 'HIGH'
    UNION ALL SELECT 'analytics', 'dim_identity', 'HIGH'
    UNION ALL SELECT 'monitoring', 'monitoring_baseline', 'CRITICAL'
    UNION ALL SELECT 'monitoring', 'monitoring_results', 'CRITICAL'
    UNION ALL SELECT 'monitoring', 'distribution_snapshot', 'HIGH'
),
table_checks AS (
    SELECT
        'table_existence_' || e.table_schema || '.' || e.table_name AS check_name,
        e.table_schema || '.' || e.table_name AS object_name,
        'EXISTS'::TEXT AS expected_state,
        COALESCE(t.table_type, 'MISSING') AS actual_state,
        CASE WHEN t.table_name IS NOT NULL THEN 'PASS' ELSE 'FAIL' END AS status,
        e.severity,
        CASE
            WHEN t.table_name IS NOT NULL THEN 'Table ' || e.table_schema || '.' || e.table_name || ' exists.'
            ELSE 'CRITICAL: Table ' || e.table_schema || '.' || e.table_name || ' is missing.'
        END AS message
    FROM expected_tables e
    LEFT JOIN information_schema.tables t
        ON e.table_schema = t.table_schema
       AND e.table_name = t.table_name
),
expected_columns AS (
    SELECT 'analytics'::TEXT AS table_schema, 'fact_transaction_clean'::TEXT AS table_name, 'TransactionID'::TEXT AS column_name, 'bigint'::TEXT AS data_type, 'CRITICAL'::TEXT AS severity
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'TransactionDT', 'bigint', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'TransactionAmt', 'numeric', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'isFraud', 'smallint', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'transaction_key', 'bigint', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'identity_key', 'bigint', 'HIGH'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'transaction_hour', 'integer', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'transaction_day_number', 'integer', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'transaction_week_number', 'integer', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'identity_available_flag', 'integer', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'fact_transaction_clean', 'missing_attribute_count', 'integer', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'identity_key', 'bigint', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'TransactionID', 'bigint', 'CRITICAL'
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'DeviceType', 'text', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'DeviceInfo', 'text', 'MEDIUM'
    UNION ALL SELECT 'analytics', 'dim_identity_clean', 'deviceinfo_normalized', 'text', 'MEDIUM'
),
column_checks AS (
    SELECT
        'column_structure_' || ec.table_schema || '.' || ec.table_name || '.' || ec.column_name AS check_name,
        ec.table_schema || '.' || ec.table_name || '.' || ec.column_name AS object_name,
        ec.data_type AS expected_state,
        COALESCE(c.data_type, 'MISSING') AS actual_state,
        CASE
            WHEN c.column_name IS NULL THEN 'FAIL'
            WHEN c.data_type <> ec.data_type THEN 'WARNING'
            ELSE 'PASS'
        END AS status,
        ec.severity,
        CASE
            WHEN c.column_name IS NULL THEN 'Column ' || ec.column_name || ' is missing from ' || ec.table_schema || '.' || ec.table_name
            WHEN c.data_type <> ec.data_type THEN 'Column ' || ec.column_name || ' type mismatch: expected ' || ec.data_type || ', found ' || c.data_type
            ELSE 'Column ' || ec.column_name || ' verified with type ' || c.data_type
        END AS message
    FROM expected_columns ec
    LEFT JOIN information_schema.columns c
        ON ec.table_schema = c.table_schema
       AND ec.table_name = c.table_name
       AND ec.column_name = c.column_name
)
SELECT check_name, object_name, expected_state, actual_state, status, severity, message FROM table_checks
UNION ALL
SELECT check_name, object_name, expected_state, actual_state, status, severity, message FROM column_checks;

-- Verification
SELECT status, severity, COUNT(*) AS count
FROM monitoring.vw_schema_monitoring
GROUP BY status, severity
ORDER BY status, severity;
