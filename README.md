# Transaction Risk Observatory

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.4-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Status](https://img.shields.io/badge/Phase_14-Completed_%26_Validated-success)](#)
[![Validation](https://img.shields.io/badge/Monitoring_Suite-98%2F98_PASS-brightgreen)](#)
[![Optimization](https://img.shields.io/badge/Q05_Optimization-76.54%25_Faster-blue)](#)

A production-grade, in-database transaction risk intelligence warehouse, anomaly detection engine, and data quality observatory built entirely within **PostgreSQL 18** using the IEEE-CIS Fraud Detection dataset.

---

## 1. Project Overview

The **Transaction Risk Observatory** is an enterprise-grade analytical platform demonstrating the advanced power of PostgreSQL as a complete analytical engine. Unlike traditional architectures that offload transformation, feature engineering, and monitoring to external Python/Spark workers, this platform implements the entire analytical lifecycle inside PostgreSQL:

* **In-Database ELT**: Processing 590,540 payment transactions and 144,233 digital identity sessions.
* **Dimensional Modeling**: Asymmetric star schema preserving 100% of transaction population and 1:0..1 identity linkages.
* **Rule-Based Fraud Intelligence**: 10 transparent detection patterns (velocity bursts, amount anomalies, device sharing, off-hours, composite risk scoring).
* **Automated Data Quality Monitoring**: 98 automated checks across 9 auditing domains executing in <60ms.
* **Empirical Query Optimization**: Single-pass `LATERAL` refactoring delivering a **76.54% latency reduction** (69.9s to 16.4s) and an **82.9% buffer I/O reduction**.

---

## 2. Business Problem

Financial institutions process millions of card-not-present transactions daily, facing two existential risks:
1. **Severe Financial Exposure**: Direct chargeback losses, interchange penalties, and operational investigation costs. In this dataset alone, confirmed fraud accounts for **$3,083,844.86** in gross exposure.
2. **Detection Latency & Black-Box Opacity**: Complex ML models often operate as unexplainable black boxes that obscure why a transaction was flagged, leading to customer friction or delayed risk review.

**The Solution**: A transparent, SQL-native observatory that pairs deterministic behavioral risk heuristics with an auditable data quality framework, empowering fraud investigators and risk executives with instant, explainable decision support.

---

## 3. Dataset & Source Characteristics

The observatory is built on the benchmark **IEEE-CIS Fraud Detection Dataset**:
* **Total Transactions**: 590,540 records
* **Total Identity Sessions**: 144,233 records (24.42% coverage)
* **Target Distribution**: Highly imbalanced:
  * Non-Fraud (`isFraud = 0`): **569,877 (96.501%)**
  * Confirmed Fraud (`isFraud = 1`): **20,663 (3.499%)**
* **Financial Volume**: **$79,738,948.735** total transaction value
* **Raw Feature Breadth**: 435 raw staging columns (394 transaction attributes, 41 identity attributes).

---

## 4. Why PostgreSQL?

PostgreSQL 18 was chosen as the primary analytical platform rather than a simple storage layer:
* **Advanced Analytical Windowing**: Sliding physical range windows (`RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW`) calculate real-time transaction velocities without external stream processors.
* **Lateral Joins & In-Memory Unpivoting**: `CROSS JOIN LATERAL (VALUES ...)` transforms 8-pass union scans into single-pass multi-dimensional aggregations.
* **Deterministic Data Quality & Integrity**: Built-in constraints, partial B-Tree indexes, and procedural functions ensure that analytical invariants are enforced at the engine level.
* **Zero Infrastructure Sprawl**: Eliminates complex synchronization between separate databases, ETL orchestrators, and cache layers.

---

## 5. Analytical Objectives

The platform provides concrete answers to 7 core executive questions:
1. **Gross Fraud Exposure**: What is the overall fraud rate and dollar loss? (3.499% rate, $3.08M loss).
2. **Fraud Ticket Premium**: Do fraudulent transactions carry higher amounts? (Yes, $149.24 average fraud ticket vs $134.51 non-fraud ticket, a +$14.73 premium).
3. **Temporal Vulnerability**: When does fraudulent activity peak? (Elevated fraud rates occur between 02:00 and 06:00).
4. **Channel & Network Risk**: Which card brands and products exhibit elevated incidence? (Ranked via `kpi_segmentation_summary`).
5. **Detection Rule Efficacy**: Which behavioral patterns provide the highest signal precision? (Entity/device sharing delivers a 7.270% fraud rate, 2.08x baseline).
6. **Prioritization Triage**: Can composite scores isolate high-risk transactions? (Additive score 0–7 successfully separates low-risk from critical multi-vector threats).
7. **Loss Concentration**: Are losses concentrated in narrow segments? (Documented Pareto distribution in `kpi_fraud_concentration`).

---

## 6. Technology Stack

* **Database Engine**: PostgreSQL 18 (Tested on PostgreSQL 18.4 x86_64)
* **Primary Query Language**: Advanced SQL (CTEs, Window Functions, Filtered Aggregations, Lateral Projections)
* **Database Client**: `psql` (PostgreSQL CLI)
* **Version Control**: Git & GitHub
* **Optional Utility Tooling**: Python 3.10+ (Standard library only: `csv`, `os`, `sys`, `json`)
* *Strict Boundary*: Zero third-party Python dependencies (no pandas, scikit-learn, dbt, or Spark).

---

## 7. Architecture & Data Flow

```text
Raw CSV Files (train_transaction, train_identity)
       │
       ▼
Staging Layer (`staging.raw_transactions`, `staging.raw_identity`)
       │ [Structural profiling, 0% type mismatches, 0 duplicate keys]
       ▼
Dimensional Model (`analytics.fact_transaction`, `analytics.dim_identity`)
       │ [Surrogate keys generated, 1:0..1 LEFT JOIN preserves 590,540 rows]
       ▼
Standardized Clean Layer (`analytics.fact_transaction_clean`, `analytics.dim_identity_clean`)
       │ [Deterministic device normalization, relative time derivation, missingness indicators]
       ▼
Analytical Views (`vw_transaction_analytics`, daily/weekly summaries)
       │
       ▼
Fraud Risk Detection Layer (`vw_velocity_analysis`, `vw_composed_risk_signals`, `vw_risk_scoring`)
       │ [Multi-signal composition, additive heuristic scoring 0-7, risk bands]
       ▼
Business KPIs & Executive Layer (`kpi_fraud_summary`, `kpi_segmentation_summary`)
       │
       ├──► Automated Quality Monitoring (`monitoring` schema, 98 rules, fn_record_monitoring_run)
       │
       └──► Query Performance Optimization (`performance` schema, single-pass LATERAL rewrite)
```

---

## 8. Phase 1–14 Overview

| Phase | Milestone Name | Key Deliverables & Achievements | Status |
|:---|:---|:---|:---:|
| **01** | Database Environment Setup | Multi-schema initialization (`staging`, `analytics`, `monitoring`, `performance`) | Complete |
| **02** | Staging Layer & Raw Ingestion | `\copy` ingestion of 590,540 transactions and 144,233 identity rows | Complete |
| **03** | Data Profiling & Structural Auditing | 435-column metadata profile, NULL analysis, key uniqueness verification | Complete |
| **04** | Dimensional Data Modeling | Relational star schema with surrogate keys and 1:0..1 optional identity relationship | Complete |
| **05** | ELT Pipeline Implementation | Full-refresh batch ETL preserving 100% of transaction population and amounts | Complete |
| **06** | Data Cleaning & Transformation | Clean layer tables (`fact_transaction_clean`, `dim_identity_clean`) with 18 derived features | Complete |
| **07** | Quality Assurance & Invariant Validation | Reconciled Phase 5 against Phase 6 with zero unexpected discrepancies | Complete |
| **08** | Analytical Query Optimization | Statistical analysis, initial B-Tree indexes, baseline execution plans | Complete |
| **09** | Analytical Views Layer | 10 modular views for daily/weekly trends, card networks, and attribute risks | Complete |
| **10** | Risk Analysis & Anomaly Detection | 10 transparent fraud detection patterns, multi-signal composition, additive scoring | Complete |
| **11** | KPI Reporting & Executive Summary | Standardized KPI catalog answering Q1–Q7 across exposure, cohorts, and concentration | Complete |
| **12** | Quality Auditing & Monitoring Framework | 9-domain automated monitoring suite with 98 rules executing in <60ms | Complete |
| **13** | Performance Tuning & Refinement | Single-pass LATERAL optimization: **76.54% latency drop**, **82.9% buffer read drop** | Complete |
| **14** | Documentation & Repository Finalization | Unified ERD, data dictionary, execution guide, and final gate certification | Complete |

---

## 9. Data Quality & Cleaning Approach

The observatory adheres to strict, disciplined data quality policies:
* **Zero Row Deletion**: No transaction records were pruned or dropped as "outliers."
* **Preservation of Source NULLs**: Missing values are preserved where analytically meaningful. No blanket imputation with fake means, medians, or arbitrary sentinels (-1, 0).
* **Missingness Indicators**: Explicit binary flags capture metadata incompleteness:
  * `dist2_missing_flag`, `d7_missing_flag`, `r_emaildomain_missing_flag`, `card_attributes_missing_count`.
* **Standardized Normalization**: Whitespace trimming and lowercase casing across categorical attributes (`card4`, `card6`, email domains, device strings) without collapsing legitimate rare categories.
* **Relative Temporal Derivation**: Elapsed seconds (`TransactionDT`) converted to relative day numbers (1–183), transaction hours (0–23), and relative weeks (1–27) without fabricating unsupported calendar dates.

---

## 10. Fraud Analytics & Risk Detection

Implemented detection heuristics in Phase 10:
1. **Transaction Velocity (`vw_velocity_analysis`)**: Flags >= 3 transactions for an identity within a rolling 24h window (captures 5,790 fraud events).
2. **Amount Anomalies (`vw_amount_anomalies`)**: Flags purchases exceeding the entity's 95th percentile baseline.
3. **Entity/Device Anomalies (`vw_entity_device_anomalies`)**: Flags shared hardware across identities or identity device-hopping (delivers **7.270% fraud rate**, 2.08x baseline).
4. **Off-Hours Activity (`vw_off_hours_analysis`)**: Flags transactions during local nighttime troughs (02:00–06:00).
5. **Geographic Capability Assessment (`vw_geographic_anomalies`)**: Documents limitation: coarse regional attributes prevent Haversine impossible travel calculation; zero synthetic GPS coordinates were fabricated.
6. **Composed Risk Signals (`vw_composed_risk_signals`)**: Identifies multi-vector threats where >= 2 signals trigger simultaneously (**5.856% fraud rate**).
7. **Transparent Risk Scoring (`vw_risk_scoring`)**: Additive integer score (0–7) prioritizing alert triage:
   $$\text{Risk Score} = 2(\text{Velocity}) + 2(\text{Amount}) + 2(\text{Device}) + 1(\text{OffHours}) + 3(\text{Travel})$$
   Stratified into `LOW` (<2), `MEDIUM` (2–4), and `HIGH` (>=5) risk tiers.

---

## 11. Automated Data Quality Monitoring

A dedicated `monitoring` schema provides continuous validation across 9 domains evaluating **98 automated checks**:
* **Audit State**: Immutable run logs in `monitoring.monitoring_results` and statistical moments in `monitoring.distribution_snapshot`.
* **Execution Latency**: Stored procedure `fn_record_monitoring_run(uuid)` evaluates all 98 checks in **< 60 ms**.
* **Controlled Anomaly Verification**: Validated in isolated transactions against synthetic duplicate keys (FAIL/CRITICAL), null keys (FAIL/CRITICAL), negative amounts (FAIL/CRITICAL), distribution shifts (WARN/MEDIUM), and fraud rate spikes (WARN/HIGH).
* **Empirical Result**: **98 of 98 checks passed (0 warnings, 0 failures)** on the active production state.

---

## 12. Performance Tuning & Optimization

During Phase 13, diagnostic profiling identified `analytics.kpi_segmentation_summary` (Q05) as the primary system bottleneck:
* **The Problem**: The original view executed 8 sequential `UNION ALL` branches across `analytics.vw_transaction_analytics`, forcing 8 full table scans over 1.14M heap blocks and generating >6.8M buffer reads.
* **The Optimization**: Refactored into a single-pass scan of `analytics.fact_transaction_clean` with a `LEFT JOIN analytics.dim_identity_clean`, combined with `CROSS JOIN LATERAL (VALUES ...)` to unpivot the 8 dimensions in memory per row.
* **Measured Execution Metrics**:
  * Baseline Execution Time: **69,900.616 ms**
  * Optimized Execution Time: **16,399.290 ms**
  * Execution Time Reduction: **76.54% (53,501.326 ms saved)**
  * Buffer I/O Reduction: **82.9% fewer shared read blocks** (dropped from 6.84M to 1.17M blocks)
  * Disk Spill: **0 bytes** (Hash aggregate completed entirely in memory: 10,464 kB)
* **Reconciliation**: Full two-way set comparison across all 1,921 rows:
  * `Original EXCEPT Optimized = 0`
  * `Optimized EXCEPT Original = 0` (100% exact numerical match).

---

## 13. Verified Key Results

| Metric / Check | Baseline Value | Current State | Verification Status |
|:---|---:|---:|:---:|
| **Fact Population** | 590,540 rows | 590,540 rows | PASS |
| **Fraud Rows (`isFraud = 1`)** | 20,663 rows | 20,663 rows | PASS |
| **Non-Fraud Rows (`isFraud = 0`)** | 569,877 rows | 569,877 rows | PASS |
| **Total Amount Volume** | $79,738,948.735 | $79,738,948.735 | PASS |
| **Identity Sessions** | 144,233 rows | 144,233 rows | PASS |
| **Q05 Execution Time** | 69,900.616 ms | 16,399.290 ms | **76.54% Reduction** |
| **Q05 Shared Block Reads** | 6,839,718 blocks | 1,166,917 blocks | **82.9% Reduction** |
| **Q05 Set Discrepancies** | N/A | 0 discrepancies | PASS |
| **Phase 7 Targeted Validation** | — | — | PASS |
| **Phase 10 Targeted Validation** | — | — | PASS |
| **Phase 11 Targeted Validation** | — | — | PASS |
| **Phase 12 Monitoring Suite** | 98 checks | 98 passed / 0 failed | **98/98 PASS** |
| **Phase 13 Final Gate** | 11 checks | 11 passed / 0 failed | **11/11 PASS** |

---

## 14. Repository Structure

```text
Transaction-Risk-Observatory/
├── data/
│   └── raw/                    # Raw IEEE-CIS CSVs (git-ignored)
├── docs/
│   ├── kpis/                   # Phase 11 KPI catalog and specifications
│   ├── monitoring/             # Phase 12 monitoring framework & range thresholds
│   ├── performance/            # Phase 8 & 13 optimization strategies
│   ├── profiling/              # Phase 3 profiling report, data dictionary, DQ issues
│   ├── reports/                # Phase 01-14 validation & execution reports
│   ├── requirements/           # Project charter, scope, and technical stack
│   ├── schema/                 # ERD diagrams, DDL designs, ETL mapping
│   └── reproducibility.md      # Practical step-by-step execution guide
├── scripts/                    # Optional Python utility scripts (standard library)
├── sql/
│   ├── 01_setup/               # Schema initialization DDL
│   ├── 02_staging/             # Ingestion & staging tables
│   ├── 03_profiling/           # Structural profiling scripts
│   ├── 04_modeling/            # Star schema DDL & constraints
│   ├── 05_etl/                 # In-database ELT loading scripts
│   ├── 06_cleaning/            # Standardization & feature engineering
│   ├── 07_quality/             # Quality assurance test suite & gate
│   ├── 08_optimization/        # Initial indexing & statistics
│   ├── 09_views/               # Modular analytical views
│   ├── 10_risk_analysis/       # Fraud detection patterns & scoring
│   ├── 11_kpis/                # Executive KPI catalog views
│   ├── 12_monitoring/          # 98-check automated monitoring suite
│   └── 13_performance/         # Workload benchmarks & LATERAL optimization
├── .gitignore                  # Security & credential protection rules
├── CHANGELOG.md                # Project development ledger (Phases 1-14)
├── README.md                   # Primary project entry point
└── requirements.md             # System requirements & sizing specifications
```

---

## 15. Reproducibility & Execution

To reproduce the complete observatory from scratch in PostgreSQL:

1. **Clone repository**:
   ```bash
   git clone https://github.com/24Bhuvan/Transaction-Risk-Observatory.git
   cd Transaction-Risk-Observatory
   ```
2. **Download data**: Place `train_transaction.csv` and `train_identity.csv` into `data/raw/`.
3. **Execute SQL pipeline in order**:
   ```bash
   # 1. Initialize Database & Schemas
   psql -U postgres -d postgres -c "CREATE DATABASE transaction_risk_observatory;"
   psql -U postgres -d transaction_risk_observatory -f sql/01_setup/01_create_database_schemas.sql

   # 2. Ingest Staging
   psql -U postgres -d transaction_risk_observatory -f sql/02_staging/01_create_staging_tables.sql
   psql -U postgres -d transaction_risk_observatory -f sql/02_staging/02_load_staging_data.sql

   # 3. Model & ELT Load
   psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/01_create_analytics_schema.sql
   psql -U postgres -d transaction_risk_observatory -f sql/05_etl/01_load_dim_identity.sql
   psql -U postgres -d transaction_risk_observatory -f sql/05_etl/02_load_fact_transaction.sql

   # 4. Clean Layer & Features
   psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/12_build_clean_layer.sql

   # 5. Build Analytical Views & Risk Signals
   psql -U postgres -d transaction_risk_observatory -f sql/09_views/03_create_transaction_analytics_view.sql
   psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/07_composed_risk_signals.sql
   psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/08_risk_scoring.sql

   # 6. Build KPI Reporting Layer
   psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/02_core_fraud_kpis.sql
   psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/05_segmentation_analysis.sql

   # 7. Apply Performance Optimizations
   psql -U postgres -d transaction_risk_observatory -f sql/13_performance/07_apply_performance_optimizations.sql

   # 8. Deploy & Run Automated Monitoring Suite
   psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/13_run_all_monitoring_checks.sql
   ```
*Full detailed instructions are cataloged in [`docs/reproducibility.md`](file:///c:/Users/Bhuvan%20Ummidisetti/Desktop/Projects/Project%202/Transaction-Risk-Observatory/docs/reproducibility.md).*

---

## 16. Validation Status

The observatory enforces validation gates across each layer:
* **Phase 7 Targeted Validation**: **PASS** (100% preservation of row counts, amounts, and foreign keys).
* **Phase 10 Targeted Validation**: **PASS** (All 9 risk views active; binary flag semantics verified).
* **Phase 11 Targeted Validation**: **PASS** (All 7 required KPI views active; core invariants confirmed).
* **Phase 12 Post-Optimization Monitoring**: **98/98 PASS** (Run ID: `5dbd0f9d-f1bc-4454-b6d6-0d831c366cdb`).
* **Phase 13 Final Gate**: **11/11 PASS** (Indexes active, benchmark telemetry recorded, zero reconciliation errors).

---

## 17. Limitations & Technical Notes

1. **Source-Relative Time**: `TransactionDT` represents elapsed seconds from an undisclosed start date. Relative day, hour, and week numbers are derived without fabricating unsupported calendar dates.
2. **Geographic Coordinates**: The dataset lacks precise GPS/latitude-longitude coordinates. Impossible travel detection (`impossible_travel_flag`) is documented as an empirical capability boundary and kept at zero to avoid fabricating fake locations.
3. **Rule-Based Prioritization**: The additive risk score (0–7) is a transparent triage rank, not a calibrated statistical probability.
4. **Targeted Validation Scope**: Multi-view window function queries over 590k rows are evaluated using targeted invariant checks rather than unindexed repetitive table scans to prevent Windows parallel worker IPC queue deadlocks.
