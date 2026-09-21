# Source-to-Target Mapping — Phase 4

**Project:** Transaction Risk Observatory
**Lifecycle Phase:** Phase 4 — Schema & Relational Modeling
**Purpose:** Define the destination of every staging field in the analytical schema.

## Mapping Rules

* Every staging field is explicitly mapped to an analytical target.
* Source field names are preserved unless a documented transformation is required.
* Phase 4 performs schema mapping only; no cleaning, imputation, feature engineering, or semantic reinterpretation is performed.
* All 435 source fields are accounted for.
* `TransactionID` is retained as the source/natural identifier.
* Surrogate keys (`transaction_key`, `identity_key`) are analytical keys and do not replace source identifiers.
* `dim_date`, `dim_product`, `dim_card`, `dim_address`, `dim_email`, and `dim_device` are not physically implemented at this stage.

## Source Coverage

| Source Table               | Source Fields | Target Table                 |
| -------------------------- | ------------: | ---------------------------- |
| `staging.raw_transactions` |           394 | `analytics.fact_transaction` |
| `staging.raw_identity`     |            41 | `analytics.dim_identity`     |
| **Total**                  |       **435** |                              |

## Transaction Field Mapping

|  # | Source                                    | Target                       | Target Column    | Transformation |
| -: | ----------------------------------------- | ---------------------------- | ---------------- | -------------- |
|  1 | `staging.raw_transactions.TransactionID`  | `analytics.fact_transaction` | `TransactionID`  | None           |
|  2 | `staging.raw_transactions.isFraud`        | `analytics.fact_transaction` | `isFraud`        | None           |
|  3 | `staging.raw_transactions.TransactionDT`  | `analytics.fact_transaction` | `TransactionDT`  | None           |
|  4 | `staging.raw_transactions.TransactionAmt` | `analytics.fact_transaction` | `TransactionAmt` | None           |
|  5 | `staging.raw_transactions.ProductCD`      | `analytics.fact_transaction` | `ProductCD`      | None           |
|  6 | `staging.raw_transactions.card1`          | `analytics.fact_transaction` | `card1`          | None           |
|  7 | `staging.raw_transactions.card2`          | `analytics.fact_transaction` | `card2`          | None           |
|  8 | `staging.raw_transactions.card3`          | `analytics.fact_transaction` | `card3`          | None           |
|  9 | `staging.raw_transactions.card4`          | `analytics.fact_transaction` | `card4`          | None           |
| 10 | `staging.raw_transactions.card5`          | `analytics.fact_transaction` | `card5`          | None           |
| 11 | `staging.raw_transactions.card6`          | `analytics.fact_transaction` | `card6`          | None           |
| 12 | `staging.raw_transactions.addr1`          | `analytics.fact_transaction` | `addr1`          | None           |
| 13 | `staging.raw_transactions.addr2`          | `analytics.fact_transaction` | `addr2`          | None           |
| 14 | `staging.raw_transactions.dist1`          | `analytics.fact_transaction` | `dist1`          | None           |
| 15 | `staging.raw_transactions.dist2`          | `analytics.fact_transaction` | `dist2`          | None           |
| 16 | `staging.raw_transactions.P_emaildomain`  | `analytics.fact_transaction` | `P_emaildomain`  | None           |
| 17 | `staging.raw_transactions.R_emaildomain`  | `analytics.fact_transaction` | `R_emaildomain`  | None           |

### C Fields

|  # | Source                         | Target                       | Target Column | Transformation |
| -: | ------------------------------ | ---------------------------- | ------------- | -------------- |
| 18 | `staging.raw_transactions.C1`  | `analytics.fact_transaction` | `C1`          | None           |
| 19 | `staging.raw_transactions.C2`  | `analytics.fact_transaction` | `C2`          | None           |
| 20 | `staging.raw_transactions.C3`  | `analytics.fact_transaction` | `C3`          | None           |
| 21 | `staging.raw_transactions.C4`  | `analytics.fact_transaction` | `C4`          | None           |
| 22 | `staging.raw_transactions.C5`  | `analytics.fact_transaction` | `C5`          | None           |
| 23 | `staging.raw_transactions.C6`  | `analytics.fact_transaction` | `C6`          | None           |
| 24 | `staging.raw_transactions.C7`  | `analytics.fact_transaction` | `C7`          | None           |
| 25 | `staging.raw_transactions.C8`  | `analytics.fact_transaction` | `C8`          | None           |
| 26 | `staging.raw_transactions.C9`  | `analytics.fact_transaction` | `C9`          | None           |
| 27 | `staging.raw_transactions.C10` | `analytics.fact_transaction` | `C10`         | None           |
| 28 | `staging.raw_transactions.C11` | `analytics.fact_transaction` | `C11`         | None           |
| 29 | `staging.raw_transactions.C12` | `analytics.fact_transaction` | `C12`         | None           |
| 30 | `staging.raw_transactions.C13` | `analytics.fact_transaction` | `C13`         | None           |
| 31 | `staging.raw_transactions.C14` | `analytics.fact_transaction` | `C14`         | None           |

