-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.14 — FINAL CLEAN-LAYER VALIDATION
-- ============================================================
-- Main Phase 6 completion gate.
--
-- Validates:
--   1. Population
--   2. Grain
--   3. Keys
--   4. Identity relationship
--   5. Fraud preservation
--   6. Transaction amount preservation
--   7. NULL semantics
--   8. Transformation domains
--   9. Row-level logic of derived features
--
-- Phase 5 analytical tables remain the comparison baseline.
-- ============================================================


-- ============================================================
-- 1. POPULATION
-- ============================================================

SELECT
    'fact_transaction_clean' AS table_name,
    COUNT(*) AS actual_rows,
    590540 AS expected_rows,
    CASE
        WHEN COUNT(*) = 590540 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'dim_identity_clean',
    COUNT(*),
    144233,
    CASE
        WHEN COUNT(*) = 144233 THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean;


-- ============================================================
-- 2. GRAIN
-- ============================================================

SELECT
    table_name,
    row_count,
    distinct_transaction_ids,
    row_count - distinct_transaction_ids AS duplicate_difference,
    CASE
        WHEN row_count = distinct_transaction_ids
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (
    SELECT
        'fact_transaction_clean' AS table_name,
        COUNT(*) AS row_count,
        COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids
    FROM analytics.fact_transaction_clean

    UNION ALL

    SELECT
        'dim_identity_clean',
        COUNT(*),
        COUNT(DISTINCT "TransactionID")
    FROM analytics.dim_identity_clean
) x;


-- ============================================================
-- 3. TRANSACTIONID DUPLICATES
-- ============================================================

SELECT
    'fact_transaction_clean' AS table_name,
    COUNT(*) - COUNT(DISTINCT "TransactionID") AS transaction_id_duplicates,
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT "TransactionID")
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean

UNION ALL

SELECT
    'dim_identity_clean',
    COUNT(*) - COUNT(DISTINCT "TransactionID"),
    CASE
        WHEN COUNT(*) = COUNT(DISTINCT "TransactionID")
            THEN 'PASS'
        ELSE 'FAIL'
    END
FROM analytics.dim_identity_clean;


-- ============================================================
-- 4. IDENTITY RELATIONSHIP
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE identity_key IS NOT NULL
    ) AS identity_linked,

    COUNT(*) FILTER (
        WHERE identity_key IS NULL
    ) AS identity_unlinked,

    CASE
        WHEN COUNT(*) FILTER (WHERE identity_key IS NOT NULL) = 144233
         AND COUNT(*) FILTER (WHERE identity_key IS NULL) = 446307
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 5. FRAUD LABEL PRESERVATION
-- ============================================================

SELECT
    "isFraud",
    COUNT(*) AS actual_rows,
    CASE
        WHEN "isFraud" = 0 THEN 569877
        WHEN "isFraud" = 1 THEN 20663
    END AS expected_rows,
    CASE
        WHEN COUNT(*) =
             CASE
                 WHEN "isFraud" = 0 THEN 569877
                 WHEN "isFraud" = 1 THEN 20663
             END
            THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
GROUP BY "isFraud"
ORDER BY "isFraud";


-- ============================================================
-- 6. TRANSACTION AMOUNT PRESERVATION
-- ============================================================

SELECT
    'COUNT(TransactionAmt)' AS metric,
    (SELECT COUNT("TransactionAmt")
     FROM analytics.fact_transaction_clean) AS clean_value,
    (SELECT COUNT("TransactionAmt")
     FROM analytics.fact_transaction) AS phase5_value,
    CASE
        WHEN
            (SELECT COUNT("TransactionAmt")
             FROM analytics.fact_transaction_clean)
            =
            (SELECT COUNT("TransactionAmt")
             FROM analytics.fact_transaction)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

UNION ALL

SELECT
    'SUM(TransactionAmt)',
    (SELECT SUM("TransactionAmt")
     FROM analytics.fact_transaction_clean),
    (SELECT SUM("TransactionAmt")
     FROM analytics.fact_transaction),
    CASE
        WHEN
            (SELECT SUM("TransactionAmt")
             FROM analytics.fact_transaction_clean)
            =
            (SELECT SUM("TransactionAmt")
             FROM analytics.fact_transaction)
        THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'AVG(TransactionAmt)',
    (SELECT AVG("TransactionAmt")
     FROM analytics.fact_transaction_clean),
    (SELECT AVG("TransactionAmt")
     FROM analytics.fact_transaction),
    CASE
        WHEN
            (SELECT AVG("TransactionAmt")
             FROM analytics.fact_transaction_clean)
            =
            (SELECT AVG("TransactionAmt")
             FROM analytics.fact_transaction)
        THEN 'PASS'
        ELSE 'FAIL'
    END;


