# Transaction Risk Observatory — Data Dictionary

## 1. Document Information

| Attribute | Value |
|---|---|
| Project | Transaction Risk Observatory |
| Phase | Phase 3 — Data Profiling & Quality Assessment |
| Step | Step 3.13 — Build the Data Dictionary |
| Database Schema | `staging` |
| Source Tables | `staging.raw_transactions`, `staging.raw_identity` |
| Total Columns | 435 |
| Transaction Columns | 394 |
| Identity Columns | 41 |
| Purpose | Document the structure, completeness, cardinality, and profiling characteristics of the staging-layer data |

---

## 2. Scope

This data dictionary documents all columns currently present in the staging layer.

The dictionary records:

- Table name
- Column name
- PostgreSQL data type
- Business/technical description where supported
- NULL percentage
- Distinct value count
- Profiling notes

The dictionary is based on the actual PostgreSQL staging schema and the profiling results produced during Phase 3.

Anonymized IEEE-CIS transaction and identity variables are not assigned invented business meanings. Their original field names are retained and their profiling characteristics are documented.

---

## 3. Source Tables

### 3.1 `staging.raw_transactions`

The transaction staging table contains:

- Transaction identifiers
- Fraud target
- Transaction time
- Transaction amount
- Product information
- Card attributes
- Address attributes
- Email domains
- Categorical M-fields
- Anonymized C-fields, D-fields, and V-fields

Total columns: **394**

### 3.2 `staging.raw_identity`

The identity staging table contains:

- Transaction identifier
- Anonymized identity attributes (`id_01`–`id_38`)
- Device type
- Device information

Total columns: **41**

The identity table contains 144,233 records and represents the subset of transactions for which identity information is available.

---

## 4. Data Type Summary

### `staging.raw_transactions`

| PostgreSQL Data Type | Column Count |
|---|---:|
| BIGINT | 3 |
| DOUBLE PRECISION | 375 |
| NUMERIC | 1 |
| SMALLINT | 1 |
| TEXT | 14 |
| **Total** | **394** |

### `staging.raw_identity`

| PostgreSQL Data Type | Column Count |
|---|---:|
| BIGINT | 1 |
| DOUBLE PRECISION | 23 |
| TEXT | 17 |
| **Total** | **41** |

All 435 staging columns are currently nullable.

---

## 5. Column-Level Data Dictionary

The complete column-level dictionary was generated directly from PostgreSQL metadata and Phase 3 profiling results.

### 5.1 `staging.raw_transactions`

| Column | Data Type | Description |
|---|---|---|
| TransactionID | BIGINT | Unique identifier for the transaction. |
| isFraud | SMALLINT | Fraud target indicator for the transaction. |
| TransactionDT | BIGINT | Time value associated with the transaction, retained in its original source representation. |
| TransactionAmt | NUMERIC | Transaction amount. |
| ProductCD | TEXT | Product category/code associated with the transaction. |
| card1 | BIGINT | Anonymized primary card-related identifier. |
| card2 | DOUBLE PRECISION | Anonymized secondary card attribute. |
| card3 | DOUBLE PRECISION | Anonymized card attribute. |
| card4 | TEXT | Card payment network/type. |
| card5 | DOUBLE PRECISION | Anonymized card attribute. |
| card6 | TEXT | Card type/category. |
| addr1 | DOUBLE PRECISION | Anonymized billing/address attribute. |
| addr2 | DOUBLE PRECISION | Anonymized address attribute. |
| dist1 | DOUBLE PRECISION | Anonymized distance-related transaction attribute. |
| dist2 | DOUBLE PRECISION | Anonymized distance-related transaction attribute. |
| P_emaildomain | TEXT | Purchaser email domain. |
| R_emaildomain | TEXT | Recipient email domain. |
| C1–C14 | DOUBLE PRECISION | Anonymized transaction-related C-series features. |
| D1–D15 | DOUBLE PRECISION | Anonymized transaction-related D-series features. |
| M1–M9 | TEXT | Anonymized categorical M-series features. |
| V1–V339 | DOUBLE PRECISION | Anonymized transaction-related V-series features. |

