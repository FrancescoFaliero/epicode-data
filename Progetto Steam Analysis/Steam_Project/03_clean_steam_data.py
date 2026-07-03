import os
import pandas as pd

def owners_to_min_max(owners):
    if pd.isna(owners):
        return None, None

    owners = str(owners).replace(",", "")
    
    if ".." not in owners:
        return None, None

    parts = owners.split("..")
    min_owners = int(parts[0].strip())
    max_owners = int(parts[1].strip())

    return min_owners, max_owners

if __name__ == "__main__":
    input_file = "data/steam_games_details.csv"
    output_file = "data/steam_games_clean.csv"

    df = pd.read_csv(input_file)

    # Converte appid in numero
    df["appid"] = pd.to_numeric(df["appid"], errors="coerce")

    # Converte prezzo da centesimi a euro/dollari
    df["price"] = pd.to_numeric(df["price"], errors="coerce")
    df["price_value"] = df["price"] / 100

    # Crea colonna free/paid
    df["is_free"] = df["price_value"].fillna(0) == 0

    # Converte recensioni positive e negative
    df["positive"] = pd.to_numeric(df["positive"], errors="coerce").fillna(0)
    df["negative"] = pd.to_numeric(df["negative"], errors="coerce").fillna(0)

    # Calcola totale recensioni
    df["total_reviews"] = df["positive"] + df["negative"]

    # Calcola percentuale recensioni positive
    df["positive_review_rate"] = df.apply(
        lambda row: row["positive"] / row["total_reviews"] if row["total_reviews"] > 0 else None,
        axis=1
    )

    # Estrae owners minimo e massimo
    df[["owners_min", "owners_max"]] = df["owners"].apply(
        lambda x: pd.Series(owners_to_min_max(x))
    )

    # Crea owners medio stimato
    df["owners_avg"] = (df["owners_min"] + df["owners_max"]) / 2

    # Crea fascia prezzo
    def price_band(price):
        if pd.isna(price):
            return "Unknown"
        elif price == 0:
            return "Free"
        elif price <= 10:
            return "0-10"
        elif price <= 30:
            return "10-30"
        elif price <= 60:
            return "30-60"
        else:
            return "60+"

    df["price_band"] = df["price_value"].apply(price_band)

    # Riordina alcune colonne utili
    columns = [
        "appid",
        "name",
        "developer",
        "publisher",
        "genre",
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
        "discount",
        "languages",
        "tags"
    ]

    existing_columns = [col for col in columns if col in df.columns]
    df_clean = df[existing_columns]

    os.makedirs("data", exist_ok=True)
    df_clean.to_csv(output_file, index=False, encoding="utf-8")

    print("File creato:", output_file)
    print("Numero righe:", len(df_clean))
    print("Numero colonne:", len(df_clean.columns))
    print(df_clean.head())