# Phase 10 — Risk Analysis Validation

## 1. Scope

Phase 10 implements a transparent, SQL-based transaction risk analysis layer in PostgreSQL.

The phase analyzes historical IEEE-CIS transaction data using rule-based fraud/risk detection patterns rather than machine-learning models.

The implemented analyses cover:

* Transaction velocity
* Transaction amount anomalies
* Entity/device anomalies
* Off-hours activity
* Geographic-analysis capability assessment
* Multi-signal risk composition
* Rule-based risk scoring
* Suspicious transaction identification
* Suspicious entity identification
* Historical fraud-label comparison
* Cross-signal analysis
* Query-performance baseline capture

The objective is to create explainable transaction and entity risk signals that can be consumed by subsequent KPI and business-analysis phases.

---

## 2. Input Sources

### Primary analytical source

```text
analytics.vw_transaction_analytics
```

Phase 10 baseline validation returned:

| Metric                 |          Value |
| ---------------------- | -------------: |
| Source rows            |        590,540 |
| Distinct transactions  |        590,540 |
| Fraud rows             |         20,663 |
| Minimum TransactionDT  |         86,400 |
| Maximum TransactionDT  |     15,811,131 |
| Transaction amount sum | 79,738,948.735 |

### Relevant source attributes

The Phase 10 analyses use fields including:

* `TransactionID`
* `transaction_key`
* `identity_key`
* `isFraud`
* `TransactionDT`
* `TransactionAmt`
* `card1`
* `P_emaildomain`
* `R_emaildomain`
* `addr1`
* `addr2`
* `dist1`
* `dist2`
* `transaction_hour`
* `deviceinfo_normalized`

Baseline entity availability included:

| Attribute               | Distinct values |
| ----------------------- | --------------: |
| Identity                |         144,233 |
| Device information      |           1,779 |
| Card4 values            |               4 |
| Card6 values            |               4 |
| Purchaser email domains |              59 |
| Recipient email domains |              60 |

### Phase 10 analytical views

The major Phase 10 outputs are built through:

```text
analytics.vw_velocity_analysis
analytics.vw_amount_anomalies
analytics.vw_entity_device_anomalies
analytics.vw_off_hours_analysis
analytics.vw_geographic_anomalies
analytics.vw_composed_risk_signals
analytics.vw_risk_scoring
analytics.vw_suspicious_transactions
analytics.vw_suspicious_entities
```

---

## 3. Detection Rules

### R01 — Transaction Velocity

Source:

```text
identity_key
TransactionDT
```

Technique:

* `LAG()`
* Window partitioning
* `ORDER BY`
* 24-hour `RANGE` window

Rule:

```text
velocity_flag = 1
when an identity has 3 or more transactions
within a 24-hour relative-time window.
```

Output:

```text
transactions_in_24h
velocity_flag
velocity_rule
```

The implemented velocity analysis produced:

```text
Total transactions: 590,540
Flagged transactions: 139,942
Maximum observed 24-hour transaction count: 192
```

---

### R02 — Amount Anomaly

Source:

```text
TransactionAmt
identity-level historical baseline
```

Techniques include:

* `PERCENTILE_CONT`
* Entity-level aggregation
* Conditional logic

Output:

```text
amount_anomaly_flag
```

Observed validation:

```text
Flagged transactions: 6,251
Fraud transactions among flagged: 166
Fraud rate among flagged: 2.6556%
```

---

### R03 — Entity / Device Anomaly

Source:

```text
identity_key
deviceinfo_normalized
```

The analysis evaluates entity/device concentration and reuse patterns.

Output:

```text
entity_device_anomaly_flag
```

Observed validation:

```text
Flagged transactions: 118,231
Fraud transactions among flagged: 8,595
Fraud rate among flagged: 7.2697%
```

---

### R04 — Off-Hours Activity

Source:

```text
transaction_hour
TransactionDT
```

The rule uses transaction timing to identify activity occurring during the defined off-hours period.

The rule does not treat every off-hours transaction as fraud.

Output:

```text
off_hours_risk_flag
```

Observed validation:

```text
Flagged transactions: 223,754
Fraud transactions among flagged: 8,287
Fraud rate among flagged: 3.7036%
```

---

### R05 — Geographic Analysis

Available geographic attributes:

```text
addr1
addr2
dist1
dist2
```

The dataset does not provide sufficient latitude/longitude coordinates for valid Haversine-based travel calculations.

Therefore:

```text
impossible_travel_flag = 0
```

for the current implementation.

No latitude/longitude values were fabricated from ZIP codes, addresses, states, or other coarse attributes.

The limitation applies to all:

```text
590,540
```

transaction rows.

---

### R06 — Multiple-Signal Detection

