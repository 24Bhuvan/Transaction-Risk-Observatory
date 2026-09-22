-- ============================================================
-- Phase 5 — Step 5.27
-- Complete Field Mapping Reconciliation
--
-- Purpose:
-- Prove that every source field has a corresponding target
-- field and that the Phase 5 ETL preserved the mapped fields.
--
-- Source:
--   staging.raw_transactions
--   staging.raw_identity
--
-- Target:
--   analytics.fact_transaction
--   analytics.dim_identity
-- ============================================================


-- ============================================================
-- CHECK 1 — Transaction field mapping
-- Every source transaction field must exist in the fact table.
-- transaction_key and identity_key are ETL-generated/mapped
-- target fields and are therefore excluded from source mapping.
-- ============================================================

SELECT
    COUNT(*) AS source_transaction_fields,
    COUNT(*) FILTER (
        WHERE t.column_name IS NOT NULL
    ) AS mapped_transaction_fields,
    COUNT(*) FILTER (
        WHERE t.column_name IS NULL
    ) AS unmapped_transaction_fields
FROM information_schema.columns s
LEFT JOIN information_schema.columns t
    ON t.table_schema = 'analytics'
   AND t.table_name = 'fact_transaction'
   AND t.column_name = s.column_name
WHERE s.table_schema = 'staging'
  AND s.table_name = 'raw_transactions';


-- ============================================================
-- CHECK 2 — Identity field mapping
-- Every source identity field must exist in the dimension.
-- identity_key is target-generated and excluded from source
-- field mapping.
-- ============================================================

SELECT
    COUNT(*) AS source_identity_fields,
    COUNT(*) FILTER (
        WHERE t.column_name IS NOT NULL
    ) AS mapped_identity_fields,
    COUNT(*) FILTER (
        WHERE t.column_name IS NULL
    ) AS unmapped_identity_fields
FROM information_schema.columns s
LEFT JOIN information_schema.columns t
    ON t.table_schema = 'analytics'
   AND t.table_name = 'dim_identity'
   AND t.column_name = s.column_name
WHERE s.table_schema = 'staging'
  AND s.table_name = 'raw_identity';


-- ============================================================
-- CHECK 3 — Transaction fields missing from target
-- Expected: 0 rows
-- ============================================================

SELECT
    s.column_name AS missing_fact_column
FROM information_schema.columns s
LEFT JOIN information_schema.columns t
    ON t.table_schema = 'analytics'
   AND t.table_name = 'fact_transaction'
   AND t.column_name = s.column_name
WHERE s.table_schema = 'staging'
  AND s.table_name = 'raw_transactions'
  AND t.column_name IS NULL
ORDER BY s.ordinal_position;


-- ============================================================
-- CHECK 4 — Identity fields missing from target
-- Expected: 0 rows
-- ============================================================

SELECT
    s.column_name AS missing_dimension_column
FROM information_schema.columns s
LEFT JOIN information_schema.columns t
    ON t.table_schema = 'analytics'
   AND t.table_name = 'dim_identity'
   AND t.column_name = s.column_name
WHERE s.table_schema = 'staging'
  AND s.table_name = 'raw_identity'
  AND t.column_name IS NULL
ORDER BY s.ordinal_position;


-- ============================================================
-- CHECK 5 — Transaction data-level reconciliation
--
-- Metadata proves column existence.
-- This check proves the actual mapped values match for
-- representative transaction fields.
-- ============================================================

SELECT
    COUNT(*) AS compared_rows,

    COUNT(*) FILTER (
        WHERE s."TransactionID" IS DISTINCT FROM f."TransactionID"
    ) AS transactionid_mismatches,

    COUNT(*) FILTER (
        WHERE s."isFraud" IS DISTINCT FROM f."isFraud"
    ) AS isfraud_mismatches,

    COUNT(*) FILTER (
        WHERE s."TransactionDT" IS DISTINCT FROM f."TransactionDT"
    ) AS transactiondt_mismatches,

    COUNT(*) FILTER (
        WHERE s."TransactionAmt" IS DISTINCT FROM f."TransactionAmt"
    ) AS transactionamt_mismatches,

    COUNT(*) FILTER (
        WHERE s."ProductCD" IS DISTINCT FROM f."ProductCD"
    ) AS productcd_mismatches

FROM staging.raw_transactions s
JOIN analytics.fact_transaction f
    ON s."TransactionID" = f."TransactionID";


-- ============================================================
-- CHECK 6 — Identity data-level reconciliation
--
-- Compare the identity source against the dimension using
-- TransactionID as the natural/source identifier.
-- ============================================================

SELECT
    COUNT(*) AS compared_rows,

    COUNT(*) FILTER (
        WHERE s."DeviceType" IS DISTINCT FROM d."DeviceType"
    ) AS devicetype_mismatches,

    COUNT(*) FILTER (
        WHERE s."DeviceInfo" IS DISTINCT FROM d."DeviceInfo"
    ) AS deviceinfo_mismatches

FROM staging.raw_identity s
JOIN analytics.dim_identity d
    ON s."TransactionID" = d."TransactionID";


-- ============================================================
-- CHECK 7 — Required target-only ETL fields
-- ============================================================

SELECT
    column_name,
    is_identity,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name = 'fact_transaction'
  AND column_name IN ('transaction_key', 'identity_key')
ORDER BY ordinal_position;


-- ============================================================
-- CHECK 8 — Identity surrogate key population
-- ============================================================

SELECT
    COUNT(*) AS total_identity_rows,
    COUNT(identity_key) AS populated_identity_keys,
    COUNT(DISTINCT identity_key) AS distinct_identity_keys
FROM analytics.dim_identity;


-- ============================================================
-- CHECK 9 — Fact surrogate key population
-- ============================================================

SELECT
    COUNT(*) AS total_fact_rows,
    COUNT(transaction_key) AS populated_transaction_keys,
    COUNT(DISTINCT transaction_key) AS distinct_transaction_keys
FROM analytics.fact_transaction;    