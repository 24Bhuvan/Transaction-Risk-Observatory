# Phase 13 — Performance Tuning & Refinement Report

## 1. Objective

The objective of Phase 13 is to systematically evaluate, benchmark, and optimize critical analytical workloads across Phases 9–12 of the `Transaction-Risk-Observatory` PostgreSQL database without compromising analytical invariants, semantic definitions, or data quality gates.

---

## 2. Baseline Results

Benchmarking evaluated five core analytical queries (Q01–Q05) against the 590,540-row fact table (`analytics.fact_transaction_clean`) and associated dimensions.

| Query ID | Workload Name | Baseline Execution Time | Notes / Execution Profile |
|:---|:---|---:|:---|
| **Q01** | Daily Fraud Trend Summary | 296.868 ms | Temporal aggregation across 182 transaction days |
| **Q02** | Amount Outlier Detection | 39.809 ms | High-selectivity filter (`>= $1,000`), warm-cache execution |
| **Q03** | Identity Risk by Device Type | 726.946 ms | Natural key join between fact and identity dimension |
| **Q04** | Card Network Risk Analysis | 138.472 ms | Categorical aggregation across card issuers and tiers |
| **Q05** | Executive KPI Segmentation Summary | 69,900.616 ms | Multi-pass aggregation evaluated over 8 full table scans |

---

## 3. Bottleneck Analysis

Execution plan diagnosis of baseline queries revealed that **Q05 (`analytics.kpi_segmentation_summary`)** was the dominant performance bottleneck:
- **8-Pass Full Table Scans**: The original Phase 11 view queried `analytics.vw_transaction_analytics` across 8 sequential `UNION ALL` branches (product, card4, card6, device_type, device_info, purchaser email, recipient email, and identity availability).
- **Excessive Buffer I/O**: Each branch scanned the 1.14M-block heap relation independently, generating over 6.8 million shared block reads and causing significant disk read pressure.

---

## 4. Q05 Optimization

### Architecture Transformation
- **Original Architecture**: 8-way `UNION ALL` querying the full `analytics.vw_transaction_analytics` view, scanning 590,540 rows 8 times.
- **Optimized Architecture**: A single-pass scan of `analytics.fact_transaction_clean` with a `LEFT JOIN analytics.dim_identity_clean` on `identity_key`, combined with a `CROSS JOIN LATERAL (VALUES ...)` structure unpivoting the 8 dimensions in memory per row.

### Empirical Performance Delta

| Metric | Baseline Architecture | Optimized Architecture | Delta / Gain |
|:---|---:|---:|:---|
| **Planning Time** | N/A | 25.793 ms | Efficient plan generation |
| **Execution Time** | 69,900.616 ms | 16,399.290 ms | **53,501.326 ms reduction (76.54% improvement)** |
| **Shared Read Blocks** | ~6,840,000 blocks | 1,166,917 blocks | **5.67M fewer read blocks (82.9% reduction)** |
| **Shared Hit Blocks** | Variable | 16 blocks | Minimal buffer caching required |
| **Temp Disk I/O** | Variable spill | 0 bytes spill | In-memory hash aggregation (Memory: 10,464 kB) |
| **Row Output** | 1,921 rows | 1,921 rows | 100% preservation of population coverage |

---

## 5. Result Reconciliation

To verify zero semantic drift, an empirical two-way set comparison was executed comparing the original 8-branch `UNION ALL` output against the active single-pass `LATERAL` optimized view across all 9 output columns (`dimension_name`, `segment_value`, `transaction_count`, `fraud_count`, `fraud_rate`, `total_amount`, `fraud_amount`, `average_amount`, `average_fraud_amount`):

- **Original Row Count**: 1,921
- **Optimized Row Count**: 1,921
- **Original EXCEPT Optimized Discrepancies**: 0
- **Optimized EXCEPT Original Discrepancies**: 0
- **Reconciliation Verdict**: **PASS** (100% exact numerical and categorical equivalence).

---

## 6. Index Strategy

Targeted B-Tree indexes were created on core tables to enforce entity integrity and support analytical filtering:

