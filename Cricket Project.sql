-- ************************************ CREATE TABLES ********************************* --
-- Creating Players Table
CREATE TABLE Players (
    PlayerID INT PRIMARY KEY,
    PlayerName VARCHAR(100),
    Age INT,
    Country VARCHAR(50)
);

-- Creating Teams Table
CREATE TABLE Teams (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(100),
    CoachName VARCHAR(100)
);

-- Creating Matches Table
CREATE TABLE Matches (
    MatchID INT PRIMARY KEY,
    Date DATE,
    Venue VARCHAR(100),
    Team1ID INT,
    Team2ID INT,
    FOREIGN KEY (Team1ID) REFERENCES Teams(TeamID),
    FOREIGN KEY (Team2ID) REFERENCES Teams(TeamID)
);

-- Creating Performances Table
CREATE TABLE Performances (
    PerformanceID INT PRIMARY KEY,
    MatchID INT,
    PlayerID INT,
    Runs INT,
    Wickets INT,
    FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),
    FOREIGN KEY (PlayerID) REFERENCES Players(PlayerID)
);

-- ************************************ INSERT DATA ********************************* --


-- Inserting data into Players Table
INSERT ALL 
INTO Players (PlayerID, PlayerName, Age, Country) VALUES (1, 'Virat Kohli', 34, 'India')
INTO Players (PlayerID, PlayerName, Age, Country) VALUES (2, 'Steve Smith', 33, 'Australia')
INTO Players (PlayerID, PlayerName, Age, Country) VALUES (3, 'Joe Root', 32, 'England')
SELECT * FROM DUAL;

-- Inserting data into Teams Table
INSERT ALL 
INTO Teams (TeamID, TeamName, CoachName) VALUES (1, 'India', 'Ravi Shastri')
INTO Teams (TeamID, TeamName, CoachName) VALUES (2, 'Australia', 'Justin Langer')
INTO Teams (TeamID, TeamName, CoachName) VALUES (3, 'England', 'Chris Silverwood')
SELECT * FROM DUAL;

-- Inserting data into Matches Table
INSERT ALL 
INTO Matches (MatchID, MDate, Venue, Team1ID, Team2ID) VALUES (1, TO_DATE('2023-06-01','YYYY-MM-DD'), 'Eden Gardens', 1, 2)
INTO Matches (MatchID, MDate, Venue, Team1ID, Team2ID) VALUES (2, TO_DATE('2023-06-15','YYYY-MM-DD'), 'Lords', 3, 1)
SELECT * FROM DUAL;

-- Inserting data into Performances Table
INSERT ALL 
INTO Performances (PerformanceID, MatchID, PlayerID, Runs, Wickets) VALUES (1, 1, 1, 100, 0)
INTO Performances (PerformanceID, MatchID, PlayerID, Runs, Wickets) VALUES (2, 1, 2, 60, 2)
INTO Performances (PerformanceID, MatchID, PlayerID, Runs, Wickets) VALUES (3, 2, 1, 80, 0)
INTO Performances (PerformanceID, MatchID, PlayerID, Runs, Wickets) VALUES (4, 2, 3, 90, 1)
SELECT * FROM DUAL;

-- ************************************ QUERY DATA ********************************* --

-- ************************************ SIMPLE QUERIES ********************************* --

-- 1. Retrieve all players from India

SELECT * FROM Players WHERE Country = 'India';

-- 2. Retrieve details of matches played at 'Eden Gardens'

SELECT * FROM Matches WHERE Venue = 'Eden Gardens';

-- 3. Retrieve performance details for a specific player

SELECT * FROM Performances WHERE PlayerID = 1;

-- 4. Join Players and Performances to get player names and their runs

SELECT 
	P.PlayerName, 
	F.Runs 
FROM 
	Players P 
	INNER JOIN Performances F ON P.PlayerID = F.PlayerID
;	

-- 5. Retrieve the total runs scored by each player

SELECT 
	P.PlayerName, 
	SUM(F.Runs) AS TotalRuns
FROM 
	Players P 
	JOIN Performances F ON P.PlayerID = F.PlayerID
GROUP BY 
P.PlayerName
;

-- ************************************ COMPLEX QUERIES ********************************* --

-- 1. Retrieve the top scorer in each match

WITH top_score AS
(
SELECT 
    performances.matchid,
    performances.playerid,
    performances.runs,
    DENSE_RANK() OVER(PARTITION BY performances.matchid ORDER BY performances.runs desc) as RANK
FROM performances
)
SELECT 
    top_score.matchid,
    matches.venue,
    players.playername,
    top_score.runs
FROM top_score 
INNER JOIN matches ON top_score.matchid = matches.matchid
INNER JOIN players ON top_score.playerid = players.playerid
WHERE top_score.rank = 1;

-- 2. Calculate the average runs scored by each player across all matches

SELECT 
    P.PlayerName, 
    AVG(F.Runs) AS AverageRuns
FROM 
    Players P
JOIN 
    Performances F ON P.PlayerID = F.PlayerID
GROUP BY 
    P.PlayerName;

-- 3. Find players who have taken more than 5 wickets in a match

SELECT
    p.matchid,
    pl.playername,
    SUM(p.wickets) AS WicketsPerMatch
FROM
    performances p
JOIN players pl ON  p.playerid = pl.playerid 
GROUP BY
    p.matchid,
    pl.playername
HAVING
    SUM(p.wickets) > 5
;

-- 4. List all matches along with the total runs scored in each match

SELECT
    m.mdate,
    SUM(p.runs) AS TotalRuns
FROM
    performances p
    JOIN matches m ON p.matchid = m.matchid
GROUP BY
    m.mdate
ORDER BY
    TotalRuns DESC
;

-- 5. Retrieve the highest individual score in each team

SELECT
    pl.country,
    MAX(p.runs) as HighestRun    
FROM
    performances p
    JOIN players pl ON p.playerid = pl.playerid
GROUP BY    
    pl.country
ORDER BY    
    HighestRun DESC   
;

-- 6. Use a window function to rank players based on their total runs scored

SELECT
    pl.playername,
    SUM(p.runs) AS TotalRuns,
    ROW_NUMBER() OVER(ORDER BY SUM(p.runs) DESC) AS Rank
FROM
    performances p
    JOIN players pl ON p.playerid = pl.playerid
GROUP BY
    pl.playername
;

-- 7. Find the player with the highest total runs across all matches

WITH cte AS
(
SELECT
    pl.playername,
    SUM(p.runs) AS TotalRuns,
    ROW_NUMBER() OVER(ORDER BY SUM(p.runs) DESC) AS Rank
FROM
    performances p
    JOIN players pl ON p.playerid = pl.playerid
GROUP BY
    pl.playername
)
SELECT 
    c.playername,
    c.totalruns
FROM 
    cte c
WHERE c.rank = 1
;

-- 8. Retrieve the number of matches played by each team
WITH cte AS
(
SELECT 
    m.matchid,
    m.team1id AS teamid
FROM 
    matches m
UNION
SELECT 
    m.matchid,
    m.team2id AS teamid
FROM 
    matches m
)
SELECT 
    t.teamname,
    COUNT(c.matchid) AS MatchesPlayed
FROM 
    cte c
    INNER JOIN teams t ON c.teamid = t.teamid
GROUP BY 
    t.teamname
;
