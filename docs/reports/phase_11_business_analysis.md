# Phase 11 — KPI Development & Business Analysis

## 1. Objective

Convert validated Phase 9 analytical views and Phase 10 risk-analysis outputs into reproducible business KPIs and descriptive evidence.

## 2. Analytical Population

The population is 590,540 unique transaction rows from `analytics.vw_risk_scoring`. It contains 20,663 rows labeled fraud and 569,877 rows labeled non-fraud. `TransactionDT` remains source-relative; this report uses day number, week number, and hour rather than fabricated calendar dates.

## 3. Core Fraud KPIs

The observed fraud rate is 20,663 / 590,540 = 3.4990009%. The observed non-fraud rate is 96.5009991%.

## 4. Financial Exposure

Total transaction amount is 79,738,948.735. Fraud-labeled transaction amount is 3,083,844.860, giving a fraud amount share of 3.8674260%. The average fraud-labeled transaction amount is 149.2447786 compared with 134.5116646 for non-fraud-labeled rows; the average premium is 14.7331140.

## 5. Temporal Fraud Trends

Daily, weekly, and hourly views are sourced from existing relative-time fields. Their partitions reconcile to the full transaction and fraud populations. The highest-rate periods are available from `analytics.kpi_daily_fraud`, `analytics.kpi_weekly_fraud`, and `analytics.kpi_hourly_fraud` without assigning calendar dates.

## 6. Fraud Segmentation

Product, card attributes, device attributes, email domains, and identity availability are evaluated as observable attributes. Segment rates describe the observed label distribution within each segment; they are not customer-level measures and do not establish causation.

## 7. Risk-Signal Performance

The six measured signals are the five Phase 10 component flags plus the existing `multiple_signal_flag`: velocity, amount anomaly, entity/device anomaly, off-hours, impossible travel, and multiple signal. The geographic signal is retained as implemented; Phase 10 documents that its impossible-travel flag is always zero because coordinates are unavailable.

## 8. Risk-Score Analysis

The existing additive heuristic score ranges from 0 to 7, with average 1.2744302 and median 1. The Phase 10 `LOW`, `MEDIUM`, and `HIGH` bands are used as defined; no new score bands are imposed.

## 9. Risk Cohorts

Cohorts use existing Phase 10 dimensions: risk band, signal count, velocity flag, and multiple-signal flag. They are descriptive partitions of the transaction population.

## 10. Fraud Concentration

Fraud count share, fraud amount share, and cumulative shares are ranked independently within product, device type, card attributes, identity availability, transaction hour, and source-relative transaction day.

## 11. Business Question Answers

The executable evidence for Q1-Q7 is in `analytics.kpi_business_questions`. Q1 and Q2 are answered by the population counts and amount shares above. Q3-Q7 are answered by ranked temporal, segmentation, signal, score, and concentration outputs.

## 12. Key Observations

**Observed facts:** The baseline totals and amount reconcile exactly. Fraud amount share is higher than fraud rate in this population. The score range is 0 to 7. Temporal and complete segmentation partitions preserve the population.

**Interpretation:** A segment or signal with a higher observed fraud rate has a higher historical label incidence within this dataset. Signal capture and flagged fraud rate should be considered together because broad flags can capture more fraud while also covering more non-fraud rows.

**Causal claims:** No causal claim is made. Association with a signal or attribute does not mean that the attribute causes fraud.

## 13. Limitations

The data is the IEEE-CIS historical benchmark. Identity and device fields are observable dataset attributes, not verified real-world people. `TransactionDT` is source-relative. Geographic analysis cannot perform coordinate-based travel inference. The Phase 10 score is a rule-based prioritization score, not a probability.

## 14. KPI Validation

`sql/11_kpis/11_validate_kpis.sql` returns explicit PASS/FAIL checks for transaction totals, fraud totals, non-fraud totals, amount totals, temporal partitions, complete segmentation partitions, risk-band partitions, score partitions, and signal-family completeness.

## 15. Phase 11 Conclusion

Phase 11 provides a reproducible descriptive KPI layer downstream of the validated Phase 9 and Phase 10 outputs. Results are calculated in PostgreSQL through reusable views and are guarded by an explicit final gate.