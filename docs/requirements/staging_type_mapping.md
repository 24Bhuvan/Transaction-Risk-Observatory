# Staging Type Mapping

## Purpose

This document defines the PostgreSQL storage types for the IEEE-CIS source files during the staging layer.

The staging layer prioritizes source fidelity and safe ingestion over analytical normalization.

Source columns are retained using their original names. Analytical renaming, normalization, feature engineering, and business-specific type refinement are deferred to later pipeline phases.

## train_transaction.csv

| Source Column | PostgreSQL Type | Reason |
|---|---|---|
| TransactionID | BIGINT | Integer transaction identifier |
| isFraud | SMALLINT | Binary source label (0/1) |
| TransactionDT | BIGINT | Source-relative transaction time |
| TransactionAmt | NUMERIC | Decimal transaction amount |
| ProductCD | TEXT | Categorical source value |
| card1 | BIGINT | Integer-valued source field |
| card2 | DOUBLE PRECISION | Source contains missing values and is read as float64 |
| card3 | DOUBLE PRECISION | Source numeric field with missing values |
| card4 | TEXT | Categorical source value |
| card5 | DOUBLE PRECISION | Source numeric field with missing values |
| card6 | TEXT | Categorical source value |
| addr1 | DOUBLE PRECISION | Numeric source field with missing values |
| addr2 | DOUBLE PRECISION | Numeric source field with missing values |
| dist1 | DOUBLE PRECISION | Numeric source field with missing values |
| dist2 | DOUBLE PRECISION | Numeric source field with missing values |
| P_emaildomain | TEXT | Categorical/text source value |
| R_emaildomain | TEXT | Categorical/text source value |
| C1-C14 | DOUBLE PRECISION | Numeric source feature family |
| D1-D15 | DOUBLE PRECISION | Numeric source feature family |
| M1-M9 | TEXT | Categorical source feature family |
| V1-V339 | DOUBLE PRECISION | Numeric source feature family |

## train_identity.csv

| Source Column | PostgreSQL Type | Reason |
|---|---|---|
| TransactionID | BIGINT | Integer transaction identifier |
| id_01-id_11 | DOUBLE PRECISION | Numeric source fields with missing values |
| id_12 | TEXT | Categorical source value |
| id_13-id_14 | DOUBLE PRECISION | Numeric source fields with missing values |
| id_15 | TEXT | Categorical source value |
| id_16 | TEXT | Categorical source value |
| id_17-id_22 | DOUBLE PRECISION | Numeric source fields with missing values |
| id_23 | TEXT | Categorical source value |
| id_24-id_26 | DOUBLE PRECISION | Numeric source fields with missing values |
| id_27 | TEXT | Categorical source value |
| id_28 | TEXT | Categorical source value |
| id_29 | TEXT | Categorical source value |
| id_30 | TEXT | Operating-system/device text |
| id_31 | TEXT | Browser/device text |
| id_32 | DOUBLE PRECISION | Numeric source field |
| id_33 | TEXT | Screen-resolution text |
| id_34 | TEXT | Categorical source value |
| id_35 | TEXT | Categorical source value |
| id_36 | TEXT | Categorical source value |
| id_37 | TEXT | Categorical source value |
| id_38 | TEXT | Categorical source value |
| DeviceType | TEXT | Categorical source value |
| DeviceInfo | TEXT | Free-form device description |

## Type Selection Rules

1. Preserve original source column names.
2. Preserve NULL values as NULL.
3. Do not rename columns during staging.
4. Do not normalize categorical values during staging.
5. Do not derive timestamps from TransactionDT during staging.
6. Do not create analytical surrogate keys during staging.
7. Use TEXT where source values are textual or categorical.
8. Use numeric PostgreSQL types for source numeric fields.
9. Defer analytical type refinement to later phases.
10. If future source inspection identifies values incompatible with the assigned type, the affected staging column should be reconsidered before ingestion.

## Validation Basis

The mapping was determined from the actual source files using full-file pandas dtype inspection.

Source dimensions verified:

- train_transaction.csv: 590,540 rows × 394 columns
- train_identity.csv: 144,233 rows × 41 columns

Observed source dtype groups:

- Integer: identifiers and binary target
- Float: numeric source features
- String: categorical and descriptive fields

## Phase 2 Principle

Source fidelity > analytical elegance.