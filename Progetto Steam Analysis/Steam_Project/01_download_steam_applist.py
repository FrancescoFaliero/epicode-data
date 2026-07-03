import os
import time
import requests
import pandas as pd

def download_steamspy_page(page=0):
    url = "https://steamspy.com/api.php"
    params = {
        "request": "all",
        "page": page
    }

    response = requests.get(url, params=params, timeout=60)
    response.raise_for_status()

    data = response.json()

    rows = []
    for appid, game in data.items():
        game["appid"] = appid
        rows.append(game)

    return rows

if __name__ == "__main__":
    os.makedirs("data", exist_ok=True)

    all_rows = []

    # Per iniziare scarichiamo solo la prima pagina, circa 1000 giochi.
    # Dopo, aumenteremo il numero di pagine.
    for page in range(1):
        print(f"Scarico pagina {page} da SteamSpy...")
        rows = download_steamspy_page(page)
        all_rows.extend(rows)
        time.sleep(2)

    df = pd.DataFrame(all_rows)

    df.to_csv("data/steam_games_details.csv", index=False, encoding="utf-8")

    print("File creato: data/steam_games_details.csv")
    print("Numero giochi scaricati:", len(df))
    print(df.head())