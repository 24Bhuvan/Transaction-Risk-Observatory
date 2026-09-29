# Phase 11 KPI Catalog

| KPI family | Finalized result object | Grain | Main measures |
| --- | --- | --- | --- |
| Core fraud | `analytics.kpi_fraud_summary` | Population | Counts, fraud rate, non-fraud rate |
| Amount / exposure | `analytics.kpi_amount_summary` | Population | Sums, averages, medians, min/max, fraud amount share, premium |
| Daily temporal | `analytics.kpi_daily_fraud` | Source-relative day number | Counts, rates, amounts, averages |
| Weekly temporal | `analytics.kpi_weekly_fraud` | Source-relative week number | Counts, rates, amounts |
| Hourly temporal | `analytics.kpi_hourly_fraud` | Transaction hour | Counts, rate, fraud amount |
| Segmentation | `analytics.kpi_segmentation_summary` | Observable dimension/value | Counts, rates, amounts, averages |
| Signal performance | `analytics.kpi_signal_performance` | Existing Phase 10 signal | Flag rate, flagged fraud, capture rate, flagged/unflagged rates |
| Risk score | `analytics.kpi_risk_score_statistics`, `analytics.kpi_risk_score_summary` | Existing score and Phase 10 band | Distribution and fraud metrics |
| Risk cohorts | `analytics.kpi_risk_cohorts` | Existing score/signal cohort | Counts, rate, fraud amount, average amount |
| Concentration | `analytics.kpi_fraud_concentration` | Dimension/value rank | Fraud count share, amount share, cumulative shares |
| Business questions | `analytics.kpi_business_questions` | Question evidence row | Measurable evidence for Q1-Q7 |

All sources are downstream of the validated Phase 9/10 views. No Phase 11 object creates or changes a fraud-detection rule.