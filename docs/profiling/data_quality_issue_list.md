# Transaction Risk Observatory — Data Quality Issue Register

## 1. Document Information

| Attribute | Value |
|---|---|
| Project | Transaction Risk Observatory |
| Phase | Phase 3 — Data Profiling & Quality Assessment |
| Step | Step 3.14 — Build the Data Quality Issue Register |
| Database Schema | `staging` |
| Source Tables | `staging.raw_transactions`, `staging.raw_identity` |
| Purpose | Record, classify, and track data-quality findings identified during Phase 3 profiling |

---

## 2. Purpose

This register records data-quality findings identified during the profiling of the staging-layer data.

Each finding receives a unique ID and is classified according to its nature:

1. **Actual Defect** — A condition that violates an expected data rule or integrity requirement.
2. **Expected Source Characteristic** — A characteristic inherent to the source dataset and not necessarily a data error.
3. **Analytical Limitation** — A condition that may restrict or affect downstream analysis.
4. **Informational Observation** — A useful observation that does not currently represent a defect or analytical limitation.

### Important Principle

Missing data is **not automatically classified as bad data**.

A NULL value may represent:

- unavailable source information,
- an optional attribute,
- a field that applies only to a subset of records,
- a characteristic of the original dataset,
- or a genuine data-quality defect.

Classification must therefore be based on evidence and the intended analytical use of the field.

---

## 3. Severity Definitions

| Severity | Definition |
|---|---|
| Critical | Prevents reliable use of a core dataset or violates a critical integrity constraint. |
| High | Materially affects important analytical fields or downstream analysis. |
| Medium | Requires attention or transformation but does not invalidate the dataset. |
| Low | Limited impact or localized issue. |
| Informational | Observation requiring documentation but no corrective action at this stage. |

---

## 4. Status Definitions

| Status | Definition |
|---|---|
| Open | Finding has been identified and requires future consideration or action. |
| Monitoring | Finding is understood but should be monitored during downstream processing. |
| Accepted | Finding is confirmed as an expected source characteristic and requires no corrective action. |
| Resolved | Corrective action has been completed in the appropriate later phase. |
| Not an Issue | Finding was investigated and determined not to represent a data-quality problem. |

---

# 5. Data Quality Issue Register

