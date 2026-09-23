-- PHASE 9 - FINAL GATE
WITH checks AS (
    SELECT 'baseline_valid' AS check_name, (SELECT COUNT(*)=590540 FROM analytics.fact_transaction_clean) AND (SELECT COUNT(*)=144233 FROM analytics.dim_identity_clean) AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=1)=20663 FROM analytics.fact_transaction_clean) AS passed
    UNION ALL SELECT 'transaction_view_valid', (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_transaction_analytics)
    UNION ALL SELECT 'daily_summary_valid', (SELECT SUM(total_transactions)=590540 AND SUM(fraud_transactions)=20663 AND SUM(non_fraud_transactions)=569877 AND COUNT(*)=COUNT(DISTINCT transaction_day_number) FROM analytics.vw_daily_fraud_summary)
    UNION ALL SELECT 'weekly_summary_valid', (SELECT SUM(total_transactions)=590540 AND SUM(fraud_transactions)=20663 AND SUM(non_fraud_transactions)=569877 AND COUNT(*)=COUNT(DISTINCT transaction_week_number) FROM analytics.vw_weekly_fraud_summary)
    UNION ALL SELECT 'fraud_comparison_valid', (SELECT COUNT(*)=2 AND COUNT(*) FILTER (WHERE "isFraud" IN (0,1))=2 FROM analytics.vw_fraud_comparison)
    UNION ALL SELECT 'identity_risk_valid', (SELECT COUNT(*)=144233 AND COUNT(*)=COUNT(DISTINCT identity_key) FROM analytics.vw_identity_risk)
    UNION ALL SELECT 'device_analysis_valid', (SELECT COUNT(*)=COUNT(DISTINCT ("DeviceType","DeviceInfo")) FROM analytics.vw_device_risk)
    UNION ALL SELECT 'card_analysis_valid', (SELECT COUNT(*)=COUNT(DISTINCT (card4,card6)) FROM analytics.vw_card_risk)
    UNION ALL SELECT 'address_analysis_valid', (SELECT COUNT(*)=COUNT(DISTINCT (addr1,addr2,dist1,dist2)) FROM analytics.vw_geographic_attribute_risk)
    UNION ALL SELECT 'risk_signal_summary_valid', (SELECT COUNT(*)=6 AND COUNT(*)=COUNT(DISTINCT signal_name) FROM analytics.vw_risk_signal_summary)
    UNION ALL SELECT 'transaction_risk_signal_view_valid', (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_transaction_risk_signals)
    UNION ALL SELECT 'daily_weekly_amounts_reconcile', (SELECT SUM(total_amount) FROM analytics.vw_daily_fraud_summary)=(SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics) AND (SELECT SUM(total_amount) FROM analytics.vw_weekly_fraud_summary)=(SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics)
    UNION ALL SELECT 'materialized_views_validated', NOT EXISTS (SELECT 1 FROM pg_matviews WHERE schemaname='analytics' AND matviewname LIKE 'mv_%')
)
SELECT check_name, CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS status FROM checks ORDER BY check_name;
WITH checks AS (
    SELECT (SELECT COUNT(*)=590540 FROM analytics.fact_transaction_clean) AND (SELECT COUNT(*)=144233 FROM analytics.dim_identity_clean) AND (SELECT COUNT(*) FILTER (WHERE "isFraud"=1)=20663 FROM analytics.fact_transaction_clean) AS passed
    UNION ALL SELECT (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_transaction_analytics)
    UNION ALL SELECT (SELECT SUM(total_transactions)=590540 AND SUM(fraud_transactions)=20663 AND SUM(non_fraud_transactions)=569877 AND COUNT(*)=COUNT(DISTINCT transaction_day_number) FROM analytics.vw_daily_fraud_summary)
    UNION ALL SELECT (SELECT SUM(total_transactions)=590540 AND SUM(fraud_transactions)=20663 AND SUM(non_fraud_transactions)=569877 AND COUNT(*)=COUNT(DISTINCT transaction_week_number) FROM analytics.vw_weekly_fraud_summary)
    UNION ALL SELECT (SELECT COUNT(*)=2 AND COUNT(*) FILTER (WHERE "isFraud" IN (0,1))=2 FROM analytics.vw_fraud_comparison)
    UNION ALL SELECT (SELECT COUNT(*)=144233 AND COUNT(*)=COUNT(DISTINCT identity_key) FROM analytics.vw_identity_risk)
    UNION ALL SELECT (SELECT COUNT(*)=COUNT(DISTINCT ("DeviceType","DeviceInfo")) FROM analytics.vw_device_risk)
    UNION ALL SELECT (SELECT COUNT(*)=COUNT(DISTINCT (card4,card6)) FROM analytics.vw_card_risk)
    UNION ALL SELECT (SELECT COUNT(*)=COUNT(DISTINCT (addr1,addr2,dist1,dist2)) FROM analytics.vw_geographic_attribute_risk)
    UNION ALL SELECT (SELECT COUNT(*)=6 AND COUNT(*)=COUNT(DISTINCT signal_name) FROM analytics.vw_risk_signal_summary)
    UNION ALL SELECT (SELECT COUNT(*)=590540 AND COUNT(DISTINCT "TransactionID")=590540 FROM analytics.vw_transaction_risk_signals)
    UNION ALL SELECT (SELECT SUM(total_amount) FROM analytics.vw_daily_fraud_summary)=(SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics) AND (SELECT SUM(total_amount) FROM analytics.vw_weekly_fraud_summary)=(SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics)
    UNION ALL SELECT NOT EXISTS (SELECT 1 FROM pg_matviews WHERE schemaname='analytics' AND matviewname LIKE 'mv_%')
)
SELECT CASE WHEN BOOL_AND(passed) THEN 'PASS' ELSE 'FAIL' END AS phase_09_final_gate FROM checks;
