# Transaction Risk Observatory — ETL Pipeline Architecture

## 1. Pipeline Overview

The Transaction Risk Observatory implements a robust, deterministic, in-database ELT pipeline in PostgreSQL 18. The pipeline ingests the raw IEEE-CIS Fraud Detection dataset, loads it into an untyped/lightly-typed staging layer, extracts dimensional and fact entities into a star schema, applies strict data quality and standardization policies, and derives analytical risk features.

```text
Raw CSV Data (train_transaction, train_identity)
       ↓
PostgreSQL Staging (staging.raw_transactions, staging.raw_identity)
       ↓
PostgreSQL Profiling & Schema Constraints (Phase 3 & 4)
       ↓
PostgreSQL Dimensional Extraction (analytics.dim_identity)
       ↓
PostgreSQL Fact Extraction & Surrogate Generation (analytics.fact_transaction)
       ↓
PostgreSQL Cleaning & Feature Engineering (analytics.dim_identity_clean, analytics.fact_transaction_clean)
       ↓
PostgreSQL Analytical Views (Phase 9)
       ↓
PostgreSQL Risk Detection Layer (Phase 10)
       ↓
PostgreSQL Business KPI Reporting (Phase 11)
       ↓
PostgreSQL Quality Auditing & Monitoring (Phase 12)
       ↓
PostgreSQL Query Tuning & Refinement (Phase 13)
```

---

## 2. Ingestion & Staging (Phases 1–2)

### 2.1 Raw Ingestion Mechanism
- **Source Files**: `train_transaction.csv` (~683 MB) and `train_identity.csv` (~26.5 MB).
- **Tooling**: PostgreSQL native `\copy` protocol executing directly into unconstrained staging tables:
  ```sql
  \copy staging.raw_transactions FROM 'data/raw/train_transaction.csv' WITH (FORMAT csv, HEADER true);
  \copy staging.raw_identity FROM 'data/raw/train_identity.csv' WITH (FORMAT csv, HEADER true);
  ```
- **Staging Schema**:
  - `staging.raw_transactions`: 394 columns, 590,540 rows.
  - `staging.raw_identity`: 41 columns, 144,233 rows.
- **Data Protection Principle**: Staging tables remain strictly read-only after ingestion. No in-place mutations, updates, or deduplication occur in `staging`.

---

## 3. Dimensional & Fact Extraction (Phases 4–5)

### 3.1 Loading Order
1. **Dimension First (`analytics.dim_identity`)**:
   - Identity records represent the optional child entity in a 1:0..1 relationship.
   - Surrogate key `identity_key` is generated via PostgreSQL:
     ```sql
     identity_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
     ```
   - All 144,233 identity rows are loaded with `TransactionID` preserved as an explicit natural key.
2. **Fact Second (`analytics.fact_transaction`)**:
   - `analytics.fact_transaction` is populated from `staging.raw_transactions` via a `LEFT JOIN` to `analytics.dim_identity` on `TransactionID`.
   - The `LEFT JOIN` ensures 100% population preservation: transactions without an identity session retain `identity_key = NULL`.
   - Surrogate key `transaction_key` is generated automatically.
   - Row count loaded: 590,540 rows. Zero rows lost or duplicated.

### 3.2 Invariant Verification
- Fact count = 590,540
- Dimension count = 144,233
- Linked transactions = 144,233 (24.42% coverage)
- Unlinked transactions = 446,307 (75.58%)
- Unmapped fields = 0

---

## 4. Cleaning, Standardization & Feature Engineering (Phase 6)

### 4.1 Target Clean Tables
- `analytics.dim_identity_clean`: Standardized identity dimension.
- `analytics.fact_transaction_clean`: Standardized fact relation with feature engineering.

### 4.2 Deduplication Policy
- Key profiling proved zero duplicate `TransactionID` occurrences in the source data.
- **Policy**: No row deduplication or arbitrary filtering was executed, preventing artificial sample distortion.

### 4.3 NULL Handling & Missingness Semantics
- **No Blanket Imputation**: NULL values are preserved where they reflect true source unavailability.
- **Exploratory Imputation Avoided**: No replacement of missing attributes with synthetic mean/mode or sentinel values (-1, 0, 'UNKNOWN').
- **Explicit Missingness Flags**:
  - `dist2_missing_flag`: 1 if secondary distance is NULL.
  - `d7_missing_flag`: 1 if D7 timedelta is NULL.
  - `r_emaildomain_missing_flag`: 1 if recipient domain is NULL.
  - `card2_missing_flag`, `card3_missing_flag`, `card5_missing_flag`, `card6_missing_flag`.
  - `card_attributes_missing_count`: Count of missing card attributes (0 to 4).
  - `card_attributes_partial_missing_flag`: 1 if count between 1 and 3.

