-- ============================================================
-- Phase 3: Data Profiling & Quality Assessment
-- Step 3.2: Profile Column Metadata
-- ============================================================


-- 1. Actual PostgreSQL column metadata
SELECT
    table_schema,
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
ORDER BY
    table_name,
    ordinal_position;


-- 2. Metadata summary by table and data type
SELECT
    table_name,
    data_type,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
GROUP BY
    table_name,
    data_type
ORDER BY
    table_name,
    data_type;


-- 3. Nullability summary
SELECT
    table_name,
    is_nullable,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'staging'
  AND table_name IN ('raw_transactions', 'raw_identity')
GROUP BY
    table_name,
    is_nullable
ORDER BY
    table_name,
    is_nullable;