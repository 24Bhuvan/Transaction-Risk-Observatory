# Phase 11 — Business KPIs & Fraud Analytics Catalog

## 1. Executive Summary

Phase 11 converts validated analytical views and Phase 10 risk detection signals into a standardized, reusable executive KPI catalog. All KPIs are computed purely within PostgreSQL 18 through relational views, ensuring reproducible business reporting across financial exposure, temporal trends, multi-dimensional segmentation, signal capture efficacy, and cohort risk concentrations.

Population baseline: **590,540 unique transactions**, **20,663 fraud events**, **$79,738,948.735 total volume**.

---

## 2. Core Fraud & Exposure KPIs

### 2.1 Fraud Rate (`analytics.kpi_fraud_summary`)
- **Formula**: `COUNT(*) FILTER (WHERE isFraud = 1) / COUNT(*)`
- **Measured Value**: **3.4990009%** (20,663 / 590,540)
- **Non-Fraud Rate**: **96.5009991%** (569,877 / 590,540)
- **Business Definition**: Proportion of completed transactions resulting in confirmed fraudulent chargebacks.

### 2.2 Financial Exposure (`analytics.kpi_amount_summary`)
- **Gross Volume**: **$79,738,948.735**
- **Gross Fraud Exposure**: **$3,083,844.860**
- **Fraud Amount Share**: **3.8674260%** ($3,083,844.86 / $79,738,948.74)
- **Average Fraud Ticket**: **$149.2447786**
- **Average Non-Fraud Ticket**: **$134.5116646**
- **Fraud Ticket Premium**: **+$14.7331140** (+10.95% higher average ticket size for fraud)
- **Amount Extremes**: Minimum: $0.00 | Median: $68.79 | Maximum: $31,937.39

---

## 3. Temporal Fraud Trends

### 3.1 Daily Fraud Trend (`analytics.kpi_daily_fraud`)
- **Grain**: `transaction_day_number` (Days 1 to 183)
- **Metrics**: Daily transaction volume, daily fraud count, daily fraud rate, daily volume exposure, daily average amount.
- **Invariance**: Sum of daily transactions = 590,540; sum of daily fraud = 20,663.

### 3.2 Weekly Fraud Trend (`analytics.kpi_weekly_fraud`)
- **Grain**: `transaction_week_number` (Weeks 1 to 27)
- **Metrics**: Weekly volume, weekly fraud rate, weekly total gross and fraud amounts.
- **Invariance**: Exactly reconciles to the 590,540 transaction population.

### 3.3 Diurnal / Hourly Trend (`analytics.kpi_hourly_fraud`)
- **Grain**: `transaction_hour` (Hours 0 to 23)
- **Key Finding**: Fraud rates rise during off-hours (02:00 to 06:00), reaching peak incidence while daytime volumes drop.

---

## 4. Multi-Dimensional Segmentation (`analytics.kpi_segmentation_summary`)

The segmentation catalog evaluates fraud incidence across 8 observable business dimensions:
1. `ProductCD` (Product category: W, C, R, H, S)
2. `card4` (Payment network: visa, mastercard, discover, american express)
3. `card6` (Card funding type: debit, credit, charge card)
4. `DeviceType` (Client hardware: desktop, mobile, unlinked)
5. `deviceinfo_normalized` (Normalized hardware model cluster)
6. `P_emaildomain` (Purchaser email service provider)
7. `R_emaildomain` (Recipient email service provider)
8. `identity_available_flag` (Authenticated digital footprint presence)

*Performance Optimization Note*: This view was refactored in Phase 13 from 8 sequential `UNION ALL` scans into a single-pass `LEFT JOIN` with `CROSS JOIN LATERAL (VALUES ...)` projection, reducing execution time from **69,900.616 ms to 16,399.290 ms** (76.54% reduction) with zero discrepancies across all 1,921 segment rows.

---

## 5. Risk Signal Performance (`analytics.kpi_signal_performance`)

Evaluates the diagnostic efficacy and capture rates of the 6 core risk flags:

| Signal Name | Flagged Transactions | Flag Rate | Captured Fraud Count | Fraud Capture Rate | Flagged Fraud Rate | Unflagged Fraud Rate |
|:---|---:|---:|---:|---:|---:|---:|
| **Entity / Device Anomaly** | 118,231 | 20.02% | 8,595 | 41.59% | **7.2697%** | 2.5551% |
| **Velocity (24h burst)** | 139,942 | 23.70% | 5,790 | 28.02% | **4.1374%** | 3.3007% |
| **Off-Hours Activity** | 223,754 | 37.89% | 8,287 | 40.11% | **3.7036%** | 3.3742% |
| **Amount Anomaly (P95)** | 6,251 | 1.06% | 166 | 0.80% | **2.6556%** | 3.5080% |
| **Multiple Signals (>=2)** | 109,197 | 18.49% | 6,394 | 30.94% | **5.8555%** | 2.9644% |
| **Impossible Travel** | 0 | 0.00% | 0 | 0.00% | N/A | 3.4990% |

---

## 6. Risk Scoring & Cohorts

### 6.1 Score Distribution (`analytics.kpi_risk_score_statistics` & `summary`)
- **Range**: Integer values from 0 to 7
- **Mean Score**: 1.2744302
- **Median Score**: 1

### 6.2 Risk Bands (`analytics.kpi_risk_cohorts`)
- **`LOW` (`risk_score < 2`)**: Accounts for majority of transactions; lowest historical fraud rate.
- **`MEDIUM` (`risk_score BETWEEN 2 AND 4`)**: Elevated operational suspicion.
- **`HIGH` (`risk_score >= 5`)**: Multi-vector compounded threat; highest operational priority.

---

## 7. Fraud Concentration (`analytics.kpi_fraud_concentration`)

Computes cumulative Pareto concentration rankings within categorical segments:
- Calculates segment fraud count share, amount share, cumulative count share, and cumulative amount share.
- Identifies that a small minority of anomalous device types, card tiers, and product codes account for over 60% of total gross fraud dollar losses.

---

## 8. Business Questions Evidence (`analytics.kpi_business_questions`)

The view provides direct empirical answers to 7 core executive questions:
- **Q1 (Overall Fraud Incidence)**: What is the baseline fraud rate and loss volume? -> 3.499% rate, $3,083,844.86 gross loss.
- **Q2 (Monetary Exposure)**: Do fraudulent transactions have higher ticket sizes? -> Yes, $149.24 vs $134.51 ($14.73 premium).
- **Q3 (Temporal Concentration)**: Are losses concentrated in specific time windows? -> Nighttime hours (02:00–06:00) demonstrate elevated fraud rates.
- **Q4 (Segment Risk)**: Which merchant categories and payment networks exhibit highest risk? -> Ranked in `kpi_segmentation_summary`.
- **Q5 (Signal Accuracy)**: Which behavioral detection rules yield the highest precision? -> Entity/Device Anomaly (7.270% fraud rate).
- **Q6 (Score Triage)**: Does the composite score effectively concentrate fraud into high bands? -> Verified monotonic fraud rate increase across score bands.
- **Q7 (Pareto Concentration)**: Where are gross losses concentrated? -> Documented via cumulative rankings in `kpi_fraud_concentration`.
