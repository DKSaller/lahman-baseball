SELECT MIN(debut) AS first_played,
	MAX(finalgame) AS last_played
FROM people;

-- Range of games in the dataset is May 5 1871 to April 3 2017

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

SELECT 
	ROUND(AVG(so), 2) AS avg_strikeouts,
	ROUND(AVG(hr), 2) AS avg_homeruns,
	FLOOR(yearid::int/10) * 10 AS decade
FROM batting
WHERE yearid >= '1920'
GROUP BY decade;

-- Run code for answer to question 5 