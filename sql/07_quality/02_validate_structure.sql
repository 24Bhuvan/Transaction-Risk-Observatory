-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.2 — VALIDATE STRUCTURE
-- ============================================================

WITH required_columns AS (
    SELECT 'analytics.fact_transaction_clean' AS table_name, 'transaction_key' AS column_name, 'BIGINT' AS expected_type
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'identity_key', 'BIGINT'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'TransactionID', 'BIGINT'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'TransactionDT', 'BIGINT'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'TransactionAmt', 'NUMERIC'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'isFraud', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'ProductCD', 'TEXT'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'dist2_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'D7_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'R_emaildomain_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card2_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card3_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card5_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card6_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card_attributes_missing_count', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'card_attributes_partial_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'transaction_day_number', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'transaction_hour', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'transaction_week_number', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'transaction_amount_zero_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'transaction_amount_log', 'NUMERIC'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'identity_available_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'email_domain_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'device_info_available_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.fact_transaction_clean', 'missing_attribute_count', 'INTEGER'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'identity_key', 'BIGINT'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'TransactionID', 'BIGINT'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'DeviceType', 'TEXT'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'DeviceInfo', 'TEXT'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'deviceinfo_normalized', 'TEXT'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'deviceinfo_missing_flag', 'INTEGER'
    UNION ALL SELECT 'analytics.dim_identity_clean', 'email_domain_missing_flag', 'INTEGER'
), actual_columns AS (
    SELECT table_schema || '.' || table_name AS table_name,
           column_name,
           UPPER(data_type) AS data_type
    FROM information_schema.columns
    WHERE table_schema = 'analytics'
      AND table_name IN ('fact_transaction_clean', 'dim_identity_clean')
), structure_validation AS (
    SELECT rc.table_name,
           rc.column_name,
           rc.expected_type,
           ac.data_type AS actual_type,
           CASE
               WHEN ac.column_name IS NULL THEN 'MISSING'
               ELSE 'FOUND'
           END AS status
    FROM required_columns rc
    LEFT JOIN actual_columns ac
      ON rc.table_name = ac.table_name
     AND rc.column_name = ac.column_name
), final_result AS (
    SELECT
        table_name,
        column_name,
        expected_type,
        actual_type,
        status,
        CASE
            WHEN status = 'FOUND' AND expected_type = COALESCE(actual_type, '') THEN 'PASS'
            ELSE 'FAIL'
        END AS validation_status
    FROM structure_validation
)
SELECT
    table_name,
    column_name,
    expected_type,
    actual_type,
    status,
    validation_status
FROM final_result
ORDER BY table_name, column_name;
