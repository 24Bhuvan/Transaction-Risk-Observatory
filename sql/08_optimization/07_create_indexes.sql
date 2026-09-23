-- PHASE 8 - STEP 8.7 - IMPLEMENT JUSTIFIED INDEXES
-- Read-only workload evidence justified exactly two indexes.

-- Purpose: accelerate W02 TransactionDT range filtering.
-- Target workload: W02.
-- Expected access pattern: btree range scan on TransactionDT.
-- Existing indexes considered: clean fact table had no indexes; Phase 5 key indexes do not cover this column.
-- Evidence: W02 BEFORE plan used a sequential scan over 1,147,458 blocks.
CREATE INDEX IF NOT EXISTS idx_fact_transaction_clean_transactiondt
    ON analytics.fact_transaction_clean ("TransactionDT");

-- Purpose: accelerate selective fraud filtering and fraud-plus-time analysis.
-- Target workloads: W01 and W05; W06 also benefits from the fraud leading key.
-- Expected access pattern: partial btree equality/range scan over fraud rows only.
-- Existing indexes considered: no clean-table index existed; standalone isFraud was rejected as redundant.
-- Evidence: fraud is 3.499% of rows and W05 returns 2,806 rows; the partial composite avoids indexing non-fraud rows.
CREATE INDEX IF NOT EXISTS idx_fact_transaction_clean_fraud_transactiondt
    ON analytics.fact_transaction_clean ("isFraud", "TransactionDT")
    WHERE "isFraud" = 1;

SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'analytics'
  AND tablename IN ('fact_transaction_clean', 'dim_identity_clean')
ORDER BY tablename, indexname;
