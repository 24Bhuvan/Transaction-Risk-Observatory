-- PHASE 8 - STEP 8.2 - CURRENT PHYSICAL DESIGN

SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname IN ('analytics', 'staging')
ORDER BY schemaname, tablename, indexname;

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    con.conname,
    CASE con.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'c' THEN 'CHECK'
        ELSE con.contype::text
    END AS constraint_type,
    pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('analytics', 'staging')
ORDER BY n.nspname, c.relname, con.conname;

SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    i.relname AS index_name,
    ix.indisprimary,
    ix.indisunique,
    ix.indisvalid,
    ix.indpred IS NOT NULL AS is_partial,
    pg_get_indexdef(ix.indexrelid) AS index_definition,
    pg_size_pretty(pg_relation_size(ix.indexrelid)) AS index_size
FROM pg_index ix
JOIN pg_class c ON c.oid = ix.indrelid
JOIN pg_class i ON i.oid = ix.indexrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('analytics', 'staging')
ORDER BY n.nspname, c.relname, i.relname;