-- ============================================================
-- 7. NULL SEMANTICS — CORE SOURCE FIELDS
-- ============================================================
-- These fields were not intentionally converted from blank
-- strings to NULL during categorical standardization.
-- Their NULL counts must remain equal to Phase 5.
-- ============================================================

SELECT
    field,
    phase5_nulls,
    clean_nulls,
    clean_nulls - phase5_nulls AS null_difference,
    CASE
        WHEN phase5_nulls = clean_nulls THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (
    SELECT
        'TransactionAmt' AS field,
        (SELECT COUNT(*) FROM analytics.fact_transaction
         WHERE "TransactionAmt" IS NULL) AS phase5_nulls,
        (SELECT COUNT(*) FROM analytics.fact_transaction_clean
         WHERE "TransactionAmt" IS NULL) AS clean_nulls

    UNION ALL

    SELECT
        'TransactionDT',
        (SELECT COUNT(*) FROM analytics.fact_transaction
         WHERE "TransactionDT" IS NULL),
        (SELECT COUNT(*) FROM analytics.fact_transaction_clean
         WHERE "TransactionDT" IS NULL)

    UNION ALL

    SELECT
        'ProductCD',
        (SELECT COUNT(*) FROM analytics.fact_transaction
         WHERE "ProductCD" IS NULL),
        (SELECT COUNT(*) FROM analytics.fact_transaction_clean
         WHERE "ProductCD" IS NULL)
) x
ORDER BY field;


-- ============================================================
-- 8. INTENTIONAL BLANK → NULL TRANSFORMATIONS
-- ============================================================
-- For categorical fields, NULL counts may increase because
-- blank/whitespace-only strings were intentionally normalized
-- to NULL.
--
-- Validate that no blank strings remain.
-- ============================================================

SELECT
    field,
    blank_rows,
    CASE
        WHEN blank_rows = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (
    SELECT
        'ProductCD' AS field,
        COUNT(*) FILTER (
            WHERE "ProductCD" = ''
        ) AS blank_rows
    FROM analytics.fact_transaction_clean

    UNION ALL

    SELECT
        'card4',
        COUNT(*) FILTER (
            WHERE "card4" = ''
        )
    FROM analytics.fact_transaction_clean

    UNION ALL

    SELECT
        'card6',
        COUNT(*) FILTER (
            WHERE "card6" = ''
        )
    FROM analytics.fact_transaction_clean

    UNION ALL

    SELECT
        'DeviceType',
        COUNT(*) FILTER (
            WHERE "DeviceType" = ''
        )
    FROM analytics.dim_identity_clean
) x
ORDER BY field;


-- ============================================================
-- 9. M1-M9 BLANK VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS rows_with_blank_M_values,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
WHERE
       "M1" = ''
    OR "M2" = ''
    OR "M3" = ''
    OR "M4" = ''
    OR "M5" = ''
    OR "M6" = ''
    OR "M7" = ''
    OR "M8" = ''
    OR "M9" = '';


-- ============================================================
-- 10. DEVICEINFO NULL / MISSINGNESS SEMANTICS
-- ============================================================

SELECT
    COUNT(*) AS total_identity_rows,

    COUNT("DeviceInfo") AS deviceinfo_non_null,

    COUNT(*) FILTER (
        WHERE "DeviceInfo" IS NULL
    ) AS deviceinfo_nulls,

    COUNT(*) FILTER (
        WHERE deviceinfo_missing_flag = 1
    ) AS deviceinfo_missing_flagged,

    COUNT(*) FILTER (
        WHERE deviceinfo_missing_flag = 0
    ) AS deviceinfo_available_flagged,

    COUNT(*) FILTER (
        WHERE deviceinfo_missing_flag <>
              CASE
                  WHEN "DeviceInfo" IS NULL THEN 1
                  ELSE 0
              END
    ) AS flag_mismatches,

    CASE
        WHEN COUNT(*) FILTER (
                 WHERE deviceinfo_missing_flag <>
                       CASE
                           WHEN "DeviceInfo" IS NULL THEN 1
                           ELSE 0
                       END
             ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status

FROM analytics.dim_identity_clean;


-- ============================================================
-- 11. DEVICEINFO NORMALIZED FIELD LOGIC
-- ============================================================

SELECT
    COUNT(*) AS normalized_mismatches,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.dim_identity_clean
WHERE
    (
        "DeviceInfo" IS NULL
        AND deviceinfo_normalized IS NOT NULL
    )
    OR
    (
        "DeviceInfo" IS NOT NULL
        AND deviceinfo_normalized <>
            LOWER(
                REGEXP_REPLACE(
                    TRIM("DeviceInfo"),
                    '[[:space:]]+',
                    ' ',
                    'g'
                )
            )
    );


-- ============================================================
-- 12. MISSINGNESS INDICATOR LOGIC
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE dist2_missing_flag <>
              CASE WHEN "dist2" IS NULL THEN 1 ELSE 0 END
    ) AS dist2_mismatches,

    COUNT(*) FILTER (
        WHERE D7_missing_flag <>
              CASE WHEN "D7" IS NULL THEN 1 ELSE 0 END
    ) AS D7_mismatches,

    COUNT(*) FILTER (
        WHERE R_emaildomain_missing_flag <>
              CASE WHEN "R_emaildomain" IS NULL THEN 1 ELSE 0 END
    ) AS R_emaildomain_mismatches,

    COUNT(*) FILTER (
        WHERE card2_missing_flag <>
              CASE WHEN "card2" IS NULL THEN 1 ELSE 0 END
    ) AS card2_mismatches,

    COUNT(*) FILTER (
        WHERE card3_missing_flag <>
              CASE WHEN "card3" IS NULL THEN 1 ELSE 0 END
    ) AS card3_mismatches,

    COUNT(*) FILTER (
        WHERE card5_missing_flag <>
              CASE WHEN "card5" IS NULL THEN 1 ELSE 0 END
    ) AS card5_mismatches,

    COUNT(*) FILTER (
        WHERE card6_missing_flag <>
              CASE WHEN "card6" IS NULL THEN 1 ELSE 0 END
    ) AS card6_mismatches

