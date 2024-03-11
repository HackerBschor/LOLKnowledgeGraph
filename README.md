# Knowledge Graph - based League of Legends Analysis 🌐🎮

## Motivation 
[Riot Games](https://www.riotgames.com/), the company behind [League of Legends](https://www.leagueoflegends.com/de-de/) 
offers a huge amount of free accessible data and an API that can be structured perfectly as a knowledge graph.  

## Problem

When playing League of Legends, one has to pick champions, runes and items wisely. 
It depends on the opponent's selections, their playstyle and other factors. 
Accessing all these information needs game understanding and time, 
what you don't have during a tournament or the champion selection phase.

## Solution 

## DATA

* https://www.kaggle.com/datasets/gyejr95/league-of-legendslol-ranked-games-2020-ver1?select=challenger_match_V2.csv

## Installation

### Database

```postgresql
CREATE DATABASE <database>;
CREATE USER <user> WITH PASSWORD '<password>';
ALTER DATABASE <database> OWNER TO <user>;
GRANT ALL ON database <database> TO <user>;
```
### Config File

```ini
[PostgreSQL]
host=<host>
database=<database>
user=<user>
password=<password>
```

## Disclaimer 

This project is part of the Knowledge Graphs course at [Technische Universität Wien](https://www.tuwien.at/). 
