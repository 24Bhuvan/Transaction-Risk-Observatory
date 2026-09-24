-- R05 - GEOGRAPHIC CAPABILITY LIMITATION.
-- addr1/addr2/dist1/dist2 are anonymized attributes, not coordinates.
CREATE OR REPLACE VIEW analytics.vw_geographic_anomalies AS
SELECT "TransactionID", transaction_key, identity_key, "TransactionDT", addr1, addr2, dist1, dist2,
       0::integer AS impossible_travel_flag,
       'Latitude/longitude fields are not available; impossible travel is not computable'::text AS geographic_limitation
FROM analytics.vw_transaction_analytics;