> Note: `C1–C14`, `D1–D15`, `M1–M9`, and `V1–V339` represent individual columns in the database. The grouped notation above summarizes their common feature families; the generated profiling output contains each individual column separately.

### 5.2 `staging.raw_identity`

| Column | Data Type | Description |
|---|---|---|
| TransactionID | BIGINT | Transaction identifier linking identity information to the transaction table. |
| id_01–id_38 | Varies | Anonymized identity-related features. |
| DeviceType | TEXT | Type of device used for the transaction. |
| DeviceInfo | TEXT | Additional device metadata. |

> Note: The anonymized `id_01–id_38` fields are documented individually in the generated dictionary with their actual PostgreSQL data types, NULL percentages, distinct counts, and profiling notes.

---

## 6. Completeness Summary

NULL profiling was performed across all 435 columns.

### `staging.raw_identity`

- Total columns: **41**
- Columns with 0% NULL: **3**
- Columns with more than 50% NULL: **12**
- Columns with more than 90% NULL: **9**
- Columns with 100% NULL: **0**

Most incomplete identity attributes include:

- `id_24`
- `id_25`
- `id_07`
- `id_08`
- `id_21`
- `id_22`
- `id_23`
- `id_26`
- `id_27`

`DeviceInfo` has:

- Total records: 144,233
- NULL records: 118,666
- Non-NULL records: 25,567
- Non-NULL percentage: 17.73%

### `staging.raw_transactions`

- Total columns: **394**
- Columns with 0% NULL: **52**
- Columns with more than 50% NULL: **174**
- Columns with more than 90% NULL: **2**
- Columns with 100% NULL: **0**

The most incomplete transaction attributes include:

- `dist2`
- `D7`
- `D12`
- `D13`
- `D14`
- `D6`
- `D8`
- `D9`
- Several V-series fields
- `R_emaildomain`

Critical transaction fields such as:

- `TransactionID`
- `isFraud`
- `TransactionDT`
- `TransactionAmt`

are fully populated.

---

## 7. Cardinality and Categorical Profiling

Categorical/text profiling identified:

- `raw_transactions`: **14** TEXT columns
- `raw_identity`: **17** TEXT columns
- Total categorical/text columns: **31**

Categorical profiling examined:

- Distinct values
- Frequency
- Percentage distribution
- NULL frequency

Examples include:

- `ProductCD`
- `card4`
- `card6`
- `P_emaildomain`
- `R_emaildomain`
- `DeviceType`
- `DeviceInfo`
- Anonymized M-series fields

### DeviceInfo

`DeviceInfo` contains a large number of distinct values and substantial missingness.

Among non-NULL values, common values include:

- Windows
- iOS Device
- MacOS
- Trident/7.0
- rv:11.0
- rv:57.0

The field is heterogeneous and contains operating-system, browser-engine/version, and device-model/build-like values.

No cleaning, grouping, or standardization is performed at the raw profiling stage.

---

## 8. Transaction–Identity Relationship

The relationship between the two staging tables was profiled.

| Metric | Value |
|---|---:|
| Total transactions | 590,540 |
| Identity records | 144,233 |
| Distinct identity TransactionIDs | 144,233 |
| Transactions with identity | 144,233 |
| Transactions without identity | 446,307 |
| Identity coverage | 24.42% |
| Identity records without matching transaction | 0 |
| Duplicate identity TransactionIDs | 0 |

The observed relationship is:

```text
staging.raw_transactions
        1
        |
        | 0 or 1
        |
staging.raw_identity
```

---

## 9. Analytical Clean Layer & Risk Feature Dictionary

