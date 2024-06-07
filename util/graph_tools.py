import networkx as nx
import matplotlib.pyplot as plt
from neo4j.graph import Node, Relationship


def visualize_graph(graph):
    # Get node types and node names
    node_types = nx.get_node_attributes(graph, 'type')
    node_names = nx.get_node_attributes(graph, 'properties')
    node_names = {x: node_names[x]["name"] for x in node_names}

    # Assign colors to node types
    unique_types = set(node_types.values())
    color_map = {node_type: f"C{i}" for i, node_type in enumerate(unique_types)}

    # Draw the graph
    pos = nx.spring_layout(graph)  # positions for all nodes

    # Draw nodes with color based on type
    nx.draw_networkx_nodes(graph, pos, node_color=[color_map[node_type] for node_type in node_types.values()])

    # Draw edges
    nx.draw_networkx_edges(graph, pos)

    # Draw node labels
    nx.draw_networkx_labels(graph, pos, labels=node_names, font_size=12, font_family="Malgun Gothic")

    # Display
    plt.axis("off")
    plt.show()


def create_graph_from_query(graph, result):
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

    for row in result.records:
        for key in result.keys:
            if isinstance(row[key], Node):
                add_node(graph, row[key])
            elif isinstance(row[key], Relationship):
                add_edge(graph, row[key])
