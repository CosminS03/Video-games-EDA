/*
-Which are the games that sold the best in every part of the world?
-Is there a difference between the prefferences of genre from one region to another? 
	How about rating?
-Which publihser had the best sales in each region?
-Which developer had the best sales in each region?
-Which region has the most sales?
*/
--Which is the most succesful year for the video game industry?
--What is the game that has the most versions?
--Which platform supported the most sales?
--Are there platform prefferences when it comes to geographical allocation? If so, which platform
--	supported the most sales in which region?
--What are the trends in the video game industry?
--Which developer has the best Sales/volume ratio?
--Which publisher has the best sale/volume ratio?
--Do ratings geared towards a younger demographic sell more?
--What's the time period of the data and how far is it from today?
--What are the top 3 best platforms in terms of video game sales for every year?(rollup)
--What is the top 3 best selling games for each platform?(Row_number)
--Rank games within each genre based on their sales in North America(rank or dense_rank)
--Identify the highest and second highest selling games for each publisher(rank)
--Calculate the year_over_year sales growth for each paltform(lag)
--Identify the first game by each publisher to reach 1 million in global sales(row_number)
--Rank games by their sales within each release year(rank)
--Calculate the trailing 3-year average sales for all the developers released a game in the most
--	recent year(lag)
--Identify publishers with consistently increasing or decreasing sales over the years(lag and lead)
--Rank each platform by total global sales(rank)

CREATE VIEW categorical_counts
AS
SELECT COUNT(*) AS Total, COUNT(DISTINCT(Sales.game_name)) AS game_names, 
	COUNT(DISTINCT(Sales.platform)) AS platforms, COUNT(DISTINCT(developer)) AS developers,
	COUNT(DISTINCT(publisher)) AS publishers, COUNT(DISTINCT(genre)) AS genres, 
	COUNT(DISTINCT(rating)) AS ratings
FROM Developers Dev
JOIN Sales
ON Dev.game_version_id = Sales.game_version_id
JOIN Games
ON Sales.game_name = Games.game_name
AND Sales.platform = Games.platform
AND Sales.year_of_release = Games.year_of_release;

--Value with the highert frequency for categorical variables

CREATE VIEW categorical_mode_values
AS
SELECT MODE() WITHIN GROUP(ORDER BY Sales.game_name) AS game_name, 
	MODE() WITHIN GROUP(ORDER BY Sales.platform) AS platform,
	MODE() WITHIN GROUP(ORDER BY Sales.year_of_release) AS year_of_release,
	MODE() WITHIN GROUP(ORDER BY developer) AS developer,
	MODE() WITHIN GROUP(ORDER BY publisher) AS publisher,
	MODE() WITHIN GROUP(ORDER BY genre) AS genre, MODE() WITHIN GROUP(ORDER BY rating)
FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
JOIN Developers Dev
ON Sales.game_version_id = Dev.game_version_id;

CREATE VIEW NA_metrics
AS
SELECT MIN(na_sales),
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY na_sales) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY na_sales) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY na_sales) AS percentile75,
	MAX(na_sales),
	ROUND(AVG(na_sales), 2) AS mean,
	MODE() WITHIN GROUP(ORDER BY na_sales),
	ROUND(STDDEV_POP(na_sales), 2) AS standard_deviation
FROM Sales
WHERE na_sales <>0;

CREATE VIEW EU_metrics
AS
SELECT MIN(eu_sales),
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY eu_sales) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY eu_sales) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY eu_sales) AS percentile75,
	MAX(eu_sales),
	ROUND(AVG(eu_sales), 2) AS mean,
	MODE() WITHIN GROUP(ORDER BY eu_sales),
	ROUND(STDDEV_POP(eu_sales), 2) AS standard_deviation
FROM Sales
WHERE eu_sales <>0;

CREATE VIEW JP_metrics
AS
SELECT MIN(jp_sales),
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY jp_sales) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY jp_sales) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY jp_sales) AS percentile75,
	MAX(jp_sales),
	ROUND(AVG(jp_sales), 2) AS mean,
	MODE() WITHIN GROUP(ORDER BY jp_sales),
	ROUND(STDDEV_POP(jp_sales), 2) AS standard_deviation