The individual risk signals are composed into a multi-signal layer.

Signals include:

```text
velocity
amount anomaly
entity/device anomaly
off-hours
geographic anomaly
```

Outputs:

```text
signal_count
multiple_signal_flag
```

Observed validation:

```text
Flagged transactions: 109,197
Fraud transactions among flagged: 6,394
Fraud rate among flagged: 5.8555%
```

---

### R07 — Rule-Based Risk Score

The implemented additive score is:

```text
velocity              × 2
amount anomaly        × 2
entity/device anomaly × 2
off-hours              × 1
impossible travel      × 3
```

Therefore:

```text
risk_score =
    velocity_flag * 2
  + amount_anomaly_flag * 2
  + entity_device_anomaly_flag * 2
  + off_hours_risk_flag
  + impossible_travel_flag * 3
```

Risk bands:

```text
HIGH   >= 5
MEDIUM >= 2
LOW    < 2
```

The score is a transparent prioritization heuristic.

It is **not a probability of fraud**.

---

## 4. SQL Techniques

Phase 10 uses advanced PostgreSQL functionality for genuine analytical purposes.

### CTEs

Used to separate intermediate analytical stages and compose multiple risk signals.

### Window functions

Used for:

* Transaction ordering
* `LAG()`
* Velocity calculations
* Time-based transaction analysis
* Entity-level analytical calculations

### Window frames

The velocity analysis uses a relative 24-hour window:

```text
RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW
```

### Conditional aggregation

Used for:

* Flagged transaction counts
* Fraud counts
* Unflagged transaction counts
* Entity/device concentration
* Rule validation

### `FILTER`

Used to calculate conditional counts such as:

```sql
COUNT(*) FILTER (WHERE flag = 1)
```

and:

```sql
COUNT(*) FILTER (WHERE flag = 1 AND isFraud = 1)
```

### Percentile analysis

`PERCENTILE_CONT` is used for amount-anomaly baseline analysis.

### CASE expressions

Used for:

* Risk flags
* Risk bands
* Rule classifications
* Explainable risk reasons

### CTE materialization

The pattern-validation query uses:

```sql
WITH scored AS MATERIALIZED (...)
```

to reuse the scoring layer during rule comparison.

### EXPLAIN ANALYZE

Phase 10 performance baselines were captured using:

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

The resulting execution output was written to:

```text
reports/phase_10_explain_baseline.txt
```

---

## 5. Outputs

### Transaction-level outputs

```text
analytics.vw_velocity_analysis
analytics.vw_amount_anomalies
analytics.vw_entity_device_anomalies
analytics.vw_off_hours_analysis
analytics.vw_geographic_anomalies
analytics.vw_composed_risk_signals
analytics.vw_risk_scoring
analytics.vw_suspicious_transactions
```

### Entity-level output

```text
analytics.vw_suspicious_entities
```

### Primary explainable risk fields

The risk layer exposes fields including:

```text
velocity_flag
amount_anomaly_flag
entity_device_anomaly_flag
off_hours_risk_flag
impossible_travel_flag
signal_count
multiple_signal_flag
risk_score
risk_band
risk_reason
```

---

## 6. Validation

### Phase 10 source validation

```text
Source rows:              590,540
Unique transactions:      590,540
Fraud transactions:        20,663
```

All source-row and transaction-uniqueness checks passed.

### Rule validation

| Rule              | Flagged | Fraud among flagged | Fraud rate flagged | Fraud rate unflagged |
| ----------------- | ------: | ------------------: | -----------------: | -------------------: |
| Amount anomaly    |   6,251 |                 166 |            2.6556% |              3.5080% |
| Entity/device     | 118,231 |               8,595 |            7.2697% |              2.5551% |
| Multiple signal   | 109,197 |               6,394 |            5.8555% |              2.9644% |
| Off-hours         | 223,754 |               8,287 |            3.7036% |              3.3742% |
| Velocity          | 139,942 |               5,790 |            4.1374% |              3.3007% |
| Impossible travel |       0 |                   0 |                N/A |              3.4990% |

These are descriptive comparisons against the historical `isFraud` label.

The following precision-like measure was also calculated:

```text
fraud transactions among flagged
---------------------------------
total flagged transactions
```

A coverage-like measure was calculated as:

```text
fraud transactions among flagged
---------------------------------
total historical fraud transactions
```

These measures describe historical rule concentration and coverage. They are **not production model-performance metrics**.

### Cross-signal validation

Observed combinations included:

