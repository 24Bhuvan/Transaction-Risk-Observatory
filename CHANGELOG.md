# ==========================================
# Transaction Risk Observatory - Git Ignore
# ==========================================

# --------------------
# Data
# --------------------
data/raw/*
data/staging/*
data/samples/*

# --------------------
# Python
# --------------------
__pycache__/
*.py[cod]
*.pyo
*.pyd
.venv/
venv/
env/
ENV/

# --------------------
# Jupyter
# --------------------
.ipynb_checkpoints/

# --------------------
# PostgreSQL / Local Files
# --------------------
*.log
*.dump
*.sql.gz

# --------------------
# OS
# --------------------
.DS_Store
Thumbs.db
desktop.ini

# --------------------
# IDE / Editors
# --------------------
.vscode/
.idea/

# --------------------
# Temporary / Generated Files
# --------------------
*.tmp
*.temp
*.bak
*.swp
*.swo

# --------------------
# Environment / Secrets
# --------------------
.env
.env.*
!.env.example