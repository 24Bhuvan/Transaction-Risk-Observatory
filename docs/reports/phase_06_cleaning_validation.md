# Phase 6 — Data Cleaning & Transformation Validation Report

## 1. Purpose

Phase 6 transforms the Phase 5 analytical layer into a clean analytical layer while preserving:

* Transaction grain
* `TransactionID`
* `transaction_key`
* `identity_key`
* `isFraud`
* `TransactionDT`
* `TransactionAmt`
* Source NULL semantics
* Identity optionality
* Anonymized source fields
* Original Phase 5 analytical tables

Phase 6 clean tables:

* `analytics.fact_transaction_clean`
* `analytics.dim_identity_clean`

Phase 5 tables remain unchanged:

* `analytics.fact_transaction`
* `analytics.dim_identity`

---

# 2. Validation Summary

| Step | Transformation                                         | Affected Columns                                                     | Before Count / Statistic                           | After Count / Statistic                               | Validation                                   | Result |
| ---- | ------------------------------------------------------ | -------------------------------------------------------------------- | -------------------------------------------------- | ----------------------------------------------------- | -------------------------------------------- | ------ |
| 6.1  | Freeze Phase 5 baseline                                | Fact / Identity                                                      | 590,540 / 144,233 rows                             | 590,540 / 144,233                                     | Baseline recorded                            | PASS   |
| 6.2  | Define cleaning boundary                               | Analytical layer                                                     | Phase 5 tables preserved                           | Clean layer defined separately                        | Boundary documented                          | PASS   |
| 6.3  | Create clean analytical layer                          | Fact / Identity                                                      | 590,540 / 144,233                                  | 590,540 / 144,233                                     | Row counts preserved                         | PASS   |
| 6.4  | Standardize categorical/text fields                    | `ProductCD`, `card4`, `card6`, `M1`–`M9`, `DeviceType`, `DeviceInfo` | Blank/whitespace values present                    | Blank values converted to NULL; whitespace normalized | No unexpected mismatches                     | PASS   |
| 6.5  | Standardize email fields                               | `P_emaildomain`, `R_emaildomain`                                     | Source values preserved                            | Trimmed/NULL-normalized values                        | 0 unexpected mismatches                      | PASS   |
| 6.6  | Normalize device information                           | `DeviceInfo`, `deviceinfo_normalized`, `deviceinfo_missing_flag`     | 118,666 non-NULL / 25,567 NULL                     | 118,666 available / 25,567 missing                    | Flag and normalization mismatches = 0        | PASS   |
| 6.7  | Preserve NULL semantics and create targeted indicators | `dist2`, `D7`, `R_emaildomain`, `card2`, `card3`, `card5`, `card6`   | Source NULLs preserved                             | Missingness indicators added                          | Indicator mismatches = 0                     | PASS   |
| 6.8  | Profile secondary card missingness                     | `card2`, `card3`, `card5`, `card6`                                   | 579,507 complete; 9,468 partial; 1,565 all missing | Same source NULL counts plus composite indicators     | Count/flag mismatches = 0                    | PASS   |
| 6.9  | Derive relative transaction-time features              | `TransactionDT`                                                      | Min 86,400; max 15,811,131                         | Day 1–182; hour 0–23; week 0–26                       | Feature mismatches = 0                       | PASS   |
| 6.10 | Validate transaction amounts and derive features       | `TransactionAmt`                                                     | Sum 79,738,948.735; avg 135.0271763724726521       | Same authoritative amount values; log feature added   | Amount/log mismatches = 0                    | PASS   |
| 6.11 | Validate categorical standardization                   | `ProductCD`, `card4`, `card6`, `DeviceType`, `M1`–`M9`, email fields | Source categories                                  | Clean categories preserved                            | Whitespace/blank/rare-category checks passed | PASS   |
| 6.12 | Create risk-signal features                            | Identity, email, device, card, amount signals                        | Source characteristics preserved                   | Signal columns added                                  | Composite signal mismatches = 0              | PASS   |
| 6.13 | Finalize clean analytical layer                        | Clean fact / identity tables                                         | 590,540 / 144,233                                  | 590,540 / 144,233                                     | Feature presence and core metrics validated  | PASS   |
| 6.14 | Validate final clean layer                             | All clean-layer transformations                                      | Phase 5 baseline                                   | Clean layer                                           | All validation gates passed                  | PASS   |
| 6.15 | Reconcile against Phase 5                              | Common analytical fields                                             | Phase 5 baseline                                   | Phase 6 clean layer                                   | 0 unexpected mismatches                      | PASS   |

