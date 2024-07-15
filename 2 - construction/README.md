# Data acquiring

To fetch the data one need a running PostgreSQL and Neo4J database.
The credentials  have to be stored in a `config.ini` file in the root of the document. 

## Riot data

To fetch the riot data one has to download the following files form the official Riot data dragon (https://developer.riotgames.com/docs/lol) 
and insert them in the PostgreSQL database. 
* summoner.json
* item.json
* champion.json
* versions.json

We created tools to do so: 

```bash
riot_data.py -f <items.csv> save_all_items
riot_data.py -f <champions.csv> save_all_champions
riot_data.py -f <sums.csv> save_all_sums
riot_data.py -f <items.csv> insert_items
riot_data.py -f <champions.csv> insert_champions
riot_data.py -f <sums.csv> insert_summoner_spells
```

## Kaggle Data

Here dataset has to be downloaded directly from kaggle (the pickled data): https://www.kaggle.com/datasets/gyejr95/league-of-legendslol-ranked-games-2020-ver1 
Then insert the data in the database.

```bash
riot_data.py -f <data.pkl> 
```

# Data Transformation

All transformation are stored in [kaggle_transformations.sql](queries/kaggle_transformations.sql), which have to be executed in the PostgreSQL database.

# From PostgreSQL to Neo4J

The database tables have to be exported to a csv file. 
Afterwards, they can be inserted in the Neo4J database using the queries in [import_neo4j.cql](queries/import_neo4j.cql)
