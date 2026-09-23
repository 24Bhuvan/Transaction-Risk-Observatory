-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.14 — VALIDATE DEVICE FIELDS
-- ============================================================

SELECT
    'DeviceType_transformation_mismatch' AS check_name,
    0::BIGINT AS expected_value,
    COUNT(*)::BIGINT AS actual_value,
    COUNT(*)::BIGINT AS difference,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS status
FROM analytics.dim_identity p
JOIN analytics.dim_identity_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE NULLIF(TRIM(p."DeviceType"), '') IS DISTINCT FROM c."DeviceType"

UNION ALL

SELECT
    'DeviceInfo_transformation_mismatch',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity p
JOIN analytics.dim_identity_clean c
  ON p."TransactionID" = c."TransactionID"
WHERE NULLIF(
    REGEXP_REPLACE(TRIM(p."DeviceInfo"), '[[:space:]]+', ' ', 'g'),
    ''
) IS DISTINCT FROM c."DeviceInfo"

UNION ALL

SELECT
    'deviceinfo_normalized_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE deviceinfo_normalized IS DISTINCT FROM LOWER(
    REGEXP_REPLACE(
        TRIM("DeviceInfo"),
        '[[:space:]]+',
        ' ',
        'g'
    )
)

UNION ALL

SELECT
    'deviceinfo_missing_flag_logic',
    0,
    COUNT(*)::BIGINT,
    COUNT(*)::BIGINT,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM analytics.dim_identity_clean
WHERE deviceinfo_missing_flag <> CASE WHEN "DeviceInfo" IS NULL THEN 1 ELSE 0 END;
