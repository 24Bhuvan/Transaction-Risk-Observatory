## Phase 6 — Data Cleaning & Transformation

### Added

* Created clean analytical layer:

  * `analytics.fact_transaction_clean`
  * `analytics.dim_identity_clean`
* Standardized categorical and text field representations.
* Implemented documented NULL and missingness handling policy.
* Performed DeviceInfo normalization and device availability handling.
* Performed email-domain normalization and missingness handling.
* Created relative transaction-time features:

  * `transaction_day_number`
  * `transaction_hour`
  * `transaction_week_number`
* Created transaction amount analytical features:

  * `transaction_amount_zero_flag`
  * `transaction_amount_log`
* Created secondary-card missingness features.
* Created transaction-level risk-signal fields:

  * `identity_available_flag`
  * `email_domain_missing_flag`
  * `device_info_available_flag`
  * `missing_attribute_count`

### Validation

* Completed Phase 6 clean-layer validation.
* Reconciled Phase 6 clean tables against Phase 5 analytical tables.
* Confirmed fact population: **590,540 rows**.
* Confirmed identity population: **144,233 rows**.
* Confirmed `TransactionID` uniqueness and population preservation.
* Confirmed `isFraud` distribution preservation:

  * `0` → **569,877**
  * `1` → **20,663**
* Confirmed `TransactionAmt` reconciliation:

  * SUM → **79,738,948.735**
  * AVG → **135.0271763724726521**
* Confirmed identity relationship preservation:

  * Linked → **144,233**
  * Unlinked → **446,307**
* Phase 5 → Phase 6 reconciliation completed with **0 unexpected mismatches**.
* Final Phase 6 validation status: **PASS**.

### Data Integrity

* Staging tables were **not modified**.
* Phase 5 analytical tables were preserved unchanged.
* No blanket NULL imputation was performed.
* No fraud labels were modified.
* No transaction records were removed.
* No undocumented semantic mappings were introduced.