| ID | Finding | Table | Column | Classification | Severity | Evidence | Recommended Phase | Status |
|---|---|---|---|---|---|---|---|---|
| DQ-001 | Identity data is available for only a subset of transactions | `staging.raw_identity` | `TransactionID` | Expected Source Characteristic | Medium | 144,233 identity records are associated with 590,540 transactions; identity coverage is 24.42%. | Phase 6 | Accepted |
| DQ-002 | Identity records contain substantial NULL values across multiple anonymized attributes | `staging.raw_identity` | `id_01`–`id_38` | Expected Source Characteristic | Medium | Multiple identity attributes have high NULL percentages; 12 columns have more than 50% NULL and 9 have more than 90% NULL. | Phase 6 | Accepted |
| DQ-003 | `DeviceInfo` has substantial missingness | `staging.raw_identity` | `DeviceInfo` | Expected Source Characteristic | Medium | 118,666 of 144,233 records are NULL; 17.73% are non-NULL. | Phase 6 | Open |
| DQ-004 | `dist2` has very high missingness | `staging.raw_transactions` | `dist2` | Expected Source Characteristic | Medium | Approximately 93.63% of values are NULL. | Phase 6 | Open |
| DQ-005 | `D7` has very high missingness | `staging.raw_transactions` | `D7` | Expected Source Characteristic | Medium | Approximately 93.41% of values are NULL. | Phase 6 | Open |
| DQ-006 | Several D-series features have high missingness | `staging.raw_transactions` | `D6`, `D8`, `D9`, `D12`, `D13`, `D14` | Expected Source Characteristic | Medium | These fields exhibit high NULL percentages during completeness profiling. | Phase 6 | Open |
| DQ-007 | Several V-series features have high missingness | `staging.raw_transactions` | V-series | Expected Source Characteristic | Medium | Multiple V-series columns contain high NULL percentages, including groups around V138–V166 and V322–V339. | Phase 6 | Open |
| DQ-008 | Recipient email domain has substantial missingness | `staging.raw_transactions` | `R_emaildomain` | Expected Source Characteristic | Medium | Approximately 76.75% of values are NULL. | Phase 6 | Open |
| DQ-009 | No duplicate transaction identifiers detected | `staging.raw_transactions` | `TransactionID` | Informational Observation | Informational | Duplicate `TransactionID` count is 0. | N/A | Accepted |
| DQ-010 | No duplicate identity transaction identifiers detected | `staging.raw_identity` | `TransactionID` | Informational Observation | Informational | Duplicate identity `TransactionID` count is 0. | N/A | Accepted |
| DQ-011 | No orphan identity records detected | `staging.raw_identity` | `TransactionID` | Informational Observation | Informational | All 144,233 identity TransactionIDs have a matching transaction record. | N/A | Accepted |
| DQ-012 | Critical transaction fields contain no NULL values | `staging.raw_transactions` | `TransactionID`, `isFraud`, `TransactionDT`, `TransactionAmt` | Informational Observation | Informational | These fields have 0% NULL during completeness profiling. | N/A | Accepted |
| DQ-013 | `TransactionDT` contains no NULL values | `staging.raw_transactions` | `TransactionDT` | Informational Observation | Informational | 590,540 non-NULL values and 0 NULL values. | N/A | Accepted |
| DQ-014 | Transaction time is stored in source-relative numeric form | `staging.raw_transactions` | `TransactionDT` | Analytical Limitation | Medium | Values range from 86,400 to 15,811,131 and require interpretation/derivation for calendar-based analysis. | Phase 6 | Open |
| DQ-015 | Secondary card fields exhibit mixed missingness patterns | `staging.raw_transactions` | `card2`, `card3`, `card5`, `card6` | Expected Source Characteristic | Low | 1,565 records have all four fields NULL, 579,507 have all four present, and 9,468 have mixed patterns. | Phase 6 | Open |
| DQ-016 | `DeviceInfo` is high-cardinality and heterogeneous | `staging.raw_identity` | `DeviceInfo` | Analytical Limitation | Medium | 25,567 non-NULL records contain 1,786 distinct values including OS, browser, device-model, and build-like values. | Phase 6 | Open |
| DQ-017 | Low-frequency email domains produce unstable fraud-rate percentages | `staging.raw_transactions` | `P_emaildomain`, `R_emaildomain` | Analytical Limitation | Medium | Some domains have very small transaction counts but high observed fraud percentages. | Phase 6 | Open |
| DQ-018 | Rare categorical values exist in card-related fields | `staging.raw_transactions` | `card6` | Informational Observation | Low | Values such as `debit or credit` and `charge card` occur at very low frequencies. | Phase 6 | Monitoring |
| DQ-019 | `ProductCD` contains a finite set of observed categorical values | `staging.raw_transactions` | `ProductCD` | Informational Observation | Informational | Observed values are W, C, R, H, and S. | N/A | Accepted |
| DQ-020 | Fraud target is imbalanced | `staging.raw_transactions` | `isFraud` | Analytical Limitation | Medium | 569,877 records have `isFraud = 0` and 20,663 have `isFraud = 1`. | Phase 6 | Open |
| DQ-021 | No 100%-NULL columns identified | Both staging tables | All columns | Informational Observation | Informational | None of the 435 staging columns contain 100% NULL values. | N/A | Accepted |
| DQ-022 | Staging data types match the defined Phase 2 staging type mapping | Both staging tables | All columns | Informational Observation | Informational | All 435 columns matched the expected staging type mapping; no type mismatches were identified. | N/A | Accepted |

---

# 6. Actual Defects

No confirmed critical structural defects were identified during Phase 3 profiling.

Specifically:

- No duplicate transaction keys were detected.
- No duplicate identity keys were detected.
- No orphan identity records were detected.
- No NULL values were detected in the core transaction identifier.
- No NULL values were detected in the fraud target.
- No NULL values were detected in the raw transaction timestamp field.
- No NULL values were detected in the transaction amount field.
- No staging data-type mismatches were detected.

