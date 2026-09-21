# Schema & Relational Modeling — Phase 4 Baseline

**Project:** Transaction Risk Observatory
**Lifecycle Phase:** Phase 4 — Schema & Relational Modeling
**Baseline Source:** Phase 3 — Data Profiling, Quality Assessment & Staging Validation
**Status:** Frozen

---

## 1. Purpose

This document establishes the validated Phase 3 baseline that will be used as the starting point for Phase 4 — Schema & Relational Modeling.

The purpose of this baseline is to define exactly what Phase 4 may assume about the existing source and staging layers before the analytical PostgreSQL schema is designed.

Phase 4 will use the validated staging tables as source structures and will not modify their data or semantics.

---

## 2. Phase 3 Source Baseline

Phase 3 established two validated staging tables:

| Source Table               |    Rows | Columns | Source Identifier |
| -------------------------- | ------: | ------: | ----------------- |
| `staging.raw_transactions` | 590,540 |     394 | `TransactionID`   |
| `staging.raw_identity`     | 144,233 |      41 | `TransactionID`   |

The combined source structure contains:

```text
435 source fields
```

calculated as:

```text
394 transaction fields + 41 identity fields = 435 fields
```

---

## 3. Source Table: Transactions

### Table

```text
staging.raw_transactions
```

### Validated structure

```text
Rows:    590,540
Columns: 394
```

### Source identifier

```text
TransactionID
```

`TransactionID` represents the natural identifier of a transaction in the source dataset.

Phase 3 established that:

* `TransactionID` is not NULL.
* `TransactionID` is unique.
* Each source transaction therefore represents a distinct transaction-level record.

The transaction table contains the primary transaction, fraud-label, temporal, amount, card-related, address-related, email-related, and anonymized feature attributes required by the analytical requirements.

---

## 4. Source Table: Identity

### Table

```text
staging.raw_identity
```

### Validated structure

```text
Rows:    144,233
Columns: 41
```

### Source identifier

```text
TransactionID
```

Phase 3 established that:

* `TransactionID` is not NULL.
* `TransactionID` is unique within the identity table.
* Each identity record corresponds to at most one transaction.

The identity table contains identity- and device-related attributes associated with a subset of transactions.

---

## 5. Transaction–Identity Relationship

The validated relationship between the two source tables is:

```text
staging.raw_transactions
        1
        |
        | 0..1
        |
        ▼
staging.raw_identity
```

This means:

> One transaction can have zero or one corresponding identity record.

Identity data is therefore optional at the transaction level.

### Identity coverage

Phase 3 established that identity information is available for approximately:

```text
24.42% of transactions
```

Therefore, approximately:

```text
75.58% of transactions
```

do not have a corresponding identity record.

This relationship must be preserved in the analytical model.

The transaction population must not be reduced by requiring an identity record.

---

## 6. Analytical Grain

The primary analytical grain for the Phase 4 model is:

> **One row represents one transaction.**

The core analytical fact will therefore represent the transaction as the atomic analytical unit.

The planned core fact is:

```text
analytics.fact_transaction
```

with:

```text
1 fact_transaction row = 1 source transaction
```

The source identifier:

```text
TransactionID
```

will be retained in the analytical model.

A separate surrogate key may be introduced for the analytical fact, but it must not replace or remove the source identifier.

---

## 7. Key Findings Carried Forward from Phase 3

The following findings are considered validated inputs to Phase 4.

### 7.1 Transaction key

```text
staging.raw_transactions.TransactionID
```

is:

```text
NOT NULL
UNIQUE
```

### 7.2 Identity key

```text
staging.raw_identity.TransactionID
```

is:

```text
NOT NULL
UNIQUE
```

### 7.3 Relationship

```text
Transaction → Identity
1 : 0..1
```

### 7.4 Source field count

```text
394 transaction fields
41 identity fields
435 total source fields
```

### 7.5 Identity coverage

```text
24.42%
```

The analytical model must therefore support transactions without identity information.

---

## 8. Modeling Constraints

The following constraints apply to Phase 4.

### 8.1 Preserve the staging layer

The following tables are preserved source representations:

```text
staging.raw_transactions
staging.raw_identity
```

Phase 4 must not modify these tables.

Specifically, Phase 4 must not:

* delete source records
* rename source columns
* overwrite source values
* alter source semantics
* impute NULL values
* perform analytical transformations in staging

---

### 8.2 Preserve transaction-level grain

