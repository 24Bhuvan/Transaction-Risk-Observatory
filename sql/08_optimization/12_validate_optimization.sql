-- PHASE 8 - STEP 8.12 - OPTIMIZATION SAFETY VALIDATION

SELECT 'fact_row_count' AS check_name, 590540::bigint AS expected_value, COUNT(*)::bigint AS actual_value, CASE WHEN COUNT(*)=590540 THEN 'PASS' ELSE 'FAIL' END AS status FROM analytics.fact_transaction_clean
UNION ALL SELECT 'identity_row_count', 144233, COUNT(*), CASE WHEN COUNT(*)=144233 THEN 'PASS' ELSE 'FAIL' END FROM analytics.dim_identity_clean
UNION ALL SELECT 'fact_transactionid_uniqueness', 0, COUNT(*)-COUNT(DISTINCT "TransactionID"), CASE WHEN COUNT(*)=COUNT(DISTINCT "TransactionID") THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'fact_transaction_key_uniqueness', 0, COUNT(*)-COUNT(DISTINCT transaction_key), CASE WHEN COUNT(*)=COUNT(DISTINCT transaction_key) THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'identity_key_uniqueness', 0, COUNT(*)-COUNT(DISTINCT identity_key), CASE WHEN COUNT(*)=COUNT(DISTINCT identity_key) THEN 'PASS' ELSE 'FAIL' END FROM analytics.dim_identity_clean
UNION ALL SELECT 'fraud_zero_count', 569877, COUNT(*) FILTER (WHERE "isFraud"=0), CASE WHEN COUNT(*) FILTER (WHERE "isFraud"=0)=569877 THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'fraud_one_count', 20663, COUNT(*) FILTER (WHERE "isFraud"=1), CASE WHEN COUNT(*) FILTER (WHERE "isFraud"=1)=20663 THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'transaction_amount_sum', 79738948.735, SUM("TransactionAmt"), CASE WHEN SUM("TransactionAmt")=79738948.735 THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'transaction_amount_avg', 135.0271763724726521, AVG("TransactionAmt"), CASE WHEN ABS(AVG("TransactionAmt")-135.0271763724726521)<0.000000000001 THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean
UNION ALL SELECT 'identity_relationship', 0, COUNT(*), CASE WHEN COUNT(*)=0 THEN 'PASS' ELSE 'FAIL' END FROM analytics.fact_transaction_clean f LEFT JOIN analytics.dim_identity_clean d ON f.identity_key=d.identity_key WHERE f.identity_key IS NOT NULL AND d.identity_key IS NULL;
