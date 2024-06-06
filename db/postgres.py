import pandas as pd
import configparser
import psycopg2
import argparse
import io

from sqlalchemy import create_engine, Engine
from psycopg2.extensions import cursor, connection


class PostgreSQLConnector:
    def __init__(self, host: str, database: str, user: str, password: str):
        self.host: str = host
        self.database: str = database
        self.user: str = user
        self.password: str = password
        self.connection_url: str = f"postgresql+psycopg2://{user}:{password}@{host}/{database}"
        self.conn: [None, connection] = None

    @staticmethod
    def create_from_config(config_file):
        config = configparser.ConfigParser()
        config.read(config_file)
        return PostgreSQLConnector(
            config["PostgreSQL"]["host"],
            config["PostgreSQL"]["database"],
            config["PostgreSQL"]["user"],
            config["PostgreSQL"]["password"])

    def connect(self) -> cursor:
        self.conn = psycopg2.connect(host=self.host, database=self.database, user=self.user, password=self.password)
        return self.conn.cursor()

    def close(self) -> None:
        self.conn.commit()
        self.conn.close()

    def insert_data(self, df: pd.DataFrame, table_name: str) -> None:
        self.connect()
        cur = self.conn.cursor()
        output = io.StringIO()
        df.to_csv(output, sep='\t', header=False, index=True)
        output.seek(0)
        output.getvalue()  # contents = output.getvalue()
        cur.copy_from(output, table_name, null="")  # null values become ''
        self.close()

    def create_engine(self) -> Engine:
        return create_engine(self.connection_url, echo=False)


def execute(sql_file: str) -> None:
    psql: PostgreSQLConnector = PostgreSQLConnector.create_from_config("config.ini")
    cur: cursor = psql.connect()

    with open(sql_file, "r") as f:
        sql = f.read()
        cur.execute(sql)

    cur.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='Data Base Connector')
    parser.add_argument('sql_file')
    args = parser.parse_args()
    execute(args.sql_file)
