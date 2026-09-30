# Transaction Risk Observatory — System Requirements & Dependencies

## 1. Primary Engine & Infrastructure

The Transaction Risk Observatory is an in-database analytical data warehouse and monitoring platform designed specifically for PostgreSQL. It does not rely on third-party ETL frameworks, Python data-manipulation libraries, or distributed execution engines.

| Component | Verified Specification | Role |
|:---|:---|:---|
| **Database Server** | PostgreSQL 18 (Tested on 18.4 x86_64) | Primary storage, ELT engine, analytical query processing, feature engineering, and monitoring |
| **Database Client** | `psql` (PostgreSQL 18.4 CLI) | Batch script execution, ingestion, data administration, and gate evaluation |
| **Operating System** | Windows x86_64, Linux, or macOS | Host environment |
| **Version Control** | Git 2.x+ | Version control for SQL DDL, queries, configuration, and documentation |

---

## 2. Resource & Sizing Guidelines

| Resource | Minimum Required | Recommended Production | Notes |
|:---|---:|---:|:---|
| **RAM** | 8 GB | 16 GB+ | Facilitates multi-pass analytical scans and parallel hash joins |
| **Disk Space** | 12 GB | 20 GB+ | Storage breakdown: raw CSVs (~1.3 GB), uncompressed tables (~5.5 GB), indexes (~1.8 GB), temp space |
| **CPU** | 4 Cores | 8 Cores+ | Supports PostgreSQL parallel query workers (`max_parallel_workers_per_gather = 2+`) |

### Recommended PostgreSQL Configuration (`postgresql.conf`)
```ini
# Recommended baseline settings for running workloads on standard workstation
shared_buffers = 128MB          # Minimum 128MB, recommended 1GB+ if dedicated
work_mem = 64MB                 # Sufficient for in-memory window aggregations and LATERAL projections
maintenance_work_mem = 256MB    # Accelerates B-Tree index creation
effective_cache_size = 4GB      # Informs planner of available OS buffer cache
max_parallel_workers_per_gather = 2
```

---

## 3. Optional Supporting Tooling

Supporting utility scripts in the `scripts/` directory use standard library Python (no external pip dependencies required):
- **Python**: Python 3.10+
- **Standard Modules Used**: `csv`, `os`, `sys`, `json`, `math`
- **Zero Third-Party Pip Packages**: No external dependencies such as pandas, numpy, scikit-learn, dbt, or airflow are required. All transformations and analyses execute directly within PostgreSQL.

---

## 4. Source Dataset

- **Dataset**: IEEE-CIS Fraud Detection Dataset (available on Kaggle)
- **Primary Source Files**:
  - `train_transaction.csv` (394 columns, 590,540 rows, ~683 MB)
  - `train_identity.csv` (41 columns, 144,233 rows, ~26.5 MB)
- **Placement**: Raw files are placed in `data/raw/` (ignored by Git).
