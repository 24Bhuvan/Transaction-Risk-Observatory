# Transaction Risk Observatory — Project Success Criteria

## 1. Purpose

This document defines the measurable criteria used to determine whether the Transaction Risk Observatory project has been successfully implemented.

Success is evaluated based on reproducibility, data integrity, analytical validity, SQL implementation, performance evidence, and documentation rather than subjective quality statements.

---

## 2. Success Criteria

The project is successful when the following criteria are satisfied.

### SC01 — Reproducible Data Ingestion

Raw IEEE-CIS transaction and identity source data can be reproducibly loaded into PostgreSQL through documented and version-controlled ingestion procedures.

**Evidence:**

* Source files are identified.
* Staging tables are documented.
* Loading procedures are documented.
* Row counts can be reconciled between source data and PostgreSQL staging.

---

### SC02 — Data Quality Assessment

Data-quality issues are systematically identified, documented, and validated.

**Evidence:**

* Missing-value analysis
* Duplicate analysis
* Data-type validation
* Domain/range checks
* Key-quality checks
* Referential consistency checks where applicable
* Documented data-quality findings

---

### SC03 — Defensible Analytical Schema

A documented analytical schema is implemented based on the actual structure and relationships discovered during profiling.

**Evidence:**

* Appropriate tables are implemented.
* Primary keys are defined where appropriate.
* Foreign keys are defined where appropriate.
* Relationships are documented.
* The model supports the required analytical questions.

---

### SC04 — Referential Integrity

Relationships between related analytical entities are validated.

**Evidence:**

* Foreign-key constraints where appropriate
* Orphan-record checks
* Key uniqueness checks
* Parent-child relationship validation
* Reconciliation of related record counts

---

### SC05 — Reproducible Data Transformation

Data cleaning and transformation can be reproduced from version-controlled SQL procedures.

**Evidence:**

* Transformation SQL scripts exist.
* Cleaning rules are documented.
* Source-to-target transformations can be rerun.
* Transformation results can be validated.

---

### SC06 — Reproducible Fraud-Risk Signals

Fraud-risk signals are generated using deterministic and version-controlled SQL rules.

**Evidence:**

* Each signal has a documented definition.
* SQL implementation exists for each signal.
* Signal outputs can be reproduced.
* Signal logic is distinguishable from the ground-truth `isFraud` label.

---

### SC07 — Transparent Risk Scoring

A transparent composite risk score is generated from documented risk signals.

**Evidence:**

* Risk-score formula is documented.
* Individual contributing signals are identifiable.
* Score calculation is reproducible.
* Risk score is not treated as equivalent to the ground-truth fraud label.

---

### SC08 — Analytical Questions Answered

The defined core analytical questions are answered through reproducible SQL queries.

**Evidence:**

* Each analytical question has a corresponding SQL query or analytical output.
* Query results are interpretable.
* Required dimensions and filters are documented.
* Results can be regenerated from the database.

---

### SC09 — Reproducible KPI Framework

Core KPIs are defined mathematically and implemented consistently.

**Evidence:**

* KPI definitions are documented.
* Numerators and denominators are explicitly defined.
* Time grain is defined for time-based KPIs.
* Source fields are identified.
* KPI SQL queries are version controlled.
* KPI results can be reproduced.

---

### SC10 — Analytical Output Validation

Important analytical results are independently checked against underlying data.

**Evidence:**

* Fraud counts are reconciled.
* Transaction totals are reconciled.
* KPI calculations are cross-checked.
* Aggregated results are validated against lower-level records where appropriate.
* Unexpected discrepancies are documented.

---

### SC11 — Query Benchmarking

Important analytical queries are benchmarked to establish measurable performance baselines.

**Evidence:**

* Selected queries are identified as performance-critical.
* Baseline execution plans are captured.
* Execution time and relevant plan information are recorded.
* Query performance can be compared before and after optimization.

---

### SC12 — Evidence-Based Performance Optimization

Performance improvements are supported by PostgreSQL execution-plan evidence rather than subjective assumptions.

**Evidence:**

* `EXPLAIN` or `EXPLAIN ANALYZE` output is captured.
* Indexes or query changes have a documented justification.
* Before/after performance is compared where applicable.
* Execution plans demonstrate the effect of optimization.

Example:

```sql
EXPLAIN ANALYZE
SELECT ...;
```

---

### SC13 — Monitoring and Data-Quality Auditing

Repeatable SQL checks exist for important data-quality and analytical integrity conditions.

**Evidence:**

* Monitoring queries exist.
* Data-quality checks are reproducible.
* Failed or anomalous checks can be identified.
* Monitoring outputs are documented.

---

### SC14 — Repository Reproducibility

Another user should be able to understand and reproduce the project environment and workflow from the repository documentation.

**Evidence:**

* Repository structure is documented.
* PostgreSQL environment is documented.
* Database and schema setup is documented.
* SQL execution order is documented.
* Required dependencies are documented.
* Important assumptions are documented.
* Git history contains the implementation steps.

---

### SC15 — Version-Controlled Implementation

Project implementation and documentation are maintained in Git.

**Evidence:**

* SQL scripts are version controlled.
* Documentation is version controlled.
* Meaningful changes are committed.
* Remote GitHub repository contains the project history.

---

## 3. Minimum Completion Standard

The project must satisfy all critical criteria below before it can be considered complete:

| Criterion                              | Required |
| -------------------------------------- | -------- |
| Reproducible data ingestion            | Yes      |
| Data-quality assessment                | Yes      |
| Analytical schema                      | Yes      |
| Referential integrity validation       | Yes      |
| Reproducible transformations           | Yes      |
| Rule-based fraud-risk signals          | Yes      |
| Transparent risk scoring               | Yes      |
| Analytical questions answered          | Yes      |
| Reproducible KPIs                      | Yes      |
| Analytical validation                  | Yes      |
| Query benchmarking                     | Yes      |
| `EXPLAIN ANALYZE` performance evidence | Yes      |
| Monitoring / data-quality auditing     | Yes      |
| Repository reproducibility             | Yes      |
| Version-controlled implementation      | Yes      |

---

## 4. Definition of Done

The Transaction Risk Observatory is considered technically complete when:

1. The complete data pipeline from raw source data to analytical outputs is reproducible.
2. Data-quality issues and their treatment are documented.
3. The analytical schema is implemented and validated.
4. Referential integrity has been tested.
5. Fraud-risk signals are implemented as reproducible SQL rules.
6. Risk scoring is transparent and reproducible.
7. Core analytical questions have corresponding SQL outputs.
8. Core KPIs have documented and reproducible definitions.
9. Important analytical queries have measurable performance baselines.
10. Performance optimizations are supported by `EXPLAIN ANALYZE` evidence.
11. Data-quality and monitoring checks are implemented.
12. The repository contains sufficient documentation for another user to reproduce the project workflow.

Success is therefore determined by **verifiable technical and analytical evidence**, not by whether the resulting system is subjectively considered "good."