### D Fields

|  # | Source                         | Target                       | Target Column | Transformation |
| -: | ------------------------------ | ---------------------------- | ------------- | -------------- |
| 32 | `staging.raw_transactions.D1`  | `analytics.fact_transaction` | `D1`          | None           |
| 33 | `staging.raw_transactions.D2`  | `analytics.fact_transaction` | `D2`          | None           |
| 34 | `staging.raw_transactions.D3`  | `analytics.fact_transaction` | `D3`          | None           |
| 35 | `staging.raw_transactions.D4`  | `analytics.fact_transaction` | `D4`          | None           |
| 36 | `staging.raw_transactions.D5`  | `analytics.fact_transaction` | `D5`          | None           |
| 37 | `staging.raw_transactions.D6`  | `analytics.fact_transaction` | `D6`          | None           |
| 38 | `staging.raw_transactions.D7`  | `analytics.fact_transaction` | `D7`          | None           |
| 39 | `staging.raw_transactions.D8`  | `analytics.fact_transaction` | `D8`          | None           |
| 40 | `staging.raw_transactions.D9`  | `analytics.fact_transaction` | `D9`          | None           |
| 41 | `staging.raw_transactions.D10` | `analytics.fact_transaction` | `D10`         | None           |
| 42 | `staging.raw_transactions.D11` | `analytics.fact_transaction` | `D11`         | None           |
| 43 | `staging.raw_transactions.D12` | `analytics.fact_transaction` | `D12`         | None           |
| 44 | `staging.raw_transactions.D13` | `analytics.fact_transaction` | `D13`         | None           |
| 45 | `staging.raw_transactions.D14` | `analytics.fact_transaction` | `D14`         | None           |
| 46 | `staging.raw_transactions.D15` | `analytics.fact_transaction` | `D15`         | None           |

### M Fields

|  # | Source                        | Target                       | Target Column | Transformation |
| -: | ----------------------------- | ---------------------------- | ------------- | -------------- |
| 47 | `staging.raw_transactions.M1` | `analytics.fact_transaction` | `M1`          | None           |
| 48 | `staging.raw_transactions.M2` | `analytics.fact_transaction` | `M2`          | None           |
| 49 | `staging.raw_transactions.M3` | `analytics.fact_transaction` | `M3`          | None           |
| 50 | `staging.raw_transactions.M4` | `analytics.fact_transaction` | `M4`          | None           |
| 51 | `staging.raw_transactions.M5` | `analytics.fact_transaction` | `M5`          | None           |
| 52 | `staging.raw_transactions.M6` | `analytics.fact_transaction` | `M6`          | None           |
| 53 | `staging.raw_transactions.M7` | `analytics.fact_transaction` | `M7`          | None           |
| 54 | `staging.raw_transactions.M8` | `analytics.fact_transaction` | `M8`          | None           |
| 55 | `staging.raw_transactions.M9` | `analytics.fact_transaction` | `M9`          | None           |

### V Fields

|      # | Source                                                        | Target                       | Target Column | Transformation |
| -----: | ------------------------------------------------------------- | ---------------------------- | ------------- | -------------- |
| 56–394 | `staging.raw_transactions.V1`–`staging.raw_transactions.V339` | `analytics.fact_transaction` | `V1`–`V339`   | None           |

## Identity Field Mapping