---

# 3. Population and Grain Validation

## Fact Table

| Metric                    | Phase 5 | Phase 6 | Result |
| ------------------------- | ------: | ------: | ------ |
| Row count                 | 590,540 | 590,540 | PASS   |
| Distinct `TransactionID`  | 590,540 | 590,540 | PASS   |
| Duplicate `TransactionID` |       0 |       0 | PASS   |

## Identity Table

| Metric                    | Phase 5 | Phase 6 | Result |
| ------------------------- | ------: | ------: | ------ |
| Row count                 | 144,233 | 144,233 | PASS   |
| Distinct `TransactionID`  | 144,233 | 144,233 | PASS   |
| Duplicate `TransactionID` |       0 |       0 | PASS   |

---

# 4. Identity Relationship Validation

| Metric                         | Phase 5 | Phase 6 | Result |
| ------------------------------ | ------: | ------: | ------ |
| Identity-linked transactions   | 144,233 | 144,233 | PASS   |
| Identity-unlinked transactions | 446,307 | 446,307 | PASS   |

The Phase 6 clean layer preserves the original optional identity relationship.

No inner join was introduced during cleaning.

---

# 5. Fraud Label Validation

| `isFraud` | Phase 5 | Phase 6 | Result |
| --------- | ------: | ------: | ------ |
| 0         | 569,877 | 569,877 | PASS   |
| 1         |  20,663 |  20,663 | PASS   |

`isFraud` was not modified or used as a transformation target.

---

# 6. Transaction Amount Validation

| Metric                |              Phase 5 |              Phase 6 | Result |
| --------------------- | -------------------: | -------------------: | ------ |
| Row count             |              590,540 |              590,540 | PASS   |
| SUM(`TransactionAmt`) |       79,738,948.735 |       79,738,948.735 | PASS   |
| AVG(`TransactionAmt`) | 135.0271763724726521 | 135.0271763724726521 | PASS   |
| Negative amounts      |                    0 |                    0 | PASS   |
| Zero amounts          |                    0 |                    0 | PASS   |

Derived features:

* `transaction_amount_zero_flag`
* `transaction_amount_log`

Validation:

* Zero-amount flag mismatches = **0**
* Log transformation mismatches = **0**

`TransactionAmt` remains the authoritative monetary field.

No outlier removal, capping, or winsorization was performed.

---

# 7. Transaction Time Validation

Original field:

* `TransactionDT`

Derived fields:

* `transaction_day_number`
* `transaction_hour`
* `transaction_week_number`

Observed range:

| Feature                 | Result     |
| ----------------------- | ---------- |
| `TransactionDT` minimum | 86,400     |
| `TransactionDT` maximum | 15,811,131 |
| Day number              | 1–182      |
| Hour                    | 0–23       |
| Week number             | 0–26       |

Validation:

* Day feature mismatches = **0**
* Hour feature mismatches = **0**
* Week feature mismatches = **0**

No calendar date, year, or month was fabricated from `TransactionDT`.

---

# 8. Device Information Validation

Identity population:

| Metric                |   Count |
| --------------------- | ------: |
| Total identity rows   | 144,233 |
| Non-NULL `DeviceInfo` | 118,666 |
| NULL `DeviceInfo`     |  25,567 |

Derived fields:

* `deviceinfo_normalized`
* `deviceinfo_missing_flag`