FROM Sales
WHERE jp_sales <>0;

CREATE VIEW Other_metrics
AS
SELECT MIN(other_sales),
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY other_sales) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY other_sales) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY other_sales) AS percentile75,
	MAX(other_sales),
	ROUND(AVG(other_sales), 2) AS mean,
	MODE() WITHIN GROUP(ORDER BY other_sales),
	ROUND(STDDEV_POP(other_sales), 2) AS standard_deviation
FROM Sales
WHERE other_sales <>0;

CREATE VIEW Global_metrics
AS
SELECT MIN(global_sales),
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY global_sales) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY global_sales) AS median,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY global_sales) AS percentile75,
	MAX(global_sales),
	ROUND(AVG(global_sales), 2) AS mean,
	MODE() WITHIN GROUP(ORDER BY global_sales),
	ROUND(STDDEV_POP(global_sales), 2) AS standard_deviation
FROM Sales;

--Which are the games that sold the best in every part of the world?
SELECT game_name, platform, year_of_release, na_sales FROM Sales
WHERE na_sales = (SELECT MAX(na_sales) FROM Sales);

SELECT game_name, platform, year_of_release, eu_sales FROM Sales
WHERE eu_sales = (SELECT MAX(eu_sales) FROM Sales);

SELECT game_name, platform, year_of_release, jp_sales FROM Sales
WHERE jp_sales = (SELECT MAX(jp_sales) FROM Sales);

SELECT game_name, platform, year_of_release, other_sales FROM Sales
WHERE other_sales = (SELECT MAX(other_sales) FROM Sales);

SELECT game_name, platform, year_of_release, global_sales FROM Sales
WHERE global_sales = (SELECT MAX(global_sales) FROM Sales);

--Is there a difference between the prefferences of genre from one region to another? 
	--How about rating?	
SELECT genre, SUM(na_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY genre
ORDER BY SUM(na_sales) DESC
LIMIT 3;

SELECT genre, SUM(eu_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY genre
ORDER BY SUM(eu_sales) DESC
LIMIT 3;

SELECT genre, SUM(jp_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY genre
ORDER BY SUM(jp_sales) DESC
LIMIT 3;

SELECT genre, SUM(other_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY genre
ORDER BY SUM(other_sales) DESC
LIMIT 3;

--Which publihser had the best sales in each region?
SELECT publisher, SUM(na_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY publisher
ORDER BY SUM(na_sales) DESC
LIMIT 1;

SELECT publisher, SUM(eu_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY publisher
ORDER BY SUM(eu_sales) DESC
LIMIT 1;

SELECT publisher, SUM(jp_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY publisher
ORDER BY SUM(jp_sales) DESC
LIMIT 1;

SELECT publisher, SUM(other_sales) AS sales FROM Games
JOIN Sales
ON Games.game_name = Sales.game_name
AND Games.platform = Sales.platform
AND Games.year_of_release = Sales.year_of_release
GROUP BY publisher
ORDER BY SUM(other_sales) DESC
LIMIT 1;

--Which developer had the best sales in each region?
SELECT developer, SUM(na_sales) AS sales FROM Developers dev
JOIN Sales
ON dev.game_version_id = Sales.game_version_id
GROUP BY developer 
ORDER BY SUM(na_sales) DESC
LIMIT 1;

SELECT developer, SUM(eu_sales) AS sales FROM Developers dev
JOIN Sales
ON dev.game_version_id = Sales.game_version_id
GROUP BY developer 
ORDER BY SUM(eu_sales) DESC
LIMIT 1;

SELECT developer, SUM(jp_sales) AS sales FROM Developers dev
JOIN Sales
ON dev.game_version_id = Sales.game_version_id
GROUP BY developer 
ORDER BY SUM(jp_sales) DESC
LIMIT 1;

SELECT developer, SUM(other_sales) AS sales FROM Developers dev
JOIN Sales
ON dev.game_version_id = Sales.game_version_id
GROUP BY developer 
ORDER BY SUM(other_sales) DESC
LIMIT 1;

--Which region has the most sales?
SELECT SUM(na_sales) AS NA, SUM(eu_sales) AS EU, SUM(jp_sales) AS JP, SUM(other_sales) AS Other
FROM Sales;