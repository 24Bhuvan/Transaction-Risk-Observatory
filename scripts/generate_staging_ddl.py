from pathlib import Path
import pandas as pd


ROOT = Path(__file__).resolve().parents[1]

TRANSACTION_FILE = ROOT / "data" / "raw" / "train_transaction.csv"
IDENTITY_FILE = ROOT / "data" / "raw" / "train_identity.csv"

OUTPUT_FILE = ROOT / "sql" / "02_staging" / "01_create_staging_tables.sql"


def map_transaction_type(column):
    explicit = {
        "TransactionID": "BIGINT",
        "isFraud": "SMALLINT",
        "TransactionDT": "BIGINT",
        "TransactionAmt": "NUMERIC",
        "ProductCD": "TEXT",
        "card1": "BIGINT",
        "card4": "TEXT",
        "card6": "TEXT",
        "P_emaildomain": "TEXT",
        "R_emaildomain": "TEXT",
    }

    if column in explicit:
        return explicit[column]

    if column.startswith(("C", "D", "V")):
        return "DOUBLE PRECISION"

    if column in {"card2", "card3", "card5", "addr1", "addr2", "dist1", "dist2"}:
        return "DOUBLE PRECISION"

    if column.startswith("M"):
        return "TEXT"

    raise ValueError(f"Unmapped transaction column: {column}")


def map_identity_type(column):
    explicit = {
        "TransactionID": "BIGINT",
        "id_12": "TEXT",
        "id_15": "TEXT",
        "id_16": "TEXT",
        "id_23": "TEXT",
        "id_27": "TEXT",
        "id_28": "TEXT",
        "id_29": "TEXT",
        "id_30": "TEXT",
        "id_31": "TEXT",
        "id_33": "TEXT",
        "id_34": "TEXT",
        "id_35": "TEXT",
        "id_36": "TEXT",
        "id_37": "TEXT",
        "id_38": "TEXT",
        "DeviceType": "TEXT",
        "DeviceInfo": "TEXT",
    }

    if column in explicit:
        return explicit[column]

    if column.startswith("id_"):
        return "DOUBLE PRECISION"

    raise ValueError(f"Unmapped identity column: {column}")


def quote_identifier(column):
    return f'"{column}"'


def create_table_sql(table_name, columns):
    lines = []

    for column, pg_type in columns:
        lines.append(f"    {quote_identifier(column)} {pg_type}")

    return (
        f"CREATE TABLE staging.{table_name} (\n"
        + ",\n".join(lines)
        + "\n);\n"
    )


transaction_columns = pd.read_csv(
    TRANSACTION_FILE,
    nrows=0
).columns.tolist()

identity_columns = pd.read_csv(
    IDENTITY_FILE,
    nrows=0
).columns.tolist()


transaction_mapping = [
    (column, map_transaction_type(column))
    for column in transaction_columns
]

identity_mapping = [
    (column, map_identity_type(column))
    for column in identity_columns
]


if len(transaction_mapping) != 394:
    raise ValueError(
        f"Expected 394 transaction columns, found {len(transaction_mapping)}"
    )

if len(identity_mapping) != 41:
    raise ValueError(
        f"Expected 41 identity columns, found {len(identity_mapping)}"
    )


ddl = """-- Phase 2.8 — Staging Table DDL
-- Source-faithful staging layer.
-- No PRIMARY KEY, FOREIGN KEY, UNIQUE, or CHECK constraints.
-- Constraints are intentionally deferred so source-data quality issues
-- remain visible to later profiling and quality phases.

CREATE SCHEMA IF NOT EXISTS staging;

"""

ddl += create_table_sql("raw_transactions", transaction_mapping)
ddl += "\n"
ddl += create_table_sql("raw_identity", identity_mapping)

OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
OUTPUT_FILE.write_text(ddl, encoding="utf-8")

print(f"Generated: {OUTPUT_FILE}")
print(f"Transaction columns: {len(transaction_mapping)}")
print(f"Identity columns: {len(identity_mapping)}")
print("Total columns:", len(transaction_mapping) + len(identity_mapping))