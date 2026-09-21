-- ============================================================
-- STEP 4.23 — RELATIONAL MODEL VALIDATION
-- ============================================================

-- 1. SCHEMA EXISTS
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.schemata
            WHERE schema_name = 'analytics'
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS analytics_schema_check;


-- 2. EXPECTED TABLES EXIST
SELECT
    table_name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM information_schema.tables t
            WHERE t.table_schema = 'analytics'
              AND t.table_name = expected.table_name
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS table_check
FROM (
    VALUES
        ('fact_transaction'),
        ('dim_identity')
) AS expected(table_name);


-- 3. EXPECTED COLUMN COUNTS
SELECT
    table_name,
    COUNT(*) AS column_count,
    CASE
        WHEN table_name = 'fact_transaction'
             AND COUNT(*) = 396
            THEN 'PASS'
        WHEN table_name = 'dim_identity'
             AND COUNT(*) = 42
            THEN 'PASS'
        ELSE 'FAIL'
    END AS column_check
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name IN ('fact_transaction', 'dim_identity')
GROUP BY table_name
ORDER BY table_name;


-- 4. PRIMARY KEYS
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    'PASS' AS validation
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'analytics'
  AND tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_name IN ('fact_transaction', 'dim_identity')
ORDER BY tc.table_name;


-- 5. TRANSACTIONID UNIQUE CONSTRAINTS
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    'PASS' AS validation
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
WHERE tc.table_schema = 'analytics'
  AND tc.constraint_type = 'UNIQUE'
  AND kcu.column_name = 'TransactionID'
ORDER BY tc.table_name;


-- 6. FOREIGN KEY STRUCTURE
SELECT
    tc.constraint_name,
    tc.table_name AS child_table,
    kcu.column_name AS child_column,
    ccu.table_name AS parent_table,
    ccu.column_name AS parent_column,
    CASE
        WHEN tc.table_name = 'fact_transaction'
         AND kcu.column_name = 'identity_key'
         AND ccu.table_name = 'dim_identity'
         AND ccu.column_name = 'identity_key'
        THEN 'PASS'
        ELSE 'FAIL'
    END AS fk_check
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.constraint_schema
WHERE tc.table_schema = 'analytics'
  AND tc.constraint_type = 'FOREIGN KEY';


-- 7. SOURCE TYPES WERE PRESERVED
SELECT
    'fact_transaction' AS table_name,
    COUNT(*) AS type_mismatches,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation
FROM information_schema.columns a
JOIN information_schema.columns s
    ON s.table_schema = 'staging'
   AND s.table_name = 'raw_transactions'
   AND s.column_name = a.column_name
WHERE a.table_schema = 'analytics'
  AND a.table_name = 'fact_transaction'
  AND (
       a.data_type <> s.data_type
       OR COALESCE(a.udt_name, '') <> COALESCE(s.udt_name, '')
  )

UNION ALL

SELECT
    'dim_identity' AS table_name,
    COUNT(*) AS type_mismatches,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation
FROM information_schema.columns a
JOIN information_schema.columns s
    ON s.table_schema = 'staging'
   AND s.table_name = 'raw_identity'
   AND s.column_name = a.column_name
WHERE a.table_schema = 'analytics'
  AND a.table_name = 'dim_identity'
  AND (
       a.data_type <> s.data_type
       OR COALESCE(a.udt_name, '') <> COALESCE(s.udt_name, '')
  );


-- 8. DATA-DEPENDENT RELATIONSHIP CHECK
-- Every identity TransactionID must exist in fact_transaction.
-- This will return 0 rows while the analytical tables are empty.

SELECT
    d."TransactionID"
FROM analytics.dim_identity d
LEFT JOIN analytics.fact_transaction f
    ON f."TransactionID" = d."TransactionID"
WHERE f."TransactionID" IS NULL;


-- 9. DATA-DEPENDENT 0..1 IDENTITY COVERAGE CHECK
-- There must be no transaction with more than one identity record.
-- This should return 0 rows.

SELECT
    "TransactionID",
    COUNT(*) AS identity_record_count
FROM analytics.dim_identity
GROUP BY "TransactionID"
HAVING COUNT(*) > 1;


-- 10. CURRENT ROW COUNTS
SELECT
    (SELECT COUNT(*) FROM analytics.fact_transaction)
        AS fact_transaction_rows,
    (SELECT COUNT(*) FROM analytics.dim_identity)
        AS dim_identity_rows;