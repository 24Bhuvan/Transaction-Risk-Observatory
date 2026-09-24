-- R04 - OFF-HOURS. Relative hour is used because no calendar reference date exists.
CREATE OR REPLACE VIEW analytics.vw_off_hours_analysis AS
SELECT "TransactionID", transaction_key, identity_key, "TransactionDT", transaction_hour, "isFraud", "TransactionAmt",
       CASE WHEN transaction_hour < 6 OR transaction_hour >= 22 THEN 1 ELSE 0 END AS off_hours_transaction,
       CASE WHEN transaction_hour < 6 OR transaction_hour >= 22 THEN 1 ELSE 0 END AS off_hours_risk_flag,
       CASE WHEN transaction_hour < 6 OR transaction_hour >= 22 THEN 'relative hour before 06:00 or at/after 22:00' ELSE NULL END AS off_hours_rule
FROM analytics.vw_transaction_analytics;
