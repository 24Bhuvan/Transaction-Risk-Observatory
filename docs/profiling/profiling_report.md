# Transaction Risk Observatory — Phase 3 Profiling Report

## 1. Executive Summary

Phase 3 — Data Profiling & Quality Assessment was performed on the PostgreSQL staging layer containing the IEEE-CIS transaction and identity data.

The investigation covered:

- Dataset structure and schema metadata
- Data types
- NULL/completeness patterns
- Cardinality and categorical distributions
- Duplicate and key integrity checks
- Numeric distributions
- Transaction–identity relationships
- Fraud-label distribution
- Temporal characteristics
- Anomaly-oriented checks
- Cross-column structural relationships
- Data-quality issue classification

The staging layer contains:

- **590,540 transaction records**
- **144,233 identity records**
- **394 transaction columns**
- **41 identity columns**
- **435 total columns**

The profiling established that the core transaction structure is internally consistent. No duplicate transaction identifiers, duplicate identity identifiers, orphan identity records, or staging data-type mismatches were identified.

The major data-quality characteristics are concentrated around missingness, partial identity coverage, high-cardinality fields, low-frequency categories, the source representation of transaction time, and fraud-class imbalance.

These findings form the baseline for Phase 4 and later data-cleaning, transformation, schema, and fraud-analytics decisions.

---

# 2. Dataset Overview

## 2.1 Source Tables

| Table | Rows | Columns |
|---|---:|---:|
| `staging.raw_transactions` | 590,540 | 394 |
| `staging.raw_identity` | 144,233 | 41 |
| **Total** | — | **435** |

The two staging tables originate from the transaction and identity portions of the IEEE-CIS Fraud Detection dataset.

---

## 2.2 Transaction Dataset

`staging.raw_transactions` contains:

- Transaction identifiers
- Fraud labels
- Transaction time
- Transaction amount
- Product information
- Card attributes
- Address attributes
- Email domains
- C-series features
- D-series features
- M-series features
- V-series features

Total columns: **394**

---

## 2.3 Identity Dataset

`staging.raw_identity` contains:

- Transaction identifier
- `id_01`–`id_38`
- `DeviceType`
- `DeviceInfo`

Total columns: **41**

Identity information is available only for a subset of transactions.

---

# 3. Structural Profile

## 3.1 Data Type Distribution

### `staging.raw_transactions`

| Data Type | Count |
|---|---:|
| BIGINT | 3 |
| DOUBLE PRECISION | 375 |
| NUMERIC | 1 |
| SMALLINT | 1 |
| TEXT | 14 |
| **Total** | **394** |

### `staging.raw_identity`

| Data Type | Count |
|---|---:|
| BIGINT | 1 |
| DOUBLE PRECISION | 23 |
| TEXT | 17 |
| **Total** | **41** |

All 435 columns are currently nullable in the staging schema.

---

## 3.2 Schema Validation

The actual PostgreSQL staging types were compared against the Phase 2 staging type mapping.

Result:

| Validation | Result |
|---|---:|
| Expected columns | 435 |
| Actual columns | 435 |
| Type matches | 435 |
| Type mismatches | 0 |
| Missing columns | 0 |

The staging schema therefore matches the established Phase 2 type mapping.

No schema correction was required during profiling.

---

# 4. Completeness Profile

NULL profiling was performed across all 435 columns.

## 4.1 `raw_identity`

| Metric | Result |
|---|---:|
| Columns | 41 |
| Columns with 0% NULL | 3 |
| Columns >50% NULL | 12 |
| Columns >90% NULL | 9 |
| Columns 100% NULL | 0 |

Several anonymized identity attributes contain substantial missingness.

The most incomplete fields include:

- `id_24`
- `id_25`
- `id_07`
- `id_08`
- `id_21`
- `id_22`
- `id_23`
- `id_26`
- `id_27`

`DeviceInfo`:

| Metric | Value |
|---|---:|
| Total records | 144,233 |
| NULL | 118,666 |
| Non-NULL | 25,567 |
| Non-NULL % | 17.73% |

---

## 4.2 `raw_transactions`

| Metric | Result |
|---|---:|
| Columns | 394 |
| Columns with 0% NULL | 52 |
| Columns >50% NULL | 174 |
| Columns >90% NULL | 2 |
| Columns 100% NULL | 0 |

Important high-missingness fields include:

- `dist2`
- `D7`
- `D12`
- `D13`
- `D14`
- `D6`
- `D8`
- `D9`
- multiple V-series fields
- `R_emaildomain`

Critical transaction fields including:

- `TransactionID`
- `isFraud`
- `TransactionDT`
- `TransactionAmt`

contain no NULL values.

---

## 4.3 Interpretation

High missingness is not automatically classified as a data defect.

The observed NULL patterns may represent:

- unavailable source information,
- attributes applicable only to subsets of records,
- source-system collection behavior,
- or analytically useful missingness.

Treatment must therefore be determined during downstream data cleaning and transformation based on analytical requirements.

---

# 5. Cardinality Profile

Categorical/text profiling identified:

| Table | TEXT Columns |
|---|---:|
| `raw_transactions` | 14 |
| `raw_identity` | 17 |
| **Total** | **31** |

Profiling considered:

- Distinct values
- Value frequency
- Distribution percentages
- NULL frequency

The categorical fields include product, card, email, device, and anonymized M-series attributes.

---

## 5.1 DeviceInfo Cardinality

`DeviceInfo` contains:

- 25,567 non-NULL records
- 1,786 distinct values
- 17.73% non-NULL coverage

Observed values include operating-system, browser-engine/version, device-model, and build-like strings.

The field is therefore both sparse and high-cardinality.

No grouping or standardization was performed during raw profiling.

---

# 6. Duplicate Analysis

Duplicate and key-integrity checks were performed on the transaction and identity identifiers.

| Check | Result |
|---|---:|
| Duplicate transaction `TransactionID` | 0 |
| Duplicate identity `TransactionID` | 0 |
| Orphan identity records | 0 |

The transaction identifier is unique within the transaction table.

The identity identifier is also unique within the identity table.

All identity records have a corresponding transaction record.

---

# 7. Numeric Distributions

Numeric profiling examined transaction amount and other numerical characteristics.

## 7.1 Transaction Amount

Observed transaction amount range:

| Metric | Value |
|---|---:|
| Minimum | 0 |
| Maximum | 31,937.391 |

No non-positive transaction amounts were identified as an immediate structural violation during the anomaly checks.

Extreme values were retained for later analytical assessment rather than automatically removed.

The profiling stage does not establish a business threshold above which a transaction amount should be classified as invalid.

---

## 7.2 Anonymized Numeric Features

The C-series, D-series, and V-series numerical attributes exhibit varying levels of completeness and cardinality.

These fields remain in their raw staging representation.

No arbitrary transformations, outlier removals, or imputations were performed during Phase 3.

---

# 8. Categorical Distributions

## 8.1 ProductCD

| ProductCD | Count |
|---|---:|
| W | 439,670 |
| C | 68,519 |
| R | 37,699 |
| H | 33,024 |
| S | 11,628 |

---

## 8.2 card4

| card4 | Count |
|---|---:|
| visa | 384,767 |
| mastercard | 189,217 |
| american express | 8,328 |
| discover | 6,651 |

---

## 8.3 card6

| card6 | Count |
|---|---:|
| debit | 439,938 |
| credit | 148,986 |
| debit or credit | 30 |
| charge card | 15 |

Rare categories are documented as observed source values. Their presence alone does not establish that they are invalid.

---

# 9. Transaction–Identity Relationship

The transaction–identity relationship was profiled using identifier overlap and uniqueness checks.

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