FROM analytics.fact_transaction_clean;


-- ============================================================
-- 13. CARD COMPOSITE LOGIC
-- ============================================================

SELECT
    COUNT(*) AS card_count_mismatches,
    COUNT(*) FILTER (
        WHERE card_attributes_partial_missing_flag <>
              CASE
                  WHEN card_attributes_missing_count BETWEEN 1 AND 3
                      THEN 1
                  ELSE 0
              END
    ) AS partial_flag_mismatches,
    CASE
        WHEN COUNT(*) = 0
         AND COUNT(*) FILTER (
                 WHERE card_attributes_partial_missing_flag <>
                       CASE
                           WHEN card_attributes_missing_count BETWEEN 1 AND 3
                               THEN 1
                           ELSE 0
                       END
             ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
WHERE
    card_attributes_missing_count <>
      (
          CASE WHEN "card2" IS NULL THEN 1 ELSE 0 END
        + CASE WHEN "card3" IS NULL THEN 1 ELSE 0 END
        + CASE WHEN "card5" IS NULL THEN 1 ELSE 0 END
        + CASE WHEN "card6" IS NULL THEN 1 ELSE 0 END
      );


-- ============================================================
-- 14. TIME FEATURE LOGIC
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE transaction_day_number <>
              FLOOR("TransactionDT" / 86400.0)::INTEGER
    ) AS day_mismatches,

    COUNT(*) FILTER (
        WHERE transaction_hour NOT BETWEEN 0 AND 23
    ) AS invalid_hours,

    COUNT(*) FILTER (
        WHERE transaction_hour <>
              FLOOR(
                  MOD("TransactionDT", 86400) / 3600.0
              )::INTEGER
    ) AS hour_mismatches,

    COUNT(*) FILTER (
        WHERE transaction_week_number <>
              FLOOR("TransactionDT" / 604800.0)::INTEGER
    ) AS week_mismatches,

    CASE
        WHEN COUNT(*) FILTER (
                 WHERE transaction_day_number <>
                       FLOOR("TransactionDT" / 86400.0)::INTEGER
             ) = 0
         AND COUNT(*) FILTER (
                 WHERE transaction_hour NOT BETWEEN 0 AND 23
             ) = 0
         AND COUNT(*) FILTER (
                 WHERE transaction_hour <>
                       FLOOR(
                           MOD("TransactionDT", 86400) / 3600.0
                       )::INTEGER
             ) = 0
         AND COUNT(*) FILTER (
                 WHERE transaction_week_number <>
                       FLOOR("TransactionDT" / 604800.0)::INTEGER
             ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 15. TRANSACTION AMOUNT FEATURE LOGIC
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE transaction_amount_zero_flag <>
              CASE
                  WHEN "TransactionAmt" = 0 THEN 1
                  ELSE 0
              END
    ) AS zero_flag_mismatches,

    COUNT(*) FILTER (
        WHERE transaction_amount_log <>
              LN("TransactionAmt" + 1)
    ) AS log_mismatches,

    COUNT(*) FILTER (
        WHERE "TransactionAmt" < 0
    ) AS negative_amounts,

    CASE
        WHEN COUNT(*) FILTER (
                 WHERE transaction_amount_zero_flag <>
                       CASE
                           WHEN "TransactionAmt" = 0 THEN 1
                           ELSE 0
                       END
             ) = 0
         AND COUNT(*) FILTER (
                 WHERE transaction_amount_log <>
                       LN("TransactionAmt" + 1)
             ) = 0
         AND COUNT(*) FILTER (
                 WHERE "TransactionAmt" < 0
             ) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 16. RISK-SIGNAL LOGIC
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE identity_available_flag <>
              CASE
                  WHEN identity_key IS NOT NULL THEN 1
                  ELSE 0
              END
    ) AS identity_flag_mismatches,

    COUNT(*) FILTER (
        WHERE email_domain_missing_flag <>
              CASE
                  WHEN "P_emaildomain" IS NULL
                   AND "R_emaildomain" IS NULL
                  THEN 1
                  ELSE 0
              END
    ) AS email_flag_mismatches,

    COUNT(*) FILTER (
        WHERE device_info_available_flag <>
              CASE
                  WHEN identity_key IS NULL THEN 0
                  WHEN EXISTS (
                      SELECT 1
                      FROM analytics.dim_identity_clean d
                      WHERE d.identity_key =
                            analytics.fact_transaction_clean.identity_key
                        AND d."DeviceInfo" IS NOT NULL
                  )
                  THEN 1
                  ELSE 0
              END
    ) AS device_flag_mismatches,

    COUNT(*) FILTER (
        WHERE identity_available_flag NOT IN (0,1)
           OR email_domain_missing_flag NOT IN (0,1)
           OR device_info_available_flag NOT IN (0,1)
           OR card_attributes_partial_missing_flag NOT IN (0,1)
           OR transaction_amount_zero_flag NOT IN (0,1)
    ) AS invalid_signal_values

