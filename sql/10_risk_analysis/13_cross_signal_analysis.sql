-- ============================================================================
-- PHASE 10.13 — CROSS-SIGNAL ANALYSIS
-- ============================================================================
-- Purpose:
-- Compare fraud concentration across individual rules and important
-- combinations of risk signals.
--
-- IMPORTANT:
-- This is descriptive historical analysis against the isFraud label.
-- It is NOT production-model performance evaluation.
-- ============================================================================

WITH signals AS MATERIALIZED (
    SELECT
        "TransactionID",
        "isFraud",
        velocity_flag,
        amount_anomaly_flag,
        entity_device_anomaly_flag,
        off_hours_risk_flag,
        impossible_travel_flag,
        multiple_signal_flag
    FROM analytics.vw_composed_risk_signals
),

patterns AS (

    -- Individual signals
    SELECT
        'velocity' AS pattern_name,
        velocity_flag AS pattern_flag,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'amount_anomaly',
        amount_anomaly_flag,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'entity_device',
        entity_device_anomaly_flag,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'off_hours',
        off_hours_risk_flag,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'impossible_travel',
        impossible_travel_flag,
        "isFraud"
    FROM signals

    -- Cross-signal combinations
    UNION ALL

    SELECT
        'velocity + amount_anomaly',
        CASE
            WHEN velocity_flag = 1
             AND amount_anomaly_flag = 1
            THEN 1 ELSE 0
        END,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'velocity + entity_device',
        CASE
            WHEN velocity_flag = 1
             AND entity_device_anomaly_flag = 1
            THEN 1 ELSE 0
        END,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'amount_anomaly + off_hours',
        CASE
            WHEN amount_anomaly_flag = 1
             AND off_hours_risk_flag = 1
            THEN 1 ELSE 0
        END,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'entity_device + impossible_travel',
        CASE
            WHEN entity_device_anomaly_flag = 1
             AND impossible_travel_flag = 1
            THEN 1 ELSE 0
        END,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'multiple_signal',
        multiple_signal_flag,
        "isFraud"
    FROM signals
),

summary AS (
    SELECT
        pattern_name,
        COUNT(*) FILTER (
            WHERE pattern_flag = 1
        ) AS flagged_transactions,

        COUNT(*) FILTER (
            WHERE pattern_flag = 1
              AND "isFraud" = 1
        ) AS fraud_transactions,

        COUNT(*) FILTER (
            WHERE pattern_flag = 0
        ) AS unflagged_transactions,

        COUNT(*) FILTER (
            WHERE pattern_flag = 0
              AND "isFraud" = 1
        ) AS unflagged_fraud_transactions
    FROM patterns
    GROUP BY pattern_name
)

SELECT
    pattern_name,
    flagged_transactions,
    fraud_transactions,

    ROUND(
        fraud_transactions::numeric
        / NULLIF(flagged_transactions, 0),
        6
    ) AS fraud_rate_flagged,

    unflagged_transactions,

    ROUND(
        unflagged_fraud_transactions::numeric
        / NULLIF(unflagged_transactions, 0),
        6
    ) AS fraud_rate_unflagged,

    ROUND(
        (
            fraud_transactions::numeric
            / NULLIF(flagged_transactions, 0)
        )
        -
        (
            unflagged_fraud_transactions::numeric
            / NULLIF(unflagged_transactions, 0)
        ),
        6
    ) AS fraud_rate_difference

FROM summary
ORDER BY
    fraud_rate_flagged DESC NULLS LAST,
    flagged_transactions DESC;