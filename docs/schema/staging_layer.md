# Staging Layer Architecture

## 1. Purpose

The staging layer provides the first PostgreSQL representation of the
original IEEE-CIS source data.

Its purpose is safe, traceable ingestion while preserving the structure
and semantics of the source files.

---

## 2. Architecture

```text
                    IEEE-CIS CSV
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
    train_transaction.csv    train_identity.csv
              │                     │
              ▼                     ▼
 staging.raw_transactions   staging.raw_identity