# PostgreSQL Environment

## 1. Database Platform

| Component                  | Verified Configuration                    |
| -------------------------- | ----------------------------------------- |
| Database Management System | PostgreSQL                                |
| PostgreSQL Server Version  | 18.4                                      |
| PostgreSQL Client (`psql`) | 18.4                                      |
| Operating System           | Windows x86_64                            |
| Architecture               | 64-bit                                    |
| Compiler                   | MSVC 19.44.35226                          |
| Database Connection        | `postgres` database using `postgres` role |

## 2. Version Verification

### PostgreSQL Client

The PostgreSQL command-line client version was verified using:

```powershell
psql --version
```

Verified output:

```text
psql (PostgreSQL) 18.4
```

### PostgreSQL Server

The PostgreSQL server version was verified through an active database connection using:

```sql
SELECT version();
```

Verified output:

```text
PostgreSQL 18.4 on x86_64-windows, compiled by msvc-19.44.35226, 64-bit
```

## 3. Database Access

The PostgreSQL server was successfully accessed using:

```powershell
psql -U postgres -d postgres
```

The connection was successful and the server responded to SQL queries.

## 4. Project Database Environment

The Transaction Risk Observatory project will use PostgreSQL as its primary analytical database.

PostgreSQL will be responsible for:

* Raw data staging
* Data profiling
* Data quality assessment
* Relational and dimensional modeling
* ETL/ELT transformations
* Data cleaning
* Data validation and reconciliation
* Fraud-risk signal generation
* KPI calculations
* Analytical views
* Materialized reporting structures
* Indexing and query optimization
* Query performance analysis using `EXPLAIN` and `EXPLAIN ANALYZE`

## 5. Client and GUI Tools

### Command-Line Client

The project uses `psql` as the PostgreSQL command-line client.

Verified version:

```text
18.4
```

### GUI

The PostgreSQL GUI tool/version will be documented separately once the installed GUI environment is confirmed.

## 6. Environment Notes

The PostgreSQL server and client are currently running on Windows x86_64.

The project will maintain SQL scripts under the repository's `sql/` directory and use Git for version control.

The PostgreSQL version recorded in this document reflects the verified environment at project setup time.
