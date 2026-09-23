-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.4 — STANDARDIZE CATEGORICAL / TEXT FIELDS
-- ============================================================
-- Purpose:
--   Apply only deterministic formatting normalization to
--   categorical/text fields based on actual Phase 6 inspection.
--
-- IMPORTANT:
--   Phase 5 tables are NOT modified.
--   Staging tables are NOT modified.
--
-- Step 6.4 rules:
--   - Preserve NULL values.
--   - Convert blank/whitespace-only categorical strings to NULL.
--   - Trim leading/trailing whitespace.
--   - Normalize repeated whitespace in DeviceInfo.
--   - Do not invent semantic mappings.
--   - Do not collapse rare categories.
--   - Do not modify email domains here.
--
-- Email domains are handled in Step 6.5.
-- ============================================================


-- ============================================================
-- 1. ProductCD
-- ============================================================
-- Inspection showed five valid source categories:
-- W, C, R, H, S.
--
-- No case transformation or semantic mapping is required.
-- Only trim and convert blank strings to NULL.

UPDATE analytics.fact_transaction_clean
SET "ProductCD" = NULLIF(TRIM("ProductCD"), '');


-- ============================================================
-- 2. card4
-- ============================================================
-- Observed categories:
-- visa
-- mastercard
-- american express
-- discover
-- blank
--
-- Existing category values are already consistently lowercase.
-- Therefore no LOWER() transformation is required.
--
-- Blank/whitespace-only values are treated as missing.

UPDATE analytics.fact_transaction_clean
SET "card4" = NULLIF(TRIM("card4"), '');


-- ============================================================
-- 3. card6
-- ============================================================
-- Observed categories:
-- debit
-- credit
-- debit or credit
-- charge card
-- blank
--
-- Preserve all observed categories.
-- Do not collapse rare categories.
--
-- Blank/whitespace-only values become NULL.

UPDATE analytics.fact_transaction_clean
SET "card6" = NULLIF(TRIM("card6"), '');


-- ============================================================
-- 4. M1-M9
-- ============================================================
-- Observed values include:
-- T, F, M0, M1, M2 and NULL/blank values.
--
-- Values are already consistently represented.
-- No case conversion is required.
--
-- Blank/whitespace-only values become NULL.

UPDATE analytics.fact_transaction_clean
SET
    "M1" = NULLIF(TRIM("M1"), ''),
    "M2" = NULLIF(TRIM("M2"), ''),
    "M3" = NULLIF(TRIM("M3"), ''),
    "M4" = NULLIF(TRIM("M4"), ''),
    "M5" = NULLIF(TRIM("M5"), ''),
    "M6" = NULLIF(TRIM("M6"), ''),
    "M7" = NULLIF(TRIM("M7"), ''),
    "M8" = NULLIF(TRIM("M8"), ''),
    "M9" = NULLIF(TRIM("M9"), '');


-- ============================================================
-- 5. DeviceType
-- ============================================================
-- Observed categories:
-- desktop
-- mobile
-- blank
--
-- Existing categories are already consistently lowercase.
-- Do not map DeviceType to unsupported concepts such as
-- operating system or hardware class.
--
-- Blank/whitespace-only values become NULL.

UPDATE analytics.dim_identity_clean
SET "DeviceType" = NULLIF(TRIM("DeviceType"), '');


-- ============================================================
-- 6. DeviceInfo
-- ============================================================
-- DeviceInfo is heterogeneous and semantically sensitive.
--
-- Only deterministic formatting is applied:
--   1. Trim leading/trailing whitespace.
--   2. Collapse repeated whitespace to one space.
--
-- Do NOT:
--   - lowercase all values
--   - classify operating systems
--   - classify browsers
--   - extract unsupported device categories
--   - collapse rare values
--
-- NULL remains NULL.

UPDATE analytics.dim_identity_clean
SET "DeviceInfo" = NULLIF(
    REGEXP_REPLACE(
        TRIM("DeviceInfo"),
        '[[:space:]]+',
        ' ',
        'g'
    ),
    ''
);


-- ============================================================
-- 7. VALIDATION — ROW COUNTS
-- ============================================================

SELECT
    'fact_transaction_clean' AS table_name,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'dim_identity_clean',
    COUNT(*)
FROM analytics.dim_identity_clean;


-- ============================================================
-- 8. VALIDATION — ORIGINAL NULL PRESERVATION
-- ============================================================
-- NULLs already present in Phase 5 must remain NULL.
--
-- Additional NULLs are expected only where the source contained
-- blank/whitespace-only strings that are explicitly standardized
-- as missing values.

SELECT
    'ProductCD' AS column_name,
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "ProductCD" IS NULL
    ) AS phase5_nulls,
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "ProductCD" IS NULL
    ) AS clean_nulls