Validation:

| Check                    | Result |
| ------------------------ | ------ |
| Missing-flag mismatches  | 0      |
| Normalization mismatches | 0      |
| Invalid flags            | 0      |

The original `DeviceInfo` field remains available.

No device taxonomy or semantic device mapping was invented.

---

# 9. NULL and Missingness Validation

Targeted missingness indicators were created for:

* `dist2`
* `D7`
* `R_emaildomain`
* `card2`
* `card3`
* `card5`
* `card6`

Observed missingness:

| Field           | Missing |
| --------------- | ------: |
| `dist2`         | 552,913 |
| `D7`            | 551,623 |
| `R_emaildomain` | 453,249 |
| `card2`         |   8,933 |
| `card3`         |   1,565 |
| `card5`         |   4,259 |
| `card6`         |   1,571 |

All indicator mismatches = **0**.

No blanket NULL imputation was performed.

---

# 10. Secondary Card Missingness

Derived:

* `card_attributes_missing_count`
* `card_attributes_partial_missing_flag`

Distribution:

| Missing secondary-card attributes | Transactions |
| --------------------------------: | -----------: |
|                                 0 |      579,507 |
|                                 1 |        8,874 |
|                                 2 |          588 |
|                                 3 |            6 |
|                                 4 |        1,565 |

Partial missingness (`1–3`) = **9,468**

Complete secondary-card missingness (`4`) = **1,565**

Validation:

* Count mismatches = **0**
* Partial-flag mismatches = **0**

---

# 11. Categorical Standardization Validation

Standardized fields:

* `ProductCD`
* `card4`
* `card6`
* `M1`–`M9`
* `DeviceType`
* `DeviceInfo`

Transformation policy:

* Trim surrounding whitespace.
* Convert blank strings to NULL where documented.
* Normalize internal whitespace for `DeviceInfo`.
* Preserve legitimate category values.
* Do not invent semantic mappings.
* Do not collapse rare categories.

Validation results:

* Whitespace violations = **0**
* Blank categorical values = **0**
* Rare `card6` categories preserved.
* M1–M9 valid values preserved.
* Unexpected transformed-field mismatches = **0**

---

# 12. Risk-Signal Features

Derived features:

* `identity_available_flag`
* `email_domain_missing_flag`
* `device_info_available_flag`
* `missing_attribute_count`

Existing supporting features:

* `card_attributes_partial_missing_flag`
* `transaction_amount_zero_flag`

Observed signals:

| Signal                         |   Count |
| ------------------------------ | ------: |
| Identity available             | 144,233 |
| Identity unavailable           | 446,307 |
| Both email domains missing     |  83,392 |
| Device information available   | 118,666 |
| Device information unavailable | 471,874 |
| Partial card missingness       |   9,468 |
| Zero-amount transactions       |       0 |

`missing_attribute_count` distribution:

| Count | Transactions |
| ----: | -----------: |
|     0 |      115,938 |
|     1 |       27,273 |
|     2 |      359,642 |
|     3 |       86,264 |
|     4 |        1,423 |

Validation:

* Risk-signal mismatches = **0**
* Composite mismatches = **0**
* Invalid signal values = **0**

No weighted fraud score was created.

`isFraud` remains the original target label.

---

# 13. Phase 5 → Phase 6 Reconciliation

Step 6.15 performed row-level and aggregate reconciliation.

## Unchanged Fields

Validated fields include:

* `transaction_key`
* `identity_key`
* `TransactionID`
* `isFraud`
* `TransactionDT`
* `TransactionAmt`

Result:

**0 mismatches**

## Transformed Fact Fields

Validated against documented normalization:

* `ProductCD`
* `card4`
* `card6`
* `M1`–`M9`

Result:

**0 unexpected mismatches**

## Transformed Identity Fields

Validated against documented normalization:

* `DeviceType`
* `DeviceInfo`

Result:

**0 unexpected mismatches**

