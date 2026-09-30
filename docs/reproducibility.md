# Transaction Risk Observatory — Reproducibility & Execution Guide

## 1. System Requirements

- **Database**: PostgreSQL 18 (Tested on PostgreSQL 18.4 x86_64 Windows / Linux / macOS)
- **Client**: `psql` (PostgreSQL 18.4 CLI)
- **Shell**: PowerShell 7+ (Windows) or Bash / Zsh (Linux/macOS)
- **Python**: Python 3.10+ (optional, standard library only for utility scripts in `scripts/`)
- **Hardware Recommendations**:
  - RAM: 8 GB minimum (16 GB recommended for parallel scan operations)
  - Disk: 15 GB free space (raw CSVs ~1.3 GB, uncompressed database tables and indexes ~8 GB)
  - PostgreSQL Configuration: Default configuration or tuned `shared_buffers = 128MB` (or higher), `work_mem = 64MB`.

> [!CAUTION]
> Never commit credentials, passwords, or host connection strings to version control. Pass credentials via standard PostgreSQL environment variables (`PGHOST`, `PGPORT`, `PGUSER`, `PGDATABASE`) or interactively via `psql`.

---

## 2. Data Preparation

1. Download the IEEE-CIS Fraud Detection dataset from Kaggle.
2. Place the raw CSV files into the repository `data/raw/` directory:
   ```text
   Transaction-Risk-Observatory/
   └── data/
       └── raw/
           ├── train_transaction.csv
           ├── train_identity.csv
           ├── test_transaction.csv      (optional)
           └── test_identity.csv       (optional)
   ```

---

## 3. End-to-End SQL Execution Workflow

All commands are run using `psql` connected to the target database `transaction_risk_observatory`.

### Step 01: Database & Schema Initialization
Create the database and base schemas (`staging`, `analytics`, `monitoring`, `performance`):
```bash
# Connect to default postgres database to initialize project DB
psql -U postgres -d postgres -c "CREATE DATABASE transaction_risk_observatory;"

# Create schemas
psql -U postgres -d transaction_risk_observatory -f sql/01_setup/01_create_database_schemas.sql
```

### Step 02: Staging Layer Setup & Ingestion
Create staging tables and ingest raw CSVs using PostgreSQL native `\copy`:
```bash
# Create staging tables
psql -U postgres -d transaction_risk_observatory -f sql/02_staging/01_create_staging_tables.sql

# Load staging data from CSV
psql -U postgres -d transaction_risk_observatory -f sql/02_staging/02_load_staging_data.sql

# Validate staging counts (expected: 590,540 transactions, 144,233 identity rows)
psql -U postgres -d transaction_risk_observatory -f sql/02_staging/03_validate_staging.sql
```

### Step 03: Data Profiling
Execute column metadata and completeness profiling:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/03_profiling/01_profile_structure.sql
psql -U postgres -d transaction_risk_observatory -f sql/03_profiling/02_profile_column_metadata.sql
psql -U postgres -d transaction_risk_observatory -f sql/03_profiling/03_build_data_dictionary.sql
```

### Step 04: Dimensional Data Modeling
Create analytical star schema tables and relational constraints:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/01_create_analytics_schema.sql
psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/02_create_dim_tables.sql
psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/03_create_fact_table.sql
psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/04_create_constraints.sql
psql -U postgres -d transaction_risk_observatory -f sql/04_modeling/05_validate_model.sql
```

### Step 05: ETL Execution & Baseline Reconciliation
Load dimension first, then fact relation with surrogate keys:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/05_etl/01_load_dim_identity.sql
psql -U postgres -d transaction_risk_observatory -f sql/05_etl/02_load_fact_transaction.sql
psql -U postgres -d transaction_risk_observatory -f sql/05_etl/03_validate_dimension_load.sql
psql -U postgres -d transaction_risk_observatory -f sql/05_etl/04_validate_fact_load.sql
psql -U postgres -d transaction_risk_observatory -f sql/05_etl/05_reconcile_etl.sql
```

### Step 06: Data Cleaning, Standardization & Feature Engineering
Create clean analytical tables and populate derived features:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/01_cleaning_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/02_create_clean_tables.sql
psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/12_build_clean_layer.sql
psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/13_validate_clean_layer.sql
psql -U postgres -d transaction_risk_observatory -f sql/06_cleaning/14_reconcile_phase5.sql
```

