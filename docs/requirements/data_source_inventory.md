# Data Source Inventory

## 1. Dataset Identification

**Dataset:** IEEE-CIS Fraud Detection

**Source:** Kaggle / IEEE-CIS Fraud Detection

**Local Source Directory:** `data/raw/`

**Inventory Generated:** 2026-09-18

---

## 2. Analytical Scope

The initial analytical pipeline will use the training datasets:

* `train_transaction.csv`
* `train_identity.csv`

`train_transaction.csv` is the primary analytical transaction dataset because it contains the `isFraud` target variable.

The following files are present locally but are excluded from the initial analytical pipeline:

* `test_transaction.csv`
* `test_identity.csv`
* `sample_submission.csv`

The test datasets will only be incorporated if a later analytical or validation requirement specifically justifies their use.

`sample_submission.csv` is treated as a submission template rather than an analytical source.

---

## 3. Source Location

### Original Source

Kaggle / IEEE-CIS Fraud Detection

### Local Repository Location

```text
data/raw/
```

### Observed Local Structure

```text
data/raw/
├── sample_submission.csv
├── test_identity.csv
├── test_transaction.csv
├── train_identity.csv
└── train_transaction.csv
```

All five CSV files are located directly under `data/raw/`.

---

## 4. File Inventory

| File                    | Purpose                   | Analytical Status  | Rows    | Columns | Size      | Encoding | Delimiter | Header |
| ----------------------- | ------------------------- | ------------------ | ------- | ------- | --------- | -------- | --------- | ------ |
| `train_transaction.csv` | Transaction data          | Included           | 590,540 | 394     | 651.69 MB | UTF-8    | `,`       | Yes    |
| `train_identity.csv`    | Identity/device data      | Included           | 144,233 | 41      | 25.30 MB  | UTF-8    | `,`       | Yes    |
| `test_transaction.csv`  | Test transaction data     | Excluded initially | 506,691 | 393     | 584.79 MB | UTF-8    | `,`       | Yes    |
| `test_identity.csv`     | Test identity/device data | Excluded initially | 141,907 | 41      | 24.60 MB  | UTF-8    | `,`       | Yes    |
| `sample_submission.csv` | Submission template       | Excluded           | 506,691 | 2       | 5.80 MB   | UTF-8    | `,`       | Yes    |

---

## 5. Primary Analytical Files

### 5.1 `train_transaction.csv`

**Purpose:** Transaction-level analytical data.

**Local Path:**

```text
data/raw/train_transaction.csv
```

**Observed Metadata:**

* Rows: 590,540
* Columns: 394
* Size: 651.69 MB
* Encoding: UTF-8
* Delimiter: Comma
* Header: Present

**Analytical Role:**

Primary transaction-level source and source of the `isFraud` target variable.

---

### 5.2 `train_identity.csv`

**Purpose:** Identity and device-related transaction attributes.

**Local Path:**

```text
data/raw/train_identity.csv
```

**Observed Metadata:**

* Rows: 144,233
* Columns: 41
* Size: 25.30 MB
* Encoding: UTF-8
* Delimiter: Comma
* Header: Present

**Analytical Role:**

Supporting identity/device source to be associated with the transaction-level data during subsequent modeling and ETL stages.

The exact join key, match rate, and join coverage will be established during profiling and modeling rather than assumed at inventory stage.

---

## 6. Secondary and Excluded Files

### `test_transaction.csv`

**Purpose:** Test transaction data.

**Status:** Excluded from the initial analytical pipeline.

**Observed Metadata:**

* Rows: 506,691
* Columns: 393
* Size: 584.79 MB

The file is preserved locally but will not be loaded into the initial analytical workflow.

---

### `test_identity.csv`

**Purpose:** Test identity/device data.

**Status:** Excluded from the initial analytical pipeline.

**Observed Metadata:**

* Rows: 141,907
* Columns: 41
* Size: 24.60 MB

The file is preserved locally but will not be loaded into the initial analytical workflow.

---

### `sample_submission.csv`

**Purpose:** Submission template.

**Status:** Excluded from analytical processing.