The core analytical fact must remain transaction-grained.

Phase 4 must not split the transaction population into separate fact tables based solely on attribute families such as:

```text
card
device
email
address
product
time
```

unless a separate analytical grain is explicitly justified later.

---

### 8.3 Preserve optional identity information

Identity must remain an optional related entity.

The model must preserve transactions that do not have identity records.

An inner join between transactions and identity must not be used to define the core transaction population.

---

### 8.4 Preserve source field semantics

The source contains anonymized feature families, including:

```text
C1–C14
D1–D15
M1–M9
V1–V339
id_01–id_38
```

These fields must not be assigned invented business meanings.

The analytical schema should preserve their source names unless a documented technical transformation is required.

---

### 8.5 Preserve NULL semantics

NULL values identified during Phase 3 remain part of the source semantics.

Phase 4 will define the schema required to accommodate those values but will not perform NULL treatment.

The following substitutions are therefore outside the scope of Phase 4:

```text
NULL → 0
NULL → -1
NULL → UNKNOWN
NULL → N/A
```

Any required NULL treatment will be addressed during the appropriate later ETL or data-cleaning phase.

---

## 9. Phase 4 Assumptions

Phase 4 proceeds under the following assumptions:

1. `staging.raw_transactions` contains 590,540 transaction records.
2. `staging.raw_transactions` contains 394 fields.
3. `staging.raw_identity` contains 144,233 identity records.
4. `staging.raw_identity` contains 41 fields.
5. `TransactionID` is NOT NULL in both staging tables.
6. `TransactionID` is unique in both staging tables.
7. The transaction-to-identity relationship is 1 : 0..1.
8. Identity coverage is approximately 24.42%.
9. The primary analytical grain is one transaction.
10. `TransactionID` will remain available as the source/natural identifier.
11. The staging layer will remain unchanged during Phase 4.
12. Source NULL semantics will be preserved during schema design.
13. Anonymized source fields will not be assigned unsupported business meanings.
14. All 435 source fields must be accounted for in the Phase 4 source-to-target mapping.
15. Phase 4 is limited to schema and relational modeling and does not perform data cleaning, feature engineering, fraud scoring, or performance optimization.

---

## 10. Phase 4 Modeling Boundary

### Included in Phase 4

```text
Analytical grain definition
Entity identification
Physical table design
Fact table design
Dimension evaluation
Primary-key strategy
Foreign-key strategy
Natural-key identification
Surrogate-key strategy
NULL policy
Anonymized-field policy
Source-to-target mapping
ERD design
PostgreSQL DDL
Relational constraints
Schema validation
Analytical-question coverage
```

### Deferred to later phases

```text
Data cleaning
NULL imputation
Feature engineering
Fraud scoring
Advanced analytical queries
Performance optimization
Index optimization
Partitioning
Query tuning
```

---

## 11. Phase 4 Baseline Acceptance Criteria

The Phase 3 baseline is accepted as the input to Phase 4 when the following conditions are established:

| Baseline Check                        | Expected Result |
| ------------------------------------- | --------------: |
| Transaction row count                 |         590,540 |
| Transaction column count              |             394 |
| Identity row count                    |         144,233 |
| Identity column count                 |              41 |
| Total source fields                   |             435 |
| TransactionID NOT NULL — transactions |            PASS |
| TransactionID unique — transactions   |            PASS |
| TransactionID NOT NULL — identity     |            PASS |
| TransactionID unique — identity       |            PASS |
| Transaction → Identity cardinality    |        1 : 0..1 |
| Identity coverage                     |          24.42% |
| Core analytical grain                 |   1 transaction |
| Staging modification during Phase 4   |   NOT PERMITTED |

---

## 12. Baseline Conclusion

Phase 3 provides a validated transaction-level source structure consisting of:

```text
staging.raw_transactions
590,540 rows × 394 columns

staging.raw_identity
144,233 rows × 41 columns
```

The validated source relationship is:

```text
raw_transactions
       1
       |
       | 0..1
       |
raw_identity
```

The transaction is therefore established as the atomic analytical unit for Phase 4.

Identity information will be modeled as optional transaction-related information because it is available for only 24.42% of the transaction population.

The staging layer remains the preserved source representation.

All 435 source fields must be explicitly accounted for during Phase 4 source-to-target mapping.

This baseline is frozen and will serve as the formal starting point for the remaining Schema & Relational Modeling work.

**Baseline Status: FROZEN**
