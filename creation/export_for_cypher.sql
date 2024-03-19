COPY (SELECT * FROM player) TO '/tmp/player.csv' WITH CSV header;

COPY (
    SELECT id, version, key, name, title, blurb, partype,
       info->>'magic' AS info_magic, info->>'attack' AS info_attack,
       info->>'defense' AS info_defense, info->>'difficulty' AS info_difficulty,
       info->>'mpregen' AS info_mpregen,
       info->>'attackdamageperlevel' AS info_attackdamageperlevel,
       info->>'hpregenperlevel' AS info_hpregenperlevel,
       info->>'hpperlevel' AS info_hpperlevel,
       info->>'crit' AS info_crit,
       info->>'mpperlevel' AS info_mpperlevel,
       info->>'armorperlevel' AS info_armorperlevel,
       info->>'movespeed' AS info_movespeed,
       info->>'critperlevel' AS info_critperlevel,
       info->>'armor' AS info_armor,
       info->>'mp' AS info_mp,
       info->>'attackrange' AS info_attackrange,
       info->>'spellblockperlevel' AS info_spellblockperlevel,
       info->>'hpregen' AS info_hpregen,
       info->>'mpregenperlevel' AS info_mpregenperlevel,
       info->>'attackspeedperlevel' AS info_attackspeedperlevel,
       info->>'attackdamage' AS info_attackdamage,
       info->>'hp' AS info_hp,
       info->>'spellblock' AS info_spellblock,
       info->>'attackspeed' AS info_attackspeed
    FROM champions) TO '/tmp/champions.csv' WITH CSV header;

COPY (SELECT * FROM champion_tags) TO '/tmp/champion_tags.csv' WITH CSV header;

COPY (
    SELECT cmid, id, game_creation, game_duration, game_id, game_mode, game_type, game_version, platform_id, queue_id, season_id
    FROM challenger_matches
) TO '/tmp/matches.csv' WITH CSV header;

COPY (SELECT * FROM teams) TO '/tmp/teams.csv' WITH CSV header;

