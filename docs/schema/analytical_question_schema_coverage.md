# Analytical Question Schema Coverage — Phase 4

## 1. Purpose

This document maps the analytical questions defined during Phase 3 to the Phase 4 relational model.

The objective is to confirm that the proposed schema contains the source fields required to support the analytical questions without inventing business meanings for anonymized source fields.

---

## 2. Analytical Model

### Fact table

`analytics.fact_transaction`

**Grain:** one row per source transaction identified by `TransactionID`.

### Dimension table

`analytics.dim_identity`

**Grain:** one row per available identity record associated with a transaction.

### Relationship

```text
fact_transaction
    |
    | identity_key (nullable FK)
    v
dim_identity
```

Cardinality:

```text
Transaction → Identity = 1 : 0..1
```

Identity information is therefore optional for a transaction.

---

## 3. Analytical Question Coverage

| AQ | Analytical Question | Required Schema Fields / Sources | Coverage |
|---|---|---|---|
| AQ01 | What is the overall transaction fraud rate? | `fact_transaction.TransactionID`, `fact_transaction.isFraud` | Covered |
| AQ02 | How does fraud vary over transaction time? | `fact_transaction.TransactionDT`, `fact_transaction.isFraud` | Covered |
| AQ03 | How does fraud vary by product category? | `fact_transaction.ProductCD`, `fact_transaction.isFraud` | Covered |
| AQ04 | How does fraud vary by transaction amount? | `fact_transaction.TransactionAmt`, `fact_transaction.isFraud` | Covered |
| AQ05 | How does fraud vary across card-related attributes? | `fact_transaction.card1`–`card6`, `fact_transaction.isFraud` | Covered |
| AQ06 | How does fraud vary across address-related attributes? | `fact_transaction.addr1`, `addr2`, `dist1`, `dist2`, `isFraud` | Covered |
| AQ07 | How does fraud vary across email-domain attributes? | `fact_transaction.P_emaildomain`, `R_emaildomain`, `isFraud` | Covered |
| AQ08 | What transaction-level C-feature patterns are associated with fraud? | `fact_transaction.C1`–`C14`, `isFraud` | Covered |
| AQ09 | What transaction-level D-feature patterns are associated with fraud? | `fact_transaction.D1`–`D15`, `isFraud` | Covered |
| AQ10 | What transaction-level M-feature patterns are associated with fraud? | `fact_transaction.M1`–`M9`, `isFraud` | Covered |
| AQ11 | What transaction-level V-feature patterns are associated with fraud? | `fact_transaction.V1`–`V339`, `isFraud` | Covered |
| AQ12 | How does fraud vary by available identity attributes? | `dim_identity.id_01`–`id_38`, `DeviceType`, `DeviceInfo`, linked through `fact_transaction.identity_key` | Covered |
| AQ13 | What transaction/device patterns can be identified from available identity information? | `dim_identity.DeviceType`, `DeviceInfo`, identity `id_*` fields, linked to `fact_transaction` | Covered |
| AQ14 | What transaction-level combinations or rule conditions identify elevated fraud risk? | Transaction fields in `fact_transaction` plus available identity fields in `dim_identity` | Covered |
| AQ15 | Which transactions/files should be prioritized for further fraud investigation? | `TransactionID`, `isFraud`, transaction feature families, optional identity information | Covered |

---

## 4. Field-Family Coverage

The Phase 4 model preserves the complete source field inventory.

### Transaction source

The 394 fields from `staging.raw_transactions` are represented in:

`analytics.fact_transaction`

This includes:

- `TransactionID`
- `isFraud`
- `TransactionDT`
- `TransactionAmt`
- `ProductCD`
- `card1`–`card6`
- `addr1`, `addr2`
- `dist1`, `dist2`
- `P_emaildomain`
- `R_emaildomain`
- `C1`–`C14`
- `D1`–`D15`
- `M1`–`M9`
- `V1`–`V339`

### Identity source

The 41 fields from `staging.raw_identity` are represented in:

`analytics.dim_identity`

This includes:

- `TransactionID`
- `id_01`–`id_38`
- `DeviceType`
- `DeviceInfo`

### Source-field accountability

```text
Total source fields      = 435
Transaction fields       = 394
Identity fields          = 41
Unmapped source fields   = 0
```

The Phase 4 field-coverage validation therefore passes:

```text
435 / 435 source fields mapped
```

---

## 5. Conditions and Boundaries

### Transaction time

`TransactionDT` is retained as the source-relative numeric transaction-time field.

A calendar/date dimension is intentionally deferred until the interpretation and transformation of `TransactionDT` are formally established.

Therefore, Phase 4 does not invent calendar dates.

### Identity availability

Identity information is sparse relative to the transaction population.

The Phase 3 relationship is:

```text
Transaction → Identity = 1 : 0..1
```

Therefore:

- `fact_transaction.identity_key` is nullable.
- Missing identity information is preserved as missing.
- Transactions without identity records remain valid fact records.

### NULL handling

Phase 4 preserves source NULLs.

No source-derived field is replaced with:

```text
0
UNKNOWN
N/A
-1
```

Imputation and analytical treatment of missing values are deferred to later analytical phases.

### Anonymized fields

Fields such as `C*`, `D*`, `M*`, `V*`, and `id_*` retain their source names.

No unsupported business meaning is assigned to these fields.

---

## 6. Analytical Layer Boundary

The Phase 4 schema provides the relational foundation for the analytical questions.

Phase 4 does not yet perform:

- fraud modeling
- predictive modeling
- feature selection
- threshold optimization
- risk scoring
- rule tuning
- imputation
- aggregation tables
- performance optimization

Those activities belong to later phases.

---

## 7. Coverage Conclusion

All analytical questions AQ01–AQ15 have a corresponding set of fields available in the Phase 4 relational model.

The model therefore provides the required structural coverage for the Phase 3 analytical question set.

```text
Analytical questions assessed = 15
Questions with schema coverage = 15
Uncovered questions             = 0
Status                          = PASS
```

---

## 8. Phase 4 Status

**Step 4.14 — COMPLETE**

The analytical-question-to-schema coverage gate is satisfied.
