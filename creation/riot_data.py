import numpy as np
import pandas as pd
import argparse
import requests
import json
import ast

from psycopg2.extras import Json

from db.postgres import PostgreSQLConnector


def get_versions(url="https://ddragon.leagueoflegends.com/api/versions.json"):
    return download_data(url)


def download_data(url):
    print(f'\rDownloading {url} ', end="")
    response = requests.get(url)
    if response.status_code != 200:
        return print(f'Error: {response}')

    print(f"Done")
    return pd.DataFrame.from_dict(response.json()["data"], orient='index')


def download_riot_data(ressource, url='https://ddragon.leagueoflegends.com/cdn', version='14.5.1', language='en_US'):
    base_url = f"{url}/{version}/data/{language}"
    return download_data(f'{base_url}/{ressource}')


def insert_champions(file):
    df = pd.read_csv(file, encoding="utf-8").replace({np.nan: None})
    idx = df.columns[0]

    psql = PostgreSQLConnector.create_from_config("../config.ini")
    cursor = psql.connect()

    for _, champion in df.iterrows():
        cursor.execute(
            """INSERT INTO champions (id, version, key, name, title, blurb, info, image, partype, stats)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            (champion[idx], champion["version"], champion["key"], champion["name"], champion["title"],
             champion["blurb"], Json(champion["info"]), Json(champion["image"]),
             champion["partype"], Json(champion["stats"])))

        for tag in ast.literal_eval(champion["tags"]):
            cursor.execute("INSERT INTO champion_tags (id, tag) VALUES (%s, %s)", (champion[idx], tag))

    psql.close()


def insert_item(file):
    df = pd.read_csv(file, encoding="utf-8").replace({np.nan: None})
    idx = df.columns[0]

    psql = PostgreSQLConnector.create_from_config("../config.ini")
    cursor = psql.connect()

    for i, item in df.iterrows():
        cursor.execute(
            """INSERT INTO items (
                id, name, description, colloq, plaintext, image, gold, maps, stats, depth, instore, effect, consumed, 
                stacks, hidefromall, consumeonfull, specialrecipe, requiredally, requiredchampion)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT DO NOTHING
            """,
            (item[idx], item["name"], item["description"], item["colloq"], item["plaintext"], Json(item["image"]),
             Json(item["gold"]), Json(item["maps"]), Json(item["stats"]), item["depth"], item["inStore"],
             Json(item["effect"]), item["consumed"], item["stacks"], item["hideFromAll"], item["consumeOnFull"],
             item["specialRecipe"], item["requiredAlly"], item["requiredChampion"]))
        if item["tags"] is not None:
            for tag in ast.literal_eval(item["tags"]):
                cursor.execute("INSERT INTO item_tags (id, tag) VALUES (%s, %s)", (item[idx], tag))

        if item["from"] is not None:
            for builds_from in ast.literal_eval(item["from"]):
                if builds_from is None:
                    continue
                cursor.execute(
                    "INSERT INTO item_builds_from (id, builds_from) VALUES (%s, %s) ON CONFLICT DO NOTHING",
                    (item[idx], builds_from))

        if item["into"] is not None:
            for builds_into in ast.literal_eval(item["into"]):
                if builds_into is None:
                    continue
                builds_into = int(builds_into)
                cursor.execute(
                    "INSERT INTO item_builds_into (id, builds_into) VALUES (%s, %s)",
                    (item[idx], builds_into))

    psql.close()


def insert_summoner_spells(file):
    j = json.load(open(file, encoding="utf-8"))

    psql = PostgreSQLConnector.create_from_config("../config.ini")
    cursor = psql.connect()

    for row in j["data"]:
        ssp = j["data"][row]

        ssp['datavalues'] = Json(ssp['datavalues'])
        ssp['vars'] = Json(ssp['vars'])
        ssp['image'] = Json(ssp['image'])
        ssp['effect'] = [a[0] if isinstance(a, list) else a for a in ssp['effect']]

        cursor.execute("""INSERT INTO summoner_spells (
                    id, name, description, tooltip, maxrank, cooldown, cooldown_burn, cost, cost_burn, datavalues, 
                    effect, effect_burn, vars, key, summoner_level, modes, cost_type, max_ammo, range, range_burn, 
                    image, resource
                ) VALUES (
                    %(id)s, %(name)s, %(description)s, %(tooltip)s, %(maxrank)s, %(cooldown)s, %(cooldownBurn)s, 
                    %(cost)s, %(costBurn)s, %(datavalues)s, %(effect)s, %(effectBurn)s, %(vars)s, %(key)s, 
                    %(summonerLevel)s, %(modes)s, %(costType)s, %(maxammo)s, %(range)s, %(rangeBurn)s, 
                    %(image)s, %(resource)s
                )""", ssp)

    psql.close()


def get_all_items():
    versions = get_versions()

    items_full = pd.DataFrame()
    for version in versions:
        if "lolpatch" in version:
            break

        items_json = download_riot_data("item.json", version=version)
        df_items = pd.DataFrame.from_dict(items_json["data"], orient='index')

        new_index_values = df_items.index.difference(items_full.index)
        # Append only the rows with index values not already in the overall DataFrame
        items_full = pd.concat([items_full, df_items.loc[new_index_values]])

    return items_full


def save_all_items(output):
    items_full = get_all_items()
    items_full.to_csv(output)


def save_all_champions(output):
    champion_json = download_riot_data("champion.json")
    champion_json.to_csv(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='Riot Data Creator',
        description='Inserts riot data into the database')

    parser.add_argument('method', choices=["save_all_items", "save_all_champions"])
    parser.add_argument('-f', '--file')
    args = parser.parse_args()

    if args.method == 'save_all_items':
        save_all_champions(args.file)
    else:
        save_all_champions(args.file)
