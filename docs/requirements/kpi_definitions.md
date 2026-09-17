# Transaction Risk Observatory — KPI Definitions

## KPI Specification Principles

Each KPI must have a defined business meaning, formula, and analytical grain.

The initial KPI specifications below establish the framework for the project. The final KPI set will be finalized after the IEEE-CIS dataset structure, available fields, and data-quality findings are confirmed.

| KPI                              | Definition                                                                                         | Formula                                                                      | Grain                |
| -------------------------------- | -------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------------- |
| **Fraud Rate**                   | Share of transactions labeled as fraudulent.                                                       | `fraudulent transactions / total transactions`                               | Overall / Time       |
| **Fraud Amount**                 | Total transaction amount associated with transactions labeled as fraudulent.                       | `SUM(amount WHERE isFraud = 1)`                                              | Overall / Time       |
| **Average Fraud Amount**         | Mean transaction amount among transactions labeled as fraudulent.                                  | `AVG(amount WHERE isFraud = 1)`                                              | Overall              |
| **Fraud Count**                  | Number of transactions labeled as fraudulent.                                                      | `COUNT(*) WHERE isFraud = 1`                                                 | Overall / Time       |
| **Non-Fraud Count**              | Number of transactions not labeled as fraudulent.                                                  | `COUNT(*) WHERE isFraud = 0`                                                 | Overall / Time       |
| **Total Transaction Amount**     | Total monetary value across all transactions.                                                      | `SUM(amount)`                                                                | Overall / Time       |
| **Average Transaction Amount**   | Mean transaction amount across all transactions.                                                   | `AVG(amount)`                                                                | Overall / Time       |
| **Risk Signal Rate**             | Share of transactions triggering a specific rule-based risk signal.                                | `flagged transactions / total transactions`                                  | Rule / Time          |
| **Risk Signal Count**            | Number of transactions triggering a specific rule-based risk signal.                               | `COUNT(*) WHERE risk_signal = TRUE`                                          | Rule / Time          |
| **Multi-Signal Count**           | Number of transactions triggering at least two independent risk rules.                             | `COUNT(*) WHERE risk_signal_count >= 2`                                      | Overall / Time       |
| **Multi-Signal Rate**            | Share of transactions triggering at least two independent risk rules.                              | `multi-signal transactions / total transactions`                             | Overall / Time       |
| **Average Risk Score**           | Mean deterministic risk score assigned to transactions.                                            | `AVG(risk_score)`                                                            | Overall / Time       |
| **High-Risk Transaction Count**  | Number of transactions exceeding the defined high-risk score threshold.                            | `COUNT(*) WHERE risk_score >= high_risk_threshold`                           | Overall / Time       |
| **High-Risk Transaction Rate**   | Share of transactions classified as high-risk by the deterministic scoring framework.              | `high-risk transactions / total transactions`                                | Overall / Time       |
| **Fraud Rate by Entity**         | Fraud rate for an available entity such as device, card, email domain, or other analytical entity. | `fraudulent transactions for entity / total transactions for entity`         | Entity               |
| **Fraud Rate by Device Type**    | Share of transactions labeled fraudulent within each device type.                                  | `fraudulent transactions by device type / total transactions by device type` | Device Type          |
| **Fraud Amount Share**           | Share of total transaction value associated with fraudulent transactions.                          | `fraud amount / total transaction amount`                                    | Overall / Time       |
| **Transactions per Time Window** | Number of transactions occurring within a defined time window for an entity.                       | `COUNT(transactions within window)`                                          | Entity / Time Window |
| **Velocity Signal Rate**         | Share of transactions triggering the defined high-velocity rule.                                   | `velocity-flagged transactions / total transactions`                         | Overall / Time       |
| **Geographic Anomaly Rate**      | Share of transactions triggering a defined geographic inconsistency rule.                          | `geographic-anomaly transactions / eligible transactions`                    | Overall / Time       |
| **Amount Anomaly Rate**          | Share of transactions triggering a defined transaction-amount anomaly rule.                        | `amount-anomaly transactions / total transactions`                           | Overall / Time       |

## KPI Calculation Rules

### Fraud Label

Where applicable, the dataset's `isFraud` label will be treated as the ground-truth transaction label supplied by the source dataset.

```text
isFraud = 1 → transaction labeled fraudulent
isFraud = 0 → transaction labeled non-fraudulent
```

Rule-generated risk signals must remain separate from the source fraud label.

A transaction triggering a risk rule must **not** automatically be described as fraudulent.

### Risk Signals

Risk signals are deterministic indicators generated by SQL rules.

Examples include:

* High transaction velocity
* Unusual transaction amount
* Off-hours activity
* Geographic inconsistency
* Device-related anomaly
* Entity-related anomaly
* Multiple suspicious attributes occurring together

Each signal will have:

* A defined rule
* A documented threshold
* A boolean flag
* A measurable signal count/rate
* Validation against available transaction labels where appropriate

### Risk Score

The risk score will be a transparent deterministic score derived from individual risk signals.

Example conceptual structure:

```text
risk_score =
    velocity_signal
  + amount_signal
  + geographic_signal
  + device_signal
  + temporal_signal
  + entity_signal
```

The actual signals, weights, and thresholds will be finalized after dataset profiling and analytical testing.

## Grain Definitions

| Grain           | Meaning                                                                                                  |
| --------------- | -------------------------------------------------------------------------------------------------------- |
| **Overall**     | KPI calculated across the complete eligible transaction population.                                      |
| **Time**        | KPI grouped by a defined temporal unit such as hour, day, week, or month.                                |
| **Rule**        | KPI calculated separately for each risk-detection rule.                                                  |
| **Entity**      | KPI calculated for an available entity such as device, card, email domain, or other relevant identifier. |
| **Device Type** | KPI grouped by the available device-type classification.                                                 |
| **Time Window** | KPI calculated over a defined rolling or fixed transaction window.                                       |

## KPI Finalization Rule

The KPI list is provisional during Phase 1.

The final KPI set will be finalized only after:

1. The IEEE-CIS transaction and identity schemas are confirmed.
2. Column availability is verified.
3. Data types are confirmed.
4. Missingness and data-quality issues are assessed.
5. Entity relationships are established.
6. Fraud-risk rules are defined and validated.
7. Analytical grain is confirmed.

No KPI will be claimed in the final project unless its required source fields exist and its calculation can be reproduced from the project data.