**Observed Metadata:**

* Rows: 506,691
* Columns: 2
* Size: 5.80 MB

The presence of an `isFraud` column in this file does not make it an analytical target source. It is treated as a submission-template field.

---

## 7. Target Variable

**Target Variable:** `isFraud`

**Analytical Source:** `train_transaction.csv`

The `isFraud` field was detected in the header of `train_transaction.csv`.

`sample_submission.csv` also contains an `isFraud` field, but this file is a submission template and is not treated as a source of observed fraud labels.

The target distribution and class balance will be calculated during subsequent profiling.

---

## 8. Source File Relationship

The initial analytical data consists of two complementary training sources:

```text
train_transaction.csv
        │
        │ transaction identifier
        ▼
train_identity.csv
```

`train_transaction.csv` provides transaction-level attributes and the fraud target.

`train_identity.csv` provides identity/device-related attributes associated with transaction records.

The following will be verified during subsequent Phase 2 work:

* Join key
* Key uniqueness
* Matching records
* Unmatched transaction records
* Join coverage
* Duplicate keys
* Relationship cardinality

No join assumptions are treated as validated at the inventory stage.

---

## 9. Initial Source Integrity Checks

The local source directory was inspected recursively.

### Results

* CSV files discovered: **5**
* Empty CSV files detected: **None**
* Unexpected/unclassified CSV files: **None**
* Primary training transaction file: **Present**
* Primary training identity file: **Present**
* Test transaction file: **Present**
* Test identity file: **Present**
* Submission template: **Present**

All five discovered CSV files are accounted for in this inventory.

---

## 10. Data Preservation and Version-Control Policy

Raw source files are preserved in:

```text
data/raw/
```

Raw datasets are not intended to be committed to Git because of their size and source-data status.

The repository `.gitignore` contains raw-data exclusion patterns covering:

```text
data/raw
data/raw/
data/raw/*
```

Raw files therefore remain local source assets rather than version-controlled project artifacts.

---

## 11. Ingestion Information

**Inventory Generation Date:** 2026-09-18

The actual date on which the dataset was originally downloaded or acquired is not inferred from the filesystem modification timestamp.

If the original acquisition date is known independently, it can be recorded separately.

The inventory generation date represents the date on which the local source files were programmatically inspected.

---

## 12. Analytical Inclusion and Exclusion Decision

### Included

```text
train_transaction.csv
train_identity.csv
```

These files form the initial analytical dataset because the training transaction data contains the observed `isFraud` target.

### Excluded Initially

```text
test_transaction.csv
test_identity.csv
sample_submission.csv
```

The test datasets are not loaded simply because they are available. They will only be incorporated if a later project requirement explicitly calls for them.

The submission template is not an analytical dataset and remains excluded from the analytical pipeline.

---

## 13. Metadata Verification Method

The metadata in this inventory was obtained directly from the local source files.

### Row Counts

Row counts were calculated programmatically by reading the CSV records from the local files.

### Column Counts

Column counts were determined from the actual CSV headers.

### File Sizes

File sizes were obtained directly from the local filesystem.

### Encoding

The files were inspected for UTF-8 compatibility.

### Delimiter

The CSV delimiter was detected from the local file contents.

### Header

Header presence was verified from the first CSV record.

No row counts, column counts, or file sizes were manually copied from external dataset documentation.

---

## 14. Limitations of This Inventory

This inventory establishes the characteristics and scope of the source files. It does not constitute detailed data profiling.

The following analyses are intentionally deferred to subsequent Phase 2 steps:

* Column-level data types
* Missing-value analysis
* Null percentages
* Unique-value analysis
* Duplicate analysis
* Distribution analysis
* Target/class balance
* Outlier analysis
* Referential integrity
* Join coverage
* Data-quality assessment
* Transaction and identity schema profiling

These analyses will be performed directly against the local source data.

---

## 15. Notes

The raw IEEE-CIS files have been preserved without modification.

The initial analytical scope is intentionally limited to the training transaction and identity datasets.

The inventory is based on the actual files present in the project repository rather than assumed dataset dimensions from external documentation.
