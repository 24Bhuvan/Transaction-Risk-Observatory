# Phase 12 — Expected Metric Ranges & Invariant Benchmarks

## 1. Population & Core Invariants

| Metric Name | Baseline Value | Invariant Type | Severity | Acceptable Range / Condition |
| :--- | :--- | :--- | :--- | :--- |
| `total_transactions` | 590,540 | Hard Invariant | CRITICAL | Exact match (590,540) |
| `total_identities` | 144,233 | Hard Invariant | CRITICAL | Exact match (144,233) |
| `fraud_transactions` | 20,663 | Hard Invariant | CRITICAL | Exact match (20,663) |
| `non_fraud_transactions` | 569,877 | Hard Invariant | CRITICAL | Exact match (569,877) |
| `fraud_rate` | 0.034990 (3.499%) | Threshold Band | HIGH | 0.030000 – 0.040000 (3.0% – 4.0%) |

---

## 2. Monetary & Exposure Baselines

| Metric Name | Baseline Value | Invariant Type | Severity | Acceptable Range |
| :--- | :--- | :--- | :--- | :--- |
| `total_transaction_amount` | $79,738,948.735 | Hard Invariant | CRITICAL | Exact match |
| `fraud_transaction_amount` | $3,083,844.860 | Hard Invariant | CRITICAL | Exact match |
| `non_fraud_transaction_amount` | $76,655,103.875 | Hard Invariant | CRITICAL | Exact match |
| `average_transaction_amount` | $135.0272 | Statistical | MEDIUM | $100.00 – $200.00 |
| `average_fraud_amount` | $149.2448 | Statistical | MEDIUM | $100.00 – $200.00 |
| `fraud_amount_share` | 0.038674 (3.867%) | Threshold Band | HIGH | 0.030000 – 0.050000 (3.0% – 5.0%) |
| `max_daily_fraud_rate` | 0.069942 (6.994%) | Threshold Band | MEDIUM | < 0.150000 (< 15.0%) |
| `max_weekly_fraud_rate` | 0.050612 (5.061%) | Threshold Band | MEDIUM | < 0.100000 (< 10.0%) |

---

## 3. Data Integrity & Invariants

| Category / Column | Target Invariant | Severity | Status |
| :--- | :--- | :--- | :--- |
| Fact Duplicate Keys (`TransactionID`, `transaction_key`) | 0 duplicates | CRITICAL | PASS |
| Dim Duplicate Keys (`identity_key`, `TransactionID`) | 0 duplicates | CRITICAL | PASS |
| Critical NULLs (`TransactionID`, `TransactionDT`, `TransactionAmt`, `isFraud`) | 0 NULLs | CRITICAL | PASS |
| Dim Critical NULLs (`identity_key`, `TransactionID`) | 0 NULLs | CRITICAL | PASS |
| Referential Linkage (`identity_linked_transactions`) | 144,233 | HIGH | PASS |
| Orphan Dim Records | 0 records | CRITICAL | PASS |
| Invalid `isFraud` Domain Values | 0 records | CRITICAL | PASS |
| Negative `TransactionAmt` | 0 records | CRITICAL | PASS |
| Invalid `transaction_hour` ([0, 23]) | 0 records | HIGH | PASS |
| Invalid `transaction_week_number` (>= 0) | 0 records | HIGH | PASS |

---

## 4. Sparse Missingness Ranges

| Feature | Baseline Missing Count | Baseline Missing Rate | Acceptable Range | Severity |
| :--- | :--- | :--- | :--- | :--- |
| `P_emaildomain` | 94,456 | 15.9949% | 10.99% – 20.99% | LOW |
| `R_emaildomain` | 453,249 | 76.7516% | 71.75% – 81.75% | LOW |
| `card2` | 8,970 | 1.5189% | 0.00% – 6.52% | LOW |
| `card4` | 1,576 | 0.2669% | 0.00% – 5.27% | LOW |
| `card6` | 1,576 | 0.2669% | 0.00% – 5.27% | LOW |
| `DeviceType` (dim) | 3,423 | 2.3732% | 0.00% – 7.37% | LOW |
| `DeviceInfo` (dim) | 25,567 | 17.7262% | 12.73% – 22.73% | LOW |

---

## 5. Statistical & Frequency Distributions

### Numerical `TransactionAmt`:
- Min: $0.2510
- Max: $31,937.3910
- Mean: $135.0272
- Median (P50): $68.7900
- P25: $43.3210
- P75: $125.0000
- P95: $474.0000
- P99: $1,104.0000
- StdDev: $239.1625

### Categorical Shares:
- `ProductCD`: W (74.45%), C (11.60%), R (6.38%), H (5.59%), S (1.97%)
- `card4`: visa (65.16%), mastercard (32.04%), american express (1.39%), discover (1.13%), NULL (0.28%)
- `card6`: debit (74.50%), credit (25.23%), debit or credit (0.01%), charge card (<0.01%), NULL (0.27%)
- `DeviceType`: desktop (59.05%), mobile (38.58%), NULL (2.37%)
