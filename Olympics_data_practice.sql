/* 1a) Create a table that lists all country IDs for countries that competed in both 
the summer and winter Olympics.

left join summer games with countries table on country id's
inner join that with winter games on country id's because we are only interested in
countries that appear in both lists
select distinct country id's
*/


SELECT DISTINCT(wg.country_id)
FROM summer_games AS sg INNER JOIN winter_games AS wg ON sg.country_id = wg.country_id;



/*1b) Create a table that lists all country IDs for countries that competed in 
both the summer or winter Olympics.

similar to above except use left joins for everything and return list of country id's
that competed in either games
*/

SELECT DISTINCT(c.id)
FROM countries AS c LEFT JOIN summer_games AS sg ON c.id = sg.country_id
					LEFT JOIN winter_games AS wg ON c.id = wg.country_id;
	
--203 rows returned	
	
	
	
/* 2a) For each country give the average height and average weight of their athletes.

okay so as to not leave out any athletes we will need to again join summer and winter 
games table to countries and then we will need to pull in the athletes table. Would 
like to return country name then the aggregate functions the question is asking of us.
Lets go!
*/

SELECT DISTINCT(c.country),
	   ROUND(AVG(a.height), 2) AS avg_height,
	   ROUND(AVG(a.weight), 2) AS avg_weight
FROM countries AS c LEFT JOIN summer_games AS sg ON c.id = sg.country_id
					LEFT JOIN winter_games AS wg ON c.id = wg.country_id
					LEFT JOIN athletes AS a ON sg.athlete_id = a.id
GROUP BY c.country;



/* 2b) For each country give the average height and average weight of their male 
athletes who won a gold medal.

going to do this for both the summer and winter games seperately then see if the answer 
is the same as if i had joined the tables together. Join countries table with the games
table then join it with athletes table. Filter the data down in where clause then return
distinct countries with the aggregate functions.
*/

SELECT DISTINCT(c.country),
	   ROUND(AVG(a.height), 2) AS avg_height,
	   ROUND(AVG(a.weight), 2) AS avg_weight
FROM summer_games AS sg LEFT JOIN countries AS c ON sg.country_id = c.id
						LEFT JOIN athletes AS a ON sg.athlete_id = a.id
WHERE a.gender ILIKE 'M' AND sg.gold NOTNULL
GROUP BY c.country;
--20 results for summer games

SELECT DISTINCT(c.country),
	   ROUND(AVG(a.height), 2) AS avg_height,
	   ROUND(AVG(a.weight), 2) AS avg_weight
FROM countries AS c LEFT JOIN winter_games AS wg ON wg.country_id = c.id
						LEFT JOIN athletes AS a ON wg.athlete_id = a.id
WHERE a.gender ILIKE 'M' AND wg.gold NOTNULL
GROUP BY c.country;
-- 8 results for winter games

SELECT DISTINCT(c.country),
	   ROUND(AVG(a.height), 2) AS avg_height,
	   ROUND(AVG(a.weight), 2) AS avg_weight
FROM countries AS c LEFT JOIN summer_games AS sg ON c.id = sg.country_id
					LEFT JOIN winter_games AS wg ON c.id = wg.country_id
					LEFT JOIN athletes AS a ON sg.athlete_id = a.id
					
WHERE a.gender ILIKE 'M'
	  AND sg.gold NOTNULL
	  AND wg.gold NOTNULL
GROUP BY c.country;
-- 4 countries won gold in summer and winter games, this returns avg height and weight
-- for the males who won gold 


/* 3) Provide a list of athletes who won a gold medal and are shorter than 
the average Olympic athlete.

do this for summer and winter games seperately. Join athletes and the games tables, 
return athletes' names. Do a subquery to filter by height
*/
 
SELECT DISTINCT(a.name),
 	   a.height
FROM summer_games AS sg INNER JOIN athletes AS a ON sg.athlete_id = a.id
WHERE sg.gold NOTNULL
	  AND a.height < (SELECT AVG(height) FROM athletes)
ORDER BY a.height DESC;
-- returns 45 rows

SELECT DISTINCT(a.name),
 	   a.height
FROM winter_games AS wg INNER JOIN athletes AS a ON wg.athlete_id = a.id
WHERE wg.gold NOTNULL
	  AND a.height < (SELECT AVG(height) FROM athletes)
ORDER BY a.height DESC;
-- 18 rows returned



/* Provide the total number of medals won for each country in the summer Olympics 
whose GDP is greater than average GDP of countries with at least 1 Nobel Prize winner

Need to join summer games, countries table, and country_stats. filter in a subquery. 
return country name and a count of medals won.
*/

SELECT DISTINCT(c.country),
	   COUNT(sg.gold) AS total_gold,
	   COUNT(sg.silver) AS total_silver,
	   COUNT(sg.bronze) AS total_bronze
FROM summer_games AS sg LEFT JOIN countries AS c ON sg.country_id = c.id
						LEFT JOIN country_stats AS cs ON c.id = cs.country_id
WHERE cs.gdp > (SELECT AVG(gdp) FROM country_stats WHERE nobel_prize_winners >= 1)
GROUP BY c.country;



/*Create a column named ‘participation_level’ that labels countries by the number of 
unique events they competed in between the summer and winter games.  
For less than 10 the rating should be ‘low’ 
for 10-19 the rating should be ‘medium’ 
for 20+ the rating should be ‘high’.

split this up into participation level for summer and winter games, respectively, will continue to work on
this problem to sum up the total events for both summer and winter games and then assign a participation level
based on the outcome.
*/

SELECT DISTINCT(c.country),
	   CASE WHEN COUNT(DISTINCT(sg.event)) < 10 THEN 'low'
	        WHEN COUNT(DISTINCT(sg.event)) <= 19 THEN 'medium'
	        ELSE 'high' END AS participation_level_summer,
	   CASE WHEN COUNT(DISTINCT(wg.event)) < 10 THEN 'low'
	        WHEN COUNT(DISTINCT(wg.event)) <= 19 THEN 'medium'
			ELSE 'high' END AS participation_level_winter

FROM summer_games AS sg INNER JOIN winter_games AS wg ON sg.country_id = wg.country_id
						INNER JOIN countries AS c ON sg.country_id = c.id
GROUP BY c.country