1. `analytics.fact_transaction_clean`:
   - `uq_fact_tx_clean_txid`: Unique natural key on `"TransactionID"`.
   - `idx_fact_tx_clean_amt_anomaly`: Partial index on `"TransactionAmt"` WHERE `"TransactionAmt" >= 1000.00`.
   - `idx_fact_tx_clean_day_fraud`: Composite index on `(transaction_day_number, "isFraud", "TransactionAmt")`.
   - `idx_fact_tx_clean_product_fraud`: Composite index on `("ProductCD", "isFraud")`.
   - `idx_fact_tx_clean_card4_card6`: Composite index on `(card4, card6, "isFraud")`.
2. `analytics.dim_identity_clean`:
   - `uq_dim_id_clean_txid`: Unique foreign key on `"TransactionID"`.
   - `pk_dim_id_clean_key`: Unique surrogate key on `identity_key`.

---

## 7. Materialization Analysis

- **Evaluated Candidate**: `analytics.mv_kpi_segmentation_summary`.
- **Decision**: **NO CHANGE** (Materialized view was not created).
- **Rationale**: The single-pass view rewrite lowered execution latency from 69.9s to 16.4s (76.54% reduction) without introducing data staleness risks, refresh overhead, or manual invalidation dependencies.

---

## 8. Regression Validation

Targeted regression validation was conducted against the current optimized database state to confirm zero analytical drift:

- **Phase 7 Targeted Invariants**: **PASS**
  - Fact row count: 590,540 (matches 590,540 baseline)
  - Fraud row count: 20,663 (matches 20,663 baseline)
  - Non-fraud row count: 569,877 (matches 569,877 baseline)
  - Total transaction amount: 79,738,948.735 (matches 79,738,948.735 baseline)
  - Identity row count: 144,233 (matches 144,233 baseline)
- **Phase 10 Targeted Regression**: **PASS**
  - Analytical input verified: 590,540 rows, 20,663 fraud, 79,738,948.735 total amount.
  - Core risk views present and active: `vw_composed_risk_signals`, `vw_risk_scoring`, `vw_suspicious_transactions`, `vw_suspicious_entities`.
- **Phase 11 Targeted Regression**: **PASS**
  - 7 of 7 required KPI views active and verified.
  - Core KPI baseline invariants confirmed passed (`transaction_count_invariant_pass = TRUE`, `fraud_count_invariant_pass = TRUE`, `amount_invariant_pass = TRUE`).
- **Phase 12 Targeted Regression**: **PASS**
  - Monitoring audit log structure intact (`monitoring.monitoring_results`).
  - Executed post-optimization monitoring run `5dbd0f9d-f1bc-4454-b6d6-0d831c366cdb` on `2026-09-30 20:59:31.188298+05:30`.
  - Phase 12 post-optimization monitoring completed successfully with 98/98 checks passing and 0 failures.
  - Overall status: `PASS` across all 9 domain categories (business_rule, distribution, duplicate, fraud_rate, null, population, referential_integrity, risk_signals, schema).

---

## 9. Limitations

1. **Unmeasured Workloads**: Workload Q10 (Automated Monitoring Suite) baseline was identified as an unverified estimate in preliminary documentation and is explicitly excluded from quantitative improvement claims.
2. **Targeted Validation Scope**: Due to PostgreSQL 18 AIO disk-spill constraints on Windows during multi-join sliding window operations, validation was conducted using targeted invariant checks rather than repeated multi-minute full-population scoring queries.
3. **Execution Environment**: Benchmarks reflect single-node execution on PostgreSQL 18.4 with 128 MB shared buffers.

---

## 10. Conclusion

Phase 13 successfully resolved the primary analytical bottleneck in the observatory by refactoring `analytics.kpi_segmentation_summary` into a single-pass `LATERAL` construct, achieving an empirically verified **76.54% latency reduction** (69.90s to 16.40s) and an **82.9% reduction in shared disk read blocks**. All data invariants and analytical populations across Phases 7–12 were preserved with 100% two-way reconciliation.
