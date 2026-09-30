-- ============================================================================
-- TRANSACTION RISK OBSERVATORY
-- PHASE 13 — PERFORMANCE TUNING & REFINEMENT
-- SCRIPT 09: PHASE 13 FINAL VALIDATION GATE
-- ============================================================================
-- Purpose:
--   Comprehensive final validation gate for Phase 13.
--   Validates existence and integrity of Phase 13 benchmarks, optimizations,
--   index structures, reconciliation evidence, population invariants, and
--   empirical post-optimization Phase 12 monitoring validation.
-- ============================================================================

WITH gate_checks AS (
    -- 1. Baseline Benchmark Evidence
    SELECT
        '01_baseline_benchmark_evidence'::TEXT AS check_name,
        (SELECT COUNT(*) >= 5 FROM performance.benchmark_results WHERE benchmark_stage = 'BASELINE_VERIFIED') AS passed,
        'Historical verified baselines Q01-Q05 recorded in benchmark_results'::TEXT AS details

    UNION ALL
    -- 2. Q05 Post-Optimization Benchmark
    SELECT
        '02_q05_optimized_benchmark_exists',
        (SELECT COUNT(*) = 1 FROM performance.benchmark_results WHERE query_id = 'Q05_KPI_SEGMENTATION' AND benchmark_stage = 'POST_OPTIMIZATION'),
        'Measured post-optimization benchmark for Q05 recorded with plan metrics'

    UNION ALL
    -- 3. Q05 Single-Pass LATERAL View Active
    SELECT
        '03_optimized_q05_view_active',
        EXISTS (
            SELECT 1 FROM pg_views 
            WHERE schemaname = 'analytics' 
              AND viewname = 'kpi_segmentation_summary' 
              AND definition ILIKE '%LATERAL%'
        ),
        'Single-pass LATERAL projection active on analytics.kpi_segmentation_summary'

    UNION ALL
    -- 4. Target B-Tree Indexes Applied
    SELECT
        '04_required_indexes_active',
        (
            SELECT COUNT(*) = 7 FROM pg_indexes 
            WHERE schemaname = 'analytics' 
              AND indexname IN (
                  'uq_fact_tx_clean_txid',
                  'idx_fact_tx_clean_amt_anomaly',
                  'idx_fact_tx_clean_day_fraud',
                  'idx_fact_tx_clean_product_fraud',
                  'idx_fact_tx_clean_card4_card6',
                  'uq_dim_id_clean_txid',
                  'pk_dim_id_clean_key'
              )
        ),
        'All 7 validated B-Tree indexes active across fact and identity clean tables'

    UNION ALL
    -- 5. Query Inventory Cataloged
    SELECT
        '05_query_inventory_exists',
        (SELECT COUNT(*) >= 10 FROM performance.query_inventory),
        'Analytical query inventory documented in performance.query_inventory'

    UNION ALL
    -- 6. Index Analysis Recommendations Cataloged
    SELECT
        '06_index_analysis_exists',
        (SELECT COUNT(*) >= 7 FROM performance.index_recommendations),
        'Index recommendations and selectivity rationale cataloged'

    UNION ALL
    -- 7. Optimization Candidates Cataloged
    SELECT
        '07_optimization_candidates_exist',
        (SELECT COUNT(*) >= 4 FROM performance.optimization_candidates),
        'Structured optimization candidates documented'

    UNION ALL
    -- 8. Materialization Trade-Off Analysis Documented
    SELECT
        '08_materialization_analysis_exists',
        (SELECT COUNT(*) >= 4 FROM performance.materialization_analysis),
        'Materialization trade-off evaluations recorded'

    UNION ALL
    -- 9. No Unintended Materialized Views
    SELECT
        '09_no_unintended_matviews',
        (SELECT COUNT(*) = 0 FROM pg_matviews WHERE schemaname = 'analytics'),
        'Materialized views evaluated but not unnecessarily created'

    UNION ALL
    -- 10. Population Invariant Preservation
    SELECT
        '10_population_invariants_preserved',
        (
            (SELECT COUNT(*) FROM analytics.fact_transaction_clean) = 590540
            AND (SELECT COUNT(*) FROM analytics.dim_identity_clean) = 144233
            AND (SELECT COUNT(*) FILTER (WHERE "isFraud" = 1) FROM analytics.fact_transaction_clean) = 20663
        ),
        'Underlying clean fact and dimension row counts and fraud totals 100% preserved'

    UNION ALL
    -- 11. Post-Optimization Phase 12 Monitoring Validation
    SELECT
        '11_post_optimization_monitoring_passed',
        (
            SELECT (COUNT(*) = 98 AND COUNT(*) FILTER (WHERE status = 'FAIL') = 0)
            FROM monitoring.monitoring_results
            WHERE monitoring_run_id = (
                SELECT monitoring_run_id 
                FROM monitoring.monitoring_results 
                ORDER BY run_timestamp DESC 
                LIMIT 1
            )
        ),
        'Newest post-optimization Phase 12 monitoring run verified with 98/98 checks passed (0 failures)'
)
SELECT
    check_name,
    CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status,
    details
