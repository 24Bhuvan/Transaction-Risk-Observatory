# Phase 13 — Performance Tuning & Refinement Strategy

## 1. Objective

The primary objective of **Phase 13 — Performance Tuning & Refinement** is to systematically identify, benchmark, diagnose, and optimize high-value analytical workloads across Phases 9–12 in the `Transaction-Risk-Observatory` PostgreSQL database. All tuning decisions are governed by empirical execution-plan evidence, rigorous result reconciliation, and zero regression against established analytical invariants and data-quality gates.

---

## 2. Engineering Methodology

Phase 13 enforces a strict, evidence-driven optimization cycle:

$$\text{Measure} \longrightarrow \text{Diagnose} \longrightarrow \text{Optimize} \longrightarrow \text{Measure} \longrightarrow \text{Reconcile} \longrightarrow \text{Regression Test} \longrightarrow \text{Final Gate}$$

1. **Measure (Baseline)**: Profile targeted workloads (Q01–Q05) using native `EXPLAIN (ANALYZE, BUFFERS)` execution profiling to capture planning time, execution time, buffer I/O, and plan nodes.
2. **Diagnose**: Identify specific plan bottlenecks (e.g. repeated full-table scans, unindexed joins, sort memory spills).
3. **Optimize**: Formulate targeted query rewrites (e.g. single-pass lateral unpivoting) or selective B-Tree indexes.
4. **Measure (Post-Optimization)**: Re-benchmark the active optimized workload under identical database conditions.
5. **Reconcile**: Perform mathematical two-way set comparison (`Original EXCEPT Optimized` and `Optimized EXCEPT Original`) to guarantee 100% numerical and categorical preservation.
6. **Regression Test**: Execute targeted invariant checks across preceding phases (Phases 7, 10, 11, 12) ensuring zero analytical drift.
7. **Final Gate**: Enforce an automated SQL validation gate (`09_phase_13_final_gate.sql`) validating all evidence artifacts before sign-off.

---

## 3. Scope

The optimization scope encompasses:
- Core analytical and reporting views created in Phase 9 (`vw_daily_fraud_summary`, `vw_weekly_fraud_summary`, `vw_identity_risk_analysis`, `vw_device_risk_analysis`, `vw_card_risk_analysis`).
- Advanced anomaly and risk scoring models from Phase 10 (`vw_velocity_analysis`, `vw_amount_anomalies`, `vw_entity_device_anomalies`, `vw_risk_scoring`).
- Executive KPIs and business questions from Phase 11 (`kpi_amount_summary`, `kpi_segmentation_summary`, `kpi_signal_performance`, `kpi_business_questions`).
- Quality auditing and monitoring infrastructure from Phase 12 (`vw_anomaly_alert_rules`, `monitoring_results`).

Out of scope:
- Modifying raw staging tables or Phase 6 cleaning transformations.
- Altering mathematical or domain logic established in Phases 7–12.
- Arbitrary unmeasured index creation or blind configuration changes.

---

## 4. Existing Performance Environment

- **Database Engine**: PostgreSQL 18.4 (x86_64-windows)
- **Primary Data Footprint**:
  - `analytics.fact_transaction_clean`: 590,540 rows, 394 columns, ~8,980 MB total table/TOAST relation size.
  - `analytics.dim_identity_clean`: 144,233 rows, 44 columns, ~152 MB total relation size.
- **Server Resources**:
  - `shared_buffers`: 128 MB (16,384 8kB pages)
  - `work_mem`: 4 MB
  - `max_parallel_workers_per_gather`: 2

---

## 5. Performance Targets & Applied Workloads

- **Primary Optimization Target**: Workload **Q05 (`analytics.kpi_segmentation_summary`)**.
  - Baseline: 8 full relation scans via `UNION ALL` (69,900.616 ms, ~6.84M read blocks).
  - Target: Single-pass scan reducing execution latency by > 50% and buffer reads by > 75%.
- **Index Support Targets**:
  - Unique natural and surrogate keys on fact and dimension tables.
  - High-selectivity partial index for large amount anomalies (`>= $1,000`).
  - Composite indexes for daily trends and categorical groupings.

---

## 6. Result-Reconciliation Methodology

Every optimized query or view must be reconciled against its unoptimized predecessor using:
```sql
(SELECT * FROM original_workload) EXCEPT (SELECT * FROM optimized_workload);
(SELECT * FROM optimized_workload) EXCEPT (SELECT * FROM original_workload);
```
Aggregates (row count, sums, fraud rates, metric distributions) must match exactly ($0$ discrepancies across all rows).

---

## 7. Regression Testing Strategy

Post-optimization validation uses targeted invariant queries across previous phases:
- **Phase 7 Invariants**: Verify total transaction rows (590,540), fraud rows (20,663), non-fraud rows (569,877), total amounts ($79,738,948.735$), and identity rows (144,233).
- **Phase 10 Invariants**: Verify existence of core risk views (`vw_composed_risk_signals`, `vw_risk_scoring`, `vw_suspicious_transactions`, `vw_suspicious_entities`) and consistency of base analytical inputs.
- **Phase 11 Invariants**: Verify existence of all 7 KPI summary views and confirm baseline KPI invariant flags.
- **Phase 12 Invariants**: Verify structural integrity of monitoring audit tables and execute an empirical post-optimization monitoring run (`fn_record_monitoring_run`) confirming 98/98 checks passed.

---

## 8. Limitations

- Optimization is bounded by single-node PostgreSQL execution on Windows.
- `fact_transaction_clean` is naturally wide (394 columns), requiring careful projection in reporting queries.
- In PostgreSQL 18 on Windows, parallel worker message queues combined with low `work_mem` (4MB) and asynchronous disk I/O (`AioIoCompletion`) can produce severe disk thrashing during complex window-function joins; targeted invariant regression testing was utilized to ensure reliable, non-hanging verification.
