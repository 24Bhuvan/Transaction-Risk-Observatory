# Schema Design — Phase 4

**Project:** Transaction Risk Observatory
**Lifecycle Phase:** Phase 4 — Schema & Relational Modeling
**Status:** Defined
**Baseline Source:** Phase 3 — Data Profiling, Quality Assessment & Staging Validation

---

## 1. Purpose

This document defines the analytical PostgreSQL schema downstream of the staging layer.

The schema is based on the evidence established during Phase 3 and is intentionally limited to entities justified by the source structure and analytical requirements.

Phase 4 does not perform:

* Data cleaning
* NULL imputation
* Feature engineering
* Fraud scoring
* Performance optimization
* Analytical query development

---

## 2. Source Schema

Phase 3 established the following staging tables:

```text
staging.raw_transactions
staging.raw_identity
```

Source structure:

| Source Table               |    Rows | Columns |
| -------------------------- | ------: | ------: |
| `staging.raw_transactions` | 590,540 |     394 |
| `staging.raw_identity`     | 144,233 |      41 |
| **Total**                  |       — | **435** |

The source relationship is:

```text
raw_transactions  1 ───────── 0..1  raw_identity
```

Identity coverage is **24.42%** of transactions.

---

## 3. Analytical Grain

### `analytics.fact_transaction`

The analytical grain is:

> **One row in `fact_transaction` represents exactly one source transaction identified by `TransactionID`.**

Expected population:

```text
590,540 transactions
```

The analytical fact must preserve the complete transaction population regardless of whether identity information exists.

Therefore:

```text
COUNT(fact_transaction)
=
COUNT(DISTINCT TransactionID)
=
590,540
```

is the expected baseline validation condition after ETL.

---

## 4. Physical Schema

The current Phase 4 physical schema is intentionally small:

```text
analytics
├── fact_transaction
└── dim_identity
```

`dim_date` has been evaluated but is deferred.

The following dimensions are not currently created:

```text
dim_product
dim_card
dim_address
dim_email
dim_device
```

---

## 5. Entity Relationship Diagram

```text
                         ┌───────────────────────┐
                         │       dim_date        │
                         │       DEFERRED        │
                         │                       │
                         │ date_key        PK    │
                         │ calendar_date         │
                         │ year                  │
                         │ quarter               │
                         │ month                 │
                         │ month_name            │
                         │ week                  │
                         │ day                   │
                         │ day_of_week           │
                         └───────────┬───────────┘
                                     │
                              Deferred FK
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────┐
│                    fact_transaction                          │
│                                                              │
│ transaction_key       PK                                    │
│ TransactionID          UQ / Source Identifier                │
│                                                              │
│ Grain: 1 row = 1 transaction                                 │
│                                                              │
│ isFraud                                                      │
│ TransactionDT                                                │
│ TransactionAmt                                                │
│ ProductCD                                                     │
│ card1–card6                                                   │
│ addr1, addr2, dist1, dist2                                   │
│ P_emaildomain, R_emaildomain                                 │
│ C1–C14                                                        │
│ D1–D15                                                        │
│ M1–M9                                                         │
│ V1–V339                                                       │
└──────────────────────────────┬───────────────────────────────┘
                               │
                          1    │    0..1
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                       dim_identity                            │
│                                                              │
│ identity_key          PK                                     │
│ TransactionID          UQ / Source Identifier                │
│                                                              │
│ Grain: 1 row = 1 available identity record                   │
│                                                              │
│ id_01–id_38                                                   │
│ DeviceType                                                    │
│ DeviceInfo                                                    │
└──────────────────────────────────────────────────────────────┘
```

Visual ERD:

```text
docs/schema/phase_04_erd.png
```

---

## 6. Primary Keys

### 6.1 `fact_transaction`

```text
transaction_key
```

Role:

* Surrogate analytical primary key
* PostgreSQL-generated
* Used for relational identification
* Does not replace `TransactionID`

Planned definition:

```sql
transaction_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

---

### 6.2 `dim_identity`

```text
identity_key
```

Role:

* Surrogate analytical primary key
* PostgreSQL-generated
* Does not replace the source `TransactionID`

Planned definition:

```sql
identity_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

---

### 6.3 `dim_date`

Planned primary key:

```text
date_key
```

However, `dim_date` is currently deferred.

---

## 7. Source / Natural Identifiers

### Transaction

```text
TransactionID
```

Rules:

```text
NOT NULL
UNIQUE
```

It must remain in `fact_transaction`.

The surrogate `transaction_key` must never replace or eliminate `TransactionID`.

---

### Identity

```text
TransactionID
```

Rules:

```text
NOT NULL
UNIQUE
```

It remains in `dim_identity` for source traceability and relationship validation.

---

### Product

```text
ProductCD
```

`ProductCD` remains directly in `fact_transaction`.

A `product_key` is not currently implemented because a separate product entity has not been justified.

---

## 8. Foreign-Key Relationships

### Transaction → Identity

The source relationship is:

```text
fact_transaction  1 ───────── 0..1  dim_identity
```

If the analytical fact uses the identity surrogate key:

```text
fact_transaction.identity_key
        │
        └──────────► dim_identity.identity_key
```

The FK must be nullable.

Reason:

Only **24.42%** of transactions have an identity record.

Approximately **75.58%** do not.

Therefore, identity information is optional from the transaction perspective.

The transaction population must not be reduced through an inner join to identity.

---

### Transaction → Date

Future relationship:

```text
fact_transaction.date_key
        │
        └──────────► dim_date.date_key
```

Status:

```text
DEFERRED
```

Reason:

`TransactionDT` is a source-relative numeric time representation and has not yet been mapped to a calendar reference date.

---

## 9. Cardinality

### Transaction → Identity

```text
1 : 0..1
```

Meaning:

* Every transaction exists independently.
* A transaction may have zero identity records.
* A transaction may have one identity record.
* An identity record corresponds to one transaction.

Phase 3 evidence:

```text
Transactions:       590,540
Identity records:   144,233
Identity coverage:   24.42%
```

Therefore, the relationship must not be modeled as mandatory `1 : 1`.

---

## 10. `fact_transaction` Field Groups

The transaction fact contains all **394 transaction source fields**.

### Core fields

```text
TransactionID
isFraud
TransactionDT
TransactionAmt
ProductCD
```

### Card-related attributes

```text
card1
card2
card3
card4
card5
card6
```

These are retained as anonymized source attributes.

No business meaning is invented.

---

### Address / Distance attributes

```text
addr1
addr2
dist1
dist2
```

These remain transaction attributes.

They are not interpreted as literal geographic entities.

---

### Email attributes

```text
P_emaildomain
R_emaildomain
```

These remain transaction-level attributes.

---

### C-family

```text
C1–C14
```

### D-family

```text
D1–D15
```

### M-family

```text
M1–M9
```

### V-family

```text
V1–V339
```

All anonymized source fields retain their original names.

---

## 11. `dim_identity` Field Groups

The identity dimension contains all **41 identity source fields**.

### Source identifier

```text
TransactionID
```

### Identity attributes

```text
id_01–id_38
```

### Device attributes

```text
DeviceType
DeviceInfo
```

`DeviceType` and `DeviceInfo` remain in `dim_identity`.

A separate `dim_device` is not created because the Phase 3 evidence does not establish a sufficiently reliable independent device entity.

---

## 12. Deferred `dim_date`

The intended date dimension is:

```text
dim_date
---------
date_key
calendar_date
year
quarter
month
month_name
week
day
day_of_week
```

However, `TransactionDT` is currently a source-relative numeric time representation.

Therefore:

* No calendar date is fabricated.
* No arbitrary reference date is introduced.
* No `date_key` is populated.
* No date FK is implemented.
* `TransactionDT` remains unchanged in `fact_transaction`.