Therefore, the currently identified NULL-heavy fields are **not automatically classified as actual defects**.

---

# 7. Expected Source Characteristics

The following conditions are treated as characteristics of the source data rather than confirmed defects:

- High NULL percentages in many anonymized identity attributes.
- High NULL percentages in several transaction D-series and V-series attributes.
- Partial availability of identity information.
- Missing recipient email domains.
- Mixed missingness patterns among secondary card attributes.
- Rare categorical values.

These characteristics should be considered during downstream transformation and analytical modeling.

---

# 8. Analytical Limitations

The following findings may affect downstream analytical interpretation:

### 8.1 Partial Identity Coverage

Only 24.42% of transactions have associated identity records.

Therefore, identity-based analysis cannot automatically be interpreted as representing the complete transaction population.

### 8.2 High Missingness

Several fields contain substantial missingness.

Any imputation, exclusion, or missing-value treatment must be determined according to the analytical purpose rather than applied automatically.

### 8.3 Transaction Time Representation

`TransactionDT` is retained in its original numeric representation.

Calendar-based analysis requires a derived time interpretation in a later analytical phase.

### 8.4 High-Cardinality Device Information

`DeviceInfo` contains many distinct values and heterogeneous strings.

Direct aggregation may therefore produce fragmented categories and may require controlled standardization during downstream feature engineering.

### 8.5 Low-Frequency Categories

Very small categorical groups can produce unstable percentages and fraud rates.

Downstream analysis should account for category frequency before drawing conclusions from such groups.

### 8.6 Fraud-Class Imbalance

Fraud cases represent a minority of the transaction population.

This imbalance must be considered when selecting analytical metrics and modeling approaches.

---

# 9. Informational Observations

The following findings do not currently require corrective action:

- 435 total staging columns are documented.
- `raw_transactions` contains 394 columns.
- `raw_identity` contains 41 columns.
- No columns are 100% NULL.
- Transaction identifiers are unique.
- Identity transaction identifiers are unique.
- Identity records have valid transaction references.
- Core transaction fields are fully populated.
- Staging data types match the Phase 2 type mapping.
- Observed categorical distributions have been profiled.

---

# 10. Recommended Downstream Actions

| Finding Area | Recommended Action | Target Phase |
|---|---|---|
| High NULL fields | Assess analytical usefulness and determine appropriate NULL treatment | Phase 6 |
| Identity coverage | Preserve coverage limitation and account for it in analysis | Phase 6 |
| `TransactionDT` | Create derived analytical date/time attributes without modifying the raw field | Phase 6 |
| High-cardinality `DeviceInfo` | Evaluate controlled normalization/grouping if required | Phase 6 |
| Low-frequency categories | Apply frequency-aware analytical treatment where appropriate | Phase 6 |
| Fraud imbalance | Use appropriate evaluation metrics and analytical techniques | Phase 6 |
| Secondary card missingness | Evaluate whether missingness itself is analytically informative | Phase 6 |

---

# 11. Classification Principle

The following rule applies to this register:

> A data condition is not classified as a defect merely because it is unusual, sparse, NULL-heavy, or imbalanced.

A condition becomes an **Actual Defect** only when there is evidence that it violates a defined data-quality, structural, or business rule.

Source characteristics are documented separately so that they are not incorrectly "fixed" during data cleaning.

---

# 12. Phase 3.14 Conclusion

The Phase 3 profiling results have been converted into a structured data-quality issue register.

The register:

- Assigns a unique ID to each finding.
- Records the affected table and column.
- Records evidence supporting each finding.
- Separates defects from expected source characteristics.
- Separates analytical limitations from informational observations.
- Assigns severity.
- Identifies the recommended downstream phase.
- Records the current status.

No confirmed critical structural data-quality defects were identified during the completed profiling checks.

The major items requiring downstream consideration are primarily **missingness, partial identity coverage, time representation, high-cardinality attributes, low-frequency categories, and fraud-class imbalance**.
