LOAD CSV WITH HEADERS FROM 'file:///player.csv' AS row
MERGE (player:Player {accountID: row.account_id, platformID: row.platform_id})
  ON CREATE SET player.summonerName = row.summoner_name;


LOAD CSV WITH HEADERS FROM 'file:///champions.csv' AS row
MERGE (champion:Champion {championID: row.id, championKey: toInteger(row.key), championName: row.name, championTitle: row.title})
  ON CREATE SET
    champion.blurb = row.blurb,
    champion.partype = row.partype,
    champion.info_magic = toInteger(row.info_magic),
    champion.info_attack = toInteger(row.info_attack),
    champion.info_defense = toInteger(row.info_defense),
    champion.info_difficulty = toInteger(row.info_difficulty),
    champion.info_mpregen = toFloat(row.info_mpregen),
    champion.info_attackdamageperlevel = toFloat(row.info_attackdamageperlevel),
    champion.info_hpregenperlevel = toFloat(row.info_hpregenperlevel),
    champion.info_hpperlevel = toInteger(row.info_hpperlevel),
    champion.info_mpperlevel = toFloat(row.info_mpperlevel),
    champion.info_armorperlevel = toFloat(row.info_armorperlevel),
    champion.info_movespeed = toInteger(row.info_movespeed),
    champion.info_critperlevel = toFloat(row.info_critperlevel),
    champion.info_armor = toInteger(row.info_armor),
    champion.info_mp = toInteger(row.info_mp),
    champion.info_attackrange = toInteger(row.info_attackrange),
    champion.info_spellblockperlevel = toFloat(row.info_spellblockperlevel),
    champion.info_hpregen = toFloat(row.info_hpregen),
    champion.info_mpregenperlevel = toFloat(row.info_mpregenperlevel),
    champion.info_attackspeedperlevel = toFloat(row.info_attackspeedperlevel),
    champion.info_attackdamage = toInteger(row.info_attackdamage),
    champion.info_hp = toInteger(row.info_hp),
    champion.info_spellblock = toInteger(row.info_spellblock),
    champion.info_attackspeed = toFloat(row.info_attackspeed);


LOAD CSV WITH HEADERS FROM 'file:///champion_tags.csv' AS row
MATCH (champion:Champion {championID: row.id})
MERGE (tag:Tag {tagID: row.tag})
MERGE (champion)-[op:HAS_TAG]->(tag);


LOAD CSV WITH HEADERS FROM 'file:///items.csv' AS row
MERGE (item: Item {itemID: toInteger(row.id)})
  ON CREATE SET item.itemName = row.name, item.description = row.plaintext,
  item.goldBase = toInteger(row.goldBase), item.goldTotal = toInteger(row.goldTotal),
  item.goldSell = toInteger(row.goldSell), item.purchasable = toBoolean(row.purchasable);

LOAD CSV WITH HEADERS FROM 'file:///item_tags.csv' AS row
MATCH (item:Item {itemID: toInteger(row.id)})
MERGE (tag:Tag {tagID: row.tag})
MERGE (item)-[op:HAS_TAG]->(tag);

LOAD CSV WITH HEADERS FROM 'file:///item_builds_to.csv' AS row
MATCH (item_from:Item {itemID: toInteger(row.id)})
MATCH (item_to:Item {itemID: toInteger(row.builds_into)})
MERGE (item_from)-[op:BUILDS_INTO]->(item_to);

LOAD CSV WITH HEADERS FROM 'file:///item_builds_from.csv' AS row
MATCH (item_to:Item {itemID: toInteger(row.id)})
MATCH (item_from:Item {itemID: toInteger(row.builds_from)})
MERGE (item_to)-[op:BUILDS_FROM]->(item_from)
    ON CREATE SET op.amount = toInteger(row.amount);


LOAD CSV WITH HEADERS FROM 'file:///summoner_spells.csv' AS row
MERGE (s: SummonerSpell {summonerSpellID: toInteger(row.id)})
    ON CREATE SET s.summonerSpellName = row.name, s.SummonerSpellDescription = row.description;


