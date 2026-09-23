-- ============================================================
-- PHASE 7 — DATA QUALITY VALIDATION & RECONCILIATION
-- STEP 7.22 — FINAL GATE
-- ============================================================
-- The final gate only returns PASS if all mandatory checks pass.
-- Otherwise it returns FAIL.
-- ============================================================

WITH mandatory AS (
    SELECT CASE WHEN (
        (SELECT COUNT(*) FROM analytics.fact_transaction_clean) = 590540
        AND (SELECT COUNT(*) FROM analytics.dim_identity_clean) = 144233
        AND (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionID" IS NULL) = 0
        AND (SELECT COUNT(*) FROM analytics.dim_identity_clean WHERE "TransactionID" IS NULL) = 0
        AND (SELECT COUNT(*) FILTER (WHERE identity_key IS NOT NULL) FROM analytics.fact_transaction_clean) = 144233
        AND (SELECT COUNT(*) FILTER (WHERE identity_key IS NULL) FROM analytics.fact_transaction_clean) = 446307
        AND (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "isFraud" NOT IN (0, 1)) = 0
        AND (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE "TransactionAmt" < 0) = 0
        AND (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE transaction_hour NOT BETWEEN 0 AND 23) = 0
        AND (SELECT COUNT(*) FROM analytics.fact_transaction_clean WHERE card_attributes_missing_count NOT BETWEEN 0 AND 4) = 0
    ) THEN 'PASS' ELSE 'FAIL' END AS phase_07_quality_status
)
SELECT phase_07_quality_status
FROM mandatory;