| Pattern                           | Flagged | Fraud | Fraud rate |
| --------------------------------- | ------: | ----: | ---------: |
| Entity/device                     | 118,231 | 8,595 |    7.2697% |
| Velocity + entity/device          |  34,619 | 2,318 |    6.6957% |
| Multiple signal                   | 109,197 | 6,394 |    5.8555% |
| Velocity                          | 139,942 | 5,790 |    4.1374% |
| Off-hours                         | 223,754 | 8,287 |    3.7036% |
| Velocity + amount anomaly         |   1,496 |    43 |    2.8743% |
| Amount anomaly + off-hours        |   1,744 |    48 |    2.7523% |
| Amount anomaly                    |   6,251 |   166 |    2.6556% |
| Entity/device + impossible travel |       0 |     0 |        N/A |
| Impossible travel                 |       0 |     0 |        N/A |

The results are descriptive historical comparisons and are not used as evidence of causal relationships.

### Phase 10 validation gate

All validation checks passed:

```text
source_rows                          PASS
unique_transactions                  PASS
velocity_flags_binary                PASS
amount_flags_binary                  PASS
entity_flags_binary                  PASS
off_hours_flags_binary               PASS
geographic_flags_binary              PASS
scores_nonnegative                   PASS
valid_risk_bands                     PASS
no_duplicate_suspicious_transactions PASS
```

### Final gate

The Phase 10 final gate returned:

```text
PASS
```

All 13 final-gate checks passed.

---

## 7. Performance

Phase 10 established a baseline performance workload using:

```sql
EXPLAIN (ANALYZE, BUFFERS)
```

The baseline output was captured in:

```text
reports/phase_10_explain_baseline.txt
```

The workload is intended to provide a reference point for later optimization.

Performance tuning is intentionally deferred to Phase 13.

Phase 10 therefore does not treat the baseline execution plan as an optimization exercise.

---

## 8. Limitations

### Missing geographic coordinates

The available geographic fields do not provide sufficient latitude/longitude information for valid Haversine distance and impossible-travel calculations.

No coordinates were fabricated.

Consequently, the current geographic analysis is a capability/limitation assessment rather than an impossible-travel detector.

### Historical-label limitation

The fraud comparisons use the historical:

```text
isFraud
```

label.

The results therefore describe how the rules relate to the available historical labels.

They do not establish future predictive performance.

### Rule-based nature

The Phase 10 risk score is a transparent heuristic prioritization mechanism.

It is not:

* A machine-learning model
* A calibrated probability
* A production fraud decision engine
* A statistically validated fraud probability

### Threshold assumptions

Thresholds such as:

```text
3+ transactions within 24 hours
risk-score bands
```

are documented analytical heuristics.

They should not be interpreted as universally optimal fraud thresholds.

### No real-time context

The analysis operates on historical transaction data.

It does not incorporate:

* Real-time transaction streams
* Current account state
* Current device reputation
* External fraud intelligence
* Real-time geolocation
* Real-time behavioral changes

### Dataset coverage

The analysis is limited to the fields available in the IEEE-CIS dataset and therefore cannot detect fraud patterns requiring unavailable attributes.

---

## 9. Phase 11 Handoff

Phase 11 should consume the validated Phase 10 analytical outputs rather than rebuilding the detection logic.

### Primary transaction-level input

```text
analytics.vw_suspicious_transactions
```

Use for:

* Suspicious transaction counts
* Risk-band analysis
* Risk-signal distribution
* Fraud-label comparisons
* Business-level risk KPIs

### Risk scoring input

```text
analytics.vw_risk_scoring
```

Use for:

* Risk-score distribution
* Risk-band metrics
* Signal contribution analysis

### Composed signal input

```text
analytics.vw_composed_risk_signals
```

Use for:

* Multi-signal KPIs
* Signal-count analysis
* Cross-signal business analysis

### Entity-level input

```text
analytics.vw_suspicious_entities
```

Use for:

* High-risk entity counts
* Entity concentration
* Fraud-rate analysis
* Entity-level risk KPIs

### Individual rule outputs

Phase 11 may also consume:

```text
analytics.vw_velocity_analysis
analytics.vw_amount_anomalies
analytics.vw_entity_device_anomalies
analytics.vw_off_hours_analysis
analytics.vw_geographic_anomalies
```

for rule-specific KPI calculations.

---

## Phase 10 Conclusion

Phase 10 established a validated, explainable SQL-based risk-analysis layer over the analytical transaction data.

The phase successfully implemented:

* Velocity analysis
* Amount anomaly analysis
* Entity/device anomaly analysis
* Off-hours analysis
* Geographic capability assessment
* Multi-signal composition
* Rule-based risk scoring
* Suspicious transaction identification
* Suspicious entity analysis
* Historical fraud-label validation
* Cross-signal analysis
* Performance baseline capture

The Phase 10 final gate returned:

```text
PASS
```

The resulting risk-analysis views are ready for consumption by Phase 11.