The date dimension can be implemented after the source-time interpretation has been established.

---

## 13. Optional Dimensions Assessment

### `dim_product`

**Decision:** Do not create.

Reason:

`ProductCD` has only five observed values and no independent product master attributes have been established.

Therefore:

```text
ProductCD → fact_transaction
```

---

### `dim_card`

**Decision:** Do not create initially.

Reason:

`card1`–`card6` are anonymized source attributes and are not established as a complete canonical payment-card entity.

Therefore:

```text
card1–card6 → fact_transaction
```

---

### `dim_address`

**Decision:** Do not create.

Reason:

`addr1`, `addr2`, `dist1`, and `dist2` are anonymized attributes and cannot safely be interpreted as literal geographic entities.

Therefore:

```text
addr1
addr2
dist1
dist2
    ↓
fact_transaction
```

---

### `dim_email`

**Decision:** Do not create.

Reason:

`P_emaildomain` and `R_emaildomain` are transaction-level categorical attributes.

Therefore:

```text
P_emaildomain
R_emaildomain
    ↓
fact_transaction
```

---

### `dim_device`

**Decision:** Do not create initially.

Reason:

`DeviceType` and `DeviceInfo` originate from the identity source, and the available evidence does not establish a canonical independent device entity.

Therefore:

```text
DeviceType
DeviceInfo
    ↓
dim_identity
```

---

## 14. Surrogate-Key Strategy

The analytical model uses surrogate keys where physical entities require them.

| Entity      | Surrogate Key     | Source Identifier |
| ----------- | ----------------- | ----------------- |
| Transaction | `transaction_key` | `TransactionID`   |
| Identity    | `identity_key`    | `TransactionID`   |
| Date        | `date_key`        | `calendar_date`   |
| Product     | Not implemented   | `ProductCD`       |

Core rule:

> Never replace the source identifier with a surrogate key and then lose the source identifier.

Therefore:

```text
transaction_key
        +
TransactionID
```

and:

```text
identity_key
        +
TransactionID
```

are intentionally maintained together.

---

## 15. Source-to-Target Accountability

Phase 3 established:

```text
394 transaction fields
41 identity fields
-------------------
435 total fields
```

Current mapping:

| Source                     |  Fields | Target                       |
| -------------------------- | ------: | ---------------------------- |
| `staging.raw_transactions` |     394 | `analytics.fact_transaction` |
| `staging.raw_identity`     |      41 | `analytics.dim_identity`     |
| **Total**                  | **435** |                              |

Mapping status:

```text
Mapped fields:       435
Unmapped fields:       0
```

The complete field-level mapping is documented in:

```text
docs/schema/source_to_target_mapping.md
```

---

## 16. Analytical Modeling Principles

The Phase 4 schema follows these principles:

1. Preserve the complete transaction population.
2. Preserve `TransactionID`.
3. Use surrogate keys for physical analytical entities.
4. Never discard source identifiers.
5. Preserve source field names where semantics are unknown.
6. Do not invent business meanings for anonymized fields.
7. Do not create dimensions solely because a column family exists.
8. Keep optional identity information separate from the transaction grain.
9. Do not fabricate calendar dates from `TransactionDT`.
10. Keep raw staging tables unchanged.
11. Map every source field to an analytical destination.
12. Keep Phase 4 limited to schema and relational modeling.

---

## 17. Phase 4 Schema Summary

### Current physical tables

```text
analytics.fact_transaction
analytics.dim_identity
```

### Deferred

```text
dim_date
```

### Not currently created

```text
dim_product
dim_card
dim_address
dim_email
dim_device
```

### Source-field accountability

```text
Total source fields:   435
Mapped fields:         435
Unmapped fields:         0
```

### Analytical grain

```text
fact_transaction
= 1 row per source transaction
```

### Primary relationship

```text
fact_transaction
       1
       │
       │
      0..1
       ▼
dim_identity
```

**Status: Phase 4 schema design defined.**