LOAD CSV WITH HEADERS FROM 'file:///roles.csv' AS row
MERGE (r: Role {roleID: row.role})

LOAD CSV WITH HEADERS FROM 'file:///lanes.csv' AS row
MERGE (l: Lane {laneID: row.lane})

LOAD CSV WITH HEADERS FROM 'file:///matches.csv' AS row
MERGE (match:Match {matchID: toInteger(row.cmid)})
  ON CREATE SET
    match.gameCreation = datetime(REPLACE(row.game_creation, ' ', 'T') + 'Z'), match.gameDuration = time(row.game_duration),
    match.gameID = toInteger(row.game_id), match.gameMode = row.game_mode, match.gameType = row.game_type,
    match.gameVersion = row.game_version, match.platformID = row.platform_id;


LOAD CSV WITH HEADERS FROM 'file:///teams.csv' AS row
MATCH (match:Match {matchID: toInteger(row.cmid)})
MERGE (q:Queue {queueID: toInteger(row.cmid) * 10 + toInteger(row.team_id)/100})
MERGE (q)-[p:CONSISTS_OF]->(match)
ON CREATE SET
    q.win = toBoolean(row.win),
    q.infoFirstinhibitor = toBoolean(row.infoFirstinhibitor),
    q.infoFirsttower = toBoolean(row.infoFirsttower),
    q.infoDragonkills = toInteger(row.infoDragonkills),
    q.infoVilemawkills = toInteger(row.infoVilemawkills),
    q.infoInhibitorkills = toInteger(row.infoInhibitorkills),
    q.infoFirstriftherald = toBoolean(row.infoFirstriftherald),
    q.infoTowerkills = toInteger(row.infoTowerkills),
    q.infoFirstblood = toBoolean(row.infoFirstblood),
    q.infoFirstbaron = toBoolean(row.infoFirstbaron),
    q.infoFirstdragon = toBoolean(row.infoFirstdragon),
    q.infoBaronkills = toInteger(row.infoBaronkills),
    q.infoRiftheraldkills = toInteger(row.infoRiftheraldkills),
    q.infoDominionvictoryscore = toInteger(row.infoDominionvictoryscore);







