import pandas as pd
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = {
    "train_transaction.csv": ROOT / "data" / "raw" / "train_transaction.csv",
    "train_identity.csv": ROOT / "data" / "raw" / "train_identity.csv",
}

for file_name, file_path in FILES.items():
    print("=" * 100)
    print(file_name)
    print("=" * 100)

    df = pd.read_csv(file_path, low_memory=False)

    print(f"Rows    : {len(df):,}")
    print(f"Columns : {len(df.columns):,}")
    print()

    profile = pd.DataFrame({
        "Source Column": df.columns,
        "Pandas Dtype": [str(df[col].dtype) for col in df.columns],
        "Non-Null": [df[col].notna().sum() for col in df.columns],
        "Null": [df[col].isna().sum() for col in df.columns],
        "Unique": [df[col].nunique(dropna=True) for col in df.columns],
    })

    print(profile.to_string(index=False))
    print()

