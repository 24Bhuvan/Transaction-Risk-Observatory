# Phase 9 View Catalog

All Phase 9 objects are normal views. No materialized views were created.

| View | Grain | Source | Purpose | Materialized |
|---|---|---|---|---|
| `vw_transaction_analytics` | One transaction | Clean fact plus identity | Reusable semantic transaction layer | No |
| `vw_daily_fraud_summary` | One transaction day number | Transaction view | Daily fraud reporting | No |
| `vw_weekly_fraud_summary` | One transaction week number | Transaction view | Weekly fraud reporting | No |
| `vw_fraud_comparison` | One fraud status | Transaction view | Fraud/non-fraud distribution | No |
| `vw_identity_risk` | One identity key | Transaction view | Identity-level descriptive summary | No |
| `vw_device_risk` | DeviceType plus DeviceInfo | Transaction view | Device-attribute analysis | No |
| `vw_card_risk` | card4 plus card6 | Transaction view | Card-attribute analysis | No |
| `vw_geographic_attribute_risk` | addr/dist attribute tuple | Transaction view | Address-related attribute analysis | No |
| `vw_risk_signal_summary` | One deterministic signal | Transaction view | Signal/fraud relationship summary | No |
| `vw_transaction_risk_signals` | One transaction | Transaction view | Deterministic signal fields and count | No |