|  # | Source                               | Target                   | Target Column   | Transformation |
| -: | ------------------------------------ | ------------------------ | --------------- | -------------- |
|  1 | `staging.raw_identity.TransactionID` | `analytics.dim_identity` | `TransactionID` | None           |
|  2 | `staging.raw_identity.id_01`         | `analytics.dim_identity` | `id_01`         | None           |
|  3 | `staging.raw_identity.id_02`         | `analytics.dim_identity` | `id_02`         | None           |
|  4 | `staging.raw_identity.id_03`         | `analytics.dim_identity` | `id_03`         | None           |
|  5 | `staging.raw_identity.id_04`         | `analytics.dim_identity` | `id_04`         | None           |
|  6 | `staging.raw_identity.id_05`         | `analytics.dim_identity` | `id_05`         | None           |
|  7 | `staging.raw_identity.id_06`         | `analytics.dim_identity` | `id_06`         | None           |
|  8 | `staging.raw_identity.id_07`         | `analytics.dim_identity` | `id_07`         | None           |
|  9 | `staging.raw_identity.id_08`         | `analytics.dim_identity` | `id_08`         | None           |
| 10 | `staging.raw_identity.id_09`         | `analytics.dim_identity` | `id_09`         | None           |
| 11 | `staging.raw_identity.id_10`         | `analytics.dim_identity` | `id_10`         | None           |
| 12 | `staging.raw_identity.id_11`         | `analytics.dim_identity` | `id_11`         | None           |
| 13 | `staging.raw_identity.id_12`         | `analytics.dim_identity` | `id_12`         | None           |
| 14 | `staging.raw_identity.id_13`         | `analytics.dim_identity` | `id_13`         | None           |
| 15 | `staging.raw_identity.id_14`         | `analytics.dim_identity` | `id_14`         | None           |
| 16 | `staging.raw_identity.id_15`         | `analytics.dim_identity` | `id_15`         | None           |
| 17 | `staging.raw_identity.id_16`         | `analytics.dim_identity` | `id_16`         | None           |
| 18 | `staging.raw_identity.id_17`         | `analytics.dim_identity` | `id_17`         | None           |
| 19 | `staging.raw_identity.id_18`         | `analytics.dim_identity` | `id_18`         | None           |
| 20 | `staging.raw_identity.id_19`         | `analytics.dim_identity` | `id_19`         | None           |
| 21 | `staging.raw_identity.id_20`         | `analytics.dim_identity` | `id_20`         | None           |
| 22 | `staging.raw_identity.id_21`         | `analytics.dim_identity` | `id_21`         | None           |
| 23 | `staging.raw_identity.id_22`         | `analytics.dim_identity` | `id_22`         | None           |
| 24 | `staging.raw_identity.id_23`         | `analytics.dim_identity` | `id_23`         | None           |
| 25 | `staging.raw_identity.id_24`         | `analytics.dim_identity` | `id_24`         | None           |
| 26 | `staging.raw_identity.id_25`         | `analytics.dim_identity` | `id_25`         | None           |
| 27 | `staging.raw_identity.id_26`         | `analytics.dim_identity` | `id_26`         | None           |
| 28 | `staging.raw_identity.id_27`         | `analytics.dim_identity` | `id_27`         | None           |
| 29 | `staging.raw_identity.id_28`         | `analytics.dim_identity` | `id_28`         | None           |
| 30 | `staging.raw_identity.id_29`         | `analytics.dim_identity` | `id_29`         | None           |
| 31 | `staging.raw_identity.id_30`         | `analytics.dim_identity` | `id_30`         | None           |
| 32 | `staging.raw_identity.id_31`         | `analytics.dim_identity` | `id_31`         | None           |
| 33 | `staging.raw_identity.id_32`         | `analytics.dim_identity` | `id_32`         | None           |
| 34 | `staging.raw_identity.id_33`         | `analytics.dim_identity` | `id_33`         | None           |
| 35 | `staging.raw_identity.id_34`         | `analytics.dim_identity` | `id_34`         | None           |
| 36 | `staging.raw_identity.id_35`         | `analytics.dim_identity` | `id_35`         | None           |
| 37 | `staging.raw_identity.id_36`         | `analytics.dim_identity` | `id_36`         | None           |
| 38 | `staging.raw_identity.id_37`         | `analytics.dim_identity` | `id_37`         | None           |
| 39 | `staging.raw_identity.id_38`         | `analytics.dim_identity` | `id_38`         | None           |
| 40 | `staging.raw_identity.DeviceType`    | `analytics.dim_identity` | `DeviceType`    | None           |
| 41 | `staging.raw_identity.DeviceInfo`    | `analytics.dim_identity` | `DeviceInfo`    | None           |

## Surrogate Keys

| Target Table                 | Target Column     | Source | Transformation                     |
| ---------------------------- | ----------------- | ------ | ---------------------------------- |
| `analytics.fact_transaction` | `transaction_key` | None   | PostgreSQL-generated surrogate key |
| `analytics.dim_identity`     | `identity_key`    | None   | PostgreSQL-generated surrogate key |

These surrogate keys are analytical identifiers and are not source fields. They do not replace `TransactionID`.

## Field Accountability

* Transaction fields mapped: **394**
* Identity fields mapped: **41**
* Total source fields mapped: **435**
* Unmapped source fields: **0**
* Phase 4 transformations: **None**

## Deferred Targets

The following potential dimensions are intentionally not physical targets in the current Phase 4 model:

* `dim_date` — deferred until `TransactionDT` is properly interpreted.
* `dim_product` — not justified by the current entity assessment; `ProductCD` remains in `fact_transaction`.
* `dim_card` — not justified; `card1`–`card6` remain in `fact_transaction`.
* `dim_address` — not justified; `addr1`, `addr2`, `dist1`, and `dist2` remain in `fact_transaction`.
* `dim_email` — not justified; `P_emaildomain` and `R_emaildomain` remain in `fact_transaction`.
* `dim_device` — not justified; `DeviceType` and `DeviceInfo` remain in `dim_identity`.

## Validation Requirement

The mapping is complete only when every staging column appears exactly once in this document and has a defined analytical target.

**Status: COMPLETE**