UNION ALL

SELECT
    'card4',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "card4" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "card4" IS NULL
    )

UNION ALL

SELECT
    'card6',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "card6" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "card6" IS NULL
    )

UNION ALL

SELECT
    'M1',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M1" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M1" IS NULL
    )

UNION ALL

SELECT
    'M2',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M2" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M2" IS NULL
    )

UNION ALL

SELECT
    'M3',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M3" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M3" IS NULL
    )

UNION ALL

SELECT
    'M4',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M4" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M4" IS NULL
    )

UNION ALL

SELECT
    'M5',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M5" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M5" IS NULL
    )

UNION ALL

SELECT
    'M6',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M6" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M6" IS NULL
    )

UNION ALL

SELECT
    'M7',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M7" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M7" IS NULL
    )

UNION ALL

SELECT
    'M8',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M8" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M8" IS NULL
    )

UNION ALL

SELECT
    'M9',
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction
        WHERE "M9" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.fact_transaction_clean
        WHERE "M9" IS NULL
    )

UNION ALL

SELECT
    'DeviceType',
    (
        SELECT COUNT(*)
        FROM analytics.dim_identity
        WHERE "DeviceType" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.dim_identity_clean
        WHERE "DeviceType" IS NULL
    )

UNION ALL

SELECT
    'DeviceInfo',
    (
        SELECT COUNT(*)
        FROM analytics.dim_identity
        WHERE "DeviceInfo" IS NULL
    ),
    (
        SELECT COUNT(*)
        FROM analytics.dim_identity_clean
        WHERE "DeviceInfo" IS NULL
    );


-- ============================================================
-- 9. VALIDATION — NO BLANK STRINGS REMAIN
-- ============================================================

SELECT
    'ProductCD' AS column_name,
    COUNT(*) AS blank_count
FROM analytics.fact_transaction_clean
WHERE "ProductCD" IS NOT NULL
  AND TRIM("ProductCD") = ''

UNION ALL

SELECT
    'card4',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card4" IS NOT NULL
  AND TRIM("card4") = ''

UNION ALL

SELECT
    'card6',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "card6" IS NOT NULL
  AND TRIM("card6") = ''

UNION ALL

SELECT
    'M1',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M1" IS NOT NULL
  AND TRIM("M1") = ''

UNION ALL

SELECT
    'M2',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M2" IS NOT NULL
  AND TRIM("M2") = ''

UNION ALL

SELECT
    'M3',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M3" IS NOT NULL
  AND TRIM("M3") = ''

UNION ALL

SELECT
    'M4',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M4" IS NOT NULL
  AND TRIM("M4") = ''

UNION ALL

SELECT
    'M5',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M5" IS NOT NULL
  AND TRIM("M5") = ''

UNION ALL

SELECT
    'M6',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M6" IS NOT NULL
  AND TRIM("M6") = ''

UNION ALL

SELECT
    'M7',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M7" IS NOT NULL
  AND TRIM("M7") = ''

UNION ALL

SELECT
    'M8',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M8" IS NOT NULL
  AND TRIM("M8") = ''

UNION ALL

SELECT
    'M9',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "M9" IS NOT NULL
  AND TRIM("M9") = ''

UNION ALL

SELECT
    'DeviceType',
    COUNT(*)
FROM analytics.dim_identity_clean
WHERE "DeviceType" IS NOT NULL
  AND TRIM("DeviceType") = ''

UNION ALL

SELECT
    'DeviceInfo',
    COUNT(*)
FROM analytics.dim_identity_clean
WHERE "DeviceInfo" IS NOT NULL
  AND TRIM("DeviceInfo") = '';


-- ============================================================
-- 10. VALIDATION — CORE PHASE 5 INVARIANTS
-- ============================================================

SELECT
    'fact_rows' AS metric,
    COUNT(*) AS value
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'distinct_transaction_ids',
    COUNT(DISTINCT "TransactionID")
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_id_duplicates',
    COUNT(*) - COUNT(DISTINCT "TransactionID")
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_key_duplicates',
    COUNT(*) - COUNT(DISTINCT "transaction_key")
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'identity_linked',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "identity_key" IS NOT NULL

UNION ALL

SELECT
    'identity_unlinked',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "identity_key" IS NULL

UNION ALL

SELECT
    'fraud_zero',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "isFraud" = 0

UNION ALL

SELECT
    'fraud_one',
    COUNT(*)
FROM analytics.fact_transaction_clean
WHERE "isFraud" = 1

UNION ALL

SELECT
    'transaction_amount_sum',
    SUM("TransactionAmt")
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'transaction_amount_average',
    AVG("TransactionAmt")
FROM analytics.fact_transaction_clean;


-- ============================================================
-- END OF STEP 6.4
-- ============================================================