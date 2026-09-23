# Phase 7 — Data Quality Validation & Reconciliation

## 1. Execution

Phase 7 was executed read-only with PostgreSQL 18.4/psql against database `transaction_risk_observatory` on 2026-09-23. The ordered SQL sequence covered Steps 7.1 through 7.22 using the scripts under `sql/07_quality`. No Phase 5, Phase 6, staging, or analytical data was modified.

## 2. Baseline Results

| Metric | Actual result | Status |
|---|---:|---|
| Fact rows | 590,540 | PASS |
| Distinct fact `TransactionID` | 590,540 | PASS |
| Fact `TransactionID` duplicates | 0 | PASS |
| Fact `transaction_key` duplicates | 0 | PASS |
| Identity rows | 144,233 | PASS |
| Distinct identity `TransactionID` | 144,233 | PASS |
| Identity `TransactionID` duplicates | 0 | PASS |
| Identity key duplicates | 0 | PASS |
| Linked transactions | 144,233 | PASS |
| Unlinked transactions | 446,307 | PASS |
| `isFraud = 0` | 569,877 | PASS |
| `isFraud = 1` | 20,663 | PASS |
| `SUM(TransactionAmt)` | 79,738,948.735 | PASS |
| `AVG(TransactionAmt)` | 135.0271763724726521 | PASS |

## 3. Validation Results

| Category | Actual result |
|---|---|
| Structure | 28 PASS; 4 contract findings: `dim_identity_clean.email_domain_missing_flag`, `fact_transaction_clean.D7_missing_flag`, and `fact_transaction_clean.R_emaildomain_missing_flag` are absent; `isFraud` is `SMALLINT` rather than expected `INTEGER`. |
| Fact grain | 7 PASS; no NULL or duplicate transaction keys/IDs. |
| Identity grain | 7 PASS; no NULL or duplicate identity keys/IDs. |
| Referential integrity | 2 PASS; zero orphan links and zero orphan identity records. |
| Identity relationship | 6 PASS; one-to-zero-or-one relationship preserved; linked plus unlinked equals 590,540. |
| NULL semantics | 16 PASS; zero unexpected blank or whitespace-only values. |
| Missingness flags | 16 PASS; all domains and source-value logic reconcile. |
| Card missingness | 5 PASS; distributions: 579,507 with zero missing cards, 9,468 with one-to-three, and 1,565 with four. |
| Time features | 4 PASS; zero day, hour, week, or range mismatches. |
| Transaction amount | 11 PASS; 590,540 non-null values, minimum 0.251, maximum 31,937.391, zero negative values, zero zero-amounts, and zero feature-logic mismatches. |
| Categorical fields | 9 PASS; zero whitespace or blank-value violations. |
| Email fields | 2 PASS; P/R email-domain transformations reconcile. |
| Device fields | 4 PASS; DeviceType, DeviceInfo, normalization, and missingness logic reconcile. |
| Risk signals | 5 PASS; all signal logic and domains reconcile. |
| Phase 5 to Phase 6 reconciliation | 10 PASS; populations, key sets, unchanged fields, fraud counts, amounts, and identity relationship reconcile. |
| Staging to analytics reconciliation | 6 PASS; transaction and identity populations, ID coverage, fraud, and amount totals reconcile. |
| Business rules | 7 PASS; fraud and signal domains, non-negative amounts, valid hours, card ranges, and non-negative missing-attribute counts pass. |
| Unified QA framework | 8 PASS. |

## 4. Final Gate

The mandatory final gate in `sql/07_quality/20_phase_07_final_gate.sql` returned exactly:

```text
PASS
```

The gate confirms the mandatory population, key, identity-link, fraud-domain, amount, time, and card-range checks. The four structure findings above are non-mandatory metadata contract findings and did not block the final gate.

## 5. Exception Status

There are no unresolved data-quality exceptions in the validated data, transformations, reconciliations, or business rules. The four metadata contract findings are recorded as schema-alignment observations; no data was changed to resolve them.

**Final Phase 7 status: PASS.**
