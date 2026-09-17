# Transaction Risk Observatory — Technical Stack

## 1. Technology Overview

The Transaction Risk Observatory is a **PostgreSQL-centric transaction risk analytics project**.

PostgreSQL is the primary analytical engine and the majority of data ingestion, transformation, validation, risk-signal generation, KPI computation, and performance analysis will be implemented in SQL.

## 2. Core Technology Stack

| Component             | Technology               | Role                                                                                                            |
| --------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------- |
| **Database**          | PostgreSQL               | Primary database, analytical engine, transformation engine, and risk-analysis platform                          |
| **Primary Language**  | SQL                      | Data ingestion, profiling, transformation, validation, analytics, KPI development, risk scoring, and monitoring |
| **Database Client**   | `psql` / pgAdmin         | Database administration, SQL execution, inspection, and development                                             |
| **Version Control**   | Git                      | Version control for SQL, documentation, configuration, and project artifacts                                    |
| **Remote Repository** | GitHub                   | Remote repository, project history, collaboration, and portfolio presentation                                   |
| **Data Source**       | IEEE-CIS Fraud Detection | Transaction and identity source data used for the analytical project                                            |

## 3. PostgreSQL Role

PostgreSQL is the **center of gravity** of the project.

The following capabilities will primarily be implemented within PostgreSQL:

* Data ingestion
* Staging tables
* Data profiling
* Data-quality analysis
* Relational and dimensional modeling
* ETL/ELT
* Data cleaning
* Data transformation
* Referential-integrity validation
* Advanced SQL analytics
* Window-function analysis
* CTE-based analytical pipelines
* Temporal analysis
* Geospatial calculations where applicable
* Rule-based risk-signal generation
* Deterministic risk scoring
* Analytical views
* Materialized views
* KPI computation
* Data-quality monitoring
* Indexing
* Query optimization
* `EXPLAIN ANALYZE`

## 4. SQL Capabilities

The project will use progressively more advanced PostgreSQL SQL, including:

* `SELECT`
* Filtering and conditional logic
* Aggregations
* `GROUP BY`
* `CASE`
* `COALESCE`
* `CAST`
* String functions
* Date/time functions
* Multi-table joins
* Self-joins
* Subqueries
* Common Table Expressions (CTEs)
* Recursive CTEs where analytically justified
* Window functions
* `LAG()`
* `LEAD()`
* `ROW_NUMBER()`
* Running and rolling aggregates
* `ROLLUP`
* `CUBE`
* `GROUPING SETS`
* JSONB operations where applicable
* Array operations where applicable
* PostgreSQL functions
* Views
* Materialized views
* Indexes
* Partial indexes
* Partitioning where justified
* `EXPLAIN`
* `EXPLAIN ANALYZE`

## 5. Database Development Environment

The primary database-development interfaces will be:

### `psql`

Used for:

* Running SQL scripts
* Loading data
* Database administration
* Reproducible command-line workflows
* Pipeline execution

### pgAdmin

Used where useful for:

* Database inspection
* Schema exploration
* Query development
* Execution-plan inspection
* Visual database administration

Both tools interact with the same PostgreSQL analytical environment.

## 6. Version Control

Git and GitHub will be used to manage the project as reproducible analytical code.

Version-controlled artifacts include:

* SQL scripts
* Database DDL
* ETL scripts
* Analytical queries
* QA scripts
* Monitoring queries
* Documentation
* Configuration templates
* Project reports
* Repository metadata

Raw IEEE-CIS datasets will not be committed to the repository unless a deliberately small, approved sample is created and explicitly allowed by the project's data-handling rules.

## 7. Optional Supporting Tools

Python and Jupyter may be used as supporting tools when they provide value beyond what PostgreSQL can reasonably provide.

Potential uses include:

* Result inspection
* Exploratory visualization
* Lightweight reporting
* Query-result analysis
* Supporting demonstrations
* Plot generation

Potential visualization libraries:

* Matplotlib
* Seaborn

These tools are **supporting components**, not the primary analytical engine.

## 8. Technology Boundary

The project should remain PostgreSQL-centric.

Python should not become the primary location for:

* Data cleaning
* Core transformations
* Fraud-risk logic
* KPI calculations
* Data-quality validation
* Primary analytical queries

Those responsibilities should remain in PostgreSQL wherever practical.

The intended architecture is:

```text
IEEE-CIS Data
      ↓
PostgreSQL Staging
      ↓
PostgreSQL Data Profiling
      ↓
PostgreSQL Analytical Model
      ↓
PostgreSQL ETL / Cleaning
      ↓
PostgreSQL Risk Signals
      ↓
PostgreSQL KPIs / Views
      ↓
PostgreSQL Performance Optimization
      ↓
Optional Python / Jupyter Visualization
```

## 9. Final Technology Principle

The project will demonstrate **PostgreSQL as an analytical platform**, not merely as a storage layer.

Python, Jupyter, Matplotlib, and Seaborn may supplement the project when appropriate, but the core data pipeline, analytical logic, fraud-risk rules, KPI calculations, validation, and optimization will be implemented and demonstrated primarily through PostgreSQL and SQL.