FROM analytics.fact_transaction_clean;


-- ============================================================
-- 17. COMPOSITE MISSING-ATTRIBUTE COUNT
-- ============================================================

SELECT
    COUNT(*) AS missing_attribute_count_mismatches,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM analytics.fact_transaction_clean
WHERE missing_attribute_count <>
      (
          CASE WHEN identity_available_flag = 0 THEN 1 ELSE 0 END
        + CASE WHEN email_domain_missing_flag = 1 THEN 1 ELSE 0 END
        + CASE WHEN device_info_available_flag = 0 THEN 1 ELSE 0 END
        + CASE WHEN card_attributes_partial_missing_flag = 1 THEN 1 ELSE 0 END
        + CASE WHEN transaction_amount_zero_flag = 1 THEN 1 ELSE 0 END
      );


-- ============================================================
-- 18. isFraud IMMUTABILITY CHECK AGAINST PHASE 5
-- ============================================================

SELECT
    COUNT(*) AS fraud_distribution_mismatches,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS status
FROM (
    SELECT
        "isFraud",
        COUNT(*) AS clean_count,
        (
            SELECT COUNT(*)
            FROM analytics.fact_transaction f5
            WHERE f5."isFraud" = fc."isFraud"
        ) AS phase5_count
    FROM analytics.fact_transaction_clean fc
    GROUP BY "isFraud"
) x
WHERE clean_count <> phase5_count;


-- ============================================================
-- 19. FINAL OVERALL GATE
-- ============================================================
-- Returns PASS only when all major completion criteria pass.
-- ============================================================

SELECT
    CASE
        WHEN
            (SELECT COUNT(*) FROM analytics.fact_transaction_clean) = 590540
        AND
            (SELECT COUNT(*) FROM analytics.dim_identity_clean) = 144233
        AND
            (SELECT COUNT(*) FROM analytics.fact_transaction_clean)
            =
            (SELECT COUNT(DISTINCT "TransactionID")
             FROM analytics.fact_transaction_clean)
        AND
            (SELECT COUNT(*) FROM analytics.dim_identity_clean)
            =
            (SELECT COUNT(DISTINCT "TransactionID")
             FROM analytics.dim_identity_clean)
        AND
            (SELECT COUNT(*) FILTER (
                WHERE identity_key IS NOT NULL
             )
             FROM analytics.fact_transaction_clean) = 144233
        AND
            (SELECT COUNT(*) FILTER (
                WHERE identity_key IS NULL
             )
             FROM analytics.fact_transaction_clean) = 446307
        AND
            (SELECT COUNT(*) FILTER (
                WHERE "isFraud" = 0
             )
             FROM analytics.fact_transaction_clean) = 569877
        AND
            (SELECT COUNT(*) FILTER (
                WHERE "isFraud" = 1
             )
             FROM analytics.fact_transaction_clean) = 20663
        AND
            (SELECT SUM("TransactionAmt")
             FROM analytics.fact_transaction_clean)
            =
            (SELECT SUM("TransactionAmt")
             FROM analytics.fact_transaction)
        AND
            (SELECT AVG("TransactionAmt")
             FROM analytics.fact_transaction_clean)
            =
            (SELECT AVG("TransactionAmt")
             FROM analytics.fact_transaction)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS phase_6_validation_status;