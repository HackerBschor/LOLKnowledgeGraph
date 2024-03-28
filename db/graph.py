import configparser
import networkx as nx
from neo4j import GraphDatabase
from neo4j.graph import Node, Relationship


class Neo4JConnector:
    def __init__(self, url, username, password):
        self.driver = GraphDatabase.driver(url, auth=(username, password))
        self.driver.verify_connectivity()

    @staticmethod
    def create_from_config(config_file):
        config = configparser.ConfigParser()
        config.read(config_file)
        return Neo4JConnector(config["Neo4j"]["NEO4J_URI"], config["Neo4j"]["NEO4J_USERNAME"],
                              config["Neo4j"]["NEO4J_PASSWORD"])

    def exec(self, query):
        return self.driver.execute_query(query)

    def close(self):
        self.driver.close()

    def create_graph_from_query(self, graph, query):
        def add_node(g: nx.Graph, node: Node):
            if not g.has_node(node.element_id):
                node_properties = {x: node[x] for x in node}
                node_type = ",".join(sorted(list(node.labels)))
                g.add_node(node.element_id, type=node_type, properties=node_properties)

        def add_edge(g: nx.Graph, relationship: Relationship):
            element_ids = []
            for node in relationship.nodes:
                add_node(g, node)
                element_ids.append(node.element_id)

            edge_properties = {x: relationship[x] for x in relationship}
            edge_type = relationship.type

            for i in range(len(element_ids)):
                for j in range(i + 1, len(element_ids)):
                    g.add_edge(element_ids[i], element_ids[j], type=edge_type, properties=edge_properties)

        result = self.exec(query)
        for row in result.records:
            for key in result.keys:
                if isinstance(row[key], Node):
                    add_node(graph, row[key])
                elif isinstance(row[key], Relationship):
                    add_edge(graph, row[key])