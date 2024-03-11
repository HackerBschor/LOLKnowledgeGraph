INSERT INTO player (platform_id, account_id)
SELECT DISTINCT p.player->>'platformId', p.player->>'accountId'
FROM (SELECT json_array_elements(participant_identities)->'player' AS player FROM challenger_matches) p;

UPDATE player p1 SET summoner_name = p2.player->>'summonerName'
FROM (SELECT json_array_elements(participant_identities)->'player' AS player FROM challenger_matches) p2
WHERE p1.platform_id = p2.player->>'platformId' AND p1.account_id = p2.player->>'accountId';

INSERT INTO plays_in (cmid, participant_id, platform_id, account_id)
SELECT cmid, CAST(player->>'participantId' AS INT), player->'player'->>'platformId', player->'player'->>'accountId'
FROM (SELECT cmid, json_array_elements(participant_identities) AS player FROM challenger_matches) p
WHERE player->'player'->>'platformId' != '';

UPDATE plays_in pi
SET team_id=CAST(player->>'teamId' AS INT),
    champion_id=CAST(player->>'championId' AS INT),
    spell1_id=CAST(player->>'spell1Id' AS INT),
    spell2_id=CAST(player->>'spell2Id' AS INT),
    stats=player->'stats', timeline=player->'timeline',
    role=player->'timeline'->>'role', lane=player->'timeline'->>'lane'
FROM (SELECT cmid, json_array_elements(participants) AS player FROM challenger_matches) p
WHERE CAST(p.player->>'participantId' AS INT) = pi.participant_id AND p.cmid = pi.cmid;

CREATE TABLE teams (
    cmid INTEGER,
    team_id INTEGER,
    win BOOLEAN,
    info JSON,
    PRIMARY KEY (cmid, team_id)
);

INSERT INTO teams (cmid, team_id, win, info)
SELECT cmid, CAST(team->>'teamId' AS INT), team->>'win' = 'Win', team
FROM (SELECT json_array_elements(teams) as team, * FROM challenger_matches) a;

UPDATE plays_in
SET position = CASE
    WHEN lane = 'BOTTOM' THEN CASE
        WHEN role = 'DUO_CARRY' THEN 'AD_CARRY'
        WHEN role = 'DUO_SUPPORT' THEN 'SUPPORT'
        ELSE role END
    ELSE lane END
WHERE 1=1;