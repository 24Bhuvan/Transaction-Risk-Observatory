# Phase 2 — Ingestion Validation Report

## 1. Source Files

Primary analytical source files:

- `data/raw/train_transaction.csv`
- `data/raw/train_identity.csv`

These files were loaded into the PostgreSQL `staging` schema without transformation.

Target field:

- `isFraud` in `train_transaction.csv`

---

## 2. Source Row Counts

| Dataset | Source Rows |
|---|---:|
| Transactions | 590,540 |
| Identity | 144,233 |

Source row counts were established during Phase 2 source inventory and verified against the actual CSV files.

---

## 3. PostgreSQL Row Counts

| Staging Table | PostgreSQL Rows |
|---|---:|
| `staging.raw_transactions` | 590,540 |
| `staging.raw_identity` | 144,233 |

Counts were verified after bulk loading using PostgreSQL `COUNT(*)`.

---

## 4. Row Count Reconciliation

| Dataset | Source Rows | PostgreSQL Rows | Difference | Status |
|---|---:|---:|---:|---|
| Transactions | 590,540 | 590,540 | 0 | PASS |
| Identity | 144,233 | 144,233 | 0 | PASS |

No row-count discrepancies were identified.

---

## 5. Column Reconciliation

| Dataset | Source Columns | PostgreSQL Columns | Difference | Status |
|---|---:|---:|---:|---|
| Transactions | 394 | 394 | 0 | PASS |
| Identity | 41 | 41 | 0 | PASS |

The staging structures were verified against the source headers for column count, source naming, and ordinal position.

No undocumented column additions, removals, or renaming were identified.

---

## 6. Key Validation

### Transactions

`TransactionID` was validated in `staging.raw_transactions`.

Results:

- Total rows: 590,540
- Non-null `TransactionID`: 590,540
- Distinct `TransactionID`: 590,540

Result:

**PASS — `TransactionID` is unique and non-null in the transaction staging table.**

### Identity

`TransactionID` was validated in `staging.raw_identity`.

Results:

- Total rows: 144,233
- Non-null `TransactionID`: 144,233
- Distinct `TransactionID`: 144,233

Result:

**PASS — `TransactionID` is unique and non-null in the identity staging table.**

---

## 7. NULL / Load Checks

Critical-key NULL checks were performed after ingestion.

| Staging Table | Total Rows | NULL `TransactionID` | Status |
|---|---:|---:|---|
| `staging.raw_transactions` | 590,540 | 0 | PASS |
| `staging.raw_identity` | 144,233 | 0 | PASS |

These checks validate ingestion of the critical transaction identifier only.

Full column-level NULL profiling is deferred to the later profiling and data-quality phases.

---

## 8. Sample Validation

Representative source records were compared with the corresponding PostgreSQL staging records.

### Transaction sample

Transaction IDs:

- 2987000
- 2987001
- 2987002
- 2987003
- 2987004

The staging records were inspected for:

- Header alignment
- Column ordering
- Values
- NULL representation
- Numeric loading
- Text/categorical values

Result:

**PASS**

### Identity sample

Transaction IDs:

- 2987004
- 2987008
- 2987010
- 2987011
- 2987016

The staging records were inspected for:

- Header alignment
- Column ordering
- Values
- NULL representation
- Numeric loading
- Identity attributes

Result:

**PASS**

---

## 9. Ingestion Errors

The bulk load was executed using PostgreSQL `\copy`.

Load results:

```text
COPY 590540
COPY 144233