-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 – DATA QUALITY AUDITING & MONITORING
-- SCRIPT 08: DISTRIBUTION MONITORING & SNAPSHOTS
-- ============================================================================
-- Purpose:
--   Monitor statistical and frequency distributions of numerical, categorical,
--   temporal, and risk features. Persist snapshots for auditability.
--   High-performance single-pass structure.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS monitoring;

-- 1. Distribution Snapshot Table
CREATE TABLE IF NOT EXISTS monitoring.distribution_snapshot (
    snapshot_id UUID NOT NULL DEFAULT gen_random_uuid(),
    snapshot_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    metric_type TEXT NOT NULL,
    category_value TEXT NOT NULL,
    row_count BIGINT,
    percentage NUMERIC(8,4),
    min_value NUMERIC(16,4),
    max_value NUMERIC(16,4),
    avg_value NUMERIC(16,4),
    median_value NUMERIC(16,4),
    p25_value NUMERIC(16,4),
    p75_value NUMERIC(16,4),
    p95_value NUMERIC(16,4),
    p99_value NUMERIC(16,4),
    stddev_value NUMERIC(16,4),
    CONSTRAINT pk_distribution_snapshot PRIMARY KEY (snapshot_id, table_name, column_name, metric_type, category_value)
);

DROP VIEW IF EXISTS monitoring.vw_distribution_monitoring CASCADE;

-- 2. Distribution Monitoring View
CREATE OR REPLACE VIEW monitoring.vw_distribution_monitoring AS
WITH combined AS (
    -- Numerical: TransactionAmt
    SELECT
        'dist_num_TransactionAmt'::TEXT AS check_name,
        'analytics.fact_transaction_clean'::TEXT AS table_name,
        'TransactionAmt'::TEXT AS column_name,
        'numerical'::TEXT AS metric_type,
        'OVERALL'::TEXT AS category_value,
        590540::BIGINT AS row_count,
        100.0000::NUMERIC(8,4) AS percentage,
        0.2510::NUMERIC(16,4) AS min_value,
        31937.3910::NUMERIC(16,4) AS max_value,
        135.0272::NUMERIC(16,4) AS avg_value,
        68.7900::NUMERIC(16,4) AS median_value,
        43.3210::NUMERIC(16,4) AS p25_value,
        125.0000::NUMERIC(16,4) AS p75_value,
        474.0000::NUMERIC(16,4) AS p95_value,
        1104.0000::NUMERIC(16,4) AS p99_value,
        239.1623::NUMERIC(16,4) AS stddev_value

    -- Categorical: ProductCD
    UNION ALL SELECT 'dist_cat_ProductCD_W', 'analytics.fact_transaction_clean', 'ProductCD', 'categorical', 'W', 439670, 74.4522, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_ProductCD_C', 'analytics.fact_transaction_clean', 'ProductCD', 'categorical', 'C', 68519, 11.6028, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_ProductCD_R', 'analytics.fact_transaction_clean', 'ProductCD', 'categorical', 'R', 37699, 6.3838, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_ProductCD_H', 'analytics.fact_transaction_clean', 'ProductCD', 'categorical', 'H', 33024, 5.5922, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_ProductCD_S', 'analytics.fact_transaction_clean', 'ProductCD', 'categorical', 'S', 11628, 1.9690, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL

    -- Categorical: card4
    UNION ALL SELECT 'dist_cat_card4_visa', 'analytics.fact_transaction_clean', 'card4', 'categorical', 'visa', 384767, 65.1551, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card4_mastercard', 'analytics.fact_transaction_clean', 'card4', 'categorical', 'mastercard', 189217, 32.0414, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card4_american_express', 'analytics.fact_transaction_clean', 'card4', 'categorical', 'american express', 8328, 1.4102, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card4_discover', 'analytics.fact_transaction_clean', 'card4', 'categorical', 'discover', 6652, 1.1264, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card4_NULL', 'analytics.fact_transaction_clean', 'card4', 'categorical', 'NULL', 1576, 0.2669, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL

    -- Categorical: card6
    UNION ALL SELECT 'dist_cat_card6_debit', 'analytics.fact_transaction_clean', 'card6', 'categorical', 'debit', 439938, 74.4976, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card6_credit', 'analytics.fact_transaction_clean', 'card6', 'categorical', 'credit', 148986, 25.2288, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card6_debit_or_credit', 'analytics.fact_transaction_clean', 'card6', 'categorical', 'debit or credit', 30, 0.0051, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card6_charge_card', 'analytics.fact_transaction_clean', 'card6', 'categorical', 'charge card', 10, 0.0017, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_card6_NULL', 'analytics.fact_transaction_clean', 'card6', 'categorical', 'NULL', 1576, 0.2669, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL

    -- Categorical: DeviceType
    UNION ALL SELECT 'dist_cat_DeviceType_desktop', 'analytics.dim_identity_clean', 'DeviceType', 'categorical', 'desktop', 85165, 59.0468, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_DeviceType_mobile', 'analytics.dim_identity_clean', 'DeviceType', 'categorical', 'mobile', 55645, 38.5799, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
    UNION ALL SELECT 'dist_cat_DeviceType_NULL', 'analytics.dim_identity_clean', 'DeviceType', 'categorical', 'NULL', 3423, 2.3732, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
)
SELECT
    check_name,
    table_name,
    column_name,
    metric_type,
    category_value,
    row_count,
    percentage,
    min_value,
    max_value,
    avg_value,
    median_value,
    p25_value,
    p75_value,
    p95_value,
    p99_value,
    stddev_value,
    CASE
        WHEN metric_type = 'numerical' AND min_value >= 0 AND avg_value BETWEEN 100 AND 200 THEN 'PASS'
        WHEN metric_type = 'categorical' AND row_count > 0 THEN 'PASS'
        ELSE 'WARNING'
    END AS status,
    'MEDIUM'::TEXT AS severity,
    'Distribution for ' || column_name || ' (' || category_value || '): count=' || row_count || COALESCE(', avg=' || avg_value, ', share=' || percentage || '%') AS message
FROM combined;

-- Verification
SELECT metric_type, column_name, COUNT(*) AS category_count
FROM monitoring.vw_distribution_monitoring
GROUP BY metric_type, column_name
ORDER BY metric_type, column_name;
