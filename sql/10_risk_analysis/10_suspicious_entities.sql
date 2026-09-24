-- R09 - SUSPICIOUS IDENTITY ENTITIES.
CREATE OR REPLACE VIEW analytics.vw_suspicious_entities AS
SELECT identity_key, 'identity'::text AS entity_type, COUNT(*) AS transaction_count, COUNT(*) FILTER (WHERE "isFraud"=1) AS fraud_transaction_count, COUNT(*) FILTER (WHERE multiple_signal_flag=1) AS flagged_transaction_count, SUM(signal_count) AS risk_signal_count, MAX(risk_score) AS max_risk_score, AVG(risk_score) AS average_risk_score, COUNT(*) FILTER (WHERE "isFraud"=1)::numeric/NULLIF(COUNT(*),0) AS fraud_rate
FROM analytics.vw_risk_scoring WHERE identity_key IS NOT NULL GROUP BY identity_key;
