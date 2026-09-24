-- ============================================================================
-- PHASE 10.14 — QUERY PERFORMANCE VALIDATION
-- ============================================================================
-- Purpose:
-- Capture baseline execution characteristics for important Phase 10 workloads.
--
-- IMPORTANT:
-- This phase records performance only.
-- No optimization or index changes are performed here.
-- Formal tuning is deferred to Phase 13.
-- ============================================================================

-- --------------------------------------------------------------------------
-- A. BASELINE: ANALYTICAL SOURCE VIEW
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE "isFraud" = 1) AS fraud_transactions,
    AVG("TransactionAmt") AS average_transaction_amount
FROM analytics.vw_transaction_analytics;


-- --------------------------------------------------------------------------
-- B. VELOCITY ANALYSIS
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (WHERE velocity_flag = 1) AS flagged_transactions,
    MAX(transactions_in_24h) AS max_velocity_count
FROM analytics.vw_velocity_analysis;


-- --------------------------------------------------------------------------
-- C. PATTERN VALIDATION
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
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
    SELECT 'velocity' AS rule_name, velocity_flag AS flag, "isFraud"
    FROM scored

    UNION ALL

    SELECT 'amount_anomaly', amount_anomaly_flag, "isFraud"
    FROM scored

    UNION ALL

    SELECT 'entity_device', entity_device_anomaly_flag, "isFraud"
    FROM scored

    UNION ALL

    SELECT 'off_hours', off_hours_risk_flag, "isFraud"
    FROM scored

    UNION ALL

    SELECT 'impossible_travel', impossible_travel_flag, "isFraud"
    FROM scored

    UNION ALL

    SELECT 'multiple_signal', multiple_signal_flag, "isFraud"
    FROM scored
)
SELECT
    rule_name,
    COUNT(*) FILTER (WHERE flag = 1) AS flagged_transactions,
    COUNT(*) FILTER (
        WHERE flag = 1
          AND "isFraud" = 1
    ) AS fraud_transactions
FROM rules
GROUP BY rule_name
ORDER BY rule_name;


-- --------------------------------------------------------------------------
-- D. CROSS-SIGNAL ANALYSIS
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
WITH signals AS MATERIALIZED (
    SELECT
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
    SELECT
        'velocity + amount_anomaly' AS pattern_name,
        velocity_flag = 1
            AND amount_anomaly_flag = 1 AS pattern_flag,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'velocity + entity_device',
        velocity_flag = 1
            AND entity_device_anomaly_flag = 1,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'amount_anomaly + off_hours',
        amount_anomaly_flag = 1
            AND off_hours_risk_flag = 1,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'entity_device + impossible_travel',
        entity_device_anomaly_flag = 1
            AND impossible_travel_flag = 1,
        "isFraud"
    FROM signals

    UNION ALL

    SELECT
        'multiple_signal',
        multiple_signal_flag = 1,
        "isFraud"
    FROM signals
)
SELECT
    pattern_name,
    COUNT(*) FILTER (WHERE pattern_flag) AS flagged_transactions,
    COUNT(*) FILTER (
        WHERE pattern_flag
          AND "isFraud" = 1
    ) AS fraud_transactions
FROM patterns
GROUP BY pattern_name
ORDER BY pattern_name;


-- --------------------------------------------------------------------------
-- E. SUSPICIOUS TRANSACTION EXTRACTION
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    "TransactionID",
    transaction_key,
    risk_score,
    risk_band,
    risk_reason
FROM analytics.vw_suspicious_transactions
WHERE risk_score >= 5
ORDER BY risk_score DESC, "TransactionID"
LIMIT 1000;


-- --------------------------------------------------------------------------
-- F. SUSPICIOUS ENTITY AGGREGATION
-- --------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT
    identity_key,
    COUNT(*) AS transaction_count,
    SUM(CASE WHEN "isFraud" = 1 THEN 1 ELSE 0 END) AS fraud_count,
    MAX(risk_score) AS max_risk_score
FROM analytics.vw_suspicious_transactions
WHERE risk_score >= 2
GROUP BY identity_key
ORDER BY max_risk_score DESC, transaction_count DESC
LIMIT 1000;