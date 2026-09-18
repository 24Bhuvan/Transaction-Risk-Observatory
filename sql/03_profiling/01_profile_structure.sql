-- ============================================================
-- Phase 3: Data Profiling & Quality Assessment
-- Step 3.1: Establish Profiling Baseline
-- ============================================================

-- 1. Database / schema / user
SELECT
    current_database() AS database_name,
    current_schema() AS current_schema,
    current_user AS database_user;


-- 2. Confirm required staging tables
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
ORDER BY table_name;


-- 3. Row counts
SELECT
    'staging.raw_transactions' AS table_name,
    COUNT(*) AS row_count
FROM staging.raw_transactions

UNION ALL

SELECT
    'staging.raw_identity' AS table_name,
    COUNT(*) AS row_count
FROM staging.raw_identity;


-- 4. Column counts
SELECT
    table_schema,
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
GROUP BY table_schema, table_name
ORDER BY table_name;


-- 5. Column structure
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
ORDER BY table_name, ordinal_position;