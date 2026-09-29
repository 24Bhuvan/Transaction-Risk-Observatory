-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 12 — DATA QUALITY AUDITING & MONITORING
-- SCRIPT 13: UNIFIED MONITORING RUNNER
-- ============================================================================
-- Purpose:
--   Execute all monitoring check layers in deterministic order, record the run
--   into persistent audit storage, and display summary metrics by category.
-- ============================================================================

-- 1. Execute a new monitoring run
DO $$
DECLARE
    v_run_id UUID := gen_random_uuid();
    v_rec RECORD;
BEGIN
    RAISE NOTICE 'Starting Phase 12 Monitoring Run: %', v_run_id;
    
    -- Call the recording function
    SELECT * INTO v_rec FROM monitoring.fn_record_monitoring_run(v_run_id);
    
    RAISE NOTICE 'Run % Complete: Total=%, Passed=%, Warning=%, Failed=%, Critical Failed=%, Overall Status=%',
        v_rec.monitoring_run_id, v_rec.total_checks, v_rec.passed_checks, v_rec.warning_checks, v_rec.failed_checks, v_rec.critical_failures, v_rec.overall_status;
END $$;

-- 2. Display Latest Run Summary by Category
WITH latest_run AS (
    SELECT monitoring_run_id
    FROM monitoring.monitoring_results
    ORDER BY run_timestamp DESC
    LIMIT 1
)
SELECT
    r.check_category,
    COUNT(*) AS total_checks,
    COUNT(*) FILTER (WHERE r.status = 'PASS') AS passed_count,
    COUNT(*) FILTER (WHERE r.status = 'WARNING') AS warning_count,
    COUNT(*) FILTER (WHERE r.status = 'FAIL') AS failed_count,
    COUNT(*) FILTER (WHERE r.status = 'FAIL' AND r.severity = 'CRITICAL') AS critical_failed_count,
    CASE
        WHEN COUNT(*) FILTER (WHERE r.status = 'FAIL') > 0 THEN 'FAIL'
        WHEN COUNT(*) FILTER (WHERE r.status = 'WARNING') > 0 THEN 'WARNING'
        ELSE 'PASS'
    END AS category_status
FROM monitoring.monitoring_results r
JOIN latest_run lr ON r.monitoring_run_id = lr.monitoring_run_id
GROUP BY r.check_category
ORDER BY r.check_category;

-- 3. Display Overall Latest Execution Status
WITH latest_run AS (
    SELECT monitoring_run_id
    FROM monitoring.monitoring_results
    ORDER BY run_timestamp DESC
    LIMIT 1
)
SELECT
    r.monitoring_run_id,
    MIN(r.run_timestamp) AS run_timestamp,
    COUNT(*) AS total_checks_evaluated,
    COUNT(*) FILTER (WHERE r.status = 'PASS') AS total_passed,
    COUNT(*) FILTER (WHERE r.status = 'WARNING') AS total_warnings,
    COUNT(*) FILTER (WHERE r.status = 'FAIL') AS total_failures,
    CASE
        WHEN COUNT(*) FILTER (WHERE r.status = 'FAIL') > 0 THEN 'FAIL'
        WHEN COUNT(*) FILTER (WHERE r.status = 'WARNING') > 0 THEN 'WARNING'
        ELSE 'PASS'
    END AS final_run_verdict
FROM monitoring.monitoring_results r
JOIN latest_run lr ON r.monitoring_run_id = lr.monitoring_run_id
GROUP BY r.monitoring_run_id;
