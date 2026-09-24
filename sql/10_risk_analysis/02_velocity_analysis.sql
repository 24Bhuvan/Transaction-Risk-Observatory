-- R01 - CARD-LINKED VELOCITY
-- Uses card1 internally because identity_key is one-to-one in this dataset.
-- Rule: 3 or more transactions linked to the same card1
-- within a rolling 1-hour window.
-- This is a heuristic review-prioritization signal, not a fraud probability.

CREATE OR REPLACE VIEW analytics.vw_velocity_analysis AS

WITH card_velocity AS (
    SELECT
        "TransactionID",
        transaction_key,
        identity_key,
        "TransactionDT",
        "TransactionAmt",
        "isFraud",

        LAG("TransactionDT") OVER (
            PARTITION BY card1
            ORDER BY "TransactionDT", "TransactionID"
        ) AS prior_transactiondt,

        COUNT(*) OVER (
            PARTITION BY card1
            ORDER BY "TransactionDT"
            RANGE BETWEEN 3600 PRECEDING AND CURRENT ROW
        ) AS transactions_in_1h

    FROM analytics.vw_transaction_analytics
    WHERE card1 IS NOT NULL
)

SELECT
    "TransactionID",
    transaction_key,
    identity_key,
    "TransactionDT",
    "TransactionAmt",
    "isFraud",
    prior_transactiondt,
    ("TransactionDT" - prior_transactiondt)
        AS seconds_since_previous_transaction,
    transactions_in_1h AS transactions_in_24h,
    CASE
        WHEN transactions_in_1h >= 3 THEN 1
        ELSE 0
    END AS velocity_flag,
    CASE
        WHEN transactions_in_1h >= 3
            THEN '3 or more card-linked transactions within rolling 1 hour'
        ELSE NULL
    END AS velocity_rule

FROM card_velocity

UNION ALL

SELECT
    "TransactionID",
    transaction_key,
    identity_key,
    "TransactionDT",
    "TransactionAmt",
    "isFraud",
    NULL AS prior_transactiondt,
    NULL AS seconds_since_previous_transaction,
    0 AS transactions_in_24h,
    0 AS velocity_flag,
    NULL AS velocity_rule

FROM analytics.vw_transaction_analytics
WHERE card1 IS NULL;