## Email Fields

Validated against documented normalization:

* `P_emaildomain`
* `R_emaildomain`

Result:

**0 unexpected mismatches**

## Final Reconciliation Gate

```text
phase_6_reconciliation_status | 0 | 0 | 0 | PASS
```

Therefore:

* Unchanged-field mismatches = **0**
* Unexpected categorical mismatches = **0**
* Unexpected device mismatches = **0**

---

# 14. Phase 3 Issue → Phase 6 Action Mapping

| Phase 3 Issue ID | Phase 6 Action                                                         | Status | Evidence                                                    |
| ---------------- | ---------------------------------------------------------------------- | ------ | ----------------------------------------------------------- |
| DQ-001           | Preserve transaction grain and validate `TransactionID` uniqueness     | PASS   | 590,540 rows; 590,540 distinct TransactionIDs; 0 duplicates |
| DQ-002           | Preserve optional identity relationship using `LEFT JOIN` semantics    | PASS   | 144,233 linked; 446,307 unlinked                            |
| DQ-003           | Preserve high-cardinality/anonymized fields without semantic remapping | PASS   | No invented mappings; reconciliation passed                 |
| DQ-004           | `dist2` high missingness — NULL preserved                              | PASS   | 552,913 NULLs; targeted missingness handling; no imputation |
| DQ-005           | `D7` high missingness — NULL preserved                                 | PASS   | 551,623 NULLs; missingness preserved                        |
| DQ-006           | `R_emaildomain` missingness — NULL preserved and indicator created     | PASS   | 453,249 missing; indicator validation passed                |
| DQ-007           | Secondary card missingness profiled and represented with indicators    | PASS   | 9,468 partial; 1,565 all missing                            |
| DQ-008           | `DeviceInfo` missingness represented explicitly                        | PASS   | 25,567 missing; `deviceinfo_missing_flag` validated         |
| DQ-009           | Categorical blanks standardized to NULL where documented               | PASS   | Blank validation = 0; transformed-field mismatches = 0      |
| DQ-010           | DeviceInfo whitespace normalized without semantic mapping              | PASS   | Normalization mismatches = 0                                |
| DQ-011           | Transaction amount retained as authoritative value                     | PASS   | SUM and AVG exactly match Phase 5                           |
| DQ-012           | TransactionDT retained and transformed only into relative features     | PASS   | Day/hour/week mismatches = 0                                |
| DQ-013           | Fraud label preserved without modification                             | PASS   | 569,877 non-fraud; 20,663 fraud                             |
| DQ-014           | Risk-signal features derived from documented missingness conditions    | PASS   | Composite mismatches = 0                                    |

> Note: Phase 3 issue IDs above are mapped to the corresponding documented Phase 3 issue categories used in the project. The Phase 6 actions do not alter source/staging data.

---

# 15. Phase 6 Final Validation Gate

| Validation Area                    | Result |
| ---------------------------------- | ------ |
| Population preservation            | PASS   |
| Transaction grain preservation     | PASS   |
| TransactionID uniqueness           | PASS   |
| Identity relationship preservation | PASS   |
| Fraud-label preservation           | PASS   |
| Transaction amount preservation    | PASS   |
| Transaction time preservation      | PASS   |
| NULL semantics preservation        | PASS   |
| Categorical standardization        | PASS   |
| DeviceInfo normalization           | PASS   |
| Missingness indicators             | PASS   |
| Card missingness logic             | PASS   |
| Risk-signal logic                  | PASS   |
| Phase 5 reconciliation             | PASS   |

## Overall Status

**PHASE 6 — PASS**

The Phase 6 clean analytical layer preserves the Phase 5 analytical population, grain, identifiers, fraud labels, financial measures, transaction timing, and identity relationship.

All documented transformations were validated, and the Phase 5 → Phase 6 reconciliation produced **zero unexpected mismatches**.

Phase 5 analytical tables remain preserved as the validated pre-cleaning analytical layer.
