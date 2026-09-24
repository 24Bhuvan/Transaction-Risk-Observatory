-- ============================================================================
-- PHASE 10.12 — FRAUD PATTERN COMPARISON
-- ============================================================================
-- Purpose:
-- Compare each major rule against the historical isFraud label.
--
-- IMPORTANT:
-- These are descriptive historical rule-evaluation metrics.
-- They are NOT production ML-model performance metrics.
-- "precision_like" and "coverage_like" are intentionally named to reflect
-- their rule-based interpretation.
-- ============================================================================

WITH scored AS MATERIALIZED (
    SELECT
        velocity_flag,
        amount_anomaly_flag,
        entity_device_anomaly_flag,
        off_hours_risk_flag,
        impossible_travel_flag,
        multiple_signal_flag,
        "isFraud"
    FROM analytics.vw_risk_scoring
),

rules AS (
    SELECT
        'velocity' AS rule_name,
        velocity_flag AS flag,
        "isFraud"
    FROM scored

    UNION ALL

    SELECT
        'amount_anomaly',
        amount_anomaly_flag,
        "isFraud"
    FROM scored

    UNION ALL

    SELECT
        'entity_device',
        entity_device_anomaly_flag,
        "isFraud"
    FROM scored

    UNION ALL

    SELECT
        'off_hours',
        off_hours_risk_flag,
        "isFraud"
    FROM scored

    UNION ALL

    SELECT
        'impossible_travel',
        impossible_travel_flag,
        "isFraud"
    FROM scored

    UNION ALL

    SELECT
        'multiple_signal',
        multiple_signal_flag,
        "isFraud"
    FROM scored
),

overall AS (
    SELECT
        COUNT(*) AS total_transactions,
        COUNT(*) FILTER (WHERE "isFraud" = 1) AS total_fraud_transactions
    FROM scored
)

SELECT
    r.rule_name,

    o.total_transactions,

    COUNT(*) FILTER (
        WHERE r.flag = 1
    ) AS flagged_transactions,

    COUNT(*) FILTER (
        WHERE r.flag = 1
          AND r."isFraud" = 1
    ) AS fraud_transactions,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE r.flag = 1
                  AND r."isFraud" = 1
            )::numeric
            /
            NULLIF(
                COUNT(*) FILTER (WHERE r.flag = 1),
                0
            )
        ),
        6
    ) AS fraud_rate_flagged,

    COUNT(*) FILTER (
        WHERE r.flag = 0
    ) AS unflagged_transactions,

    ROUND(
        (
            COUNT(*) FILTER (
                WHERE r.flag = 0
                  AND r."isFraud" = 1
            )::numeric
            /
            NULLIF(
                COUNT(*) FILTER (WHERE r.flag = 0),
                0
            )
        ),
        6
    ) AS fraud_rate_unflagged,

    -- Historical flagged-fraud concentration.
    -- Equivalent to fraud_rate_flagged; retained under an explicit
    -- precision-like label for documentation purposes.
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE r.flag = 1
                  AND r."isFraud" = 1
            )::numeric
            /
            NULLIF(
                COUNT(*) FILTER (WHERE r.flag = 1),
                0
            )
        ),
        6
    ) AS precision_like_flagged_fraud_concentration,

    -- Historical coverage of all known fraudulent transactions.
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE r.flag = 1
                  AND r."isFraud" = 1
            )::numeric
            /
            NULLIF(
                o.total_fraud_transactions,
                0
            )
        ),
        6
    ) AS coverage_like,

    o.total_fraud_transactions

FROM rules r
CROSS JOIN overall o

GROUP BY
    r.rule_name,
    o.total_transactions,
    o.total_fraud_transactions

ORDER BY
    r.rule_name;