# Transaction Risk Observatory — Data Dictionary

## 1. Document Information

| Attribute | Value |
|---|---|
| Project | Transaction Risk Observatory |
| Phase | Phase 3 — Data Profiling & Quality Assessment |
| Step | Step 3.13 — Build the Data Dictionary |
| Database Schema | `staging` |
| Source Tables | `staging.raw_transactions`, `staging.raw_identity` |
| Total Columns | 435 |
| Transaction Columns | 394 |
| Identity Columns | 41 |
| Purpose | Document the structure, completeness, cardinality, and profiling characteristics of the staging-layer data |

---

## 2. Scope

This data dictionary documents all columns currently present in the staging layer.

The dictionary records:

- Table name
- Column name
- PostgreSQL data type
- Business/technical description where supported
- NULL percentage
- Distinct value count
- Profiling notes

The dictionary is based on the actual PostgreSQL staging schema and the profiling results produced during Phase 3.

Anonymized IEEE-CIS transaction and identity variables are not assigned invented business meanings. Their original field names are retained and their profiling characteristics are documented.

---

## 3. Source Tables

### 3.1 `staging.raw_transactions`

The transaction staging table contains:

- Transaction identifiers
- Fraud target
- Transaction time
- Transaction amount
- Product information
- Card attributes
- Address attributes
- Email domains
- Categorical M-fields
- Anonymized C-fields, D-fields, and V-fields

Total columns: **394**

### 3.2 `staging.raw_identity`

The identity staging table contains:

- Transaction identifier
- Anonymized identity attributes (`id_01`–`id_38`)
- Device type
- Device information

Total columns: **41**

The identity table contains 144,233 records and represents the subset of transactions for which identity information is available.

---

## 4. Data Type Summary

### `staging.raw_transactions`

| PostgreSQL Data Type | Column Count |
|---|---:|
| BIGINT | 3 |
| DOUBLE PRECISION | 375 |
| NUMERIC | 1 |
| SMALLINT | 1 |
| TEXT | 14 |
| **Total** | **394** |

### `staging.raw_identity`

| PostgreSQL Data Type | Column Count |
|---|---:|
| BIGINT | 1 |
| DOUBLE PRECISION | 23 |
| TEXT | 17 |
| **Total** | **41** |

All 435 staging columns are currently nullable.

---

## 5. Column-Level Data Dictionary

The complete column-level dictionary was generated directly from PostgreSQL metadata and Phase 3 profiling results.

### 5.1 `staging.raw_transactions`

| Column | Data Type | Description |
|---|---|---|
| TransactionID | BIGINT | Unique identifier for the transaction. |
| isFraud | SMALLINT | Fraud target indicator for the transaction. |
| TransactionDT | BIGINT | Time value associated with the transaction, retained in its original source representation. |
| TransactionAmt | NUMERIC | Transaction amount. |
| ProductCD | TEXT | Product category/code associated with the transaction. |
| card1 | BIGINT | Anonymized primary card-related identifier. |
| card2 | DOUBLE PRECISION | Anonymized secondary card attribute. |
| card3 | DOUBLE PRECISION | Anonymized card attribute. |
| card4 | TEXT | Card payment network/type. |
| card5 | DOUBLE PRECISION | Anonymized card attribute. |
| card6 | TEXT | Card type/category. |
| addr1 | DOUBLE PRECISION | Anonymized billing/address attribute. |
| addr2 | DOUBLE PRECISION | Anonymized address attribute. |
| dist1 | DOUBLE PRECISION | Anonymized distance-related transaction attribute. |
| dist2 | DOUBLE PRECISION | Anonymized distance-related transaction attribute. |
| P_emaildomain | TEXT | Purchaser email domain. |
| R_emaildomain | TEXT | Recipient email domain. |
| C1–C14 | DOUBLE PRECISION | Anonymized transaction-related C-series features. |
| D1–D15 | DOUBLE PRECISION | Anonymized transaction-related D-series features. |
| M1–M9 | TEXT | Anonymized categorical M-series features. |
| V1–V339 | DOUBLE PRECISION | Anonymized transaction-related V-series features. |

> Note: `C1–C14`, `D1–D15`, `M1–M9`, and `V1–V339` represent individual columns in the database. The grouped notation above summarizes their common feature families; the generated profiling output contains each individual column separately.

### 5.2 `staging.raw_identity`

| Column | Data Type | Description |
|---|---|---|
| TransactionID | BIGINT | Transaction identifier linking identity information to the transaction table. |
| id_01–id_38 | Varies | Anonymized identity-related features. |
| DeviceType | TEXT | Type of device used for the transaction. |
| DeviceInfo | TEXT | Additional device metadata. |

> Note: The anonymized `id_01–id_38` fields are documented individually in the generated dictionary with their actual PostgreSQL data types, NULL percentages, distinct counts, and profiling notes.

---

## 6. Completeness Summary

NULL profiling was performed across all 435 columns.

### `staging.raw_identity`

- Total columns: **41**
- Columns with 0% NULL: **3**
- Columns with more than 50% NULL: **12**
- Columns with more than 90% NULL: **9**
- Columns with 100% NULL: **0**

Most incomplete identity attributes include:

- `id_24`
- `id_25`
- `id_07`
- `id_08`
- `id_21`
- `id_22`
- `id_23`
- `id_26`
- `id_27`

`DeviceInfo` has:

- Total records: 144,233
- NULL records: 118,666
- Non-NULL records: 25,567
- Non-NULL percentage: 17.73%

### `staging.raw_transactions`

- Total columns: **394**
- Columns with 0% NULL: **52**
- Columns with more than 50% NULL: **174**
- Columns with more than 90% NULL: **2**
- Columns with 100% NULL: **0**

The most incomplete transaction attributes include:

- `dist2`
- `D7`
- `D12`
- `D13`
- `D14`
- `D6`
- `D8`
- `D9`
- Several V-series fields
- `R_emaildomain`

Critical transaction fields such as:

- `TransactionID`
- `isFraud`
- `TransactionDT`
- `TransactionAmt`

are fully populated.

---

## 7. Cardinality and Categorical Profiling

Categorical/text profiling identified:

- `raw_transactions`: **14** TEXT columns
- `raw_identity`: **17** TEXT columns
- Total categorical/text columns: **31**

Categorical profiling examined:

- Distinct values
- Frequency
- Percentage distribution
- NULL frequency

Examples include:

- `ProductCD`
- `card4`
- `card6`
- `P_emaildomain`
- `R_emaildomain`
- `DeviceType`
- `DeviceInfo`
- Anonymized M-series fields

### DeviceInfo

`DeviceInfo` contains a large number of distinct values and substantial missingness.

Among non-NULL values, common values include:

- Windows
- iOS Device
- MacOS
- Trident/7.0
- rv:11.0
- rv:57.0

The field is heterogeneous and contains operating-system, browser-engine/version, and device-model/build-like values.

No cleaning, grouping, or standardization is performed at the raw profiling stage.

---

## 8. Transaction–Identity Relationship

The relationship between the two staging tables was profiled.

| Metric | Value |
|---|---:|
| Total transactions | 590,540 |
| Identity records | 144,233 |
| Distinct identity TransactionIDs | 144,233 |
| Transactions with identity | 144,233 |
| Transactions without identity | 446,307 |
| Identity coverage | 24.42% |
| Identity records without matching transaction | 0 |
| Duplicate identity TransactionIDs | 0 |

The observed relationship is:

```text
staging.raw_transactions
        1
        |
        | 0 or 1
        |
staging.raw_identity