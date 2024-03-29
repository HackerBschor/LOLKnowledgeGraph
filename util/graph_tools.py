import networkx as nx
import matplotlib.pyplot as plt


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
