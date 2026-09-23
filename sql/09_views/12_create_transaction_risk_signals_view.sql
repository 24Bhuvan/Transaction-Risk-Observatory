-- PHASE 9 - STEP 9.15 - TRANSACTION DETERMINISTIC SIGNAL VIEW
CREATE OR REPLACE VIEW analytics.vw_transaction_risk_signals AS
SELECT
    "TransactionID",
    transaction_key,
    "isFraud",
    "TransactionAmt",
    identity_available_flag,
    email_domain_missing_flag,
    device_info_available_flag,
    card_attributes_partial_missing_flag,
    transaction_amount_zero_flag,
    missing_attribute_count,
    (CASE WHEN identity_available_flag=0 THEN 1 ELSE 0 END
     + CASE WHEN email_domain_missing_flag=1 THEN 1 ELSE 0 END
     + CASE WHEN device_info_available_flag=0 THEN 1 ELSE 0 END
     + CASE WHEN card_attributes_partial_missing_flag=1 THEN 1 ELSE 0 END
     + CASE WHEN transaction_amount_zero_flag=1 THEN 1 ELSE 0 END) AS risk_signal_count
FROM analytics.vw_transaction_analytics;
