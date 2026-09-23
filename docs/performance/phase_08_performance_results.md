# Phase 8 - Performance Results

## Measurement Method

PostgreSQL `EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)` was used for identical W01-W06 queries before and after the selected indexes. `TIMING OFF` reduces per-node timing overhead; total execution time and buffer activity remain reported by PostgreSQL. Results are workload evidence, not a universal benchmark.

## BEFORE Evidence

| Workload | Plan | Execution time | Shared reads | Actual rows |
|---|---|---:|---:|---:|
| W01 | Sequential scan | 19,752.361 ms | 1,147,458 | 20,663 |
| W02 | Sequential scan | 20,130.136 ms | 1,147,458 | 75,527 |
| W03 | Sequential scan | 20,123.351 ms | 1,147,458 | 24,324 |
| W04 | Hash join with sequential scans | 21,633.889 ms | 1,166,917 | 144,233 |
| W05 | Sequential scan | 21,074.952 ms | 1,147,458 | 2,806 |
| W06 | Sequential scan | 20,864.217 ms | 1,147,458 | 11,318 |

## AFTER Evidence

The exact same workload returned the following live PostgreSQL plans:

| Workload | Plan | Execution time | Buffer behavior | Actual rows |
|---|---|---:|---|---:|
| W01 | Index Only Scan on partial fraud/time index | 6.192 ms | 13,638 hit; 81 read; 0 heap fetches | 20,663 |
| W02 | Bitmap Heap Scan plus Bitmap Index Scan on TransactionDT | 692.512 ms | 3 hit; 33,141 read | 75,527 |
| W03 | Sequential scan | 20,600.453 ms | 42 hit; 1,147,416 read | 24,324 |
| W04 | Hash join with sequential scans | 21,323.775 ms | 1,166,917 read | 144,233 |
| W05 | Index Scan on partial fraud/time index | 388.803 ms | 202 hit; 2,434 read | 2,806 |
| W06 | Index Scan on partial fraud/time index, then identity filter | 2,652.829 ms | 3,494 hit; 15,738 read | 11,318 |

## Comparison

The BEFORE evidence established high-cost sequential scans on the wide clean fact. W01, W02, W05, and W06 changed to index-backed access with large reductions in execution time and/or scanned buffers. W03 remained a sequential scan and was 477.102 ms slower in this run, so no amount index was created. W04 remained a hash join with unchanged buffer volume and only a 310.114 ms run-to-run difference, so no fact identity index was created.

| Query | Before | After | Change | Plan change | Decision |
|---|---:|---:|---:|---|---|
| W01 | 19,752.361 ms | 6.192 ms | -19,746.169 ms | Seq Scan to Index Only Scan | KEEP partial composite |
| W02 | 20,130.136 ms | 692.512 ms | -19,437.624 ms | Seq Scan to Bitmap Heap/Index Scan | KEEP TransactionDT |
| W03 | 20,123.351 ms | 20,600.453 ms | +477.102 ms | Seq Scan unchanged | NO MATERIAL BENEFIT |
| W04 | 21,633.889 ms | 21,323.775 ms | -310.114 ms | Hash Join unchanged | NO MATERIAL BENEFIT |
| W05 | 21,074.952 ms | 388.803 ms | -20,686.149 ms | Seq Scan to Index Scan | KEEP partial composite |
| W06 | 20,864.217 ms | 2,652.829 ms | -18,211.388 ms | Seq Scan to Index Scan | KEEP partial fraud index |

## Limitations

Execution timing is sensitive to Windows filesystem cache, concurrent database activity, and server state. A single captured run per workload is evidence for this phase, not a production SLA or Phase 13 benchmark.