### Step 07: Quality Assurance & Invariant Validation Gate
Execute data quality test suite and Phase 7 final gate:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/07_quality/20_phase_07_final_gate.sql
```
*Expected Result*: `PHASE 7 STATUS: PASS`

### Step 08: Analytical Optimization Baseline & Indexes
Analyze table statistics and apply initial indexes:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/08_optimization/01_optimization_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/08_optimization/07_create_indexes.sql
psql -U postgres -d transaction_risk_observatory -f sql/08_optimization/08_analyze_optimized_tables.sql
psql -U postgres -d transaction_risk_observatory -f sql/08_optimization/13_phase_08_final_gate.sql
```

### Step 09: Analytical Views Layer
Build core reusable analytical views:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/09_views/01_view_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/03_create_transaction_analytics_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/04_create_daily_fraud_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/05_create_weekly_fraud_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/06_create_fraud_comparison_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/07_create_identity_risk_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/08_create_device_risk_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/09_create_card_risk_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/10_create_geographic_attribute_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/11_create_risk_signal_summary.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/12_create_transaction_risk_signals_view.sql
psql -U postgres -d transaction_risk_observatory -f sql/09_views/16_phase_09_final_gate.sql
```

### Step 10: Fraud Risk Analytics Layer
Instantiate rule-based anomaly detection views and scoring:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/01_risk_analysis_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/02_velocity_analysis.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/03_amount_anomalies.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/04_entity_device_anomalies.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/05_off_hours_analysis.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/06_geographic_anomalies.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/07_composed_risk_signals.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/08_risk_scoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/09_suspicious_transactions.sql
psql -U postgres -d transaction_risk_observatory -f sql/10_risk_analysis/10_suspicious_entities.sql
```

### Step 11: Business KPIs & Executive Reporting Layer
Build executive reporting views:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/01_kpi_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/02_core_fraud_kpis.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/03_amount_kpis.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/04_temporal_kpis.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/05_segmentation_analysis.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/06_risk_signal_performance.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/07_risk_score_analysis.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/08_risk_cohorts.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/09_fraud_concentration.sql
psql -U postgres -d transaction_risk_observatory -f sql/11_kpis/10_business_questions.sql
```

### Step 12: Data Quality Monitoring Suite Setup & Execution
Deploy monitoring schema, 9 domain views, baseline targets, and execute an automated audit run:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/01_monitoring_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/02_schema_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/03_population_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/04_duplicate_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/05_null_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/06_referential_integrity_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/07_business_rule_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/08_distribution_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/09_fraud_rate_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/10_risk_signal_monitoring.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/11_anomaly_alert_rules.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/12_monitoring_results.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/13_run_all_monitoring_checks.sql
psql -U postgres -d transaction_risk_observatory -f sql/12_monitoring/14_phase_12_final_gate.sql
```
*Expected Result*: `PHASE 12 STATUS: PASS (15/15 checks passed)`

### Step 13: Query Performance Refinement & Optimization
Apply production indexes and the verified single-pass `LATERAL` rewrite of `kpi_segmentation_summary`:
```bash
psql -U postgres -d transaction_risk_observatory -f sql/13_performance/01_performance_baseline.sql
psql -U postgres -d transaction_risk_observatory -f sql/13_performance/07_apply_performance_optimizations.sql
psql -U postgres -d transaction_risk_observatory -f sql/13_performance/08_post_optimization_benchmarks.sql
psql -U postgres -d transaction_risk_observatory -f sql/13_performance/09_phase_13_final_gate.sql
```
*Expected Result*: `PHASE 13 STATUS: PASS (11/11 checks passed)`

---

## 4. Verification Checkpoints

At any point following Phase 13, verify system integrity using targeted queries:
```sql
-- 1. Fact Population Invariant (590,540 rows, 20,663 fraud, $79,738,948.735)
SELECT
    COUNT(*) = 590540 AS count_pass,
    COUNT(*) FILTER (WHERE "isFraud" = 1) = 20663 AS fraud_pass,
    ROUND(SUM("TransactionAmt"), 3) = 79738948.735 AS amount_pass
FROM analytics.fact_transaction_clean;

-- 2. Identity Population Invariant (144,233 rows)
SELECT COUNT(*) = 144233 AS id_pass FROM analytics.dim_identity_clean;

-- 3. Monitoring Suite Status (98 checks passed, 0 failures)
SELECT
    monitoring_run_id,
    COUNT(*) AS total_evaluated,
    COUNT(*) FILTER (WHERE status = 'PASS') AS passed
FROM monitoring.monitoring_results
GROUP BY monitoring_run_id
ORDER BY MAX(run_timestamp) DESC
LIMIT 1;
```
