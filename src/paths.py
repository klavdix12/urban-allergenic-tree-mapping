from pathlib import Path

def get_project_root() -> Path:
    """Return the project root directory."""
    # Path(_file).resolve takes the absolute path to this script and .parent[1] move one folder up
    return Path(__file__).resolve().parents[1]

PROJECT_ROOT = get_project_root()

DATA_DIR = PROJECT_ROOT / "data"
RAW_DIR = DATA_DIR / "raw"
INTERIM_DIR = DATA_DIR / "interim"
PROCESSED_DIR = DATA_DIR / "processed"
EXTERNAL_DIR = DATA_DIR / "external"