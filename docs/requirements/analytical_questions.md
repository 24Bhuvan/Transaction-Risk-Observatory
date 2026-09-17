# Transaction Risk Observatory — Analytical Questions

## 1. Fraud Exposure

### AQ01 — Fraud Rate

What percentage of transactions are labeled fraudulent?

### AQ02 — Fraud Transaction Value

What is the total transaction value associated with fraudulent transactions?

### AQ03 — Fraud vs. Non-Fraud Amount

What is the average transaction amount for fraudulent transactions compared with non-fraudulent transactions?

---

## 2. Temporal Behavior

### AQ04 — Fraud by Time

Are fraudulent transactions concentrated during particular hours, days of the week, or periods?

### AQ05 — Transaction Bursts

Are short-term transaction bursts associated with fraudulent activity?

### AQ06 — Pre-Fraud Transaction Frequency

How frequently do transactions occur within defined short time windows before a transaction labeled as fraudulent?

---

## 3. Transaction Behavior

### AQ07 — Amount Anomalies

Are unusually large or unusually small transaction amounts associated with fraudulent transactions?

### AQ08 — Recurring Transaction Patterns

Are recurring transaction patterns or repeated transaction behaviors associated with fraudulent activity?

---

## 4. Entity and Device Behavior

### AQ09 — High-Risk Entities

Which available entities exhibit unusually high fraud rates or concentrations of fraudulent transactions?

### AQ10 — Device Risk

Are particular device types or device characteristics associated with elevated fraud rates?

### AQ11 — Attribute Changes

Are changes in identifiable transaction attributes, such as device, payment, or other available attributes, associated with fraudulent activity?

---

## 5. Geographic Behavior

### AQ12 — Geographic Inconsistency

Are geographically inconsistent transaction patterns associated with fraudulent activity?

### AQ13 — Implausible Movement

Can successive transactions exhibit implausible movement relative to their timestamps and available location information?

---

## 6. Risk Scoring

### AQ14 — Multiple Risk Signals

Which transactions trigger multiple independent rule-based risk signals simultaneously?

### AQ15 — Transparent Risk Score

Can multiple rule-based risk signals be combined into a transparent and interpretable transaction-level risk score?

---

## Analytical Constraints

The questions will be answered using PostgreSQL and deterministic, rule-based SQL analysis.

The project will:

* Use the available IEEE-CIS transaction and identity data.
* Distinguish observed fraud labels from analytically generated risk signals.
* Avoid machine-learning classification.
* Avoid claiming that a rule-based signal represents confirmed fraud unless supported by the dataset's fraud label.
* Use only attributes available in the source data.
* Document thresholds and assumptions used by each analytical rule.
* Validate analytical outputs against the underlying transaction data.

## Expected Analytical Outputs

The analytical questions are expected to produce outputs such as:

* Fraud-rate summaries
* Fraud transaction-value summaries
* Fraud vs. non-fraud amount comparisons
* Time-based fraud distributions
* Velocity and burst indicators
* Transaction anomaly indicators
* Entity and device risk summaries
* Geographic anomaly results
* Multi-signal transaction flags
* Transparent transaction-level risk scores
* Supporting SQL result sets and analytical views
