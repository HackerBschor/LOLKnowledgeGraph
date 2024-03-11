import pandas as pd
import configparser
import psycopg2
import argparse
import io


class PostgreSQLConnector:
    def __init__(self, host, database, user, password):
        self.host = host
        self.database = database
        self.user = user
        self.password = password
        self.connection_url = f"postgresql+psycopg2://{user}:{password}@{host}/{database}"
        self.conn = None

    @staticmethod
    def create_from_config(config_file):
        config = configparser.ConfigParser()
        config.read("../config.ini")
        return PostgreSQLConnector(
            config["PostgreSQL"]["host"],
            config["PostgreSQL"]["database"],
            config["PostgreSQL"]["user"],
            config["PostgreSQL"]["password"])

    def connect(self):
        self.conn = psycopg2.connect(host=self.host, database=self.database, user=self.user, password=self.password)
        return self.conn.cursor()

    def close(self):
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


def execute(sql_file: str) -> None:
    psql = PostgreSQLConnector.create_from_config("../config.ini")
    cur = psql.connect()
    with open(sql_file, "r") as f:
        cur.execute(f.read())
    cur.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(prog='Data Base Connector')
    parser.add_argument('sql_file')
    args = parser.parse_args()
    execute(args.sql_file)
