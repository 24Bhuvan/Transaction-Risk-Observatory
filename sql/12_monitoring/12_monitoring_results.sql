-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 12: PERSISTENT MONITORING RESULTS & AUDIT LOGGING
-- ============================================================================
-- Purpose:
--   Create the persistent audit results table and logging function to record
--   monitoring execution outcomes with unique run UUIDs.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS monitoring;

-- 1. Create Monitoring Results Table
CREATE TABLE IF NOT EXISTS monitoring.monitoring_results (
    result_id BIGSERIAL PRIMARY KEY,
    monitoring_run_id UUID NOT NULL,
    run_timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_category TEXT NOT NULL,
    check_name TEXT NOT NULL,
    source_object TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    expected_value TEXT,
    actual_value TEXT,
    difference TEXT,
    threshold TEXT,
    severity TEXT NOT NULL,
    status TEXT NOT NULL,
    message TEXT NOT NULL
);

-- 2. Indexes for Audit Performance
CREATE INDEX IF NOT EXISTS idx_monitoring_results_run_id ON monitoring.monitoring_results (monitoring_run_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_results_timestamp ON monitoring.monitoring_results (run_timestamp);
CREATE INDEX IF NOT EXISTS idx_monitoring_results_status ON monitoring.monitoring_results (status);
CREATE INDEX IF NOT EXISTS idx_monitoring_results_category ON monitoring.monitoring_results (check_category);

DROP FUNCTION IF EXISTS monitoring.fn_record_monitoring_run(uuid) CASCADE;

-- 3. Monitoring Execution & Recording Function
CREATE OR REPLACE FUNCTION monitoring.fn_record_monitoring_run(
    p_run_id UUID DEFAULT gen_random_uuid()
)
RETURNS TABLE (
    monitoring_run_id UUID,
    total_checks BIGINT,
    passed_checks BIGINT,
    warning_checks BIGINT,
    failed_checks BIGINT,
    critical_failures BIGINT,
    overall_status TEXT
) AS $$
DECLARE
    v_total BIGINT;
    v_passed BIGINT;
    v_warning BIGINT;
    v_failed BIGINT;
    v_critical_failed BIGINT;
    v_overall TEXT;
BEGIN
    -- Record all alert rules into persistent results table
    INSERT INTO monitoring.monitoring_results (
        monitoring_run_id,
        run_timestamp,
        check_category,
        check_name,
        source_object,
        metric_name,
        expected_value,
        actual_value,
        difference,
        threshold,
        severity,
        status,
        message
    )
    SELECT
        p_run_id,
        CURRENT_TIMESTAMP,
        check_category,
        check_name,
        source_object,
        metric_name,
        expected_value,
        actual_value,
        difference,
        threshold,
        severity,
        status,
        message
    FROM monitoring.vw_anomaly_alert_rules;

    -- Also record distribution snapshot
    INSERT INTO monitoring.distribution_snapshot (
        snapshot_id,
        snapshot_timestamp,
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
        stddev_value
    )
    SELECT
        p_run_id,
        CURRENT_TIMESTAMP,
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
        stddev_value
    FROM monitoring.vw_distribution_monitoring
    ON CONFLICT (snapshot_id, table_name, column_name, metric_type, category_value) DO NOTHING;

    -- Aggregate Run Metrics
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE r.status = 'PASS'),
        COUNT(*) FILTER (WHERE r.status = 'WARNING'),
        COUNT(*) FILTER (WHERE r.status = 'FAIL'),
        COUNT(*) FILTER (WHERE r.status = 'FAIL' AND r.severity = 'CRITICAL')
    INTO
        v_total,
        v_passed,
        v_warning,
        v_failed,
        v_critical_failed
    FROM monitoring.monitoring_results r
    WHERE r.monitoring_run_id = p_run_id;

    IF v_critical_failed > 0 OR v_failed > 0 THEN
        v_overall := 'FAIL';
    ELSIF v_warning > 0 THEN
        v_overall := 'WARNING';
    ELSE
        v_overall := 'PASS';
    END IF;

    RETURN QUERY SELECT
        p_run_id,
        v_total,
        v_passed,
        v_warning,
        v_failed,
        v_critical_failed,
        v_overall;
END;
$$ LANGUAGE plpgsql;