COPY (
    SELECT cmid, platform_id, account_id, participant_id, team_id, champion_id, spell1_id, spell2_id, role, lane,
           stats->>'assists' AS "statsAssists", stats->>'champLevel' AS "statsChamplevel", stats->>'combatPlayerScore' AS "statsCombatplayerscore", stats->>'damageDealtToObjectives' AS "statsDamagedealttoobjectives", stats->>'damageDealtToTurrets' AS "statsDamagedealttoturrets", stats->>'damageSelfMitigated' AS "statsDamageselfmitigated", stats->>'deaths' AS "statsDeaths", stats->>'doubleKills' AS "statsDoublekills", stats->>'firstBloodAssist' AS "statsFirstbloodassist", stats->>'firstBloodKill' AS "statsFirstbloodkill", stats->>'firstInhibitorAssist' AS "statsFirstinhibitorassist", stats->>'firstInhibitorKill' AS "statsFirstinhibitorkill", stats->>'firstTowerAssist' AS "statsFirsttowerassist", stats->>'firstTowerKill' AS "statsFirsttowerkill", stats->>'goldEarned' AS "statsGoldearned", stats->>'goldSpent' AS "statsGoldspent", stats->>'inhibitorKills' AS "statsInhibitorkills", stats->>'item0' AS "statsItem0", stats->>'item1' AS "statsItem1", stats->>'item2' AS "statsItem2", stats->>'item3' AS "statsItem3", stats->>'item4' AS "statsItem4", stats->>'item5' AS "statsItem5", stats->>'item6' AS "statsItem6", stats->>'killingSprees' AS "statsKillingsprees", stats->>'kills' AS "statsKills", stats->>'largestCriticalStrike' AS "statsLargestcriticalstrike", stats->>'largestKillingSpree' AS "statsLargestkillingspree", stats->>'largestMultiKill' AS "statsLargestmultikill", stats->>'longestTimeSpentLiving' AS "statsLongesttimespentliving", stats->>'magicDamageDealt' AS "statsMagicdamagedealt", stats->>'magicDamageDealtToChampions' AS "statsMagicdamagedealttochampions", stats->>'magicalDamageTaken' AS "statsMagicaldamagetaken", stats->>'neutralMinionsKilled' AS "statsNeutralminionskilled", stats->>'neutralMinionsKilledEnemyJungle' AS "statsNeutralminionskilledenemyjungle", stats->>'neutralMinionsKilledTeamJungle' AS "statsNeutralminionskilledteamjungle", stats->>'objectivePlayerScore' AS "statsObjectiveplayerscore", stats->>'participantId' AS "statsParticipantid", stats->>'pentaKills' AS "statsPentakills", stats->>'perk0' AS "statsPerk0", stats->>'perk0Var1' AS "statsPerk0var1", stats->>'perk0Var2' AS "statsPerk0var2", stats->>'perk0Var3' AS "statsPerk0var3", stats->>'perk1' AS "statsPerk1", stats->>'perk1Var1' AS "statsPerk1var1", stats->>'perk1Var2' AS "statsPerk1var2", stats->>'perk1Var3' AS "statsPerk1var3", stats->>'perk2' AS "statsPerk2", stats->>'perk2Var1' AS "statsPerk2var1", stats->>'perk2Var2' AS "statsPerk2var2", stats->>'perk2Var3' AS "statsPerk2var3", stats->>'perk3' AS "statsPerk3", stats->>'perk3Var1' AS "statsPerk3var1", stats->>'perk3Var2' AS "statsPerk3var2", stats->>'perk3Var3' AS "statsPerk3var3", stats->>'perk4' AS "statsPerk4", stats->>'perk4Var1' AS "statsPerk4var1", stats->>'perk4Var2' AS "statsPerk4var2", stats->>'perk4Var3' AS "statsPerk4var3", stats->>'perk5' AS "statsPerk5", stats->>'perk5Var1' AS "statsPerk5var1", stats->>'perk5Var2' AS "statsPerk5var2", stats->>'perk5Var3' AS "statsPerk5var3", stats->>'perkPrimaryStyle' AS "statsPerkprimarystyle", stats->>'perkSubStyle' AS "statsPerksubstyle", stats->>'physicalDamageDealt' AS "statsPhysicaldamagedealt", stats->>'physicalDamageDealtToChampions' AS "statsPhysicaldamagedealttochampions", stats->>'physicalDamageTaken' AS "statsPhysicaldamagetaken", stats->>'playerScore0' AS "statsPlayerscore0", stats->>'playerScore1' AS "statsPlayerscore1", stats->>'playerScore2' AS "statsPlayerscore2", stats->>'playerScore3' AS "statsPlayerscore3", stats->>'playerScore4' AS "statsPlayerscore4", stats->>'playerScore5' AS "statsPlayerscore5", stats->>'playerScore6' AS "statsPlayerscore6", stats->>'playerScore7' AS "statsPlayerscore7", stats->>'playerScore8' AS "statsPlayerscore8", stats->>'playerScore9' AS "statsPlayerscore9", stats->>'quadraKills' AS "statsQuadrakills", stats->>'sightWardsBoughtInGame' AS "statsSightwardsboughtingame", stats->>'statPerk0' AS "statsStatperk0", stats->>'statPerk1' AS "statsStatperk1", stats->>'statPerk2' AS "statsStatperk2", stats->>'timeCCingOthers' AS "statsTimeccingothers", stats->>'totalDamageDealt' AS "statsTotaldamagedealt", stats->>'totalDamageDealtToChampions' AS "statsTotaldamagedealttochampions", stats->>'totalDamageTaken' AS "statsTotaldamagetaken", stats->>'totalHeal' AS "statsTotalheal", stats->>'totalMinionsKilled' AS "statsTotalminionskilled", stats->>'totalPlayerScore' AS "statsTotalplayerscore", stats->>'totalScoreRank' AS "statsTotalscorerank", stats->>'totalTimeCrowdControlDealt' AS "statsTotaltimecrowdcontroldealt", stats->>'totalUnitsHealed' AS "statsTotalunitshealed", stats->>'tripleKills' AS "statsTriplekills", stats->>'trueDamageDealt' AS "statsTruedamagedealt", stats->>'trueDamageDealtToChampions' AS "statsTruedamagedealttochampions", stats->>'trueDamageTaken' AS "statsTruedamagetaken", stats->>'turretKills' AS "statsTurretkills", stats->>'unrealKills' AS "statsUnrealkills", stats->>'visionScore' AS "statsVisionscore", stats->>'visionWardsBoughtInGame' AS "statsVisionwardsboughtingame", stats->>'wardsKilled' AS "statsWardskilled", stats->>'wardsPlaced' AS "statsWardsplaced", stats->>'win' AS "statsWin"
    FROM plays_in
) TO '/tmp/plays_in.csv' WITH CSV header;