### 4.4 Categorical & Text Standardization
- Whitespace stripping via `TRIM()`.
- Case normalization via `LOWER()` across `card4`, `card6`, `P_emaildomain`, `R_emaildomain`, `DeviceType`.
- Deterministic device normalization: `deviceinfo_normalized` groups raw build strings without collapsing legitimate rare signatures.

### 4.5 Temporal Derivations
`TransactionDT` represents elapsed seconds from an unknown baseline. The pipeline derives relative temporal cycles without fabricating calendar dates:
- `transaction_day_number = FLOOR(TransactionDT / 86400) + 1` (Days 1–183)
- `transaction_hour = FLOOR(TransactionDT / 3600) % 24` (Hours 0–23)
- `transaction_week_number = FLOOR(TransactionDT / 604800) + 1` (Weeks 1–27)

### 4.6 Monetary Transformations
- `transaction_amount_zero_flag = CASE WHEN TransactionAmt = 0 THEN 1 ELSE 0 END`
- `transaction_amount_log = ROUND(LN(TransactionAmt + 1), 6)`

### 4.7 Risk Signal Indicators
- `identity_available_flag`: 1 if identity present, else 0.
- `email_domain_missing_flag`: 1 if purchaser email is NULL.
- `device_info_available_flag`: 1 if device info is present.
- `missing_attribute_count`: Composite missingness index across critical metadata fields.

---

## 5. Execution Order & Script Registry

To reproduce the ELT pipeline from scratch:

| Step | Script | Execution Action |
|:---|:---|:---|
| **01** | `sql/01_setup/01_create_database_schemas.sql` | Creates `staging`, `analytics`, `monitoring`, `performance` schemas |
| **02** | `sql/02_staging/01_create_staging_tables.sql` | Generates DDL for staging tables |
| **03** | `sql/02_staging/02_load_staging_data.sql` | Executes `\copy` ingestion from CSVs |
| **04** | `sql/02_staging/03_validate_staging.sql` | Audits row counts, column counts, and nullness |
| **05** | `sql/04_modeling/01_create_analytics_schema.sql` | Initializes dimensional schema objects |
| **06** | `sql/04_modeling/02_create_dim_tables.sql` | Creates `dim_identity` table |
| **07** | `sql/04_modeling/03_create_fact_table.sql` | Creates `fact_transaction` table |
| **08** | `sql/04_modeling/04_create_constraints.sql` | Applies primary/foreign keys and unique constraints |
| **09** | `sql/05_etl/01_load_dim_identity.sql` | Loads `dim_identity` from staging |
| **10** | `sql/05_etl/02_load_fact_transaction.sql` | Loads `fact_transaction` via LEFT JOIN |
| **11** | `sql/05_etl/03_validate_dimension_load.sql` | Verifies identity surrogate keys |
| **12** | `sql/05_etl/04_validate_fact_load.sql` | Verifies fact surrogate keys and amounts |
| **13** | `sql/05_etl/05_reconcile_etl.sql` | Confirms zero discrepancies between staging and analytics |
| **14** | `sql/06_cleaning/02_create_clean_tables.sql` | Creates `dim_identity_clean` and `fact_transaction_clean` DDL |
| **15** | `sql/06_cleaning/12_build_clean_layer.sql` | Executes feature engineering and loads clean tables |
| **16** | `sql/06_cleaning/13_validate_clean_layer.sql` | Validates clean layer invariants |
| **17** | `sql/06_cleaning/14_reconcile_phase5.sql` | Reconciles Phase 5 against Phase 6 clean tables |
| **18** | `sql/07_quality/20_phase_07_final_gate.sql` | Comprehensive quality assurance final gate |

---

## 6. Pipeline Reconciliation Summary

| Invariant Metric | Staging Layer | Phase 5 Base Analytics | Phase 6 Clean Analytics | Match Status |
|:---|---:|---:|---:|:---|
| **Fact Row Count** | 590,540 | 590,540 | 590,540 | EXACT MATCH |
| **Identity Row Count** | 144,233 | 144,233 | 144,233 | EXACT MATCH |
| **Fraud Rows (`isFraud = 1`)** | 20,663 | 20,663 | 20,663 | EXACT MATCH |
| **Non-Fraud Rows (`isFraud = 0`)** | 569,877 | 569,877 | 569,877 | EXACT MATCH |
| **Total Amount (`TransactionAmt`)** | $79,738,948.735 | $79,738,948.735 | $79,738,948.735 | EXACT MATCH |
| **Average Amount** | $135.027176 | $135.027176 | $135.027176 | EXACT MATCH |
| **Duplicate Transaction IDs** | 0 | 0 | 0 | ZERO DUPLICATES |