FROM gate_checks
ORDER BY check_name;

-- Final Derived Verdict
WITH summary AS (
    SELECT
        COUNT(*) AS total_checks,
        COUNT(*) FILTER (WHERE passed) AS passed_checks,
        BOOL_AND(passed) AS all_passed
    FROM (
        SELECT (SELECT COUNT(*) >= 5 FROM performance.benchmark_results WHERE benchmark_stage = 'BASELINE_VERIFIED') AS passed
        UNION ALL SELECT (SELECT COUNT(*) = 1 FROM performance.benchmark_results WHERE query_id = 'Q05_KPI_SEGMENTATION' AND benchmark_stage = 'POST_OPTIMIZATION')
        UNION ALL SELECT EXISTS (SELECT 1 FROM pg_views WHERE schemaname = 'analytics' AND viewname = 'kpi_segmentation_summary' AND definition ILIKE '%LATERAL%')
        UNION ALL SELECT (SELECT COUNT(*) = 7 FROM pg_indexes WHERE schemaname = 'analytics' AND indexname IN ('uq_fact_tx_clean_txid', 'idx_fact_tx_clean_amt_anomaly', 'idx_fact_tx_clean_day_fraud', 'idx_fact_tx_clean_product_fraud', 'idx_fact_tx_clean_card4_card6', 'uq_dim_id_clean_txid', 'pk_dim_id_clean_key'))
        UNION ALL SELECT (SELECT COUNT(*) >= 10 FROM performance.query_inventory)
        UNION ALL SELECT (SELECT COUNT(*) >= 7 FROM performance.index_recommendations)
        UNION ALL SELECT (SELECT COUNT(*) >= 4 FROM performance.optimization_candidates)
        UNION ALL SELECT (SELECT COUNT(*) >= 4 FROM performance.materialization_analysis)
        UNION ALL SELECT (SELECT COUNT(*) = 0 FROM pg_matviews WHERE schemaname = 'analytics')
        UNION ALL SELECT ((SELECT COUNT(*) FROM analytics.fact_transaction_clean) = 590540 AND (SELECT COUNT(*) FROM analytics.dim_identity_clean) = 144233 AND (SELECT COUNT(*) FILTER (WHERE "isFraud" = 1) FROM analytics.fact_transaction_clean) = 20663)
        UNION ALL SELECT (
            SELECT (COUNT(*) = 98 AND COUNT(*) FILTER (WHERE status = 'FAIL') = 0)
            FROM monitoring.monitoring_results
            WHERE monitoring_run_id = (
                SELECT monitoring_run_id 
                FROM monitoring.monitoring_results 
                ORDER BY run_timestamp DESC 
                LIMIT 1
            )
        )
    ) sub
)
SELECT
    CASE
        WHEN all_passed THEN 'PHASE 13 STATUS: PASS'
        ELSE 'PHASE 13 STATUS: FAIL'
    END AS phase_13_final_gate,
    passed_checks || '/' || total_checks || ' checks passed' AS score
FROM summary;
