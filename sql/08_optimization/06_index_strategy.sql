-- PHASE 8 - STEP 8.6 - INDEX STRATEGY
-- Decisions are based on the live BEFORE plans and selectivity.

SELECT 'transaction_key / TransactionID / identity_key on Phase 5 tables' AS candidate,
       'ALREADY COVERED' AS decision,
       'Primary-key and unique-constraint indexes already exist on Phase 5 tables.' AS evidence
UNION ALL SELECT 'fact_transaction_clean TransactionDT', 'JUSTIFIED',
       'W02 scans 1,147,458 blocks and returns 75,527 rows from 590,540; a range index targets repeated time filtering.'
UNION ALL SELECT 'fact_transaction_clean (isFraud, TransactionDT) WHERE isFraud = 1', 'JUSTIFIED',
       'W01 has 3.499% fraud selectivity and W05 returns 2,806 rows; one partial composite supports both equality and time-range predicates.'
UNION ALL SELECT 'fact_transaction_clean isFraud alone', 'NO MATERIAL BENEFIT',
       'Covered by the selected partial composite index; a second standalone fraud index would duplicate its leading equality path.'
UNION ALL SELECT 'fact_transaction_clean TransactionAmt', 'NOT JUSTIFIED',
       'W03 is a threshold aggregate; no existing workload evidence requires a dedicated amount index and it would add maintenance/storage cost.'
UNION ALL SELECT 'fact_transaction_clean identity_key', 'NO MATERIAL BENEFIT',
       'W04 returns all 144,233 linked rows and uses a hash join; the fact-side index is not justified for this broad join.'
UNION ALL SELECT 'fact_transaction_clean (identity_key, isFraud)', 'NO MATERIAL BENEFIT',
       'W06 can filter the selected fraud partial index then apply identity availability; no second composite is justified without a repeated selective workload.';
