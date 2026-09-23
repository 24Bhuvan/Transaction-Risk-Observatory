-- PHASE 9 - STEP 9.2 - EXISTING VIEW INVENTORY
SELECT table_schema AS schema_name, table_name AS view_name, view_definition
FROM information_schema.views
WHERE table_schema IN ('analytics','staging')
ORDER BY table_schema, table_name;

SELECT schemaname AS schema_name, matviewname AS view_name, definition
FROM pg_matviews
WHERE schemaname IN ('analytics','staging')
ORDER BY schemaname, matviewname;

SELECT dependent_ns.nspname AS dependent_schema, dependent_view.relname AS dependent_object,
       source_ns.nspname AS source_schema, source.relname AS source_object
FROM pg_depend dep
JOIN pg_rewrite rw ON rw.oid=dep.objid
JOIN pg_class dependent_view ON dependent_view.oid=rw.ev_class
JOIN pg_namespace dependent_ns ON dependent_ns.oid=dependent_view.relnamespace
JOIN pg_class source ON source.oid=dep.refobjid
JOIN pg_namespace source_ns ON source_ns.oid=source.relnamespace
WHERE dependent_view.relkind IN ('v','m')
ORDER BY dependent_schema, dependent_object;