The following table documents the core analytical fields in the production analytical layer (`analytics.fact_transaction_clean`, `analytics.dim_identity_clean`, and derived views `vw_composed_risk_signals`, `vw_risk_scoring`, `vw_suspicious_transactions`, and `vw_suspicious_entities`), adhering to the standardized format:

| Field | Table | Data Type | Description | Business Meaning |
|---|---|---|---|---|
| `TransactionID` | `analytics.fact_transaction_clean` | BIGINT | Unique natural transaction identifier from source | Primary business key for individual payment transaction |
| `isFraud` | `analytics.fact_transaction_clean` | SMALLINT | Binary fraud ground truth indicator (0 = legitimate, 1 = fraudulent) | Target variable defining confirmed fraudulent chargeback or reported fraud event |
| `TransactionDT` | `analytics.fact_transaction_clean` | BIGINT | Elapsed time in seconds from an undisclosed historical reference point | Relative temporal anchor used for sequencing and velocity calculations |
| `TransactionAmt` | `analytics.fact_transaction_clean` | NUMERIC | Transaction value in original currency units | Direct gross financial exposure of the transaction |
| `ProductCD` | `analytics.fact_transaction_clean` | TEXT | Categorical product identifier code (W, C, R, H, S) | High-level merchant line of business or transaction type |
| `card1` | `analytics.fact_transaction_clean` | BIGINT | Anonymized primary payment card identifier / issuer routing code | Core proxy for user payment instrument |
| `card4` | `analytics.fact_transaction_clean` | TEXT | Standardized card payment network (visa, mastercard, discover, american express) | Payment brand handling card clearing and settlement |
| `card6` | `analytics.fact_transaction_clean` | TEXT | Standardized payment card tier/funding type (debit, credit, charge card) | Credit vs. debit exposure classification |
| `P_emaildomain` | `analytics.fact_transaction_clean` | TEXT | Purchaser email domain, standardized to lowercase and trimmed | Counterparty contact identity and institutional domain reputation |
| `R_emaildomain` | `analytics.fact_transaction_clean` | TEXT | Recipient email domain, standardized to lowercase and trimmed | Recipient entity identity for peer-to-peer or remittance payments |
| `transaction_day_number` | `analytics.fact_transaction_clean` | INTEGER | Derived relative day sequence calculated as `FLOOR(TransactionDT / 86400) + 1` | Day of observation window (Days 1–183) for longitudinal trend analysis |
| `transaction_hour` | `analytics.fact_transaction_clean` | INTEGER | Derived hour of day calculated as `FLOOR(TransactionDT / 3600) % 24` | Diurnal cycle marker (0–23) used for off-hours behavioral anomaly detection |
| `transaction_week_number` | `analytics.fact_transaction_clean` | INTEGER | Derived relative week sequence calculated as `FLOOR(TransactionDT / 604800) + 1` | Weekly cohort grouping (Weeks 1–27) for volume and loss monitoring |
| `transaction_amount_zero_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary flag: 1 if `TransactionAmt = 0`, else 0 | Zero-amount authorization/card verification attempt |
| `transaction_amount_log` | `analytics.fact_transaction_clean` | NUMERIC | Natural log transformation: `LN(TransactionAmt + 1)` | Log-scaled monetary metric to stabilize extreme skewness in regression and modeling |
| `identity_available_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if matching record exists in `dim_identity_clean`, else 0 | Digital footprint indicator differentiating web/app authenticated sessions from anonymous checkout |
| `email_domain_missing_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if `P_emaildomain` is NULL, else 0 | Missing contact attribute flag signaling elevated transaction anonymity |
| `device_info_available_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if `DeviceInfo` is populated, else 0 | Hardware telemetry presence indicator |
| `card_attributes_missing_count` | `analytics.fact_transaction_clean` | INTEGER | Count of NULL values across `card2`, `card3`, `card5`, and `card6` (0 to 4) | Incomplete payment card tokenization metric |
| `card_attributes_partial_missing_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary flag: 1 if missing count is between 1 and 3, else 0 | Inconsistent or partial card metadata signal |
| `dist2_missing_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if secondary distance `dist2` is NULL, else 0 | Missing billing-to-shipping distance telemetry |
| `d7_missing_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if timedelta feature `D7` is NULL, else 0 | Missing elapsed transaction history flag |
| `r_emaildomain_missing_flag` | `analytics.fact_transaction_clean` | INTEGER | Binary indicator: 1 if `R_emaildomain` is NULL, else 0 | Single-party vs two-party transaction flow indicator |
| `identity_key` | `analytics.dim_identity_clean` | BIGINT | PostgreSQL-generated surrogate primary key | Unique entity identifier for authenticated digital session |
| `TransactionID` | `analytics.dim_identity_clean` | BIGINT | Natural transaction identifier linking to `fact_transaction_clean` | Relational bridge linking identity dimension to payment event (1 : 0..1) |
| `DeviceType` | `analytics.dim_identity_clean` | TEXT | High-level client platform type ('desktop', 'mobile') | Form factor classification for channel-specific risk modeling |
| `DeviceInfo` | `analytics.dim_identity_clean` | TEXT | Raw hardware, browser, and OS telemetry string from client device | Granular client device signature |
| `deviceinfo_normalized` | `analytics.dim_identity_clean` | TEXT | Trimmed, lowercase standardized device specification string | Clean device cluster key grouping identical hardware signatures |
| `deviceinfo_missing_flag` | `analytics.dim_identity_clean` | INTEGER | Binary indicator: 1 if `DeviceInfo` is NULL within identity record, else 0 | Identity session with masked or uncollected user agent metadata |
| `id_01` through `id_38` | `analytics.dim_identity_clean` | NUMERIC/TEXT | Anonymized biometric, network, and device risk attributes | Behavioral and network telemetry captured during authentication |
| `velocity_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if >= 3 transactions observed for same identity within 24h window | High-frequency transaction burst suggesting card testing or bot automation |
| `amount_anomaly_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if `TransactionAmt` exceeds identity 95th percentile baseline | Deviant high-ticket purchase relative to historical entity spending |
| `entity_device_anomaly_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if device shared across multiple identities or identity hopping across devices | Device sharing or emulator device-spoofing signature |
| `off_hours_risk_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if transaction executed during local overnight trough (02:00–06:00) | Higher-risk temporal window when manual authorization review is minimal |
| `impossible_travel_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if speed between consecutive transactions exceeds 800 km/h (fixed 0) | Physical impossibility marker (documented limitation: coarse geolocation only) |
| `signal_count` | `analytics.vw_composed_risk_signals` | INTEGER | Sum of active component risk flags (0 to 5) | Multi-vector threat density score |
| `multiple_signal_flag` | `analytics.vw_composed_risk_signals` | INTEGER | 1 if `signal_count >= 2`, else 0 | Cross-dimensional composite risk trigger |
| `risk_score` | `analytics.vw_risk_scoring` | INTEGER | Weighted additive score: `velocity*2 + amount*2 + device*2 + offhours*1 + travel*3` | Transparent heuristic prioritization rank (range 0 to 7) for alert triage |
| `risk_band` | `analytics.vw_risk_scoring` | TEXT | Categorical triage tier: 'HIGH' (>=5), 'MEDIUM' (2-4), 'LOW' (<2) | Operational routing classification for automated hold, review, or pass |
| `risk_reason` | `analytics.vw_risk_scoring` | TEXT | Concatenated string of active risk triggers | Explainable diagnostic summary explaining score derivation |
| `is_suspicious_transaction` | `analytics.vw_suspicious_transactions` | INTEGER | 1 if `risk_score >= 2` (MEDIUM or HIGH band) | Operational alert trigger for fraud analysts |
| `is_suspicious_entity` | `analytics.vw_suspicious_entities` | INTEGER | 1 if identity entity exhibits >= 2 flagged transactions or >= 1 fraud event | Entity-level blacklist/watchlist candidate |
