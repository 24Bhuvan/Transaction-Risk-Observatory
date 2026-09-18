-- Phase 2.11 — Load source data into PostgreSQL staging
-- Uses psql \copy so files are read from the local Windows machine.
-- Source files are loaded without transformation.

\copy staging.raw_transactions FROM 'C:/Users/Bhuvan Ummidisetti/Desktop/Projects/Project 2/Transaction-Risk-Observatory/data/raw/train_transaction.csv' WITH (FORMAT csv, HEADER true);

\copy staging.raw_identity FROM 'C:/Users/Bhuvan Ummidisetti/Desktop/Projects/Project 2/Transaction-Risk-Observatory/data/raw/train_identity.csv' WITH (FORMAT csv, HEADER true);