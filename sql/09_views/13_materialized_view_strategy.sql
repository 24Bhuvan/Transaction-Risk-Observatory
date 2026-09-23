-- PHASE 9 - STEP 9.16 - MATERIALIZED VIEW ASSESSMENT
SELECT * FROM (VALUES
 ('daily fraud summary', 'analytics.vw_daily_fraud_summary', 'Low query complexity; one grouped scan; no measured repeated refresh workload', 'No materialized view created'),
 ('weekly fraud summary', 'analytics.vw_weekly_fraud_summary', 'Low query complexity; one grouped scan; no measured repeated refresh workload', 'No materialized view created'),
 ('identity/device/card summaries', 'Phase 9 summary views', 'Reusable aggregations but current Phase 8 evidence does not establish refresh frequency or refresh-cost benefit', 'No materialized view created'),
 ('risk signal summary', 'analytics.vw_risk_signal_summary', 'Deterministic union over the transaction view; no demonstrated repeated expensive execution requirement', 'No materialized view created')
) AS assessment(candidate, source, evidence, decision);
