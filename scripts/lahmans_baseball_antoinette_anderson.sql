-- 1. What range of years for baseball games played does the provided database cover? 
SELECT DISTINCT year
FROM homegames
ORDER BY year;

-- 1871-2016 

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT DISTINCT namefirst, namelast, height, a.teamid, t.name, hg.games 
FROM people as p
JOIN appearances as a
USING (playerid)
JOIN teams as t
USING(teamid)
FULL JOIN homegames as h
ON p.namefirst = h.games
ORDER BY height;






-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT p.namefirst, p.namelast, MAX(c.yearid) as year, s.schoolname, MAX(ss.salary) AS salary
FROM people as p
JOIN collegeplaying as c
USING(playerid)
JOIN schools as s
USING(schoolid)
JOIN salaries as ss
USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast, s.schoolname
ORDER BY salary DESC

-- David Price with 30 million



-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
   
WITH CTE AS
(SELECT   pos, SUM(po) as putouts,
CASE WHEN pos = 'OF' THEN 'Outfield'
	 WHEN pos = 'SS' THEN 'Infield'
	 WHEN pos = '1B' THEN 'Infield'
	 WHEN pos = '2B' THEN 'Infield'
	 WHEN pos = '3B' THEN 'Infield'
	 WHEN pos= 'C' THEN 'Battery'
	 WHEN pos ='P' THEN 'Battery'
END AS group_players
FROM fielding
WHERE yearid ='2016'
GROUP BY  pos)
SELECT group_players, putouts
FROM cte

--- Outfield: 29560, Battery: 41424, Infield: 58934

   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   

-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
	

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT  namefirst, namelast, teamid
FROM people as p
JOIN appearances as a
USING (playerid)
JOIN awardsmanagers as am
USING (playerid)
WHERE am.lgid IN ('AL', 'NL')
GROUP BY namefirst, namelast, teamid
HAVING COUNT(DISTINCT am.lgid)=2


-- Bob Melvin, Bobby Cox, Davey Johnson, Lou Priniella, Tony LaRussa


-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

SELECT namefirst, namelast, debut, hr
FROM people as p
JOIN batting as b
USING (playerid)
WHERE b.yearid = 2016
AND debut <= '2006-12-31'
AND hr >= '1'
ORDER by hr DESC;
