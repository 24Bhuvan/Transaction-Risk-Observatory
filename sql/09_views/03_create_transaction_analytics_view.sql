-- PHASE 9 - STEP 9.5 - TRANSACTION ANALYTICAL VIEW
CREATE OR REPLACE VIEW analytics.vw_transaction_analytics AS
SELECT
    f.transaction_key,
    f."TransactionID",
    f.identity_key,
    f."isFraud",
    f."TransactionDT",
    f."TransactionAmt",
    f."ProductCD",
    f.card1, f.card2, f.card3, f.card4, f.card5, f.card6,
    f.addr1, f.addr2, f.dist1, f.dist2,
    f."P_emaildomain", f."R_emaildomain",
    f.transaction_day_number,
    f.transaction_hour,
    f.transaction_week_number,
    f.transaction_amount_zero_flag,
    f.transaction_amount_log,
    f.card_attributes_missing_count,
    f.card_attributes_partial_missing_flag,
    f.identity_available_flag,
    f.email_domain_missing_flag,
    f.device_info_available_flag,
    f.missing_attribute_count,
    d."DeviceType",
    d."DeviceInfo",
    d.deviceinfo_normalized,
    d.deviceinfo_missing_flag,
    d.id_01, d.id_02, d.id_03, d.id_04, d.id_05, d.id_06, d.id_07, d.id_08, d.id_09, d.id_10,
    d.id_11, d.id_12, d.id_13, d.id_14, d.id_15, d.id_16, d.id_17, d.id_18, d.id_19, d.id_20,
    d.id_21, d.id_22, d.id_23, d.id_24, d.id_25, d.id_26, d.id_27, d.id_28, d.id_29, d.id_30,
    d.id_31, d.id_32, d.id_33, d.id_34, d.id_35, d.id_36, d.id_37, d.id_38
FROM analytics.fact_transaction_clean f
LEFT JOIN analytics.dim_identity_clean d ON d.identity_key = f.identity_key;
