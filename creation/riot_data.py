import numpy as np
import pandas as pd
import argparse
import requests
from requests import Response
import json
import ast

from psycopg2.extras import Json

from db.postgres import PostgreSQLConnector
from psycopg2.extensions import cursor as Cursor


def get_versions(url="https://ddragon.leagueoflegends.com/api/versions.json") -> json:
    return download_data(url)


def download_data(url: str) -> json:
    print(f'\rDownloading {url} ', end="")
    response: Response = requests.get(url)
    if response.status_code != 200:
        return print(f'Error: {response}')
    print(f"Done")
    return response.json()


def download_riot_data(ressource: str, url: str = 'https://ddragon.leagueoflegends.com/cdn', version: str = '14.5.1',
                       language: str = 'en_US') -> json:
    base_url: str = f"{url}/{version}/data/{language}"
    return download_data(f'{base_url}/{ressource}')


def insert_champions(file: str) -> None:
    df: pd.DataFrame = pd.read_csv(file, encoding="utf-8").replace({np.nan: None})
    idx: int = df.columns[0]

    psql: PostgreSQLConnector = PostgreSQLConnector.create_from_config("../config.ini")
    cursor: Cursor = psql.connect()

    for _, champion in df.iterrows():
        champion["info"] = json.loads(champion["info"].replace("\'", "\""))
        champion["image"] = json.loads(champion["image"].replace("\'", "\""))
        champion["stats"] = json.loads(champion["stats"].replace("\'", "\""))

        cursor.execute(
            """INSERT INTO champions (id, version, key, name, title, blurb, info, image, partype, stats)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            (champion[idx], champion["version"], champion["key"], champion["name"], champion["title"],
             champion["blurb"], Json(champion["info"]), Json(champion["image"]),
             champion["partype"], Json(champion["stats"])))

        for tag in ast.literal_eval(champion["tags"]):
            cursor.execute("INSERT INTO champion_tags (id, tag) VALUES (%s, %s)", (champion[idx], tag))

    psql.close()


def insert_items(file: str) -> None:
    df: pd.DataFrame = pd.read_csv(file, encoding="utf-8").replace({np.nan: None})
    idx: int = df.columns[0]

    psql: PostgreSQLConnector = PostgreSQLConnector.create_from_config("../config.ini")
    cursor: Cursor = psql.connect()

    for i, item in df.iterrows():
        item["image"] = None if item["image"] is None else ast.literal_eval(item["image"])
        item["gold"] = None if item["gold"] is None else ast.literal_eval(item["gold"])
        item["maps"] = None if item["maps"] is None else ast.literal_eval(item["maps"])
        item["stats"] = None if item["stats"] is None else ast.literal_eval(item["stats"])
        item["effect"] = None if item["effect"] is None else ast.literal_eval(item["effect"])

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
            builds_from: dict = {}
            for builds_from_item in ast.literal_eval(item["from"]):
                if builds_from is None:
                    continue
                if builds_from_item not in builds_from:
                    builds_from[builds_from_item] = 0
                builds_from[builds_from_item] += 1

            for builds_from_item in builds_from:
                cursor.execute(
                    "INSERT INTO item_builds_from (id, builds_from, amount) VALUES (%s, %s, %s)",
                    (item[idx], builds_from_item, builds_from[builds_from_item]))

        if item["into"] is not None:
            for builds_into in ast.literal_eval(item["into"]):
                if builds_into is None:
                    continue
                builds_into = int(builds_into)
                cursor.execute(
                    "INSERT INTO item_builds_into (id, builds_into) VALUES (%s, %s)",
                    (item[idx], builds_into))

    psql.close()


def insert_summoner_spells(file: str) -> json:
    df: pd.DataFrame = pd.read_csv(file, encoding="utf-8").replace({np.nan: None})

    psql: PostgreSQLConnector = PostgreSQLConnector.create_from_config("../config.ini")
    cursor: Cursor = psql.connect()

    for i, ssp in df.iterrows():
        ssp['id'] = ssp['key']
        ssp['cooldown'] = ast.literal_eval(ssp['cooldown'])
        ssp['cost'] = ast.literal_eval(ssp['cost'])
        ssp['datavalues'] = Json(ssp['datavalues'])
        ssp['vars'] = Json(ssp['vars'])
        ssp['image'] = Json(ssp['image'])
        ssp['effect'] = [a[0] if isinstance(a, list) else a for a in ast.literal_eval(ssp['effect'])]
        ssp['effectBurn'] = [int(a[0]) if isinstance(a, list) else a for a in ast.literal_eval(ssp['effectBurn'])]
        ssp['modes'] = ast.literal_eval(ssp['modes'])
        ssp['range'] = ast.literal_eval(ssp['range'])
        ssp["image"] = None

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


def get_all_items() -> pd.DataFrame:
    versions: json = get_versions()

    items_full: pd.DataFrame = pd.DataFrame()
    for version in versions:
        if "lolpatch" in version:
            break

        items_json: json = download_riot_data("item.json", version=version)
        df_items: pd.DataFrame = pd.DataFrame.from_dict(items_json["data"], orient='index')

        new_index_values: pd.Index = df_items.index.difference(items_full.index)
        # Append only the rows with index values not already in the overall DataFrame
        items_full: pd.DataFrame = pd.concat([items_full, df_items.loc[new_index_values]])

    return items_full


def save_all_items(output: str) -> None:
    items_full: pd.DataFrame = get_all_items()
    items_full.to_csv(output)


def save_all_champions(output: str) -> None:
    champion_json: json = download_riot_data("champion.json")
    champions: pd.DataFrame = pd.DataFrame.from_dict(champion_json["data"], orient="index")
    champions.to_csv(output)


def save_all_sums(output) -> None:
    summoner_json: json = download_riot_data("summoner.json")
    summoner: pd.DataFrame = pd.DataFrame.from_dict(summoner_json["data"], orient="index")
    summoner.to_csv(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='Riot Data Creator',
        description='Inserts riot data into the database')

    parser.add_argument('method', choices=[
        "save_all_items", "save_all_champions", "save_all_sums",
        "insert_champions", "insert_items", "insert_summoner_spells"
    ])
    parser.add_argument('-f', '--file')
    args = parser.parse_args()

    if args.method == 'save_all_items':
        save_all_items(args.file)
    elif args.method == "save_all_champions":
        save_all_champions(args.file)
    elif args.method == "save_all_sums":
        save_all_sums(args.file)
    elif args.method == "insert_champions":
        insert_champions(args.file)
    elif args.method == "insert_items":
        insert_items(args.file)
    elif args.method == "insert_summoner_spells":
        insert_summoner_spells(args.file)
    else:
        pass
