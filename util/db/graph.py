import configparser
from neo4j import GraphDatabase, Driver
from configparser import ConfigParser
import typing as t
import typing_extensions as te


class Neo4JConnector:
    def __init__(self, url, username, password):
        self.driver: Driver = GraphDatabase.driver(url, auth=(username, password))
        self.driver.verify_connectivity()

    @staticmethod
    def create_from_config(config_file: str):
        config: ConfigParser = configparser.ConfigParser()
        config.read(config_file)
        return Neo4JConnector(config["Neo4j"]["NEO4J_URI"], config["Neo4j"]["NEO4J_USERNAME"],
                              config["Neo4j"]["NEO4J_PASSWORD"])

    def exec(self, query: te.LiteralString, **kwargs: t.Any) -> t.Any:
        return self.driver.execute_query(query, kwargs)

    def close(self) -> None:
        self.driver.close()
