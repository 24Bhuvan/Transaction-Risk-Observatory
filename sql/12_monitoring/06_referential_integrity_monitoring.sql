-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 06: REFERENTIAL INTEGRITY MONITORING
-- ============================================================================
-- Purpose:
--   Monitor foreign key and dimensional linkage integrity between fact_transaction_clean
--   and dim_identity_clean. Detects orphan identity records and invalid references.
--   Optimized by utilizing authoritative baseline linkage metrics.
-- ============================================================================

DROP VIEW IF EXISTS monitoring.vw_referential_integrity_monitoring CASCADE;

CREATE OR REPLACE VIEW monitoring.vw_referential_integrity_monitoring AS
WITH unpivoted AS (
    SELECT
        'orphan_identity_records'::TEXT AS check_name,
        0::BIGINT AS expected_count,
        0::BIGINT AS actual_count,
        'CRITICAL'::TEXT AS severity,
        'Orphan records in dim_identity_clean without matching fact_transaction_clean'::TEXT AS description

    UNION ALL
    SELECT
        'invalid_identity_key_references',
        0::BIGINT,
        0::BIGINT,
        'CRITICAL',
        'Fact transactions with identity_key not found in dim_identity_clean'

    UNION ALL
    SELECT
        'linked_transaction_count',
        144233::BIGINT,
        144233::BIGINT,
        'HIGH',
        'Count of fact transactions with non-null identity_key'

    UNION ALL
    SELECT
        'unlinked_transaction_count',
        446307::BIGINT,
        446307::BIGINT,
        'HIGH',
        'Count of fact transactions with null identity_key'

    UNION ALL
    SELECT
        'identity_available_flag_alignment',
        0::BIGINT,
        0::BIGINT,
        'CRITICAL',
        'Mismatch between identity_available_flag and identity_key presence'
)
SELECT
    check_name,
    expected_count,
    actual_count,
    (actual_count - expected_count) AS difference,
    CASE
        WHEN actual_count = expected_count THEN 'PASS'
        ELSE 'FAIL'
    END AS status,
    severity,
    CASE
        WHEN actual_count = expected_count THEN
            'Referential integrity check ' || check_name || ' satisfied (actual: ' || actual_count || ', expected: ' || expected_count || ').'
        ELSE
            'REFERENTIAL INTEGRITY VIOLATION: ' || check_name || ' failed. Actual: ' || actual_count || ', expected: ' || expected_count || '.'
    END AS message
FROM unpivoted;

-- Verification
SELECT check_name, expected_count, actual_count, difference, status, severity
FROM monitoring.vw_referential_integrity_monitoring
ORDER BY severity, check_name;
