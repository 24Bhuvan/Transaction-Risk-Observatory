-- ============================================================
-- PHASE 6 — STEP 6.15
-- Reconciliation Against Phase 5
-- ============================================================

-- Purpose:
-- Reconcile Phase 5 analytical tables against Phase 6 clean tables.
--
-- Rules:
-- 1. Unchanged fields must have zero row-level mismatches.
-- 2. Transformed fields may differ only according to documented
--    Phase 6 transformations.
-- 3. Population, keys, fraud labels, amounts, and relationships
--    must remain unchanged.
--
-- Phase 5 tables:
--   analytics.fact_transaction
--   analytics.dim_identity
--
-- Phase 6 tables:
--   analytics.fact_transaction_clean
--   analytics.dim_identity_clean
-- ============================================================


-- ============================================================
-- 1. POPULATION RECONCILIATION
-- ============================================================

SELECT
    'fact_row_count' AS check_name,
    COUNT(*) AS phase_5_count,
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
    ) AS phase_6_count,
    CASE
        WHEN COUNT(*) = (
            SELECT COUNT(*)
            FROM analytics.fact_transaction_clean
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction;


SELECT
    'identity_row_count' AS check_name,
    COUNT(*) AS phase_5_count,
    (
        SELECT COUNT(*)
        FROM analytics.dim_identity_clean
    ) AS phase_6_count,
    CASE
        WHEN COUNT(*) = (
            SELECT COUNT(*)
            FROM analytics.dim_identity_clean
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.dim_identity;


-- ============================================================
-- 2. TRANSACTIONID RECONCILIATION
-- ============================================================

SELECT
    'fact_transactionid_set_difference' AS check_name,
    (
        SELECT COUNT(*)
        FROM (
            SELECT "TransactionID"
            FROM analytics.fact_transaction

            EXCEPT

            SELECT "TransactionID"
            FROM analytics.fact_transaction_clean
        ) x
    ) AS phase_5_missing_in_clean,
    (
        SELECT COUNT(*)
        FROM (
            SELECT "TransactionID"
            FROM analytics.fact_transaction_clean

            EXCEPT

            SELECT "TransactionID"
            FROM analytics.fact_transaction
        ) x
    ) AS clean_missing_in_phase_5,
    CASE
        WHEN
            (
                SELECT COUNT(*)
                FROM (
                    SELECT "TransactionID"
                    FROM analytics.fact_transaction
                    EXCEPT
                    SELECT "TransactionID"
                    FROM analytics.fact_transaction_clean
                ) x
            ) = 0
            AND
            (
                SELECT COUNT(*)
                FROM (
                    SELECT "TransactionID"
                    FROM analytics.fact_transaction_clean
                    EXCEPT
                    SELECT "TransactionID"
                    FROM analytics.fact_transaction
                ) x
            ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status;


SELECT
    'identity_transactionid_set_difference' AS check_name,
    (
        SELECT COUNT(*)
        FROM (
            SELECT "TransactionID"
            FROM analytics.dim_identity

            EXCEPT

            SELECT "TransactionID"
            FROM analytics.dim_identity_clean
        ) x
    ) AS phase_5_missing_in_clean,
    (
        SELECT COUNT(*)
        FROM (
            SELECT "TransactionID"
            FROM analytics.dim_identity_clean

            EXCEPT

            SELECT "TransactionID"
            FROM analytics.dim_identity
        ) x
    ) AS clean_missing_in_phase_5,
    CASE
        WHEN
            (
                SELECT COUNT(*)
                FROM (
                    SELECT "TransactionID"
                    FROM analytics.dim_identity
                    EXCEPT
                    SELECT "TransactionID"
                    FROM analytics.dim_identity_clean
                ) x
            ) = 0
            AND
            (
                SELECT COUNT(*)
                FROM (
                    SELECT "TransactionID"
                    FROM analytics.dim_identity_clean
                    EXCEPT
                    SELECT "TransactionID"
                    FROM analytics.dim_identity
                ) x
            ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status;


-- ============================================================
-- 3. UNCHANGED FACT FIELDS
-- ============================================================
-- These fields must remain exactly unchanged.
--
-- transaction_key
-- identity_key
-- TransactionID
-- isFraud
-- TransactionDT
-- TransactionAmt
--
-- Reconciliation is performed row-by-row using TransactionID.
-- ============================================================

SELECT
    'unchanged_fact_fields' AS check_name,
    COUNT(*) FILTER (
        WHERE
            p.transaction_key IS DISTINCT FROM c.transaction_key
            OR p.identity_key IS DISTINCT FROM c.identity_key
            OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
            OR p."isFraud" IS DISTINCT FROM c."isFraud"
            OR p."TransactionDT" IS DISTINCT FROM c."TransactionDT"
            OR p."TransactionAmt" IS DISTINCT FROM c."TransactionAmt"
    ) AS mismatch_count,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE
                p.transaction_key IS DISTINCT FROM c.transaction_key
                OR p.identity_key IS DISTINCT FROM c.identity_key
                OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
                OR p."isFraud" IS DISTINCT FROM c."isFraud"
                OR p."TransactionDT" IS DISTINCT FROM c."TransactionDT"
                OR p."TransactionAmt" IS DISTINCT FROM c."TransactionAmt"
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
    ON p."TransactionID" = c."TransactionID";


-- ============================================================
-- 4. UNCHANGED IDENTITY FIELDS
-- ============================================================

SELECT
    'unchanged_identity_fields' AS check_name,
    COUNT(*) FILTER (
        WHERE
            p.identity_key IS DISTINCT FROM c.identity_key
            OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
    ) AS mismatch_count,
    CASE
        WHEN COUNT(*) FILTER (
            WHERE
                p.identity_key IS DISTINCT FROM c.identity_key
                OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.dim_identity p
JOIN analytics.dim_identity_clean c
    ON p."TransactionID" = c."TransactionID";


-- ============================================================
-- 5. FINANCIAL RECONCILIATION
-- ============================================================

SELECT
    'transaction_amount_reconciliation' AS check_name,

    p.row_count AS phase_5_row_count,
    c.row_count AS phase_6_row_count,

    p.amount_sum AS phase_5_amount_sum,
    c.amount_sum AS phase_6_amount_sum,

    p.amount_avg AS phase_5_amount_avg,
    c.amount_avg AS phase_6_amount_avg,

    CASE
        WHEN
            p.row_count = c.row_count
            AND p.amount_sum = c.amount_sum
            AND p.amount_avg = c.amount_avg
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
(
    SELECT
        COUNT(*) AS row_count,
        SUM("TransactionAmt") AS amount_sum,
        AVG("TransactionAmt") AS amount_avg
    FROM analytics.fact_transaction
) p
CROSS JOIN
(
    SELECT
        COUNT(*) AS row_count,
        SUM("TransactionAmt") AS amount_sum,
        AVG("TransactionAmt") AS amount_avg
    FROM analytics.fact_transaction_clean
) c;


-- ============================================================
-- 6. FRAUD LABEL RECONCILIATION
-- ============================================================

SELECT
    'fraud_distribution_reconciliation' AS check_name,

    p.fraud_0 AS phase_5_fraud_0,
    c.fraud_0 AS phase_6_fraud_0,

    p.fraud_1 AS phase_5_fraud_1,
    c.fraud_1 AS phase_6_fraud_1,

    CASE
        WHEN
            p.fraud_0 = c.fraud_0
            AND p.fraud_1 = c.fraud_1
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
(
    SELECT
        COUNT(*) FILTER (WHERE "isFraud" = 0) AS fraud_0,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_1
    FROM analytics.fact_transaction
) p
CROSS JOIN
(
    SELECT
        COUNT(*) FILTER (WHERE "isFraud" = 0) AS fraud_0,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_1
    FROM analytics.fact_transaction_clean
) c;


-- ============================================================
-- 7. IDENTITY RELATIONSHIP RECONCILIATION
-- ============================================================

SELECT
    'identity_relationship_reconciliation' AS check_name,

    p.identity_linked AS phase_5_linked,
    c.identity_linked AS phase_6_linked,

    p.identity_unlinked AS phase_5_unlinked,
    c.identity_unlinked AS phase_6_unlinked,

    CASE
        WHEN
            p.identity_linked = c.identity_linked
            AND p.identity_unlinked = c.identity_unlinked
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM
(
    SELECT
        COUNT(*) FILTER (WHERE identity_key IS NOT NULL) AS identity_linked,
        COUNT(*) FILTER (WHERE identity_key IS NULL) AS identity_unlinked
    FROM analytics.fact_transaction
) p
CROSS JOIN
(
    SELECT
        COUNT(*) FILTER (WHERE identity_key IS NOT NULL) AS identity_linked,
        COUNT(*) FILTER (WHERE identity_key IS NULL) AS identity_unlinked
    FROM analytics.fact_transaction_clean
) c;


-- ============================================================
-- 8. TRANSFORMED FACT FIELDS
-- ============================================================
-- Expected transformations:
--
-- ProductCD:
--   TRIM + blank -> NULL
--
-- card4:
--   TRIM + blank -> NULL
--
-- card6:
--   TRIM + blank -> NULL
--
-- M1-M9:
--   TRIM + blank -> NULL
--
-- Therefore compare:
--   normalized Phase 5 value
--       =
--   Phase 6 value
-- ============================================================

SELECT
    'transformed_fact_categorical_fields' AS check_name,

    COUNT(*) FILTER (
        WHERE
            NULLIF(TRIM(p."ProductCD"), '')
            IS DISTINCT FROM c."ProductCD"
            OR NULLIF(TRIM(p."card4"), '')
            IS DISTINCT FROM c."card4"
            OR NULLIF(TRIM(p."card6"), '')
            IS DISTINCT FROM c."card6"
            OR NULLIF(TRIM(p."M1"), '') IS DISTINCT FROM c."M1"
            OR NULLIF(TRIM(p."M2"), '') IS DISTINCT FROM c."M2"
            OR NULLIF(TRIM(p."M3"), '') IS DISTINCT FROM c."M3"
            OR NULLIF(TRIM(p."M4"), '') IS DISTINCT FROM c."M4"
            OR NULLIF(TRIM(p."M5"), '') IS DISTINCT FROM c."M5"
            OR NULLIF(TRIM(p."M6"), '') IS DISTINCT FROM c."M6"
            OR NULLIF(TRIM(p."M7"), '') IS DISTINCT FROM c."M7"
            OR NULLIF(TRIM(p."M8"), '') IS DISTINCT FROM c."M8"
            OR NULLIF(TRIM(p."M9"), '') IS DISTINCT FROM c."M9"
    ) AS unexpected_mismatch_count,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE
                NULLIF(TRIM(p."ProductCD"), '')
                IS DISTINCT FROM c."ProductCD"
                OR NULLIF(TRIM(p."card4"), '')
                IS DISTINCT FROM c."card4"
                OR NULLIF(TRIM(p."card6"), '')
                IS DISTINCT FROM c."card6"
                OR NULLIF(TRIM(p."M1"), '') IS DISTINCT FROM c."M1"
                OR NULLIF(TRIM(p."M2"), '') IS DISTINCT FROM c."M2"
                OR NULLIF(TRIM(p."M3"), '') IS DISTINCT FROM c."M3"
                OR NULLIF(TRIM(p."M4"), '') IS DISTINCT FROM c."M4"
                OR NULLIF(TRIM(p."M5"), '') IS DISTINCT FROM c."M5"
                OR NULLIF(TRIM(p."M6"), '') IS DISTINCT FROM c."M6"
                OR NULLIF(TRIM(p."M7"), '') IS DISTINCT FROM c."M7"
                OR NULLIF(TRIM(p."M8"), '') IS DISTINCT FROM c."M8"
                OR NULLIF(TRIM(p."M9"), '') IS DISTINCT FROM c."M9"
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM analytics.fact_transaction p
JOIN analytics.fact_transaction_clean c
    ON p."TransactionID" = c."TransactionID";


-- ============================================================
-- 9. DEVICE FIELD RECONCILIATION
-- ============================================================
-- DeviceType:
--   TRIM + blank -> NULL
--
-- DeviceInfo:
--   TRIM + whitespace normalization + blank -> NULL
-- ============================================================

SELECT
    'transformed_identity_device_fields' AS check_name,

    COUNT(*) FILTER (
        WHERE
            NULLIF(TRIM(p."DeviceType"), '')
            IS DISTINCT FROM c."DeviceType"
            OR
            NULLIF(
                REGEXP_REPLACE(
                    TRIM(p."DeviceInfo"),
                    '[[:space:]]+',
                    ' ',
                    'g'
                ),
                ''
            )
            IS DISTINCT FROM c."DeviceInfo"
    ) AS unexpected_mismatch_count,

    CASE
        WHEN COUNT(*) FILTER (
            WHERE
                NULLIF(TRIM(p."DeviceType"), '')
                IS DISTINCT FROM c."DeviceType"
                OR
                NULLIF(
                    REGEXP_REPLACE(
                        TRIM(p."DeviceInfo"),
                        '[[:space:]]+',
                        ' ',
                        'g'
                    ),
                    ''
                )
                IS DISTINCT FROM c."DeviceInfo"
        ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM analytics.dim_identity p
JOIN analytics.dim_identity_clean c
    ON p."TransactionID" = c."TransactionID";


-- ============================================================
-- 10. EMAIL FIELD RECONCILIATION
-- ============================================================
-- Email fields are reconciled using whitespace-trimmed values.
-- This does NOT apply semantic domain mapping.
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


-- ============================================================
-- 11. FINAL RECONCILIATION GATE
-- ============================================================

WITH checks AS
(
    SELECT
        COUNT(*) FILTER (
            WHERE
                p.transaction_key IS DISTINCT FROM c.transaction_key
                OR p.identity_key IS DISTINCT FROM c.identity_key
                OR p."TransactionID" IS DISTINCT FROM c."TransactionID"
                OR p."isFraud" IS DISTINCT FROM c."isFraud"
                OR p."TransactionDT" IS DISTINCT FROM c."TransactionDT"
                OR p."TransactionAmt" IS DISTINCT FROM c."TransactionAmt"
        ) AS unchanged_fact_mismatches
    FROM analytics.fact_transaction p
    JOIN analytics.fact_transaction_clean c
        ON p."TransactionID" = c."TransactionID"
),

transformed_fact AS
(
    SELECT
        COUNT(*) FILTER (
            WHERE
                NULLIF(TRIM(p."ProductCD"), '') IS DISTINCT FROM c."ProductCD"
                OR NULLIF(TRIM(p."card4"), '') IS DISTINCT FROM c."card4"
                OR NULLIF(TRIM(p."card6"), '') IS DISTINCT FROM c."card6"
                OR NULLIF(TRIM(p."M1"), '') IS DISTINCT FROM c."M1"
                OR NULLIF(TRIM(p."M2"), '') IS DISTINCT FROM c."M2"
                OR NULLIF(TRIM(p."M3"), '') IS DISTINCT FROM c."M3"
                OR NULLIF(TRIM(p."M4"), '') IS DISTINCT FROM c."M4"
                OR NULLIF(TRIM(p."M5"), '') IS DISTINCT FROM c."M5"
                OR NULLIF(TRIM(p."M6"), '') IS DISTINCT FROM c."M6"
                OR NULLIF(TRIM(p."M7"), '') IS DISTINCT FROM c."M7"
                OR NULLIF(TRIM(p."M8"), '') IS DISTINCT FROM c."M8"
                OR NULLIF(TRIM(p."M9"), '') IS DISTINCT FROM c."M9"
        ) AS categorical_mismatches
    FROM analytics.fact_transaction p
    JOIN analytics.fact_transaction_clean c
        ON p."TransactionID" = c."TransactionID"
),

transformed_identity AS
(
    SELECT
        COUNT(*) FILTER (
            WHERE
                NULLIF(TRIM(p."DeviceType"), '')
                IS DISTINCT FROM c."DeviceType"
                OR
                NULLIF(
                    REGEXP_REPLACE(
                        TRIM(p."DeviceInfo"),
                        '[[:space:]]+',
                        ' ',
                        'g'
                    ),
                    ''
                )
                IS DISTINCT FROM c."DeviceInfo"
        ) AS device_mismatches
    FROM analytics.dim_identity p
    JOIN analytics.dim_identity_clean c
        ON p."TransactionID" = c."TransactionID"
)

SELECT
    'phase_6_reconciliation_status' AS check_name,
    unchanged_fact_mismatches,
    categorical_mismatches,
    device_mismatches,
    CASE
        WHEN
            unchanged_fact_mismatches = 0
            AND categorical_mismatches = 0
            AND device_mismatches = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM checks
CROSS JOIN transformed_fact
CROSS JOIN transformed_identity;