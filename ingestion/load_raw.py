"""Chargement des CSV Olist dans le schema raw de PostgreSQL (idempotent)."""
import csv
import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv
from psycopg2 import sql

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "data"
SCHEMA = "raw"


def table_name(csv_path: Path) -> str:
    """olist_orders_dataset.csv -> orders"""
    name = csv_path.stem
    name = name.removeprefix("olist_").removesuffix("_dataset")
    return name


def connect():
    load_dotenv(ROOT / ".env")
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "localhost"),
        port=os.getenv("POSTGRES_PORT", "5432"),
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=os.environ["POSTGRES_DB"],
    )


def load_file(cur, csv_path: Path) -> int:
    table = table_name(csv_path)

    with open(csv_path, "r", encoding="utf-8-sig", newline="") as f:
        columns = next(csv.reader(f))

    cols_ddl = sql.SQL(", ").join(
        sql.SQL("{} text").format(sql.Identifier(c)) for c in columns
    )
    target = sql.Identifier(SCHEMA, table)

    cur.execute(sql.SQL("DROP TABLE IF EXISTS {}").format(target))
    cur.execute(
        sql.SQL(
            "CREATE TABLE {} ({}, _loaded_at timestamptz DEFAULT now(), "
            "_source_file text DEFAULT {})"
        ).format(target, cols_ddl, sql.Literal(csv_path.name))
    )

    copy_stmt = sql.SQL(
        "COPY {} ({}) FROM STDIN WITH (FORMAT csv, HEADER true, NULL '', ENCODING 'UTF8')"
    ).format(target, sql.SQL(", ").join(sql.Identifier(c) for c in columns))

    with open(csv_path, "r", encoding="utf-8-sig", newline="") as f:
        cur.copy_expert(copy_stmt.as_string(cur), f)

    cur.execute(sql.SQL("SELECT count(*) FROM {}").format(target))
    return cur.fetchone()[0]


def main() -> None:
    files = sorted(DATA_DIR.glob("*.csv"))
    if not files:
        raise SystemExit("Aucun CSV dans data/. Lance d'abord extract.py")

    conn = connect()
    try:
        with conn, conn.cursor() as cur:
            for csv_path in files:
                n = load_file(cur, csv_path)
                print(f"{SCHEMA}.{table_name(csv_path):<35} {n:>9} lignes")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
