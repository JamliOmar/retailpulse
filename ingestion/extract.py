"""Telechargement des CSV Olist depuis Kaggle (idempotent)."""
import os
import shutil
import sys
from pathlib import Path

import kagglehub
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
DATASET = "olistbr/brazilian-ecommerce"
EXPECTED_FILES = 9


def main() -> None:
    load_dotenv(ROOT / ".env")
    DATA_DIR.mkdir(exist_ok=True)

    existing = list(DATA_DIR.glob("*.csv"))
    if len(existing) >= EXPECTED_FILES:
        print(f"{len(existing)} CSV deja presents dans data/, rien a telecharger.")
        return

    if not os.getenv("KAGGLE_API_TOKEN"):
        print("KAGGLE_API_TOKEN absent du fichier .env")
        sys.exit(1)

    print(f"Telechargement de {DATASET} depuis Kaggle...")
    source_dir = Path(kagglehub.dataset_download(DATASET))

    for csv_file in source_dir.glob("*.csv"):
        shutil.copy2(csv_file, DATA_DIR / csv_file.name)

    copied = sorted(p.name for p in DATA_DIR.glob("*.csv"))
    print(f"{len(copied)} fichiers copies dans data/ :")
    for name in copied:
        print(f"  - {name}")


if __name__ == "__main__":
    main()
