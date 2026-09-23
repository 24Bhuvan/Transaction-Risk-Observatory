-- PHASE 8 - STEP 8.4 - REPRESENTATIVE WORKLOAD
-- Fixed predicates are reused unchanged by steps 8.5 and 8.9.
-- TransactionDT 8,000,000..10,000,000 is inside the observed live range
-- 86,400..15,811,131 and represents a repeatable elapsed-time slice.

SELECT 'W01' AS workload_id, 'Fraud filtering' AS purpose,
       'analytics.fact_transaction_clean' AS tables,
       '"isFraud" = 1' AS predicates,
       'none' AS join_keys,
       'count fraud transactions; candidate partial/composite fraud index' AS expected_access_path
UNION ALL SELECT 'W02', 'Transaction-time filtering', 'analytics.fact_transaction_clean',
       '"TransactionDT" BETWEEN 8000000 AND 10000000', 'none',
       'time-range scan; candidate TransactionDT index'
UNION ALL SELECT 'W03', 'Transaction amount filtering/analysis', 'analytics.fact_transaction_clean',
       '"TransactionAmt" >= 500', 'none',
       'amount threshold scan; candidate amount index evaluated but not assumed'
UNION ALL SELECT 'W04', 'Fact-to-identity join',
       'analytics.fact_transaction_clean f JOIN analytics.dim_identity_clean d',
       'f.identity_key IS NOT NULL', 'f.identity_key = d.identity_key',
       'fact-side join access plus dimension lookup'
UNION ALL SELECT 'W05', 'Fraud plus transaction time', 'analytics.fact_transaction_clean',
       '"isFraud" = 1 AND "TransactionDT" BETWEEN 8000000 AND 10000000', 'none',
       'composite (isFraud, TransactionDT) access path'
UNION ALL SELECT 'W06', 'Fraud plus identity availability', 'analytics.fact_transaction_clean',
       'identity_key IS NOT NULL AND "isFraud" = 1', 'none',
       'fraud/identity filtered access path';

-- W01
SELECT COUNT(*) AS result FROM analytics.fact_transaction_clean WHERE "isFraud" = 1;
-- W02
SELECT COUNT(*), AVG("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "TransactionDT" BETWEEN 8000000 AND 10000000;
-- W03
SELECT COUNT(*), AVG("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "TransactionAmt" >= 500;
-- W04
SELECT COUNT(*) FROM analytics.fact_transaction_clean f JOIN analytics.dim_identity_clean d ON f.identity_key = d.identity_key WHERE f.identity_key IS NOT NULL;
-- W05
SELECT COUNT(*), SUM("TransactionAmt") FROM analytics.fact_transaction_clean WHERE "isFraud" = 1 AND "TransactionDT" BETWEEN 8000000 AND 10000000;
-- W06
SELECT COUNT(*), SUM("TransactionAmt") FROM analytics.fact_transaction_clean WHERE identity_key IS NOT NULL AND "isFraud" = 1;
