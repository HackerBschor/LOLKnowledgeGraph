DROP TABLE IF EXISTS champions;
DROP TABLE IF EXISTS champion_tags;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS item_builds_into;
DROP TABLE IF EXISTS item_tags;
DROP TABLE IF EXISTS item_builds_from;
DROP TABLE IF EXISTS summoner_spells;
DROP TABLE IF EXISTS challenger_matches;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS plays_in;


CREATE TABLE champions (
    id varchar(50) PRIMARY KEY ,
    version VARCHAR(10),
    key INTEGER,
    name VARCHAR(50),
    title VARCHAR(100),
    blurb TEXT,
    info JSONB,
    image JSONB,
    partype VARCHAR(50),
    stats JSONB
);

CREATE TABLE champion_tags (
    id varchar(50),
    tag varchar(50),
    PRIMARY KEY (id, tag)
);

CREATE TABLE items (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    colloq VARCHAR(255),
    plaintext TEXT,
    image JSON,
    gold JSON,
    maps JSON,
    stats JSON,
    depth INT,
    inStore BOOLEAN,
    effect JSON,
    consumed BOOLEAN,
    stacks INT,
    hideFromAll BOOLEAN,
    consumeOnFull BOOLEAN,
    specialRecipe INT,
    requiredAlly VARCHAR(255),
    requiredChampion VARCHAR(255)
);

CREATE TABLE item_builds_into (
    id INTEGER,
    builds_into INTEGER,
    PRIMARY KEY (id, builds_into)
);

CREATE TABLE item_tags (
    id INTEGER,
    tag varchar(50),
    PRIMARY KEY (id, tag)
);

CREATE TABLE item_builds_from (
    id INTEGER,
    builds_from INTEGER,
    amount INTEGER,
    PRIMARY KEY (id, builds_from)
);

CREATE TABLE summoner_spells (
    id VARCHAR(255) PRIMARY KEY ,
    name VARCHAR(255),
    description TEXT,
    tooltip TEXT,
    maxrank INTEGER,
    cooldown INTEGER[],
    cooldown_burn VARCHAR(255),
    cost INTEGER[],
    cost_burn VARCHAR(255),
    datavalues JSON,
    effect INTEGER[],
    effect_burn VARCHAR(255)[],
    vars JSON,
    key VARCHAR(255),
    summoner_level INTEGER,
    modes VARCHAR(255)[],
    cost_type VARCHAR(255),
    max_ammo VARCHAR(255),
    range INTEGER[],
    range_burn VARCHAR(255),
    image JSON,
    resource VARCHAR(255)
);

CREATE TABLE challenger_matches (
    cmid BIGINT PRIMARY KEY,
    id BIGINT,
    game_creation timestamp,
    game_duration TIME,
    game_id BIGINT,
    game_mode VARCHAR(20),
    game_type VARCHAR(16),
    game_version VARCHAR(16),
    map_id INTEGER,
    participant_identities JSON,
    participants JSON,
    platform_id VARCHAR(2),
    queue_id INTEGER,
    season_id INTEGER,
    status_message TEXT,
    status_status_code INTEGER,
    teams JSON
);

CREATE TABLE player (
    platform_id VARCHAR(3),
    account_id VARCHAR(64),
    summoner_name VARCHAR(64),
    PRIMARY KEY (platform_id, account_id)
);

CREATE TABLE plays_in (
    cmid INTEGER,
    platform_id VARCHAR(3),
    account_id VARCHAR(64),
    participant_id INTEGER,
    team_id INTEGER,
    champion_id INTEGER,
    spell1_id INTEGER,
    spell2_id INTEGER,
    stats JSON,
    timeline JSON,
    role VARCHAR(16),
    lane VARCHAR(16),
    position VARCHAR(16),
    PRIMARY KEY (cmid, platform_id, account_id)
);