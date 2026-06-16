import pathlib
import re
import mysql.connector

SQL_PATH = pathlib.Path(__file__).parent / "bddiane_sp.sql"

if not SQL_PATH.exists():
    raise SystemExit(f"SQL file missing: {SQL_PATH}")

sql_text = SQL_PATH.read_text(encoding="utf-8", errors="ignore")
# Remove line comments and block comments while preserving MySQL conditional comments
sql_text = re.sub(r"/\*![0-9]+ .*?\*/", "", sql_text, flags=re.S)
sql_text = re.sub(r"--.*?$", "", sql_text, flags=re.M)

statements = [stmt.strip() for stmt in re.split(r";\s*(?:\n|$)", sql_text) if stmt.strip()]
print(f"Loaded {len(statements)} SQL statements")

conn = mysql.connector.connect(
    host="zephyr.proxy.rlwy.net",
    user="root",
    password="OuzasvvAAYwhBfawfFrGIigaJuYEGXVb",
    port=31906,
    database="railway",
    ssl_disabled=True,
)
cur = conn.cursor()
executed = 0
errors = 0
for idx, stmt in enumerate(statements, start=1):
    try:
        cur.execute(stmt)
        executed += 1
    except Exception as exc:
        print(f"ERROR statement {idx}: {exc}")
        print(stmt[:400])
        errors += 1
        if errors >= 5:
            break

conn.commit()
cur.close()
conn.close()
print(f"Executed {executed} statements, {errors} errors")
