-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.13 — BUILD / FINALIZE CLEAN LAYER
-- ============================================================
-- Purpose:
--   Finalize the Phase 6 clean analytical layer after all
--   approved transformations and derived features have been
--   applied.
--
-- IMPORTANT:
--   - analytics.fact_transaction_clean remains 1 row = 1 transaction.
--   - analytics.dim_identity_clean remains 1 row = 1 identity record.
--   - Phase 5 tables are NOT modified.
--   - Staging tables are NOT modified.
--   - No additional business transformations are performed here.
-- ============================================================


BEGIN;


-- ============================================================
-- 1. Verify required clean tables exist
-- ============================================================

DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'analytics'
          AND table_name = 'fact_transaction_clean'
    ) THEN
        RAISE EXCEPTION
            'analytics.fact_transaction_clean does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'analytics'
          AND table_name = 'dim_identity_clean'
    ) THEN
        RAISE EXCEPTION
            'analytics.dim_identity_clean does not exist';
    END IF;

END $$;


-- ============================================================
-- 2. Verify final fact grain
-- ============================================================

DO $$
DECLARE
    v_rows BIGINT;
    v_distinct_ids BIGINT;
BEGIN

    SELECT COUNT(*), COUNT(DISTINCT "TransactionID")
    INTO v_rows, v_distinct_ids
    FROM analytics.fact_transaction_clean;

    IF v_rows <> 590540 THEN
        RAISE EXCEPTION
            'Fact row-count validation failed: expected 590540, got %',
            v_rows;
    END IF;

    IF v_distinct_ids <> 590540 THEN
        RAISE EXCEPTION
            'Transaction grain validation failed: expected 590540 distinct TransactionID values, got %',
            v_distinct_ids;
    END IF;

END $$;


-- ============================================================
-- 3. Verify final identity grain
-- ============================================================

DO $$
DECLARE
    v_rows BIGINT;
    v_distinct_ids BIGINT;
BEGIN

    SELECT COUNT(*), COUNT(DISTINCT "TransactionID")
    INTO v_rows, v_distinct_ids
    FROM analytics.dim_identity_clean;

    IF v_rows <> 144233 THEN
        RAISE EXCEPTION
            'Identity row-count validation failed: expected 144233, got %',
            v_rows;
    END IF;

    IF v_distinct_ids <> 144233 THEN
        RAISE EXCEPTION
            'Identity grain validation failed: expected 144233 distinct TransactionID values, got %',
            v_distinct_ids;
    END IF;

END $$;


-- ============================================================
-- 4. Verify identity linkage
-- ============================================================

DO $$
DECLARE
    v_linked BIGINT;
    v_unlinked BIGINT;
BEGIN

    SELECT
        COUNT(*) FILTER (WHERE identity_key IS NOT NULL),
        COUNT(*) FILTER (WHERE identity_key IS NULL)
    INTO v_linked, v_unlinked
    FROM analytics.fact_transaction_clean;

    IF v_linked <> 144233 THEN
        RAISE EXCEPTION
            'Identity-linked validation failed: expected 144233, got %',
            v_linked;
    END IF;

    IF v_unlinked <> 446307 THEN
        RAISE EXCEPTION
            'Identity-unlinked validation failed: expected 446307, got %',
            v_unlinked;
    END IF;

END $$;


-- ============================================================
-- 5. Verify fraud distribution
-- ============================================================

DO $$
DECLARE
    v_zero BIGINT;
    v_one BIGINT;
BEGIN

    SELECT
        COUNT(*) FILTER (WHERE "isFraud" = 0),
        COUNT(*) FILTER (WHERE "isFraud" = 1)
    INTO v_zero, v_one
    FROM analytics.fact_transaction_clean;

    IF v_zero <> 569877 THEN
        RAISE EXCEPTION
            'isFraud=0 validation failed: expected 569877, got %',
            v_zero;
    END IF;

    IF v_one <> 20663 THEN
        RAISE EXCEPTION
            'isFraud=1 validation failed: expected 20663, got %',
            v_one;
    END IF;

END $$;


-- ============================================================
-- 6. Verify TransactionAmt reconciliation
-- ============================================================

DO $$
DECLARE
    v_sum NUMERIC;
    v_avg NUMERIC;
BEGIN

    SELECT
        SUM("TransactionAmt"),
        AVG("TransactionAmt")
    INTO v_sum, v_avg
    FROM analytics.fact_transaction_clean;

    IF v_sum <> 79738948.735 THEN
        RAISE EXCEPTION
            'TransactionAmt SUM validation failed: expected 79738948.735, got %',
            v_sum;
    END IF;

    IF v_avg <> 135.0271763724726521 THEN
        RAISE EXCEPTION
            'TransactionAmt AVG validation failed: expected 135.0271763724726521, got %',
            v_avg;
    END IF;

END $$;


-- ============================================================
-- 7. Final clean-layer summary
-- ============================================================

SELECT
    'fact_transaction_clean' AS table_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'dim_identity_clean',
    COUNT(*),
    COUNT(DISTINCT "TransactionID")
FROM analytics.dim_identity_clean;


-- ============================================================
-- 8. Final feature presence check
-- ============================================================

SELECT
    table_name,
    column_name
FROM information_schema.columns
WHERE
    (table_schema = 'analytics'
     AND table_name = 'fact_transaction_clean'
     AND column_name IN (
         'dist2_missing_flag',
         'D7_missing_flag',
         'R_emaildomain_missing_flag',
         'card2_missing_flag',
         'card3_missing_flag',
         'card5_missing_flag',
         'card6_missing_flag',
         'card_attributes_missing_count',
         'card_attributes_partial_missing_flag',
         'transaction_day_number',
         'transaction_hour',
         'transaction_week_number',
         'transaction_amount_zero_flag',
         'transaction_amount_log',
         'identity_available_flag',
         'email_domain_missing_flag',
         'device_info_available_flag',
         'missing_attribute_count'
     ))
 OR
    (table_schema = 'analytics'
     AND table_name = 'dim_identity_clean'
     AND column_name IN (
         'deviceinfo_normalized',
         'deviceinfo_missing_flag'
     ))
ORDER BY table_name, column_name;


-- ============================================================
-- 9. Commit only after all validations pass
-- ============================================================

COMMIT;