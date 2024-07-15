/*
 * Logical Reasoning
 */
/* Winning Rate */
:auto MATCH (p1)-[w:WINS_OVER]->(p2)
CALL { WITH w DETACH DELETE w } IN TRANSACTIONS OF 1000 ROWS;


:auto MATCH (p1:Player)
CALL {
    WITH p1
    MATCH
      (p1)-[:PLAYS_IN]->(pi1:PlayerInMatch)-[:PLAYS_IN]->(q1:Queue)<-[:CONSISTS_OF]-
      (m:Match)-[:CONSISTS_OF]->(q2:Queue)<-[:PLAYS_IN]-(pi2:PlayerInMatch)<-[:PLAYS_IN]-(p2:Player)
    WHERE q1 <> q2
    WITH p1, p2, COUNT(DISTINCT m.matchID) AS matchPlayed, SUM(CASE WHEN q1.win THEN 1 ELSE 0 END) AS matchesWon
    MERGE (p1)-[pa:PLAYED_AGAINST]->(p2)
      ON CREATE SET pa.matchesPlayed = matchPlayed, pa.matchesWon = matchesWon
} IN TRANSACTIONS OF 1000 ROWS;


:auto MATCH (p1:Player) -[pa:PLAYED_AGAINST]->(p2:Player)
      WHERE toFloat(pa.matchesWon) > toFloat(pa.matchesPlayed)/2
      CALL {
          WITH p1, p2, pa
          MERGE (p1)-[w:WINS_OVER]->(p2)
            ON CREATE SET w.rate = toFloat(pa.matchesWon) / toFloat(pa.matchesPlayed)
      } IN TRANSACTIONS OF 1000 ROWS;


/* Top 5 Champions */
:auto MATCH (p:Player) CALL {
  WITH p CALL {
    WITH p MATCH
      (p)-[:PLAYS_IN]->(pi1:PlayerInMatch)-[h:PLAYS_CHAMP]->(c:Champion),
      (pi1)-[:PLAYS_IN]->(q1:Queue)
    RETURN c, COUNT(pi1.matchID) AS matchesPlayed, SUM(CASE WHEN q1.win THEN 1 ELSE 0 END) AS matchesWon
    ORDER BY matchesPlayed DESC
    LIMIT 5
  }
  MERGE (p)-[pc:PLAYS_CHAMP]->(c)
    ON CREATE SET pc.matchesPlayed = matchesPlayed,
      pc.matchesWon = matchesWon, pc.winningrate = toFloat(matchesWon) / toFloat(matchesPlayed)
} IN TRANSACTIONS OF 1000 ROWS;

/* Player Has Role */
:auto MATCH(p) CALL {
    WITH p
    MATCH
        (pt:Position {positionID: "TOP"}),
        (pm:Position {positionID: "MID"}),
        (ps:Position {positionID: "SUP"}),
        (pb:Position {positionID: "BOT"}),
        (pj:Position {positionID: "JGL"})
    CALL {
        WITH p MATCH (p)-[:PLAYS_IN]->(pi:PlayerInMatch)-[:PLAYS_ROLE]->(r:Role), (pi)-[:PLAYS_LANE]->(l:Lane {laneID: "TOP"}), (pi)-[:PLAYS_IN]->(q:Queue)
        WHERE r.roleID <> "DUO_SUPPORT"
        RETURN COUNT(pi.matchID) AS gamesTop, SUM(CASE WHEN q.win THEN 1 ELSE 0 END) AS gamesWonTop
    }
    CALL {
        WITH p MATCH (p)-[:PLAYS_IN]->(pi:PlayerInMatch)-[:PLAYS_ROLE]->(r:Role), (pi)-[:PLAYS_LANE]->(l:Lane {laneID: "JUNGLE"}), (pi)-[:PLAYS_IN]->(q:Queue)
        RETURN COUNT(pi.matchID) AS gamesJungle, SUM(CASE WHEN q.win THEN 1 ELSE 0 END) AS gamesWonJungle
    }
    CALL {
        WITH p MATCH (p)-[:PLAYS_IN]->(pi:PlayerInMatch)-[:PLAYS_ROLE]->(r:Role), (pi)-[:PLAYS_LANE]->(l:Lane {laneID: "MIDDLE"}), (pi)-[:PLAYS_IN]->(q:Queue)
        WHERE r.roleID <> "DUO_SUPPORT"
        RETURN COUNT(pi.matchID) AS gamesMiddle, SUM(CASE WHEN q.win THEN 1 ELSE 0 END) AS gamesWonMiddle
    }
    CALL {
        WITH p MATCH (p)-[:PLAYS_IN]->(pi:PlayerInMatch)-[:PLAYS_ROLE]->(r:Role), (pi)-[:PLAYS_LANE]->(l:Lane {laneID: "BOTTOM"}), (pi)-[:PLAYS_IN]->(q:Queue)
        WHERE r.roleID <> "DUO_SUPPORT"
        RETURN COUNT(pi.matchID) AS gamesBottom, SUM(CASE WHEN q.win THEN 1 ELSE 0 END) AS gamesWonBottom
    }
    CALL {
        WITH p MATCH (p)-[:PLAYS_IN]->(pi:PlayerInMatch)-[:PLAYS_ROLE]->(r:Role {roleID: "DUO_SUPPORT"}), (pi)-[:PLAYS_LANE]->(l:Lane), (pi)-[:PLAYS_IN]->(q:Queue)
        RETURN COUNT(pi.matchID) AS gamesSupport, SUM(CASE WHEN q.win THEN 1 ELSE 0 END) AS gamesWonSupport
    }
    CALL {
        WITH * MATCH (p)
        WHERE toFloat(gamesTop) / toFloat(gamesTop + gamesJungle + gamesMiddle + gamesBottom + gamesSupport) > 0.5
        MERGE (p)-[hp:HAS_POSITION]->(pt)
        ON CREATE SET hp.winningRate = toFloat(gamesWonTop) / toFloat(gamesTop)
    }
    CALL {
        WITH * MATCH (p)
        WHERE toFloat(gamesJungle) / toFloat(gamesTop + gamesJungle + gamesMiddle + gamesBottom + gamesSupport) > 0.5
        MERGE (p)-[hp:HAS_POSITION]->(pj)
        ON CREATE SET hp.winningRate = toFloat(gamesWonJungle) / toFloat(gamesJungle)
    }
    CALL {
        WITH * MATCH (p)
        WHERE toFloat(gamesMiddle) / toFloat(gamesTop + gamesJungle + gamesMiddle + gamesBottom + gamesSupport) > 0.5
        MERGE (p)-[hp:HAS_POSITION]->(pm)
        ON CREATE SET hp.winningRate = toFloat(gamesWonMiddle) / toFloat(gamesMiddle)
    }
    CALL {
        WITH * MATCH (p)
        WHERE toFloat(gamesBottom) / toFloat(gamesTop + gamesJungle + gamesMiddle + gamesBottom + gamesSupport) > 0.5
        MERGE (p)-[hp:HAS_POSITION]->(pb)
        ON CREATE SET hp.winningRate = toFloat(gamesWonBottom) / toFloat(gamesMiddle)
    }
    CALL {
        WITH * MATCH (p)
        WHERE toFloat(gamesSupport) / toFloat(gamesTop + gamesJungle + gamesMiddle + gamesBottom + gamesSupport) > 0.5
        MERGE (p)-[hp:HAS_POSITION]->(ps)
        ON CREATE SET hp.winningRate = toFloat(gamesWonSupport) / toFloat(gamesSupport)
    }
} IN TRANSACTIONS OF 10000 ROWS;