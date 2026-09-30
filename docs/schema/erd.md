# Transaction Risk Observatory — Entity Relationship & Architecture Diagram

## 1. Overview

The Transaction Risk Observatory is modeled across four PostgreSQL schemas:
1. **`staging`**: Raw ingested relational tables mirroring the IEEE-CIS Fraud Detection source files.
2. **`analytics`**: Dimensional star schema containing analytical facts, dimensions, standardized clean layers, and feature-engineered views.
3. **`monitoring`**: Automated data quality auditing tables and alerting views.
4. **`performance`**: Workload inventories, index evaluations, optimization candidates, and benchmark telemetry.

The source dataset exhibits an asymmetric 1:0..1 relationship between transactions and identities, where identity information is present for approximately 24.42% of transactions (144,233 of 590,540 rows).

Visual ERD diagram artifact: [`docs/schema/phase_04_erd.png`](file:///c:/Users/Bhuvan%20Ummidisetti/Desktop/Projects/Project%202/Transaction-Risk-Observatory/docs/schema/phase_04_erd.png)

---

## 2. Mermaid Entity Relationship Diagram

```mermaid
erDiagram
    %% STAGING LAYER
    "staging.raw_transactions" ||--o| "staging.raw_identity" : "1 : 0..1 (TransactionID)"
    "staging.raw_transactions" {
        bigint TransactionID PK
        smallint isFraud
        bigint TransactionDT
        numeric TransactionAmt
        text ProductCD
        bigint card1
        double_precision card2
        double_precision card3
        text card4
        double_precision card5
        text card6
        double_precision addr1
        double_precision addr2
        double_precision dist1
        double_precision dist2
        text P_emaildomain
        text R_emaildomain
    }

    "staging.raw_identity" {
        bigint TransactionID PK
        text DeviceType
        text DeviceInfo
        double_precision id_01_through_id_38
    }

    %% ANALYTICS PHYSICAL LAYER (BASE DIMENSIONAL)
    "analytics.dim_identity" ||--o| "analytics.fact_transaction" : "1 : 0..1 (identity_key)"
    "analytics.dim_identity" {
        bigint identity_key PK "Generated Always as Identity"
        bigint TransactionID UQ "Source Natural Key"
        text DeviceType
        text DeviceInfo
    }

    "analytics.fact_transaction" {
        bigint transaction_key PK "Generated Always as Identity"
        bigint identity_key FK "Nullable FK to dim_identity"
        bigint TransactionID UQ "Source Natural Key"
        smallint isFraud
        bigint TransactionDT
        numeric TransactionAmt
        text ProductCD
        text card4
        text card6
    }

    %% ANALYTICS PHYSICAL LAYER (STANDARDIZED CLEAN)
    "analytics.dim_identity_clean" ||--o| "analytics.fact_transaction_clean" : "1 : 0..1 (TransactionID / identity_key)"
    "analytics.dim_identity_clean" {
        bigint identity_key PK "Unique Surrogate Key"
        bigint TransactionID UQ "Unique Natural Key"
        text DeviceType
        text DeviceInfo
        text deviceinfo_normalized "Whitespace & Case Cleaned"
        integer deviceinfo_missing_flag
    }

    "analytics.fact_transaction_clean" {
        bigint TransactionID PK "Unique Natural Key"
        smallint isFraud "Fraud Label (0 or 1)"
        bigint TransactionDT "Elapsed Time (Seconds)"
        numeric TransactionAmt "Transaction Amount"
        text ProductCD "Product Category"
        text card4 "Payment Network"
        text card6 "Card Tier/Type"
        integer transaction_day_number "Derived Elapsed Day (1-183)"
        integer transaction_hour "Derived Hour of Day (0-23)"
        integer transaction_week_number "Derived Week (1-27)"
        integer transaction_amount_zero_flag "Zero Amount Indicator"
        numeric transaction_amount_log "Log-Transformed Amount"
        integer identity_available_flag "1 if Identity Present, else 0"
        integer email_domain_missing_flag "1 if P_emaildomain Missing"
        integer device_info_available_flag "1 if Device Available"
        integer missing_attribute_count "Composite Missing Count"
    }

    %% MONITORING SCHEMA
    "monitoring.monitoring_results" {
        uuid monitoring_run_id PK
        timestamp run_timestamp
        text check_name
        text check_category
        text status "PASS / FAIL / WARN"
        text severity "CRITICAL / HIGH / MEDIUM / LOW"
        numeric observed_value
        text message
    }

    "monitoring.monitoring_baseline" {
        text metric_name PK
        text metric_category
        numeric baseline_value
        numeric tolerance_lower
        numeric tolerance_upper
    }

    %% PERFORMANCE SCHEMA
    "performance.benchmark_results" {
        text query_id PK
        text benchmark_stage "BASELINE / POST_OPTIMIZATION"
        numeric execution_time_ms
        bigint shared_read_blocks
        bigint shared_hit_blocks
    }

    "performance.query_inventory" {
        text query_id PK
        text query_name
        text target_view
        text complexity_profile
    }
```

---

## 3. Relational & Schema Boundaries

### 3.1 Staging Layer (`staging`)
* **Tables**: `staging.raw_transactions` (394 columns, 590,540 rows), `staging.raw_identity` (41 columns, 144,233 rows).
* **Constraints**: Pure ingestion landing zone. All columns are nullable text/numeric representations matching the source CSV types without artificial constraints.

### 3.2 Analytical Dimensional Layer (`analytics`)
* **Base Star Schema**:
  * `analytics.dim_identity`: Stores 144,233 identity records with surrogate key `identity_key` and natural key `TransactionID`.
  * `analytics.fact_transaction`: Stores 590,540 transaction rows with surrogate key `transaction_key` and nullable `identity_key` foreign key.
* **Standardized Clean Layer**:
  * `analytics.dim_identity_clean`: Standardized text representations, deterministic normalization of device strings (`deviceinfo_normalized`), missingness indicators (`deviceinfo_missing_flag`).
  * `analytics.fact_transaction_clean`: Contains all 394 source attributes plus 18 derived feature columns (temporal extractions, log transformations, attribute missingness indicators). Enforces unique index `uq_fact_tx_clean_txid` on `TransactionID`.

### 3.3 Analytical Views & KPI Layer (`analytics`)
* **Phase 9 Core Views**: `vw_transaction_analytics`, `vw_daily_fraud_summary`, `vw_weekly_fraud_summary`, `vw_fraud_comparison`, `vw_identity_risk`, `vw_device_risk`, `vw_card_risk`, `vw_geographic_attribute_risk`, `vw_risk_signal_summary`, `vw_transaction_risk_signals`.
* **Phase 10 Risk Detection Views**: `vw_velocity_analysis`, `vw_amount_anomalies`, `vw_entity_device_anomalies`, `vw_off_hours_analysis`, `vw_geographic_anomalies`, `vw_composed_risk_signals`, `vw_risk_scoring`, `vw_suspicious_transactions`, `vw_suspicious_entities`.
* **Phase 11 Business KPI Views**: `kpi_fraud_summary`, `kpi_amount_summary`, `kpi_daily_fraud`, `kpi_weekly_fraud`, `kpi_hourly_fraud`, `kpi_segmentation_summary` (optimized via single-pass `LATERAL` projection), `kpi_signal_performance`, `kpi_risk_cohorts`, `kpi_fraud_concentration`, `kpi_business_questions`.

### 3.4 Monitoring Schema (`monitoring`)
* **Audit Storage**: `monitoring_baseline` (40 authoritative metric targets), `monitoring_results` (historical execution logs with run UUIDs), `distribution_snapshot` (numerical moments and categorical frequency tables).
* **Evaluation Views**: 9 domain-specific monitoring views (`02` to `10`) unified into `vw_anomaly_alert_rules` evaluating 98 discrete data quality and statistical invariant checks.
* **Stored Procedure**: `fn_record_monitoring_run(p_run_id UUID)` executes the entire 98-check suite in <60ms and persists findings.

### 3.5 Performance Schema (`performance`)
* **Workload & Telemetry Tables**: `query_inventory`, `index_recommendations`, `optimization_candidates`, `materialization_analysis`, `benchmark_results`.
* **Verified Optimization**: `kpi_segmentation_summary` refactored from 8 sequential scans (69,900.616 ms) to a single-pass `LATERAL` construct (16,399.290 ms), yielding a 76.54% latency reduction and an 82.9% reduction in shared disk read blocks.
