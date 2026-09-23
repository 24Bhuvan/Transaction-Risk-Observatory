# Phase 9 — Analytical Views & Materialized Reports

## 1. Objective

Phase 9 creates a reusable semantic layer over the existing Phase 6 clean analytical tables without modifying those tables, adding cleaning logic, inventing entities, geographic meanings, fraud probabilities, or machine-learning scores.

## 2. Source Tables

- `analytics.fact_transaction_clean`: one row per transaction.
- `analytics.dim_identity_clean`: one row per available identity record.
- Verified live baseline: 590,540 transactions, 144,233 identity rows, 20,663 fraud, 569,877 non-fraud, and amount sum 79,738,948.735.

## 3. Baseline Results

The baseline SQL returned PASS for counts, uniqueness, orphan-link integrity, and transaction amount sum.

## 4. View Architecture

`vw_transaction_analytics` is the one-row-per-transaction semantic layer. Temporal, fraud-comparison, identity, device, card, address-related, and deterministic signal views depend on it.

## 5. Transaction Analytical View

`vw_transaction_analytics` preserves 590,540 rows and 590,540 distinct `TransactionID` values. It exposes verified transaction fields, identity/device attributes, selected `id_*` attributes, address-related attributes, card attributes, and Phase 6 derived fields.

## 6. Temporal Summary Views

Daily grouping uses `transaction_day_number`; weekly grouping uses `transaction_week_number`. No calendar dates were invented from `TransactionDT`. Daily and weekly totals reconcile to the base transaction layer.

## 7. Fraud Comparison

`vw_fraud_comparison` has exactly two statuses, 0 and 1, with count and amount statistics including PostgreSQL median calculation.

## 8. Identity/Device/Card Views

Identity summaries use `identity_key`, not customer or cardholder terminology. Device summaries use `DeviceType` and `DeviceInfo` as attributes, not canonical physical-device claims. Card summaries use `card4` and `card6` only.

## 9. Address/Geographic Attribute View

`addr1`, `addr2`, `dist1`, and `dist2` are retained as anonymized address-related attributes. No latitude, longitude, city, country, state, or geographic heatmap meaning is asserted.

## 10. Risk Signal Views

The signal summary and transaction signal views expose deterministic Phase 6 signals. `risk_signal_count` is a count of triggered deterministic signals, not a probability, machine-learning score, or causal fraud score.

## 11. Materialized View Assessment

No materialized views were created. Current evidence does not demonstrate repeated expensive aggregation or a refresh-cost benefit sufficient to justify materialization.

## 12. Materialized Views Implemented

None.

## 13. Grain Validation

The validation SQL checks transaction, daily, weekly, fraud-status, identity, device, card, address-related, signal-summary, and transaction-signal grains.

## 14. Reconciliation Results

Daily and weekly transaction counts, fraud counts, non-fraud counts, and amount totals reconcile to the transaction analytical view. The transaction signal view preserves transaction count and distinct IDs.

## 15. Refresh Validation

Not applicable: no materialized views exist and no refresh operation was required.

## 16. Exceptions / Deviations

The actual `isFraud` type is `SMALLINT`, and the Phase 6 clean identity relationship is nullable on the fact side; the views adapt to those actual definitions. No geographic or customer/entity semantics were invented.

## 17. Phase 9 Conclusion

Phase 9 is complete when `16_phase_09_final_gate.sql` returns PASS. All objects are normal views over the validated clean layer, with no Phase 6 table modifications.