LOAD CSV WITH HEADERS FROM 'file:///plays_in.csv' AS row
MATCH (player: Player {accountID: row.account_id, platformID: row.platform_id})
MATCH (queue: Queue {queueID: toInteger(row.cmid) * 10 + toInteger(row.team_id)/100})
MATCH (champion: Champion {championKey: toInteger(row.champion_id)})
MATCH (summonerspell1: SummonerSpell {summonerSpellID: toInteger(row.spell1_id)})
MATCH (summonerspell2: SummonerSpell {summonerSpellID: toInteger(row.spell2_id)})
MATCH (role: Role {roleID: row.role})
MATCH (lane: Lane {laneID: row.lane})
MATCH (item0: Item {itemID: toInteger(row.statsItem0)})
MATCH (item1: Item {itemID: toInteger(row.statsItem1)})
MATCH (item2: Item {itemID: toInteger(row.statsItem2)})
MATCH (item3: Item {itemID: toInteger(row.statsItem3)})
MATCH (item4: Item {itemID: toInteger(row.statsItem4)})
MATCH (item5: Item {itemID: toInteger(row.statsItem5)})
MATCH (item6: Item {itemID: toInteger(row.statsItem6)})
MERGE (player)-[pi:PLAYS_IN]->(queue)
MERGE (pi)-[pc:PLAYS_CHAMP]->(champion)
MERGE (pi)-[ps1:PLAYS_SUMMONERSPELL]->(summonerspell1)
MERGE (pi)-[ps2:PLAYS_SUMMONERSPELL]->(summonerspell2)
MERGE (pi)-[pr:PLAYS_ROLE]->(role)
MERGE (pi)-[pl:PLAYS_LANE]->(lane)
MERGE (pi)-[pi0:PLAYS_Item]->(item0)
MERGE (pi)-[pi1:PLAYS_Item]->(item1)
MERGE (pi)-[pi2:PLAYS_Item]->(item2)
MERGE (pi)-[pi3:PLAYS_Item]->(item3)
MERGE (pi)-[pi4:PLAYS_Item]->(item4)
MERGE (pi)-[pi5:PLAYS_Item]->(item5)
MERGE (pi)-[pi6:PLAYS_Item]->(item6)
    ON CREATE SET
        pi.participantID = toInteger(row.participant_id),
        ps1.sumNo = 1, ps2.sumNo = 1,
        pi0.itemNo = 0, pi1.itemNo = 1, pi2.itemNo = 2, pi3.itemNo = 3, pi4.itemNo = 4, pi5.itemNo = 5, pi6.itemNo = 6,
        pi.assists = toInteger(row.statsAssists),
        pi.champLevel = toInteger(row.statsChamplevel),
        pi.combatPlayerScore = toInteger(row.statsCombatplayerscore),
        pi.damageDealtToObjectives = toInteger(row.statsDamagedealttoobjectives),
        pi.damageDealtToTurrets = toInteger(row.statsDamagedealttoturrets),
        pi.damageSelfMitigated = toInteger(row.statsDamageselfmitigated),
        pi.deaths = toInteger(row.statsDeaths),
        pi.doubleKills = toInteger(row.statsDoublekills),
        pi.firstBloodAssist = toBoolean(row.statsFirstbloodassist),
        pi.firstBloodKill = toBoolean(row.statsFirstbloodkill),
        pi.firstInhibitorAssist = toBoolean(row.statsFirstinhibitorassist),
        pi.firstInhibitorKill = toBoolean(row.statsFirstinhibitorkill),
        pi.firstTowerAssist = toBoolean(row.statsFirsttowerassist),
        pi.firstTowerKill = toBoolean(row.statsFirsttowerkill),
        pi.goldEarned = toInteger(row.statsGoldearned),
        pi.goldSpent = toInteger(row.statsGoldspent),
        pi.inhibitorKills = toInteger(row.statsInhibitorkills),

        pi.killingSprees = toInteger(row.statsKillingsprees),
        pi.kills = toInteger(row.statsKills),
        pi.largestCriticalStrike = toInteger(row.statsLargestcriticalstrike),
        pi.largestKillingSpree = toInteger(row.statsLargestkillingspree),
        pi.largestMultiKill = toInteger(row.statsLargestmultikill),
        pi.longestTimeSpentLiving = toInteger(row.statsLongesttimespentliving),
        pi.magicDamageDealt = toInteger(row.statsMagicdamagedealt),
        pi.magicDamageDealtToChampions = toInteger(row.statsMagicdamagedealttochampions),
        pi.magicalDamageTaken = toInteger(row.statsMagicaldamagetaken),
        pi.neutralMinionsKilled = toInteger(row.statsNeutralminionskilled),
        pi.neutralMinionsKilledEnemyJungle = toInteger(row.statsNeutralminionskilledenemyjungle),
        pi.neutralMinionsKilledTeamJungle = toInteger(row.statsNeutralminionskilledteamjungle),
        pi.objectivePlayerScore = toInteger(row.statsObjectiveplayerscore),
        pi.pentaKills = toInteger(row.statsPentakills),
        pi.perk0 = toInteger(row.statsPerk0),
        pi.perk0Var1 = toInteger(row.statsPerk0var1),
        pi.perk0Var2 = toInteger(row.statsPerk0var2),
        pi.perk0Var3 = toInteger(row.statsPerk0var3),
        pi.perk1 = toInteger(row.statsPerk1),
        pi.perk1Var1 = toInteger(row.statsPerk1var1),
        pi.perk1Var2 = toInteger(row.statsPerk1var2),
        pi.perk1Var3 = toInteger(row.statsPerk1var3),
        pi.perk2 = toInteger(row.statsPerk2),
        pi.perk2Var1 = toInteger(row.statsPerk2var1),
        pi.perk2Var2 = toInteger(row.statsPerk2var2),
        pi.perk2Var3 = toInteger(row.statsPerk2var3),
        pi.perk3 = toInteger(row.statsPerk3),
        pi.perk3Var1 = toInteger(row.statsPerk3var1),
        pi.perk3Var2 = toInteger(row.statsPerk3var2),
        pi.perk3Var3 = toInteger(row.statsPerk3var3),
        pi.perk4 = toInteger(row.statsPerk4),
        pi.perk4Var1 = toInteger(row.statsPerk4var1),
        pi.perk4Var2 = toInteger(row.statsPerk4var2),
        pi.perk4Var3 = toInteger(row.statsPerk4var3),
        pi.perk5 = toInteger(row.statsPerk5),
        pi.perk5Var1 = toInteger(row.statsPerk5var1),
        pi.perk5Var2 = toInteger(row.statsPerk5var2),
        pi.perk5Var3 = toInteger(row.statsPerk5var3),
        pi.perkPrimaryStyle = toInteger(row.statsPerkprimarystyle),
        pi.perkSubStyle = toInteger(row.statsPerksubstyle),
        pi.physicalDamageDealt = toInteger(row.statsPhysicaldamagedealt),
        pi.physicalDamageDealtToChampions = toInteger(row.statsPhysicaldamagedealttochampions),
        pi.physicalDamageTaken = toInteger(row.statsPhysicaldamagetaken),
        pi.playerScore0 = toInteger(row.statsPlayerscore0),
        pi.playerScore1 = toInteger(row.statsPlayerscore1),
        pi.playerScore2 = toInteger(row.statsPlayerscore2),
        pi.playerScore3 = toInteger(row.statsPlayerscore3),
        pi.playerScore4 = toInteger(row.statsPlayerscore4),
        pi.playerScore5 = toInteger(row.statsPlayerscore5),
        pi.playerScore6 = toInteger(row.statsPlayerscore6),
        pi.playerScore7 = toInteger(row.statsPlayerscore7),
        pi.playerScore8 = toInteger(row.statsPlayerscore8),
        pi.playerScore9 = toInteger(row.statsPlayerscore9),
        pi.quadraKills = toInteger(row.statsQuadrakills),
        pi.sightWardsBoughtInGame = toInteger(row.statsSightwardsboughtingame),
        pi.statPerk0 = toInteger(row.statsStatperk0),
        pi.statPerk1 = toInteger(row.statsStatperk1),
        pi.statPerk2 = toInteger(row.statsStatperk2),
        pi.timeCCingOthers = toInteger(row.statsTimeccingothers),
        pi.totalDamageDealt = toInteger(row.statsTotaldamagedealt),
        pi.totalDamageDealtToChampions = toInteger(row.statsTotaldamagedealttochampions),
        pi.totalDamageTaken = toInteger(row.statsTotaldamagetaken),
        pi.totalHeal = toInteger(row.statsTotalheal),
        pi.totalMinionsKilled = toInteger(row.statsTotalminionskilled),
        pi.totalPlayerScore = toInteger(row.statsTotalplayerscore),
        pi.totalScoreRank = toInteger(row.statsTotalscorerank),
        pi.totalTimeCrowdControlDealt = toInteger(row.statsTotaltimecrowdcontroldealt),
        pi.totalUnitsHealed = toInteger(row.statsTotalunitshealed),
        pi.tripleKills = toInteger(row.statsTriplekills),
        pi.trueDamageDealt = toInteger(row.statsTruedamagedealt),
        pi.trueDamageDealtToChampions = toInteger(row.statsTruedamagedealttochampions),
        pi.trueDamageTaken = toInteger(row.statsTruedamagetaken),
        pi.turretKills = toInteger(row.statsTurretkills),
        pi.unrealKills = toInteger(row.statsUnrealkills),
        pi.visionScore = toInteger(row.statsVisionscore),
        pi.visionWardsBoughtInGame = toInteger(row.statsVisionwardsboughtingame),
        pi.wardsKilled = toInteger(row.statsWardskilled),
        pi.wardsPlaced = toInteger(row.statsWardsplaced),
        pi.win = toInteger(row.statsWin)

