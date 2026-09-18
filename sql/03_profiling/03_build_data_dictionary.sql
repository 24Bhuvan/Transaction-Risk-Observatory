-- STEP 3.13 — Build the Data Dictionary
-- Project: Transaction Risk Observatory
--
-- Purpose:
--   Build docs/profiling/data_dictionary.md from the ACTUAL PostgreSQL
--   staging tables. Null % and distinct counts are calculated directly
--   from the database. Descriptions are restricted to documented meanings.
--
-- Run from psql:
--   \i 05_SQL/profiling/03_build_data_dictionary.sql
--
-- The script prints Markdown to the psql session. Redirect/capture the
-- output to:
--   docs/profiling/data_dictionary.md
--
-- IMPORTANT:
--   C/D/M/V and id_* fields are intentionally anonymized. Their individual
--   business meanings are not invented here.

DROP TABLE IF EXISTS tmp_data_dictionary;

CREATE TEMP TABLE tmp_data_dictionary (
    table_name       text,
    column_name      text,
    data_type        text,
    description      text,
    null_pct         numeric(8,2),
    distinct_count   bigint,
    profiling_notes  text
);

DO $$
DECLARE
    r record;
    total_rows bigint;
    null_count bigint;
    distinct_count bigint;
    sql text;
    description text;
    profiling_notes text;
BEGIN
    FOR r IN
        SELECT
            c.table_name,
            c.column_name,
            c.ordinal_position,
            c.data_type
        FROM information_schema.columns c
        WHERE c.table_schema = 'staging'
          AND c.table_name IN ('raw_transactions', 'raw_identity')
        ORDER BY
            CASE c.table_name
                WHEN 'raw_transactions' THEN 1
                WHEN 'raw_identity' THEN 2
            END,
            c.ordinal_position
    LOOP
        EXECUTE format(
            'SELECT COUNT(*) FROM staging.%I',
            r.table_name
        )
        INTO total_rows;

        EXECUTE format(
            'SELECT COUNT(*) FROM staging.%I WHERE %I IS NULL',
            r.table_name,
            r.column_name
        )
        INTO null_count;

        EXECUTE format(
            'SELECT COUNT(DISTINCT %I) FROM staging.%I',
            r.column_name,
            r.table_name
        )
        INTO distinct_count;

        /*
         * Documented descriptions only.
         * Anonymized fields are explicitly identified as such.
         */
        description :=
            CASE
                WHEN r.column_name = 'TransactionID'
                    THEN 'Transaction identifier used to link transaction and identity records.'
                WHEN r.column_name = 'isFraud'
                    THEN 'Binary training target indicating whether the transaction is fraudulent (0/1).'
                WHEN r.column_name = 'TransactionDT'
                    THEN 'Relative transaction time represented as a timedelta from a reference point; not a calendar timestamp.'
                WHEN r.column_name = 'TransactionAmt'
                    THEN 'Transaction amount.'
                WHEN r.column_name = 'ProductCD'
                    THEN 'Product code associated with the transaction.'
                WHEN r.column_name IN ('card1','card2','card3','card4','card5','card6')
                    THEN 'Payment-card-related feature; the individual field meaning is anonymized.'
                WHEN r.column_name IN ('addr1','addr2')
                    THEN 'Address-related feature; the individual field meaning is anonymized.'
                WHEN r.column_name IN ('dist1','dist2')
                    THEN 'Distance-related feature; the individual field meaning is anonymized.'
                WHEN r.column_name = 'P_emaildomain'
                    THEN 'Purchaser email domain.'
                WHEN r.column_name = 'R_emaildomain'
                    THEN 'Recipient email domain.'
                WHEN r.column_name LIKE 'C%'
                    THEN 'Anonymized counting feature associated with transaction/card-related metadata.'
                WHEN r.column_name LIKE 'D%'
                    THEN 'Anonymized time-delta feature associated with transaction history or related events.'
                WHEN r.column_name LIKE 'M%'
                    THEN 'Anonymized match feature.'
                WHEN r.column_name LIKE 'V%'
                    THEN 'Vesta-engineered anonymized feature; individual semantic meaning is undisclosed.'
                WHEN r.column_name LIKE 'id_%'
                    THEN 'Anonymized identity feature; individual semantic meaning is undisclosed.'
                WHEN r.column_name = 'DeviceType'
                    THEN 'Type of device used for the transaction.'
                WHEN r.column_name = 'DeviceInfo'
                    THEN 'Additional device metadata.'
                ELSE
                    'Source field; semantic definition not documented.'
            END;

        profiling_notes :=
            CASE
                WHEN null_count = 0
                    THEN 'No NULL values observed in the raw staging profile.'
                WHEN null_count = total_rows
                    THEN '100% NULL in the raw staging profile.'
                ELSE
                    format(
                        '%s NULL values observed in the raw staging profile.',
                        to_char(null_count, 'FM999,999,999')
                    )
            END;

        INSERT INTO tmp_data_dictionary
        VALUES (
            r.table_name,
            r.column_name,
            CASE
                WHEN r.table_name = 'raw_transactions'
                     AND r.column_name = 'TransactionAmt'
                    THEN 'NUMERIC'
                WHEN r.table_name = 'raw_transactions'
                     AND r.column_name = 'isFraud'
                    THEN 'SMALLINT'
                WHEN r.data_type = 'bigint'
                    THEN 'BIGINT'
                WHEN r.data_type = 'double precision'
                    THEN 'DOUBLE PRECISION'
                WHEN r.data_type = 'numeric'
                    THEN 'NUMERIC'
                WHEN r.data_type = 'smallint'
                    THEN 'SMALLINT'
                WHEN r.data_type = 'text'
                    THEN 'TEXT'
                ELSE upper(r.data_type)
            END,
            description,
            CASE
                WHEN total_rows = 0 THEN 0
                ELSE round((null_count * 100.0) / total_rows, 2)
            END,
            distinct_count,
            profiling_notes
        );
    END LOOP;
