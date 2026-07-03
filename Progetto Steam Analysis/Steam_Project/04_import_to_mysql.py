import pandas as pd
import mysql.connector
from getpass import getpass

CSV_FILE = "data/steam_games_clean.csv"

db_password = getpass("Inserisci la password MySQL dell'utente root: ")

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password=db_password,
    database="SteamAnalytics"
)

cursor = conn.cursor()

cursor.execute("DROP TABLE IF EXISTS steam_games")

cursor.execute("""
CREATE TABLE steam_games (
    appid INT PRIMARY KEY,
    name VARCHAR(255),
    developer VARCHAR(255),
    publisher VARCHAR(255),
    owners VARCHAR(50),
    owners_min BIGINT,
    owners_max BIGINT,
    owners_avg BIGINT,
    positive INT,
    negative INT,
    total_reviews INT,
    positive_review_rate DECIMAL(10,4),
    price_value DECIMAL(10,2),
    price_band VARCHAR(20),
    is_free VARCHAR(10),
    average_forever INT,
    median_forever INT,
    ccu INT,
    discount INT
)
""")

df = pd.read_csv(CSV_FILE)

# Teniamo solo le colonne presenti nella tabella MySQL
columns = [
    "appid",
    "name",
    "developer",
    "publisher",
    "owners",
    "owners_min",
    "owners_max",
    "owners_avg",
    "positive",
    "negative",
    "total_reviews",
    "positive_review_rate",
    "price_value",
    "price_band",
    "is_free",
    "average_forever",
    "median_forever",
    "ccu",
    "discount"
]

df = df[columns]

# Sostituisce NaN con None, così MySQL li interpreta come NULL
df = df.where(pd.notnull(df), None)

insert_query = """
INSERT INTO steam_games (
    appid, name, developer, publisher, owners,
    owners_min, owners_max, owners_avg,
    positive, negative, total_reviews, positive_review_rate,
    price_value, price_band, is_free,
    average_forever, median_forever, ccu, discount
)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

for _, row in df.iterrows():
    cursor.execute(insert_query, tuple(row))

conn.commit()

cursor.execute("SELECT COUNT(*) FROM steam_games")
total = cursor.fetchone()[0]

cursor.close()
conn.close()

print(f"Importazione completata. Righe importate: {total}")