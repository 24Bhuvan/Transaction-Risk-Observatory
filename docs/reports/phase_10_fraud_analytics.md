# Phase 10 — Fraud Analytics & Detection Patterns

## 1. Overview

Phase 10 implements an explainable, deterministic, rule-based transaction risk analytics layer in PostgreSQL 18. Rather than black-box machine learning models, the observatory relies on transparent SQL detection heuristics that evaluate transaction velocity, amount anomalies, entity/device concentrations, off-hours timing, composite signal densities, and additive risk scoring.

All analytical logic queries `analytics.vw_transaction_analytics` over the validated 590,540-row fact population.

---

## 2. Implemented Detection Patterns

### Pattern 1: Baseline Risk Analysis
- **Problem**: Establish baseline fraud rates and financial exposure across the entire dataset to calibrate detection thresholds.
- **SQL Approach**: Population-level aggregations computing total count, fraud count, fraud rate, total volume, and fraud volume share.
- **Signal / Output**: Population fraud rate of **3.499%** (20,663 / 590,540) and gross fraud exposure of **$3,083,844.86** (3.867% of $79,738,948.74).
- **Business Interpretation**: Fraud transactions have a higher average ticket size ($149.24) than non-fraud transactions ($134.51), generating a $14.73 fraud premium.

### Pattern 2: Transaction Velocity Analysis (`analytics.vw_velocity_analysis`)
- **Problem**: Card-testing bots and account-takeover fraudsters execute high-frequency bursts of transactions within short timeframes.
- **SQL Approach**: Window frame aggregation partitioned by `identity_key` using a sliding physical range of 86,400 seconds (24 hours):
  ```sql
  COUNT(*) OVER (
      PARTITION BY identity_key
      ORDER BY "TransactionDT"
      RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW
  ) AS transactions_in_24h
  ```
- **Signal / Output**: `velocity_flag = 1` when an entity performs >= 3 transactions in a rolling 24-hour window. Flags 139,942 transactions; captures 5,790 historical fraud events (fraud rate: **4.137%** vs 3.301% unflagged). Maximum observed velocity: 192 transactions in 24 hours.
- **Business Interpretation**: Identifies rapid-fire automated script testing and payment card enumeration attacks.

### Pattern 3: Amount Anomaly Analysis (`analytics.vw_amount_anomalies`)
- **Problem**: Fraudulent card usage frequently deviates significantly from an entity's typical purchasing behavior.
- **SQL Approach**: Computes entity-level historical 95th percentile purchase amounts using `PERCENTILE_CONT(0.95)` and compares against current `TransactionAmt`:
  ```sql
  CASE WHEN "TransactionAmt" > entity_p95_amt THEN 1 ELSE 0 END AS amount_anomaly_flag
  ```
- **Signal / Output**: Flags 6,251 transactions; captures 166 fraud events (fraud rate: **2.656%**).
- **Business Interpretation**: Detects abnormal high-ticket spending spikes. Because non-fraud accounts also occasionally make large purchases, this signal operates best when combined with other indicators.

### Pattern 4: Temporal / Off-Hours Analysis (`analytics.vw_off_hours_analysis`)
- **Problem**: Fraudulent activity disproportionately occurs during late-night and early-morning hours when cardholders are asleep and manual fraud review staffing is low.
- **SQL Approach**: Filters on derived diurnal hour `transaction_hour` (`FLOOR(TransactionDT / 3600) % 24`):
  ```sql
  CASE WHEN transaction_hour BETWEEN 2 AND 5 THEN 1 ELSE 0 END AS off_hours_risk_flag
  ```
- **Signal / Output**: Flags 223,754 transactions; captures 8,287 fraud events (fraud rate: **3.704%** vs 3.374% daylight).
- **Business Interpretation**: Highlights high-risk temporal operating windows, providing contextual risk weighting for overnight payment processing.

### Pattern 5: Entity / Device Anomalies (`analytics.vw_entity_device_anomalies`)
- **Problem**: Organized fraud rings leverage device emulators or shared hardware to access multiple distinct customer identities.
- **SQL Approach**: Window aggregation counting distinct identities per normalized device string (`deviceinfo_normalized`) and distinct devices per `identity_key`:
  ```sql
  CASE WHEN device_shared_count > 1 OR identity_device_count > 2 THEN 1 ELSE 0 END AS entity_device_anomaly_flag
  ```
- **Signal / Output**: Flags 118,231 transactions; captures 8,595 fraud events (fraud rate: **7.270%** vs 2.555% unflagged).
- **Business Interpretation**: Strongest single precision signal in the observatory, yielding a 2.8x fraud rate increase by isolating hardware sharing and device spoofing.

