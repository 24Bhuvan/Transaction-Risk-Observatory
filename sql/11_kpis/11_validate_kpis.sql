-- ============================================================================
-- PHASE 11.12 — KPI VALIDATION & RECONCILIATION
-- ============================================================================
-- Purpose:
-- Perform exhaustive automated reconciliation checks across all Phase 11 KPI views
-- against the authoritative population invariants.
--
-- Checks:
--   1. transaction_totals = 590,540
--   2. fraud_totals = 20,663
--   3. non_fraud_totals = 569,877
--   4. amount_totals = 79,738,948.735
--   5. daily_partition = 590,540 transactions & 20,663 fraud
--   6. weekly_partition = 590,540 transactions & 20,663 fraud
--   7. hourly_partition = 590,540 transactions & 20,663 fraud
--   8. product_partition = 590,540 transactions & 20,663 fraud
--   9. identity_availability_partition = 590,540 transactions & 20,663 fraud
--  10. risk_band_partition = 590,540 transactions & 20,663 fraud
--  11. score_partition = 590,540 transactions & 20,663 fraud
--  12. signal_family_complete = 6 Phase 10 signals evaluated
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_phase_11_validation CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_phase_11_validation AS
WITH baseline AS (
    SELECT * FROM analytics.kpi_phase_11_baseline
), checks AS (
    SELECT 'transaction_totals'::text AS check_name, total_transactions = 590540 AS passed FROM baseline
    UNION ALL SELECT 'fraud_totals', fraud_transactions = 20663 FROM baseline
    UNION ALL SELECT 'non_fraud_totals', non_fraud_transactions = 569877 FROM baseline
    UNION ALL SELECT 'amount_totals', total_transaction_amount = 79738948.735 FROM baseline
    UNION ALL SELECT 'daily_partition', (SELECT SUM(total_transactions) = 590540 AND SUM(fraud_transactions) = 20663 FROM analytics.kpi_daily_fraud)
    UNION ALL SELECT 'weekly_partition', (SELECT SUM(total_transactions) = 590540 AND SUM(fraud_transactions) = 20663 FROM analytics.kpi_weekly_fraud)
    UNION ALL SELECT 'hourly_partition', (SELECT SUM(total_transactions) = 590540 AND SUM(fraud_transactions) = 20663 FROM analytics.kpi_hourly_fraud)
    UNION ALL SELECT 'product_partition', (SELECT SUM(transaction_count) = 590540 AND SUM(fraud_count) = 20663 FROM analytics.kpi_segmentation_summary WHERE dimension_name = 'product')
    UNION ALL SELECT 'identity_availability_partition', (SELECT SUM(transaction_count) = 590540 AND SUM(fraud_count) = 20663 FROM analytics.kpi_segmentation_summary WHERE dimension_name = 'identity_availability')
    UNION ALL SELECT 'risk_band_partition', (SELECT SUM(transaction_count) = 590540 AND SUM(fraud_count) = 20663 FROM analytics.kpi_risk_cohorts WHERE cohort_dimension = 'risk_band')
    UNION ALL SELECT 'score_partition', (SELECT SUM(transaction_count) = 590540 AND SUM(fraud_count) = 20663 FROM analytics.kpi_risk_score_summary)
    UNION ALL SELECT 'signal_family_complete', (SELECT COUNT(*) = 6 FROM analytics.kpi_signal_performance)
)
SELECT
    check_name,
    passed,
    CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status
FROM checks;

-- Display Individual Check Results
SELECT check_name, status FROM analytics.kpi_phase_11_validation ORDER BY check_name;

-- Display Overall Phase 11 Validation Status
SELECT
    CASE WHEN BOOL_AND(passed) THEN 'PASS' ELSE 'FAIL' END AS phase_11_kpi_validation
FROM analytics.kpi_phase_11_validation;