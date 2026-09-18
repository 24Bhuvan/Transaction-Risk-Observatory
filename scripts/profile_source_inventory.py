from pathlib import Path
from datetime import datetime
import csv
import os
import subprocess


# ============================================================
# Configuration
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]

RAW_DIR = PROJECT_ROOT / "data" / "raw"
OUTPUT_FILE = PROJECT_ROOT / "docs" / "requirements" / "data_source_inventory.md"

PRIMARY_FILES = [
    "train_transaction.csv",
    "train_identity.csv",
]

EXCLUDED_FILES = [
    "test_transaction.csv",
    "test_identity.csv",
    "sample_submission.csv",
]


# ============================================================
# Utility Functions
# ============================================================

def format_number(value):
    """Format integers with thousands separators."""
    return f"{value:,}"


def format_size(size_bytes):
    """Return human-readable file size."""
    if size_bytes < 1024:
        return f"{size_bytes} B"

    if size_bytes < 1024 ** 2:
        return f"{size_bytes / 1024:.2f} KB"

    if size_bytes < 1024 ** 3:
        return f"{size_bytes / (1024 ** 2):.2f} MB"

    return f"{size_bytes / (1024 ** 3):.2f} GB"


def detect_encoding(file_path):
    """
    Detect a practical CSV encoding.

    IEEE-CIS CSV files are normally UTF-8 compatible,
    but we test UTF-8 first and fall back to Latin-1.
    """
    encodings = ["utf-8", "utf-8-sig", "latin-1"]

    for encoding in encodings:
        try:
            with open(file_path, "r", encoding=encoding) as file:
                file.read(100000)

            return encoding

        except UnicodeDecodeError:
            continue

    return "unknown"


def detect_delimiter(file_path, encoding):
    """Detect CSV delimiter using csv.Sniffer."""
    try:
        with open(
            file_path,
            "r",
            encoding=encoding,
            newline=""
        ) as file:

            sample = file.read(100000)

            dialect = csv.Sniffer().sniff(
                sample,
                delimiters=",;\t|"
            )

            return dialect.delimiter

    except Exception:
        return ","


def inspect_csv(file_path):
    """
    Inspect a CSV without loading the entire dataset into memory.

    Returns:
        rows
        columns
        column_names
        encoding
        delimiter
        header_present
        empty_file
        target_present
    """

    file_size = file_path.stat().st_size

    if file_size == 0:
        return {
            "rows": 0,
            "columns": 0,
            "column_names": [],
            "encoding": "unknown",
            "delimiter": ",",
            "header_present": False,
            "empty_file": True,
            "target_present": False,
        }

    encoding = detect_encoding(file_path)
    delimiter = detect_delimiter(file_path, encoding)

    rows = 0
    column_names = []

    with open(
        file_path,
        "r",
        encoding=encoding,
        newline=""
    ) as file:

        reader = csv.reader(file, delimiter=delimiter)

        try:
            header = next(reader)
        except StopIteration:
            header = []

        column_names = [
            column.strip()
            for column in header
        ]

        for _ in reader:
            rows += 1

    return {
        "rows": rows,
        "columns": len(column_names),
        "column_names": column_names,
        "encoding": encoding,
        "delimiter": repr(delimiter),
        "header_present": bool(column_names),
        "empty_file": False,
        "target_present": "isFraud" in column_names,
    }


