-- ============================================================
-- PHASE 10 — TRANSACTION RISK ANALYSIS
-- Orchestrator / Entry Point
-- ============================================================

\echo '============================================================'
\echo 'PHASE 10 — TRANSACTION RISK ANALYSIS'
\echo '============================================================'

\echo '10.1 Baseline'
\ir 01_risk_analysis_baseline.sql

\echo '10.3 Velocity Analysis'
\ir 02_velocity_analysis.sql

\echo '10.4 Amount Anomalies'
\ir 03_amount_anomalies.sql

\echo '10.5 Entity / Device Anomalies'
\ir 04_entity_device_anomalies.sql

\echo '10.6 Off-Hours Analysis'
\ir 05_off_hours_analysis.sql

\echo '10.7 Geographic Anomalies'
\ir 06_geographic_anomalies.sql

\echo '10.8 Composed Risk Signals'
\ir 07_composed_risk_signals.sql

\echo '10.9 Rule-Based Risk Scoring'
\ir 08_risk_scoring.sql

\echo '10.10 Suspicious Transactions'
\ir 09_suspicious_transactions.sql

\echo '10.11 Suspicious Entities'
\ir 10_suspicious_entities.sql

\echo '10.12 Pattern Validation'
\ir 11_pattern_validation.sql

\echo '10.13 Phase 10 Validation'
\ir 12_phase_10_validation.sql

\echo '10.17 Final Gate'
\ir 13_phase_10_final_gate.sql