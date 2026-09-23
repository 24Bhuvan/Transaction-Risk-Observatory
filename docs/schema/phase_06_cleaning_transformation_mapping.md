# Phase 6 — Cleaning & Transformation Mapping

## 1. Purpose

This document defines the formal cleaning and transformation boundary for Phase 6 of the Transaction Risk Observatory.

Phase 6 transforms the validated Phase 5 analytical layer while preserving:

* Transaction grain
* `TransactionID`
* `isFraud`
* Source NULL semantics where meaningful
* Source-relative `TransactionDT`
* Anonymized field semantics
* Identity optionality
* Phase 5 population and reconciliation

The Phase 5 analytical tables remain unchanged.

### Phase 6 source layer

```text
analytics.fact_transaction
analytics.dim_identity
```

### Phase 6 target layer

```text
analytics.fact_transaction_clean
analytics.dim_identity_clean
```

### Staging protection

The following tables must not be modified during Phase 6:

```text
staging.raw_transactions
staging.raw_identity
```

---

# 2. Cleaning Principles

Phase 6 follows these principles:

1. Preserve source information wherever possible.
2. Do not perform blanket NULL imputation.
3. Do not delete sparse columns solely because of missingness.
4. Do not delete transactions because they appear to be outliers.
5. Do not rebalance the fraud target.
6. Do not reinterpret anonymized fields as unsupported business concepts.
7. Preserve the original transaction and identity grain.
8. Apply only deterministic and documented transformations.
9. Preserve original source columns where practical.
10. Create derived analytical fields separately from authoritative source fields.
11. Treat missingness as potentially informative rather than automatically erroneous.
12. Validate every transformation against the Phase 5 baseline.

---

# 3. Phase 3 Issue Disposition

## DQ-001 — Identity Coverage

### Issue

Only approximately 24.42% of transactions have an available identity record, while the remaining transactions are identity-unlinked.

### Action

Preserve the existing identity optionality.

Do not discard transactions without identity information.

Do not impute or fabricate identity attributes.

Create an explicit identity availability indicator where useful.

### Reason

Identity information is optional in the source population. Removing identity-unlinked transactions would change the analytical population and introduce selection bias.

### Target

```text
analytics.fact_transaction_clean
```

Potential derived field:

```text
identity_available_flag
```

Relationship remains:

```text
fact_transaction_clean.identity_key
        ↓
dim_identity_clean.identity_key
```

### Validation

Verify:

```text
Total transactions = 590,540
Identity-linked = 144,233
Identity-unlinked = 446,307
```

### Status

**APPROVED — PRESERVE**

---

# DQ-002 — High NULL `id_*` Fields

### Issue

Multiple identity attributes contain substantial NULL values.

### Action

Preserve NULL values.

Do not replace NULL with:

```text
0
-1
UNKNOWN
N/A
```

unless a specific field has a separately documented transformation requirement.

### Reason

The Phase 3 analysis indicates that NULL-heavy identity attributes are primarily source characteristics rather than confirmed data-quality defects.

Blanket imputation would introduce values that were not present in the source.

### Target

```text
analytics.dim_identity_clean
```

Original fields:

```text
id_01 – id_38
```

remain available with their source NULL semantics.

### Validation

Compare NULL counts between:

```text
analytics.dim_identity
analytics.dim_identity_clean
```

For unchanged `id_*` fields:

```text
NULL count difference = 0
```

### Status

**APPROVED — PRESERVE NULLS**

---

# DQ-003 — DeviceInfo Missingness

### Issue

`DeviceInfo` contains substantial missingness and heterogeneous device/build/browser-style values.

### Action

Preserve NULL values.

For non-NULL values, apply only controlled deterministic normalization where justified, such as:

```text
TRIM()
whitespace normalization
controlled case normalization
```

Create a missingness indicator if analytically useful.

### Reason

Missing `DeviceInfo` is not established as a data defect.

Replacing missing values with an artificial category would alter source semantics.

### Target

```text
analytics.dim_identity_clean
```

Potential derived fields:

```text
deviceinfo_normalized
deviceinfo_missing_flag
```

The original:

```text
DeviceInfo
```

remains preserved where possible.

### Validation

Verify:

```text
Original NULL DeviceInfo count
=
Clean-layer original DeviceInfo NULL count
```

For non-NULL values, validate that normalization is deterministic.

### Status

**APPROVED — CONTROLLED NORMALIZATION**

---

# DQ-004 — `dist2` High NULL Rate

### Issue

`dist2` contains a high proportion of NULL values.

### Action

Preserve NULL values.

Do not impute distance values.

Do not replace NULL with zero.

### Reason

The Phase 3 evidence does not establish NULL `dist2` as an error.

Zero and NULL represent different meanings and must not be conflated.

### Target

```text
analytics.fact_transaction_clean.dist2
```

### Validation

Compare:

```text
analytics.fact_transaction.dist2 NULL count
analytics.fact_transaction_clean.dist2 NULL count
```

Expected:

```text
difference = 0
```

### Status

**APPROVED — PRESERVE NULLS**

---