END $$;

\pset format unaligned
\pset tuples_only on
\pset fieldsep '|'

SELECT '# Transaction Risk Observatory — Data Dictionary'
UNION ALL
SELECT ''
UNION ALL
SELECT 'This dictionary records observed PostgreSQL staging metadata and documented source meanings.'
UNION ALL
SELECT ''
UNION ALL
SELECT '## Scope'
UNION ALL
SELECT ''
UNION ALL
SELECT '- Tables: `staging.raw_transactions`, `staging.raw_identity`'
UNION ALL
SELECT '- Metadata: PostgreSQL type, observed NULL percentage, observed distinct count, and profiling notes.'
UNION ALL
SELECT '- Source semantics are used only where documented.'
UNION ALL
SELECT '- Anonymized C/D/M/V and id_* fields are not assigned invented business meanings.'
UNION ALL
SELECT ''
UNION ALL
SELECT '## Column Dictionary'
UNION ALL
SELECT ''
UNION ALL
SELECT '| Column | Table | Type | Description | Null % | Distinct Count | Profiling Notes |'
UNION ALL
SELECT '|---|---|---|---|---:|---:|---|'
UNION ALL
SELECT
    '| `' || replace(column_name, '|', '\|') || '`'
    || ' | `' || table_name || '`'
    || ' | `' || data_type || '`'
    || ' | ' || replace(description, '|', '\|')
    || ' | ' || to_char(null_pct, 'FM990.00')
    || ' | ' || to_char(distinct_count, 'FM999,999,999')
    || ' | ' || replace(profiling_notes, '|', '\|')
    || ' |'
FROM tmp_data_dictionary
ORDER BY
    CASE
        WHEN column_name LIKE '#%' THEN 0
        ELSE 1
    END,
    table_name,
    column_name;