def get_git_remote():
    """Return configured Git remote URL, if available."""

    try:
        result = subprocess.run(
            ["git", "remote", "-v"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            return "Not available"

        lines = result.stdout.strip().splitlines()

        if not lines:
            return "Not configured"

        return lines[0].strip()

    except Exception:
        return "Not available"


def check_gitignore():
    """
    Check whether data/raw is protected by .gitignore.

    This is a basic textual check, not a complete Git staging test.
    """

    gitignore = PROJECT_ROOT / ".gitignore"

    if not gitignore.exists():
        return False, "No .gitignore file found."

    content = gitignore.read_text(
        encoding="utf-8",
        errors="ignore"
    )

    patterns = [
        "data/raw",
        "data/raw/",
        "data/raw/*",
        "*.csv",
    ]

    matched = [
        pattern
        for pattern in patterns
        if pattern in content
    ]

    if matched:
        return True, ", ".join(matched)

    return False, "No obvious raw-data exclusion pattern found."


def check_git_status():
    """Return current Git status."""

    try:
        result = subprocess.run(
            ["git", "status", "--short"],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )

        if result.returncode != 0:
            return "Git status unavailable"

        if not result.stdout.strip():
            return "Clean"

        return "Changes present"

    except Exception:
        return "Git status unavailable"


def find_file(file_name):
    """
    Find a file anywhere under data/raw.

    This allows the inventory to work even if the files are
    accidentally placed inside a subdirectory.
    """

    matches = list(RAW_DIR.rglob(file_name))

    if not matches:
        return None

    return matches[0]


# ============================================================
# Main Inventory Process
# ============================================================

def main():

    print("=" * 70)
    print("IEEE-CIS SOURCE DATA INVENTORY")
    print("=" * 70)

    if not RAW_DIR.exists():
        raise FileNotFoundError(
            f"Raw data directory does not exist: {RAW_DIR}"
        )

    OUTPUT_FILE.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    inventory = {}

    # --------------------------------------------------------
    # Inspect all CSV files in data/raw
    # --------------------------------------------------------

    csv_files = sorted(
        RAW_DIR.rglob("*.csv")
    )

    print(f"\nCSV files found: {len(csv_files)}")

    for file_path in csv_files:

        relative_path = file_path.relative_to(
            PROJECT_ROOT
        )

        print(f"\nInspecting: {relative_path}")

        metadata = inspect_csv(file_path)

        metadata["path"] = str(relative_path)
        metadata["size_bytes"] = file_path.stat().st_size
        metadata["size"] = format_size(
            file_path.stat().st_size
        )

        inventory[file_path.name] = metadata

        print(
            f"Rows: {format_number(metadata['rows'])}"
        )

        print(
            f"Columns: {format_number(metadata['columns'])}"
        )

        print(
            f"Size: {metadata['size']}"
        )

        print(
            f"Encoding: {metadata['encoding']}"
        )

        print(
            f"Delimiter: {metadata['delimiter']}"
        )

    # --------------------------------------------------------
    # Determine primary files
    # --------------------------------------------------------

    primary_results = {}

    for file_name in PRIMARY_FILES:

        file_path = find_file(file_name)

        if file_path:

            primary_results[file_name] = inventory[
                file_path.name
            ]

        else:

            primary_results[file_name] = None

    # --------------------------------------------------------
    # Determine excluded files
    # --------------------------------------------------------

    excluded_results = {}

    for file_name in EXCLUDED_FILES:

        file_path = find_file(file_name)

        if file_path:

            excluded_results[file_name] = inventory[
                file_path.name
            ]

        else:

            excluded_results[file_name] = None

    # --------------------------------------------------------
    # Target detection
    # --------------------------------------------------------

    target_files = []

    for file_name, metadata in inventory.items():

        if metadata["target_present"]:
            target_files.append(file_name)

    # --------------------------------------------------------
    # Git metadata
    # --------------------------------------------------------

    git_remote = get_git_remote()

    gitignore_protected, gitignore_evidence = check_gitignore()

    git_status = check_git_status()

    # --------------------------------------------------------
    # Generate Markdown
    # --------------------------------------------------------

    generated_date = datetime.now().strftime(
        "%Y-%m-%d %H:%M:%S"
    )

    lines = []

    lines.append("# Data Source Inventory")
    lines.append("")

    lines.append("## 1. Dataset Identification")
    lines.append("")
    lines.append("**Dataset:** IEEE-CIS Fraud Detection")
    lines.append("")
    lines.append(
        "**Source:** Kaggle / IEEE-CIS Fraud Detection"
    )
    lines.append("")
    lines.append(
        "**Inventory generated:** "
        f"{generated_date}"
    )
    lines.append("")

    lines.append("## 2. Analytical Scope")
    lines.append("")
    lines.append(
        "The primary analytical dataset consists of "
        "`train_transaction.csv` and `train_identity.csv`."
    )
    lines.append("")
    lines.append(
        "The training transaction data is the primary "
        "analytical source because it contains the "
        "`isFraud` target variable."
    )
    lines.append("")
    lines.append(
        "Test datasets are preserved in `data/raw/` but "
        "are excluded from the initial analytical pipeline."
    )
    lines.append("")

    lines.append("## 3. Source Location")
    lines.append("")
    lines.append(
        "**Original Source:** Kaggle / IEEE-CIS Fraud Detection"
    )
    lines.append("")
    lines.append(
        "**Local Source Directory:** `data/raw/`"
    )
    lines.append("")

    lines.append("## 4. File Inventory")
    lines.append("")
    lines.append(
        "| File | Purpose | Rows | Columns | Size | "
        "Encoding | Delimiter | Header |"
    )
    lines.append(
        "|------|---------|------|---------|------|"
        "----------|-----------|--------|"
    )

    purpose_map = {
        "train_transaction.csv": "Transaction data",
        "train_identity.csv": "Identity/device data",
        "test_transaction.csv": "Test transaction data",
        "test_identity.csv": "Test identity/device data",
        "sample_submission.csv": "Submission template",
    }

    for file_name in sorted(inventory):

        metadata = inventory[file_name]

        purpose = purpose_map.get(
            file_name,
            "Additional source file"
        )

        header = (
            "Yes"
            if metadata["header_present"]
            else "No"
        )

        lines.append(
            f"| `{file_name}` | "
            f"{purpose} | "
            f"{format_number(metadata['rows'])} | "
            f"{format_number(metadata['columns'])} | "
            f"{metadata['size']} | "
            f"{metadata['encoding']} | "
            f"`{metadata['delimiter']}` | "
            f"{header} |"
        )

    lines.append("")

    lines.append("## 5. Primary Analytical Files")
    lines.append("")

    for file_name in PRIMARY_FILES:

        metadata = primary_results[file_name]

        if metadata:

            lines.append(
                f"### `{file_name}`"
            )
            lines.append("")
            lines.append(
                f"- Path: `{metadata['path']}`"
            )
            lines.append(
                f"- Rows: {format_number(metadata['rows'])}"
            )
            lines.append(
                f"- Columns: {format_number(metadata['columns'])}"
            )
            lines.append(
                f"- Size: {metadata['size']}"
            )
            lines.append(
                f"- Encoding: `{metadata['encoding']}`"
            )
            lines.append(
                f"- Delimiter: `{metadata['delimiter']}`"
            )
            lines.append(
                f"- Header present: "
                f"{metadata['header_present']}"
            )
            lines.append("")

        else:

            lines.append(
                f"### `{file_name}`"
            )
            lines.append("")
            lines.append(
                "**Status:** NOT FOUND"
            )
            lines.append("")

    lines.append("## 6. Excluded Files")
    lines.append("")

    for file_name in EXCLUDED_FILES:

        metadata = excluded_results[file_name]

        if metadata:

            lines.append(
                f"- `{file_name}` — present but excluded "
                "from the initial analytical pipeline."
            )

        else:

            lines.append(
                f"- `{file_name}` — not found."
            )

    lines.append("")

    lines.append("## 7. Target Variable")
    lines.append("")

    lines.append("**Target:** `isFraud`")
    lines.append("")

    if target_files:

        lines.append(
            "The target variable was detected in:"
        )
        lines.append("")

        for file_name in target_files:
            lines.append(
                f"- `{file_name}`"
            )

    else:

        lines.append(
            "**WARNING:** `isFraud` was not detected "
            "in the inspected CSV headers."
        )

    lines.append("")

    lines.append("## 8. Source File Relationships")
    lines.append("")
    lines.append(
        "`train_transaction.csv` contains transaction-level "
        "records and the `isFraud` target."
    )
    lines.append("")
    lines.append(
        "`train_identity.csv` contains identity/device-related "
        "attributes associated with transaction records."
    )
    lines.append("")
    lines.append(
        "The exact join key and join coverage will be verified "
        "during the profiling and data-modeling stages."
    )
    lines.append("")

    lines.append("## 9. Initial Data Integrity Checks")
    lines.append("")

    lines.append(
        f"- CSV files discovered under `data/raw/`: "
        f"**{len(csv_files)}**"
    )

    empty_files = [
        name
        for name, metadata in inventory.items()
        if metadata["empty_file"]
    ]

    if empty_files:

        lines.append(
            "- Empty files detected: "
            + ", ".join(
                f"`{name}`"
                for name in empty_files
            )
        )

    else:

        lines.append(
            "- Empty CSV files detected: **None**"
        )

    lines.append(
        "- Unexpected/unclassified CSV files: "
        + (
            ", ".join(
                f"`{name}`"
                for name in inventory
                if name not in PRIMARY_FILES
                and name not in EXCLUDED_FILES
            )
            if any(
                name not in PRIMARY_FILES
                and name not in EXCLUDED_FILES
                for name in inventory
            )
            else "None"
        )
    )

    lines.append("")

    lines.append("## 10. Data Preservation and Version Control")
    lines.append("")

    lines.append(
        "Raw files are preserved locally under `data/raw/`."
    )
    lines.append("")

    lines.append(
        "Raw datasets should remain outside Git version control."
    )
    lines.append("")

    lines.append(
        f"`.gitignore` raw-data protection detected: "
        f"**{'Yes' if gitignore_protected else 'No'}**"
    )
    lines.append("")

    lines.append(
        f"Gitignore evidence: `{gitignore_evidence}`"
    )
    lines.append("")

    lines.append(
        f"Git remote: `{git_remote}`"
    )
    lines.append("")

    lines.append(
        f"Current Git working tree status: **{git_status}**"
    )
    lines.append("")

    lines.append("## 11. Ingestion Information")
    lines.append("")

    lines.append(
        "**Inventory generation date:** "
        f"{generated_date}"
    )
    lines.append("")

    lines.append(
        "The ingestion/acquisition date of the raw dataset "
        "is not inferred from file metadata. It should be "
        "recorded separately if the actual acquisition date "
        "is known."
    )
    lines.append("")

    lines.append("## 12. Analytical Inclusion / Exclusion Decision")
    lines.append("")

    lines.append(
        "**Included in initial analytical pipeline:**"
    )
    lines.append("")

    lines.append(
        "- `train_transaction.csv`"
    )
    lines.append(
        "- `train_identity.csv`"
    )
    lines.append("")

    lines.append(
        "**Excluded from initial analytical pipeline:**"
    )
    lines.append("")

    lines.append(
        "- `test_transaction.csv`"
    )
    lines.append(
        "- `test_identity.csv`"
    )
    lines.append(
        "- `sample_submission.csv`"
    )
    lines.append("")

    lines.append(
        "Test data will only be incorporated later if a "
        "specific analytical or validation requirement is "
        "defined."
    )
    lines.append("")

    lines.append("## 13. Metadata Verification Method")
    lines.append("")

    lines.append(
        "Row counts and column counts were calculated directly "
        "from the local CSV files."
    )
    lines.append("")

    lines.append(
        "File sizes were obtained directly from the local "
        "filesystem."
    )
    lines.append("")

    lines.append(
        "Encoding and delimiter information were inspected "
        "from the local files."
    )
    lines.append("")

    lines.append(
        "No row counts, column counts, or file sizes were "
        "manually copied from external dataset documentation."
    )
    lines.append("")

    lines.append("## 14. Notes")
    lines.append("")

    lines.append(
        "Detailed column-level profiling, missing-value "
        "analysis, duplicate analysis, distributions, "
        "fraud-rate analysis, and data-quality assessment "
        "will be performed in subsequent Phase 2 steps."
    )
    lines.append("")

    # --------------------------------------------------------
    # Write output
    # --------------------------------------------------------

    OUTPUT_FILE.write_text(
        "\n".join(lines),
        encoding="utf-8"
    )

    print("\n" + "=" * 70)
    print("INVENTORY GENERATED")
    print("=" * 70)
    print(f"Output: {OUTPUT_FILE}")

    print("\nPrimary analytical files:")

    for file_name in PRIMARY_FILES:

        if primary_results[file_name]:
            print(f"  [FOUND] {file_name}")
        else:
            print(f"  [MISSING] {file_name}")

    print("\nTarget detected in:")

    for file_name in target_files:
        print(f"  [TARGET] {file_name}")


if __name__ == "__main__":
    main()