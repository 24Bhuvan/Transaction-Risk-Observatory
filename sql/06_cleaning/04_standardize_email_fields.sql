-- ============================================================
-- PHASE 6 — STEP 6.5
-- Standardize Email Fields
-- ============================================================

-- Purpose:
-- Standardize email-domain fields in the clean analytical layer.
--
-- Rules:
-- 1. Trim leading/trailing whitespace.
-- 2. Convert blank strings to NULL.
-- 3. Preserve valid domain values.
-- 4. Preserve existing NULL values.
-- 5. Do not perform semantic domain mapping.
-- 6. Do not modify Phase 5 analytical tables.
-- ============================================================


-- ============================================================
-- 1. STANDARDIZE P_emaildomain
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET "P_emaildomain" =
    NULLIF(TRIM("P_emaildomain"), '');


-- ============================================================
-- 2. STANDARDIZE R_emaildomain
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET "R_emaildomain" =
    NULLIF(TRIM("R_emaildomain"), '');


-- ============================================================
-- 3. VALIDATE EMAIL STANDARDIZATION
-- ============================================================

SELECT
    'P_emaildomain_blank_check' AS check_name,
    COUNT(*) AS invalid_blank_rows,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
WHERE "P_emaildomain" = '';


SELECT
    'R_emaildomain_blank_check' AS check_name,
    COUNT(*) AS invalid_blank_rows,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
WHERE "R_emaildomain" = '';


-- ============================================================
-- 4. VALIDATE TRANSFORMATION AGAINST PHASE 5
-- ============================================================
-- Expected transformation:
--
-- NULLIF(TRIM(Phase_5_value), '') = Phase_6_value
-- ============================================================

SELECT
    'email_domain_reconciliation' AS check_name,

    COUNT(*) FILTER (
        WHERE
            NULLIF(TRIM(p."P_emaildomain"), '')
            IS DISTINCT FROM c."P_emaildomain"
            OR
            NULLIF(TRIM(p."R_emaildomain"), '')
            IS DISTINCT FROM c."R_emaildomain"
    ) AS unexpected_mismatch_count,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE
                NULLIF(TRIM(p."P_emaildomain"), '')
                IS DISTINCT FROM c."P_emaildomain"
                OR
                NULLIF(TRIM(p."R_emaildomain"), '')
                IS DISTINCT FROM c."R_emaildomain"
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
    ON p."TransactionID" = c."TransactionID";