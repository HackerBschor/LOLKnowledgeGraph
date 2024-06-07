import argparse
import pandas as pd
from db.postgres import PostgreSQLConnector
from psycopg2.extras import Json
from psycopg2.extensions import cursor, connection


def insert_kaggle_data(file: str) -> None:
    psqlc: PostgreSQLConnector = PostgreSQLConnector.create_from_config("../config.ini")
    cur: cursor = psqlc.connect()

    df: pd.DataFrame = pd.read_pickle(file)

    for i, (x, row) in enumerate(df.iterrows()):
        print("\r", float(i) / float(len(df)) * 100.0, "%", end="")
        row: pd.Series = row.fillna(0)
        row['gameCreation'] = pd.to_datetime(row['gameCreation'] * 1000000)
        row['gameDuration'] = pd.to_timedelta(row['gameDuration'] * 1000000000)
        cur.execute(
            """INSERT INTO challenger_matches (
                    cmid, id, game_creation, game_duration, game_id, game_mode, game_type, game_version, map_id, 
                    participant_identities, participants, platform_id, queue_id, season_id
                    , status_message, status_status_code, teams
                ) 
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
            (i, x, row['gameCreation'], row['gameDuration'], row['gameId'], row['gameMode'],
             row["gameType"], row['gameVersion'], row['mapId'], Json(row['participantIdentities']),
             Json(row['participants']), row['platformId'], row['queueId'], row['seasonId'],
             row['status.message'], row['status.status_code'], Json(row['teams'])))

    print("Done")
    psqlc.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='Kaggle Data Creator',
        description='Inserts kaggle data into the database and applies data transformations')

    parser.add_argument('file')
    insert_kaggle_data(parser.parse_args().file)
