# Phase 11 KPI Specification

## Analytical Contract

The KPI layer uses `analytics.vw_risk_scoring` as its authoritative transaction-grain Phase 10 source and `analytics.vw_transaction_analytics` for temporal and observable attributes. All measures are descriptive historical statistics against `isFraud`; they are not causal estimates and do not represent real-world customer or cardholder entities.

| KPI | Business question | Definition and formula | Numerator / denominator | Grain | Source | Validation |
| --- | --- | --- | --- | --- | --- | --- |
| Total transactions | What is the population? | `COUNT(*)` | N/A | Population | `vw_risk_scoring` | 590,540 |
| Fraud transactions | What is the observed fraud count? | `COUNT(*) FILTER (WHERE isFraud=1)` | N/A | Population | `vw_risk_scoring` | 20,663 |
| Fraud rate | What is the overall fraud level? | Fraud transactions / total transactions | Fraud rows / all rows | Population | `kpi_fraud_summary` | Reconciles to baseline |
| Fraud amount share | How much value is associated with fraud? | Fraud amount / total amount | Fraud amount / all amount | Population | `kpi_amount_summary` | Amount reconciliation |
| Average fraud amount premium | Are observed fraud amounts higher on average? | Avg fraud amount - avg non-fraud amount | Difference | Population | `kpi_amount_summary` | Derived from source rows |
| Temporal fraud rate | When does observed fraud incidence vary? | Fraud rows / period rows | Period fraud / period total | Day, week, hour | `kpi_daily_fraud`, `kpi_weekly_fraud`, `kpi_hourly_fraud` | Each partition totals population |
| Segment fraud rate | Which observable segments have elevated observed rates? | Segment fraud / segment transactions | Segment fraud / segment total | Observable segment | `kpi_segmentation_summary` | Product and identity partitions reconcile |
| Fraud capture rate | Which existing signal is associated with known fraud? | Flagged fraud / all fraud | Fraudulent flagged / total fraud | Signal | `kpi_signal_performance` | Six actual Phase 10 signals |
| Flag rate | How broadly does a signal flag transactions? | Flagged rows / all rows | Flagged / total | Signal | `kpi_signal_performance` | Six actual Phase 10 signals |
| Score-band fraud rate | How does incidence vary by score? | Fraud rows / score-band rows | Fraud / band total | Existing risk score and band | `kpi_risk_score_summary` | Score partition reconciles |
| Risk cohort fraud rate | How do existing signal-derived cohorts differ? | Cohort fraud / cohort rows | Fraud / cohort total | Existing cohort | `kpi_risk_cohorts` | Risk-band partition reconciles |
| Fraud count share | Is fraud concentrated? | Dimension-value fraud / dimension fraud | Value fraud / dimension fraud | Ranked dimension value | `kpi_fraud_concentration` | Shares sum to 1 per dimension |
| Fraud amount share by dimension | Where is fraud value concentrated? | Value fraud amount / dimension fraud amount | Value fraud amount / dimension fraud amount | Ranked dimension value | `kpi_fraud_concentration` | Shares sum to 1 per dimension |

Fraud rate is a **row-based incidence measure**. Fraud amount share is a **value-based exposure measure**. They answer different questions and must not be substituted for one another.