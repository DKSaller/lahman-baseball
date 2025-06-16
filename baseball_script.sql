--1. What range of years for baseball games played does the provided database cover?

SELECT MIN(debut) AS first_played,
	MAX(finalgame) AS last_played
FROM people;

-- Range of games in the dataset is May 5 1871 to April 3 2017

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namefirst,
	namelast,
	MIN(height) AS shortest_height,
	debut,
	teams.name,
	g_all
FROM people
INNER JOIN appearances USING (playerid)
INNER JOIN teams USING (teamid)
GROUP BY namefirst, namelast, debut, teams.name, g_all
ORDER BY shortest_height
LIMIT 1;

-- Eddie Gaedel, was the shortest man to play baseball at 43 inches. He played 1 games for the STL Browns

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

SELECT namefirst AS first_name,
	namelast AS last_name,
	SUM(salary) AS total_salary
FROM people
INNER JOIN collegeplaying USING (playerid)
INNER JOIN schools USING (schoolid)
INNER JOIN salaries USING (playerid)
WHERE schoolid = 'vandy'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;

-- Davide Price earned the most salary in the majors, earning $245,553,888 during his tenure

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
	END AS position_group,
	SUM(po) AS total_putouts
FROM fielding
INNER JOIN people USING (playerid)
WHERE yearid = 2016
GROUP BY position_group;

-- For the year 2016, Battery has 41424 putouts, Infield had 58934 putouts, and Outfield had 29560 putouts

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT 
	ROUND(AVG(so), 2) AS avg_strikeouts,
	ROUND(AVG(hr), 2) AS avg_homeruns,
	FLOOR(yearid::int/10) * 10 AS decade
FROM batting
WHERE yearid >= '1920'
GROUP BY decade;

-- Run code for answer to question 5 

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT 
	namefirst AS first_name,
	namelast AS last_name,
	sb,
	cs,
	ROUND((sb * 1.0/(sb+cs)) * 100, 2) AS sb_percent
FROM batting
INNER JOIN people USING (playerid)
WHERE sb >= 20 AND yearid = '2016'
ORDER BY sb_percent DESC
LIMIT 1;

-- Chris Ownings had the greatest sb percentage at 91.30%

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


SELECT 
	name,
	yearid,
	w
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'N'
ORDER BY w DESC
LIMIT 1;

-- the 2001 Seattle Mariners won the most games without winning the World Series at 116 wins

SELECT 
	name,
	yearid,
	w
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'Y'
	AND yearid != '1981'
ORDER BY w
LIMIT 1;

-- the 2006 St. Louis Cardinals won the World Series with the least amount of wins at 83, taking into account the year the season was split and removing it.

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT teams.name,
	park_name,
	SUM(homegames.attendance)/SUM(homegames.games) AS avg_attendance
FROM homegames
INNER JOIN parks USING (park)
INNER JOIN teams ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE year = '2016' AND games >= 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance DESC
LIMIT 5;

-- Top 5 teams and parks by average attendance

SELECT teams.name,
	park_name,
	SUM(homegames.attendance)/SUM(homegames.games) AS avg_attendance
FROM homegames
INNER JOIN parks USING (park)
INNER JOIN teams ON homegames.year = teams.yearid AND homegames.team = teams.teamid
WHERE year = '2016' AND games >= 10
GROUP BY teams.name, park_name
ORDER BY avg_attendance
LIMIT 5;

-- Bottom 5 teams and parks by average attendance

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

WITH awardsbothleagues AS (SELECT playerid
FROM awardsmanagers
WHERE awardid LIKE 'TSN%'
	AND lgid IN ('NL', 'AL')
GROUP BY playerid
HAVING COUNT(DISTINCT lgid) = 2)


SELECT DISTINCT
	p.namefirst,
	p.namelast,
	t.name AS team,
	am.lgid,
	am.awardid
FROM awardsmanagers AS am
INNER JOIN awardsbothleagues AS abl ON am.playerid = abl.playerid
INNER JOIN people AS p ON p.playerid = am.playerid
INNER JOIN managers AS m ON am.playerid = m.playerid AND am.yearid = m.yearid
INNER JOIN teams AS t ON t.yearid = am.yearid AND t.teamid = m.teamid
WHERE am.awardid LIKE 'TSN%'
	AND am.lgid IN ('NL', 'AL')
ORDER BY p.namelast;

-- Davey Johnson won the award during his time on the Baltimore Orioles  (AL) and Washington Nationals (NL)
-- Jim Leyland won the award during his time on the Detroit Tigers (AL) and the Pittsburgh Pirates (NL)

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

WITH career_best_hr AS (SELECT 
						playerid,
						MAX(hr) AS max_hr
						FROM batting
						GROUP BY playerid),

years_played AS (SELECT 
					playerid,
					COUNT(DISTINCT yearid) AS years_played
					FROM batting
					GROUP BY playerid)

SELECT 
	namefirst,
	namelast,
	b.hr AS hr_2016
FROM batting AS b
INNER JOIN people AS p ON b.playerid = p.playerid
INNER JOIN career_best_hr AS cbh ON b.playerid = cbh.playerid AND b.hr = cbh.max_hr 
INNER JOIN years_played AS yp ON b.playerid = yp.playerid
WHERE b.yearid = '2016'
	AND b.hr >= 1
	AND yp.years_played >= 10
GROUP BY namefirst, namelast, cbh.max_hr, b.hr
ORDER BY b.hr DESC, namelast;

-- Answer) Edwin Encarnacion: 42
--		   Robinson Cano: 39
--         Mike Napoli: 34
--         Justin Upton: 31
--         Rajai Davis: 12
--         Angel Pagan: 12
--         Adam Wainwright: 2
--         Bartolo Colon: 1
--         Francisco Liriano: 1


-- 11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

SELECT 
	teamid,
	yearid,
	w,
	SUM(salary) AS total_salary,
	LAG(SUM(salary)) OVER (PARTITION BY teamid ORDER BY yearid) AS prev_year_salary,
	SUM(salary) - LAG(SUM(salary)) OVER (PARTITION BY teamid ORDER BY yearid) AS salary_diff
FROM salaries AS s
INNER JOIN teams AS t USING (teamid, yearid)
WHERE yearid >= '2000'
GROUP BY teamid, w, yearid
ORDER BY teamid, yearid

-- There's no correlation between the amount of wins a team has in a prior season and the amount of salary they're paying out to their players.















