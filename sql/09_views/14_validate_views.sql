-- PHASE 9 - VIEW RECONCILIATION AND GRAIN VALIDATION
SELECT 'transaction_view_rows' AS check_name, 590540::bigint AS expected_value, COUNT(*)::bigint AS actual_value, CASE WHEN COUNT(*)=590540 THEN 'PASS' ELSE 'FAIL' END AS status FROM analytics.vw_transaction_analytics
UNION ALL SELECT 'transaction_view_distinct_ids', 590540, COUNT(DISTINCT "TransactionID"), CASE WHEN COUNT(DISTINCT "TransactionID")=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_transaction_analytics
UNION ALL SELECT 'transaction_view_fraud', 20663, COUNT(*) FILTER (WHERE "isFraud"=1), CASE WHEN COUNT(*) FILTER (WHERE "isFraud"=1)=20663 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_transaction_analytics
UNION ALL SELECT 'transaction_view_amount_sum', 79738948.735, SUM("TransactionAmt"), CASE WHEN SUM("TransactionAmt")=79738948.735 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_transaction_analytics
UNION ALL SELECT 'daily_total_transactions', 590540, SUM(total_transactions), CASE WHEN SUM(total_transactions)=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_daily_fraud_summary
UNION ALL SELECT 'daily_fraud_transactions', 20663, SUM(fraud_transactions), CASE WHEN SUM(fraud_transactions)=20663 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_daily_fraud_summary
UNION ALL SELECT 'daily_non_fraud_transactions', 569877, SUM(non_fraud_transactions), CASE WHEN SUM(non_fraud_transactions)=569877 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_daily_fraud_summary
UNION ALL SELECT 'weekly_total_transactions', 590540, SUM(total_transactions), CASE WHEN SUM(total_transactions)=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_weekly_fraud_summary
UNION ALL SELECT 'weekly_fraud_transactions', 20663, SUM(fraud_transactions), CASE WHEN SUM(fraud_transactions)=20663 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_weekly_fraud_summary
UNION ALL SELECT 'weekly_non_fraud_transactions', 569877, SUM(non_fraud_transactions), CASE WHEN SUM(non_fraud_transactions)=569877 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_weekly_fraud_summary
UNION ALL SELECT 'fraud_comparison_statuses', 2, COUNT(*), CASE WHEN COUNT(*)=2 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_fraud_comparison
UNION ALL SELECT 'identity_risk_rows', 144233, COUNT(*), CASE WHEN COUNT(*)=144233 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_identity_risk
UNION ALL SELECT 'transaction_signal_rows', 590540, COUNT(*), CASE WHEN COUNT(*)=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_transaction_risk_signals
UNION ALL SELECT 'transaction_signal_distinct_ids', 590540, COUNT(DISTINCT "TransactionID"), CASE WHEN COUNT(DISTINCT "TransactionID")=590540 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_transaction_risk_signals
UNION ALL SELECT 'risk_signal_summary_rows', 6, COUNT(*), CASE WHEN COUNT(*)=6 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_risk_signal_summary
UNION ALL SELECT 'daily_internal_count_consistency', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_daily_fraud_summary WHERE fraud_transactions + non_fraud_transactions <> total_transactions
UNION ALL SELECT 'weekly_internal_count_consistency', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.vw_weekly_fraud_summary WHERE fraud_transactions + non_fraud_transactions <> total_transactions;

SELECT 'daily_amount_reconciliation' AS check_name, (SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics) AS expected_value, (SELECT SUM(total_amount) FROM analytics.vw_daily_fraud_summary) AS actual_value, CASE WHEN (SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics)=(SELECT SUM(total_amount) FROM analytics.vw_daily_fraud_summary) THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL SELECT 'weekly_amount_reconciliation', (SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics), (SELECT SUM(total_amount) FROM analytics.vw_weekly_fraud_summary), CASE WHEN (SELECT SUM("TransactionAmt") FROM analytics.vw_transaction_analytics)=(SELECT SUM(total_amount) FROM analytics.vw_weekly_fraud_summary) THEN 'PASS' ELSE 'FAIL' END;
