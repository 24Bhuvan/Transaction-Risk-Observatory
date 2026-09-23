-- PHASE 9 - VIEW CATALOG
SELECT table_schema AS schema_name, table_name AS object_name, 'VIEW' AS materialization_status, view_definition
FROM information_schema.views
WHERE table_schema='analytics' AND table_name LIKE 'vw_%'
UNION ALL
SELECT schemaname, matviewname, 'MATERIALIZED VIEW', definition
FROM pg_matviews
WHERE schemaname='analytics' AND matviewname LIKE 'mv_%'
ORDER BY object_name;
