-- ============================================================
-- PHASE 6 — DATA CLEANING & TRANSFORMATION
-- STEP 6.12 — RISK-SIGNAL FEATURES
-- ============================================================
-- Purpose:
--   Create deterministic transaction-level analytical signals.
--
-- IMPORTANT:
--   These are descriptive signals, NOT fraud predictions.
--
--   isFraud remains unchanged.
--
-- No:
--   - weighted fraud score
--   - risk ranking
--   - fraud threshold
--   - arbitrary scoring
--
-- Signals:
--   identity_available_flag
--   email_domain_missing_flag
--   device_info_available_flag
--   card_attributes_partial_missing_flag
--   transaction_amount_zero_flag
--   missing_attribute_count
-- ============================================================


-- ============================================================
-- 1. Add risk-signal columns
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS identity_available_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS email_domain_missing_flag INTEGER;

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS device_info_available_flag INTEGER;


-- ============================================================
-- 2. Populate identity availability
-- ============================================================
-- identity_key is the Phase 5 relationship to dim_identity.
--
-- 1 = identity record available
-- 0 = identity record unavailable
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET identity_available_flag =
    CASE
        WHEN identity_key IS NOT NULL THEN 1
        ELSE 0
    END;


-- ============================================================
-- 3. Populate email-domain missingness signal
-- ============================================================
-- Missing if BOTH purchaser and recipient email domains
-- are unavailable.
--
-- This avoids treating a single missing email-domain field
-- as complete email-domain absence.
-- ============================================================

UPDATE analytics.fact_transaction_clean
SET email_domain_missing_flag =
    CASE
        WHEN "P_emaildomain" IS NULL
         AND "R_emaildomain" IS NULL
            THEN 1
        ELSE 0
    END;


-- ============================================================
-- 4. Populate DeviceInfo availability
-- ============================================================
-- DeviceInfo is stored in dim_identity_clean.
--
-- LEFT JOIN semantics are represented through identity_key:
-- transactions without an identity record have no DeviceInfo.
--
-- 1 = DeviceInfo available
-- 0 = DeviceInfo unavailable
-- ============================================================

UPDATE analytics.fact_transaction_clean f
SET device_info_available_flag =
    CASE
        WHEN d."DeviceInfo" IS NOT NULL THEN 1
        ELSE 0
    END
FROM analytics.dim_identity_clean d
WHERE f.identity_key = d.identity_key;


-- ============================================================
-- 5. Handle transactions without an identity record
-- ============================================================

UPDATE analytics.fact_transaction_clean f
SET device_info_available_flag = 0
WHERE f.identity_key IS NULL;


-- ============================================================
-- 6. Create composite missing-attribute count
-- ============================================================
-- Count only the controlled analytical signals already defined:
--
--   identity unavailable
--   both email domains missing
--   DeviceInfo unavailable
--   card attributes partially missing
--   zero transaction amount
--
-- This is a descriptive missingness count.
-- It is NOT a fraud score.
-- ============================================================

ALTER TABLE analytics.fact_transaction_clean
ADD COLUMN IF NOT EXISTS missing_attribute_count INTEGER;

UPDATE analytics.fact_transaction_clean
SET missing_attribute_count =
      CASE WHEN identity_available_flag = 0 THEN 1 ELSE 0 END
    + CASE WHEN email_domain_missing_flag = 1 THEN 1 ELSE 0 END
    + CASE WHEN device_info_available_flag = 0 THEN 1 ELSE 0 END
    + CASE WHEN card_attributes_partial_missing_flag = 1 THEN 1 ELSE 0 END
    + CASE WHEN transaction_amount_zero_flag = 1 THEN 1 ELSE 0 END;


-- ============================================================
-- 7. Validate signal distributions
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE identity_available_flag = 1
    ) AS identity_available,

    COUNT(*) FILTER (
        WHERE identity_available_flag = 0
    ) AS identity_unavailable,

    COUNT(*) FILTER (
        WHERE email_domain_missing_flag = 1
    ) AS email_domain_missing,

    COUNT(*) FILTER (
        WHERE device_info_available_flag = 1
    ) AS device_info_available,

    COUNT(*) FILTER (
        WHERE device_info_available_flag = 0
    ) AS device_info_unavailable,

    COUNT(*) FILTER (
        WHERE card_attributes_partial_missing_flag = 1
    ) AS card_partial_missing,

    COUNT(*) FILTER (
        WHERE transaction_amount_zero_flag = 1
    ) AS zero_amount_transactions

FROM analytics.fact_transaction_clean;


-- ============================================================
-- 8. Validate composite distribution
-- ============================================================

SELECT
    missing_attribute_count,
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
GROUP BY missing_attribute_count
ORDER BY missing_attribute_count;


-- ============================================================
-- 9. Validate signal domains
-- ============================================================

SELECT
    COUNT(*) FILTER (
        WHERE identity_available_flag NOT IN (0,1)
           OR email_domain_missing_flag NOT IN (0,1)
           OR device_info_available_flag NOT IN (0,1)
           OR card_attributes_partial_missing_flag NOT IN (0,1)
           OR transaction_amount_zero_flag NOT IN (0,1)
    ) AS invalid_signal_rows
FROM analytics.fact_transaction_clean;


-- ============================================================
-- 10. Validate composite calculation
-- ============================================================

SELECT
    COUNT(*) AS missing_attribute_count_mismatches
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
-- 11. Confirm isFraud remains unchanged
-- ============================================================

SELECT
    "isFraud",
    COUNT(*) AS row_count
FROM analytics.fact_transaction_clean
GROUP BY "isFraud"
ORDER BY "isFraud";


-- ============================================================
-- 12. Confirm transaction grain
-- ============================================================

SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT "TransactionID") AS distinct_transaction_ids,
    COUNT(*) - COUNT(DISTINCT "TransactionID") AS transaction_id_duplicates
FROM analytics.fact_transaction_clean;