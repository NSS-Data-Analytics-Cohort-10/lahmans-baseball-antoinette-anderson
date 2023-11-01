-- 1. What range of years for baseball games played does the provided database cover? 
SELECT DISTINCT year
FROM homegames
ORDER BY year;

-- 1871-2016 

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namefirst, namelast, height, g_all, teamid
FrOM people as p
JOIN appearances as a
USING(playerid)
WHERE height < 60
ORDER BY height 

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
SELECT group_players, SUM(putouts) as putouts_total
FROM cte
GROUP BY group_players

--- Outfield: 29560, Battery: 41424, Infield: 58934

   
-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   

WITH averages_table AS
(SELECT g, ROUND(AVG(so),2) as avg_so, ROUND(AVG(hr),2) as avg_hr,
CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
	 WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
	 WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
	 WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
	 WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
	 WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
	 WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
	 WHEN yearid BETWEEN 1990 and 1999 THEN '1990s'
	 WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
	 WHEN yearid BETWEEN 2010 AND 2016 THEN '2010s'
	 END AS decade
FROM batting
WHERE yearid BETWEEN 1920 AND 2016
GRoUP BY g, decade
ORDER BY decade)
SELECT SUM(averages_table.g) as games, ROUND(SUM(averages_table.avg_hr/100),1)as avg_homerun, ROUND(SUM(averages_table.avg_so/100 ),1) as average_strikeouts
, decade
FROM averages_table
GROUP BY decade
																						  
-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT namefirst, namelast, yearid, sb, cs, sb+cs as total
FROM people
JOIN batting
USING (playerid)
WHERE yearid = 2016
ORDER BY sb DESC
LIMIT 1;



-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
SELECT name, w, l, w+l as total_games
FROM teams
WHERE wswin ='N'
AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC ;

-- Seattle Mariners: 116

SELECT name, w
FROM teams
WHERE wswin ='Y'
AND yearid BETWEEN 1970 AND 2016
ORDER By w

-- Los Angeles Dodgers: 63

SELECT name, yearid, w, l,  w+l as total_games
FROM teams
WHERE wswin ='Y'
AND yearid BETWEEN 1970 AND 2016
GROUP BY name, w, l, yearid
ORDER By w desc;

-- the reason is the total games played. For example, LAD only played 110 games vs the usual 162. 

SELECT name, yearid, w, l, wswin, w+l as total_games 
FROM teams
WHERE wswin = 'Y'
AND w > 100
AND yearid BETWEEN 1970 AND 2016
GROUP BY name, yearid, w, l, wswin
ORDER BY w desc;

--- 8 games and around 3% of the time

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT  hg.team, park_name, AVG(hg.attendance/games) as avg_attendance
FROM homegames as hg
JOIN parks p
USING (park)
WHERE year =2016
GROUP BY hg.team, park_name, hg.year
ORDER by AVG(hg.attendance/games) DESC
LIMIT 5

-- TOP 5: LAN/Dodger Statium, SLN/Busch Stadium III, TOR/Rogers Centre, SFN/AT%T Park, CHN/Wrigley Field

SELECT  hg.team, park_name, AVG(hg.attendance/games) as avg_attendance
FROM homegames as hg
JOIN parks p
USING (park)
WHERE year =2016
GROUP BY hg.team, park_name, hg.year
ORDER by AVG(hg.attendance/games) 
LIMIT 5

--BOTTOM 5: ATL/Fort Bragg Field, TBA/Tropicana Field, OAK/Oakland-Alameda County Coliseum, CLE/Progressive Field, MIA/Marlins Park

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



-- 11.Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.
SELECT DISTINCT name, w, SUM(salary )as team_salary,t.yearid
FROM teams as t
JOIN salaries
USING(teamid)
WHERE t.yearid >= 2000
GROUP BY name, w, t.yearid
ORDER BY t.yearid;

-- There is no correlation between number of wins and team salary. Some total salaries are higher with less wins.

-- 12. In this question, you will explore the connection between number of wins and attendance.
--  <ol type="a">
--    <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
--    <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
--  </ol>

SELECT DISTINCT name, w, divwin, wcwin, wswin, h.attendance,  h.park, yearid
FROM teams as t
FULL JOIN homegames as h
ON t.yearid = h.year
WHERE yearid > 1903
AND wswin IS NOT NULL
AND divwin IS NOT NULL
AND wcwin IS NOT NULL
AND h.attendance > 1
ORDER BY yearid;

-- There is no corrolation between attendance and home games. It seems regardles attandance was steady.

--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?
SELECT COUNT(throws) as left_pitchers
FrOM people
WHERE throws = 'L'
UNION ALL
SELECT COUNT(throws) as right_pitchers
FROM people
Where throws ='R'


SELECT DISTINCT namefirst, namelast, throws, awardid, inducted
FrOM people
JOIN awardsplayers
USING(playerid)
JOIN halloffame
USING(playerid)
WHERE awardid = 'Cy Young Award'
AND inducted = 'Y'
ORDER by throws 

-- Right-handed pitchers are still more likely to win the Cy Young Award and to be inducted into the Hall of Fame. This could be due to how rare rare left-handed pitchers are (3k vs 14k)




