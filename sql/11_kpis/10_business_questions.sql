-- ============================================================================
-- PHASE 11.11 — MEASURABLE BUSINESS-QUESTION EVIDENCE
-- ============================================================================
-- Purpose:
-- Provide direct, quantitative evidence for business questions Q1 through Q7
-- using the validated Phase 11 KPI summary views.
--
-- Business Questions:
--   Q1: What is the overall fraud level?
--   Q2: How much financial exposure is associated with fraud?
--   Q3: When does fraud activity concentrate?
--   Q4: Which observable attributes have elevated observed fraud rates?
--   Q5: Which Phase 10 signals are associated with known fraud?
--   Q6: How does observed fraud incidence vary across risk scores/cohorts?
--   Q7: Is fraud concentrated within a relatively small portion of the transaction
--       population or distributed broadly?
-- ============================================================================

DROP VIEW IF EXISTS analytics.kpi_business_questions CASCADE;

CREATE OR REPLACE VIEW analytics.kpi_business_questions AS
WITH q3 AS (
    SELECT
        transaction_hour::numeric AS value_1,
        fraud_transactions::numeric AS value_2,
        fraud_rate AS value_3,
        'Peak fraud rate hour: hour ' || transaction_hour || ' with ' || fraud_transactions || ' fraud transactions and fraud rate ' || (ROUND(fraud_rate * 100, 2)) || '%' AS metric_description
    FROM analytics.kpi_hourly_fraud
    ORDER BY fraud_rate DESC
    LIMIT 1
),
q5 AS (
    SELECT
        flagged_transactions::numeric AS value_1,
        fraudulent_flagged_transactions::numeric AS value_2,
        fraud_capture_rate AS value_3,
        'Top signal by capture rate: ' || signal_name || ' captures ' || fraudulent_flagged_transactions || ' fraud tx (' || (ROUND(fraud_capture_rate * 100, 2)) || '% of all fraud)' AS metric_description
    FROM analytics.kpi_signal_performance
    ORDER BY fraud_capture_rate DESC
    LIMIT 1
),
q6 AS (
    SELECT
        risk_score::numeric AS value_1,
        fraud_count::numeric AS value_2,
        fraud_rate AS value_3,
        'Risk Band ' || risk_band || ' (Score ' || risk_score || '): ' || fraud_count || ' fraud tx, ' || (ROUND(fraud_rate * 100, 2)) || '% fraud rate' AS metric_description
    FROM analytics.kpi_risk_score_summary
    WHERE risk_band = 'HIGH'
    ORDER BY risk_score DESC
    LIMIT 1
),
q7 AS (
    SELECT
        concentration_rank::numeric AS value_1,
        fraud_count::numeric AS value_2,
        cumulative_fraud_count_share AS value_3,
        'Concentration in ' || dimension_name || ': top value ' || dimension_value || ' represents ' || (ROUND(cumulative_fraud_count_share * 100, 2)) || '% of fraud' AS metric_description
    FROM analytics.kpi_fraud_concentration
    WHERE dimension_name = 'card4' AND concentration_rank = 1
)
SELECT
    'Q1'::text AS question_id,
    'What is the overall fraud level?'::text AS business_question,
    total_transactions::numeric AS metric_value_1,
    fraud_transactions::numeric AS metric_value_2,
    fraud_rate AS metric_value_3,
    'Total population: 590,540 tx, 20,663 fraud tx, 3.4990% observed fraud rate'::text AS metric_description
FROM analytics.kpi_fraud_summary

UNION ALL

SELECT
    'Q2',
    'How much financial exposure is associated with fraud?',
    total_transaction_amount,
    fraud_transaction_amount,
    fraud_amount_share,
    'Total value: $79.74M, Fraud value: $3.08M, 3.8674% fraud amount share, $14.73 fraud premium'
FROM analytics.kpi_amount_summary

UNION ALL

SELECT
    'Q3',
    'When does fraud activity concentrate?',
    value_1,
    value_2,
    value_3,
    metric_description
FROM q3

UNION ALL

SELECT
    'Q4',
    'Which observable attributes have elevated observed fraud rates?',
    transaction_count::numeric,
    fraud_count::numeric,
    fraud_rate,
    'Elevated segment: ' || dimension_name || ' = ' || segment_value || ' (fraud rate ' || (ROUND(fraud_rate * 100, 2)) || '%, ' || fraud_count || ' fraud tx)'
FROM analytics.kpi_segmentation_summary
WHERE dimension_name = 'product' AND segment_value = 'C'

UNION ALL

SELECT
    'Q5',
    'Which Phase 10 signals are associated with known fraud?',
    value_1,
    value_2,
    value_3,
    metric_description
FROM q5

UNION ALL

SELECT
    'Q6',
    'How does observed fraud incidence vary across risk scores/cohorts?',
    value_1,
    value_2,
    value_3,
    metric_description
FROM q6

UNION ALL

SELECT
    'Q7',
    'Is fraud concentrated within a relatively small portion of the transaction population or distributed broadly?',
    value_1,
    value_2,
    value_3,
    metric_description
FROM q7;

-- Display Business Questions and Evidence
SELECT
    question_id,
    business_question,
    metric_value_1,
    metric_value_2,
    metric_value_3,
    metric_description
FROM analytics.kpi_business_questions
ORDER BY question_id;