### Pattern 6: Geographic Analysis / Impossible Travel Assessment (`analytics.vw_geographic_anomalies`)
- **Problem**: Identify physically impossible consecutive transactions across distant geographic locations.
- **SQL Approach**: Evaluates `addr1`, `addr2`, `dist1`, and `dist2`. Because the source dataset provides only coarse, anonymized billing regions and lacks precise GPS/latitude-longitude coordinates, Haversine travel speed cannot be calculated without fabricating synthetic data.
- **Signal / Output**: `impossible_travel_flag = 0` (fixed across all 590,540 rows).
- **Business Interpretation**: Documents an empirical technical capability boundary: geographic anomaly detection requires true geographic coordinates; no coordinates were synthetically fabricated.

### Pattern 7: Composed Risk Signals (`analytics.vw_composed_risk_signals`)
- **Problem**: Single detection rules generate false positives. Multi-vector threat density indicates coordinated fraud attacks.
- **SQL Approach**: Sums all active binary component flags:
  ```sql
  signal_count = velocity_flag + amount_anomaly_flag + entity_device_anomaly_flag + off_hours_risk_flag + impossible_travel_flag
  multiple_signal_flag = CASE WHEN signal_count >= 2 THEN 1 ELSE 0 END
  ```
- **Signal / Output**: Flags 109,197 transactions; captures 6,394 fraud events (fraud rate: **5.856%** vs 2.964% for single/zero signal).
- **Business Interpretation**: Isolates multi-layered risks where multiple independent behavioral anomalies trigger simultaneously.

### Pattern 8: Additive Risk Scoring (`analytics.vw_risk_scoring`)
- **Problem**: Operational teams require a single transparent rank to prioritize investigations rather than evaluating disjointed flags.
- **SQL Approach**: Linear weighted scoring model:
  ```sql
  risk_score = (velocity_flag * 2)
             + (amount_anomaly_flag * 2)
             + (entity_device_anomaly_flag * 2)
             + (off_hours_risk_flag * 1)
             + (impossible_travel_flag * 3)
  ```
  Risk bands:
  - `HIGH`: `risk_score >= 5`
  - `MEDIUM`: `risk_score BETWEEN 2 AND 4`
  - `LOW`: `risk_score < 2`
- **Signal / Output**: Score spans integers 0 to 7 (average: 1.274, median: 1).
- **Business Interpretation**: Provides a deterministic, auditable triage hierarchy for automated holding, manual review, or immediate clearing.

### Pattern 9: Suspicious Transactions (`analytics.vw_suspicious_transactions`)
- **Problem**: Surface high-priority payment events for operational fraud queue routing.
- **SQL Approach**: Filters `vw_risk_scoring` for `risk_score >= 2` (MEDIUM and HIGH bands) and builds an explainable textual diagnostics summary (`risk_reason`).
- **Signal / Output**: Curated queue containing transaction metadata, customer contact info, active flags, and formatted score justification.
- **Business Interpretation**: Operational workbench view for fraud risk analysts.

### Pattern 10: Suspicious Entities (`analytics.vw_suspicious_entities`)
- **Problem**: Identify compromised digital entities or persistent bad actors operating across multiple transactions.
- **SQL Approach**: Entity-level aggregation over `identity_key` summarizing total transaction volume, flagged transaction count, confirmed fraud incidents, and average risk score.
- **Signal / Output**: Entity watchlist ranking entities by total exposure and suspicious activity frequency.
- **Business Interpretation**: Enables proactive account suspension, step-up MFA enforcement, and entity-level blacklisting.

---

## 3. Pattern Validation & Performance Summary

| Rule / Signal View | Flagged Volume | Flagged Fraud Count | Flagged Fraud Rate | Baseline Multiplier |
|:---|---:|---:|---:|:---|
| **Entity / Device Anomaly** | 118,231 | 8,595 | **7.270%** | 2.08x baseline |
| **Velocity (24h burst)** | 139,942 | 5,790 | **4.137%** | 1.18x baseline |
| **Off-Hours Activity** | 223,754 | 8,287 | **3.704%** | 1.06x baseline |
| **Amount Anomaly (P95)** | 6,251 | 166 | **2.656%** | 0.76x baseline |
| **Multiple Signals (>=2)** | 109,197 | 6,394 | **5.856%** | 1.67x baseline |
| **Velocity + Entity/Device** | 34,619 | 2,318 | **6.696%** | 1.91x baseline |
| **Full Population Baseline** | 590,540 | 20,663 | **3.499%** | 1.00x baseline |
