# Phase 12 — Data Quality Auditing & Monitoring Framework

## 1. Framework Architecture

Phase 12 establishes an automated, in-database monitoring framework within a dedicated `monitoring` schema in PostgreSQL 18. The system tracks population drift, schema regressions, key uniqueness violations, unexpected NULL spikes, referential integrity breaks, business invariant deviations, statistical distribution shifts, fraud rate anomalies, and operational risk signal outages.

```text
Target Relations: analytics.fact_transaction_clean, analytics.dim_identity_clean
                               │
                               ▼
        9 Domain-Specific Monitoring Views (vw_02 - vw_10)
                               │
                               ▼
            monitoring.vw_anomaly_alert_rules (98 rules)
                               │
                               ▼
     Stored Procedure: monitoring.fn_record_monitoring_run(p_run_id)
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
monitoring.monitoring_results        monitoring.distribution_snapshot
   (Immutable Audit Log)               (Moments & Frequency Tables)
```

---

## 2. Nine Monitoring Domains

The framework evaluates 98 discrete automated audit checks categorized into 9 domains:

### 1. Schema Structure (`monitoring.vw_schema_monitoring` — 23 checks)
- **Expected Condition**: Key columns, required data types, primary keys, and unique indexes exist on clean tables.
- **PASS/FAIL Rule**: PASS if column/index exists in `information_schema` / `pg_indexes`; FAIL if dropped or altered.

### 2. Population Monitoring (`monitoring.vw_population_monitoring` — 5 checks)
- **Expected Condition**: Fact row count = 590,540; dimension row count = 144,233; linked count = 144,233; unlinked = 446,307.
- **PASS/FAIL Rule**: PASS if count matches exact baseline; FAIL if row counts drop or unexpectedly multiply.

### 3. Duplicate Key Monitoring (`monitoring.vw_duplicate_monitoring` — 4 checks)
- **Expected Condition**: Zero duplicate `TransactionID` values in fact and dimension tables; zero duplicate surrogate keys.
- **PASS/FAIL Rule**: PASS if `COUNT(*) - COUNT(DISTINCT key) = 0`; FAIL if > 0 (Severity: CRITICAL).

### 4. NULL & Missingness Monitoring (`monitoring.vw_null_monitoring` — 14 checks)
- **Expected Condition**: Mandatory core fields (`TransactionID`, `TransactionDT`, `TransactionAmt`, `isFraud`, `ProductCD`) have 0 NULLs; optional fields remain within baseline tolerances.
- **PASS/FAIL Rule**: PASS if mandatory NULL count = 0 and optional missingness rates match expected baseline ±0.01%; FAIL otherwise.

### 5. Referential Integrity (`monitoring.vw_referential_integrity_monitoring` — 5 checks)
- **Expected Condition**: Every non-null `fact_transaction_clean.identity_key` matches an existing `dim_identity_clean.identity_key`.
- **PASS/FAIL Rule**: PASS if orphan count = 0; FAIL if orphan count > 0 (Severity: CRITICAL).

### 6. Business Rules & Invariants (`monitoring.vw_business_rule_monitoring` — 9 checks)
- **Expected Condition**: `TransactionAmt >= 0`; `isFraud IN (0, 1)`; `transaction_hour BETWEEN 0 AND 23`; `transaction_day_number BETWEEN 1 AND 183`.
- **PASS/FAIL Rule**: PASS if violation count = 0; FAIL if invalid values detected (Severity: CRITICAL).

### 7. Distribution Monitoring (`monitoring.vw_distribution_monitoring` — 19 checks)
- **Expected Condition**: Numeric moments (mean, stddev, min, max, percentiles) and categorical frequencies remain within historical bands. Total amount = $79,738,948.735; average = $135.027.
- **PASS/FAIL Rule**: PASS if observed values fall within baseline bounds [tolerance_lower, tolerance_upper]; WARNING/FAIL if distribution drifts.

### 8. Fraud Rate & Exposure Monitoring (`monitoring.vw_fraud_rate_monitoring` — 7 checks)
- **Expected Condition**: Baseline fraud count = 20,663; fraud rate = 3.499%; fraud volume share = 3.867%; fraud average ticket = $149.24.
- **PASS/FAIL Rule**: PASS if fraud rate and exposure match baseline bounds [3.0%, 4.0%]; WARNING if sudden spike or drop.

### 9. Risk Signal Operationality (`monitoring.vw_risk_signal_monitoring` — 12 checks)
- **Expected Condition**: All 6 risk signal views are active and return valid binary flags; score distribution covers 0 to 7; high risk band >= 5.
- **PASS/FAIL Rule**: PASS if signal counts are non-zero and within expected ranges; FAIL if any signal fails to compute.

---

## 3. Verified Audit Execution Results

### 3.1 Initial Baseline Execution
- **Run ID**: `57c1dce4-d490-402d-9dbb-e9d38511bd10`
- **Timestamp**: `2026-09-29 20:41:03+05:30`
- **Total Checks Evaluated**: 98
- **Passed Checks**: 98
- **Failed Checks**: 0
- **Overall Verdict**: **PASS**

### 3.2 Post-Optimization Monitoring Run (Phase 13)
- **Run ID**: `5dbd0f9d-f1bc-4454-b6d6-0d831c366cdb`
- **Timestamp**: `2026-09-30 20:59:31+05:30`
- **Total Checks Evaluated**: 98
- **Passed Checks**: 98
- **Failed Checks**: 0
- **Overall Verdict**: **PASS**

---

## 4. Controlled Anomaly Testing Outcomes

The framework was tested in isolated rollback transactions using deliberate synthetic anomalies to verify sensitivity:
1. **Test A (Duplicate Key Injection)**: 5 duplicate keys injected -> `FAIL` (Severity: `CRITICAL`).
2. **Test B (Critical NULL Injection)**: 12 NULL values injected into mandatory keys -> `FAIL` (Severity: `CRITICAL`).
3. **Test C (Business Rule Violation)**: 8 negative transaction amounts injected -> `FAIL` (Severity: `CRITICAL`).
4. **Test D (Distribution Shift Simulation)**: Shifted mean amount to $850.25 -> `WARNING` (Severity: `MEDIUM`).
5. **Test E (Fraud Rate Spike Simulation)**: Shifted fraud rate to 12.50% -> `WARNING` (Severity: `HIGH`).

---

## 5. Execution Latency

Thanks to targeted indexes and optimized views, suite orchestration via `monitoring.fn_record_monitoring_run(uuid)` evaluates all 98 checks and persists complete audit results in **< 60 milliseconds**.
