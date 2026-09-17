# Transaction Risk Observatory — Project Scope

## 1. In Scope

The Transaction Risk Observatory project covers PostgreSQL-centric transaction analytics and rule-based fraud-risk analysis.

The project includes:

- PostgreSQL-based transaction analytics
- Data ingestion and staging
- Data profiling
- Data-quality assessment
- Relational and dimensional data modeling
- SQL-based data cleaning and transformation
- Fraud-risk signal generation
- Rule-based fraud analytics
- Transaction velocity analysis
- Temporal and behavioral anomaly analysis
- Geospatial anomaly analysis where applicable
- Entity and device risk analysis
- Risk scoring using deterministic SQL rules
- KPI development and business analysis
- Analytical views and materialized views
- PostgreSQL indexing and query optimization
- `EXPLAIN ANALYZE`-based performance analysis
- Data-quality validation and reconciliation
- Ongoing data-quality monitoring queries
- Reproducible and version-controlled SQL workflows
- Technical documentation and project reporting

## 2. Out of Scope

The project does not attempt to build or simulate a production fraud-prevention system.

The following are explicitly excluded:

- Machine-learning fraud classification
- Deep-learning fraud detection
- Predictive model training
- Real-time production transaction blocking
- Automated payment authorization or rejection
- Live banking-system integration
- Production payment processing
- Automated fraud investigation workflows
- Customer account intervention
- Automated case management
- Live alert delivery to banking or payment systems

## 3. Analytical Approach

Fraud risk will be analyzed using deterministic, rule-based SQL logic rather than machine-learning models.

The project will derive risk signals from transaction characteristics and available behavioral, temporal, geographical, payment, device, and entity-level attributes.

Examples include:

- High transaction velocity
- Unusual transaction amounts
- Rapid changes in transaction location
- Impossible-travel patterns
- Unusual transaction timing
- Abnormal entity or device behavior
- Multiple suspicious signals occurring together

These signals will be combined where appropriate to support transaction- and entity-level risk analysis.

## 4. Project Boundary

The project is an analytical fraud-risk observatory, not a production fraud engine.

Its purpose is to demonstrate how PostgreSQL and advanced SQL can be used to:

1. Ingest and structure transaction data.
2. Assess and improve data quality.
3. Build an analytical relational model.
4. Generate deterministic fraud-risk signals.
5. Analyze suspicious transaction patterns.
6. Produce fraud-related KPIs and business insights.
7. Optimize analytical query performance.
8. Establish reproducible data-quality and monitoring workflows.

The resulting outputs are intended for analytical and portfolio demonstration purposes.