# DQ-005 — D-Series High NULL Rates

### Issue

Several `D*` fields contain substantial NULL values.

### Action

Preserve NULL values.

Do not blanket-impute D-series fields.

Where justified by analytical requirements, derive missingness indicators for selected fields.

### Reason

The D-series fields are anonymized source variables. Their missingness patterns have not been established as defects.

### Target

```text
analytics.fact_transaction_clean
```

Applicable fields include:

```text
D1 – D15
```

Potential derived fields:

```text
D7_missing_flag
```

and other selected indicators only where analytically justified.

### Validation

For unchanged D-series source columns:

```text
NULL counts before = NULL counts after
```

### Status

**APPROVED — PRESERVE NULLS**

---

# DQ-006 — V-Series High NULL Rates

### Issue

Several `V*` fields contain substantial NULL values.

### Action

Preserve NULL values.

Do not blanket-impute V-series fields.

Do not convert NULL into zero or an arbitrary sentinel.

### Reason

The V-series fields are anonymized source variables and their NULL patterns are not established as data defects.

### Target

```text
analytics.fact_transaction_clean
```

Applicable fields:

```text
V1 – V339
```

### Validation

For unchanged V-series fields:

```text
NULL counts before = NULL counts after
```

No source V-series values should be lost or fabricated.

### Status

**APPROVED — PRESERVE NULLS**

---

# DQ-007 — `R_emaildomain` High NULL Rate

### Issue

`R_emaildomain` contains substantial missingness.

### Action

Preserve NULL values.

For non-NULL values:

```text
TRIM()
case normalization
```

may be applied.

Do not replace NULL with:

```text
unknown
none
missing
```

### Reason

NULL represents unavailable source information and should remain distinguishable from an actual domain category.

### Target

```text
analytics.fact_transaction_clean
```

Potential derived field:

```text
R_emaildomain_missing_flag
```

### Validation

Verify:

```text
NULL count before = NULL count after
```

for the original field.

For non-NULL values, verify deterministic normalization.

### Status

**APPROVED — STANDARDIZE NON-NULL VALUES / PRESERVE NULLS**

---

# DQ-008 — Source-Relative `TransactionDT`

### Issue

`TransactionDT` is a source-relative numeric time representation rather than a validated calendar timestamp.

### Action

Preserve:

```text
TransactionDT
```

unchanged.

Where analytically justified, derive relative temporal features such as:

```text
transaction_day_number
transaction_hour
transaction_week_number
```

These must represent elapsed/source-relative time only.

### Reason

There is no validated reference date establishing a real calendar date.

Converting `TransactionDT` into a fabricated calendar date would introduce unsupported information.

### Target

```text
analytics.fact_transaction_clean
```

Potential derived fields:

```text
transaction_day_number
transaction_hour
transaction_week_number
```

### Validation

Verify:

```text
TransactionDT before = TransactionDT after
```

for every transaction.

Validate derived fields mathematically against the original `TransactionDT`.

### Status

**APPROVED — PRESERVE SOURCE TIME / DERIVE RELATIVE FEATURES ONLY**

---

# DQ-009 — Card Attribute Mixed Missingness

### Issue

Card attributes show mixed missingness across:

```text
card2
card3
card5
card6
```

The Phase 3 analysis identified:

```text
1,565 records  → all four NULL
9,468 records  → partial/mixed missingness
579,507 records → all four present
```

### Action

Preserve the original NULL values.

Do not impute card attributes.

Create controlled missingness indicators:

```text
card_attributes_missing_count
card_attributes_partial_missing_flag
```

### Reason

The mixed pattern is not established as a structural defect.

Missing card attributes may contain analytical information.

### Target

```text
analytics.fact_transaction_clean
```

Potential derived fields:

```text
card_attributes_missing_count
card_attributes_partial_missing_flag
```

### Validation

Verify:

```text
all four missing
partial missing
none missing
```

distributions against the Phase 5 baseline.

Validate the derived count against:

```text
card2
card3
card5
card6
```

### Status

**APPROVED — PRESERVE NULLS / DERIVE MISSINGNESS FEATURES**

---

# DQ-010 — DeviceInfo High Cardinality

### Issue

`DeviceInfo` contains heterogeneous device, operating-system, browser, build, and related source strings with high cardinality.

### Action

Apply controlled deterministic normalization to non-NULL values.

Possible operations:

```text
TRIM()
whitespace normalization
controlled case normalization
```

Retain the original `DeviceInfo` value where possible.

Do not collapse categories solely because they are rare.

Do not invent semantic categories without supporting evidence.

### Reason

Formatting inconsistencies can be normalized without changing the underlying source meaning.

Aggressive categorization could destroy useful information or create unsupported interpretations.

### Target

```text
analytics.dim_identity_clean
```

Potential derived field:

```text
deviceinfo_normalized
```

### Validation

Verify:

```text
original non-NULL count
normalized non-NULL count
original NULL count
normalized NULL count
```

No original non-NULL value should become NULL.

### Status

**APPROVED — CONTROLLED NORMALIZATION**

---

