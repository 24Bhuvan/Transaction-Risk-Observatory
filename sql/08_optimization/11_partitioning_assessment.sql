-- PHASE 8 - STEP 8.11 - PARTITIONING ASSESSMENT

WITH distribution AS (
    SELECT MIN("TransactionDT") AS min_dt,
           MAX("TransactionDT") AS max_dt,
           COUNT(*) AS rows,
           COUNT(*) FILTER (WHERE "TransactionDT" BETWEEN 8000000 AND 10000000) AS workload_slice_rows
    FROM analytics.fact_transaction_clean
)
SELECT rows, min_dt, max_dt, workload_slice_rows,
       ROUND(workload_slice_rows * 100.0 / rows, 4) AS workload_slice_pct,
       'PARTITIONING NOT JUSTIFIED' AS decision,
       '590,540-row table; one observed time slice is 12.79%; partitioning would add key/maintenance/query complexity without demonstrated pruning evidence.' AS rationale
FROM distribution;
