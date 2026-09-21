ALTER TABLE analytics.fact_transaction
    ADD CONSTRAINT pk_fact_transaction
    PRIMARY KEY (transaction_key);

ALTER TABLE analytics.fact_transaction
    ADD CONSTRAINT uq_fact_transaction_transactionid
    UNIQUE (TransactionID);

ALTER TABLE analytics.fact_transaction
    ADD CONSTRAINT fact_transaction_TransactionID_not_null
    CHECK (TransactionID IS NOT NULL);


ALTER TABLE analytics.dim_identity
    ADD CONSTRAINT pk_dim_identity
    PRIMARY KEY (identity_key);

ALTER TABLE analytics.dim_identity
    ADD CONSTRAINT uq_dim_identity_transactionid
    UNIQUE (TransactionID);

ALTER TABLE analytics.dim_identity
    ADD CONSTRAINT dim_identity_TransactionID_not_null
    CHECK (TransactionID IS NOT NULL);

ALTER TABLE analytics.fact_transaction
    ADD CONSTRAINT fk_fact_transaction_identity
    FOREIGN KEY (identity_key)
    REFERENCES analytics.dim_identity (identity_key);
