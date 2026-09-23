# Phase 8 - Indexing & Query Optimization Strategy

## Objective

Establish an evidence-backed physical optimization strategy for the live Transaction Risk Observatory analytical layer without changing analytical meaning or entering Phase 13 broad tuning.

## Live Context

- PostgreSQL 18.4
- Database: `transaction_risk_observatory`
- Schemas: `analytics`, `staging`
- Clean fact: `analytics.fact_transaction_clean`
- Clean identity: `analytics.dim_identity_clean`
- Verified clean populations: 590,540 fact rows and 144,233 identity rows

## Baseline and Existing Design

Phase 5 had constraint-backed indexes on `fact_transaction.transaction_key`, `fact_transaction.TransactionID`, `dim_identity.identity_key`, and `dim_identity.TransactionID`. The Phase 6 clean tables initially had no indexes. The baseline script records table/index sizes, counts, statistics timestamps, and actual populations.

The clean fact is wide and physically large (about 8.8 GiB table size in the live baseline), so sequential plans read about 1.15 million shared blocks for broad scans. The live planner estimate before refresh was stale for the clean fact; Step 8.3 refreshed statistics and recorded the post-refresh timestamps.

## Workload

W01 fraud filtering; W02 TransactionDT range; W03 amount threshold; W04 fact-to-identity join; W05 fraud plus time; W06 fraud plus identity. Exact SQL is in `04_define_workload.sql` and is reused unchanged by the before/after plan scripts.

## Candidate Decisions

- Phase 5 key indexes: **ALREADY COVERED**.
- Clean fact `TransactionDT`: **JUSTIFIED** for repeated time-range workload W02.
- Partial clean fact `(isFraud, TransactionDT) WHERE isFraud = 1`: **JUSTIFIED** for selective W01/W05 and useful for W06.
- Standalone clean fact `isFraud`: **NO MATERIAL BENEFIT**, because the selected partial composite has the same leading equality key.
- Clean fact `TransactionAmt`: **NOT JUSTIFIED** from the single threshold workload; no dedicated index was created.
- Clean fact `identity_key`: **NO MATERIAL BENEFIT** for the broad W04 hash join returning all 144,233 linked rows.
- Clean fact `(identity_key, isFraud)`: **NO MATERIAL BENEFIT** without a repeated workload requiring another composite path.

## Partitioning

Partitioning was assessed on actual `TransactionDT` range and workload slice distribution. The decision is **PARTITIONING NOT JUSTIFIED** for the current 590,540-row reference volume: the measured slice is broad enough that pruning benefit is not established, while partitioning would add key, maintenance, and query complexity.

## Safety

Step 8.12 rechecks population, uniqueness, fraud counts, financial aggregates, and identity referential integrity after indexing. Indexes change access paths only; they do not change analytical rows or values.

## Phase Boundary

Phase 8 establishes a small, evidence-backed physical design. It does not build views, KPIs, monitoring, models, or broad Phase 13 tuning.