# DQ-011 — Rare Email/Card Categories

### Issue

Several categorical fields contain low-frequency values.

Examples include:

```text
email domains
card4
card6
```

### Action

Standardize deterministic formatting inconsistencies.

Preserve legitimate rare categories.

Do not collapse rare categories solely based on frequency.

Do not replace rare values with:

```text
OTHER
UNKNOWN
RARE
```

without explicit analytical justification.

### Reason

Low frequency does not establish that a value is invalid.

Rare categories may contain meaningful fraud-related signal.

### Target

```text
analytics.fact_transaction_clean
```

Applicable fields include:

```text
card4
card6
P_emaildomain
R_emaildomain
```

### Validation

Compare distinct-value distributions before and after transformation.

Any changed category must be explainable by a documented formatting transformation.

### Status

**APPROVED — STANDARDIZE / DO NOT BLINDLY COLLAPSE**

---

# DQ-012 — Fraud Class Imbalance

### Issue

The fraud target is imbalanced:

```text
isFraud = 0 → 569,877
isFraud = 1 → 20,663
```

### Action

Preserve the original:

```text
isFraud
```

distribution.

No oversampling, undersampling, SMOTE, weighting, or other class rebalancing is performed in Phase 6.

### Reason

`isFraud` is the source target and must remain unchanged in the analytical cleaning layer.

Class balancing belongs to later modeling/training workflows, not source-aligned cleaning.

### Target

```text
analytics.fact_transaction_clean.isFraud
```

### Validation

Verify:

```text
isFraud = 0 → 569,877
isFraud = 1 → 20,663
```

### Status

**APPROVED — PRESERVE**

---

# DQ-013 — Duplicate Keys

### Issue

Phase 5 validation established that transaction and identity keys are unique.

### Action

No deduplication is performed.

### Reason

Removing rows without evidence of duplicate business records could alter the transaction or identity population.

Phase 5 already established:

```text
TransactionID duplicates = 0
identity_key duplicates = 0
```

### Target

```text
analytics.fact_transaction_clean
analytics.dim_identity_clean
```

### Validation

Verify after Phase 6:

```text
COUNT(*) = COUNT(DISTINCT TransactionID)
```

and:

```text
COUNT(*) = COUNT(DISTINCT identity_key)
```

for the applicable tables.

### Status

**APPROVED — NO DEDUPLICATION**

---

# 4. Explicitly Prohibited Transformations

The following transformations are outside the Phase 6 boundary:

```text
Blanket NULL imputation
Deletion of sparse columns
Deletion of high-value transactions
Outlier removal without a documented business rule
Winsorization of TransactionAmt
Fraud-label modification
Fraud-class rebalancing
Synthetic fraud scoring
ML-based imputation
Fabricated calendar dates
Unsupported semantic renaming
Blind rare-category collapsing
Transaction deduplication
Identity deduplication
```

---

# 5. Phase 6 Invariants

The following values must remain unchanged unless a documented exception is explicitly approved.

```text
Fact transactions              590,540
Identity records               144,233

Identity-linked transactions   144,233
Identity-unlinked transactions 446,307

isFraud = 0                    569,877
isFraud = 1                    20,663

TransactionID duplicates       0
identity_key duplicates        0
transaction_key duplicates     0

TransactionAmt SUM             79,738,948.735
TransactionAmt AVG             135.0271763724726521
```

The source transaction grain remains:

```text
1 row = 1 transaction
```

The source identity grain remains:

```text
1 row = 1 available identity record
```

---

# 6. Transformation Lineage

The Phase 6 lineage is:

```text
Phase 3 profiling finding
        ↓
Phase 6 cleaning decision
        ↓
SQL transformation
        ↓
Clean analytical field
        ↓
Validation
        ↓
Documented result
```

Every transformation introduced during Phase 6 must have:

```text
Source column
Original behavior
Transformation
Target column
Reason
NULL policy
Validation rule
Result
```

---

# 7. Phase 6 Boundary

## Included

```text
Cleaning
Standardization
Controlled normalization
NULL preservation
Selected missingness indicators
Relative time derivation
Deterministic analytical signals
Transformation lineage
Validation
Reconciliation
```

## Excluded

```text
Machine learning
Fraud prediction
Fraud score optimization
Advanced fraud investigation
KPI development
Indexes
Query optimization
Materialized views
Performance tuning
```

---

# 8. Approval Criteria

Phase 6 may proceed only if:

```text
Phase 5 baseline = PASS
Staging tables remain unchanged
Transformations are deterministic
NULL semantics are preserved
Original source fields remain authoritative
No unsupported business meaning is introduced
Every transformation has a validation rule
```

Phase 6 completion requires successful validation of:

```text
Population
Grain
Keys
Identity coverage
Fraud distribution
Transaction amount reconciliation
NULL preservation
Transformation logic
Phase 3 issue disposition
```

---

# 9. Current Status

```text
Phase 5 baseline: PASS
Phase 6 cleaning policy: DEFINED
Phase 6 transformations: NOT YET EXECUTED
Phase 6 validation: NOT YET EXECUTED
```
