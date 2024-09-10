/*
-Which are the games that sold the best in every part of the world?
-Is there a difference between the prefferences of genre from one region to another? 
	How about rating?
-Which publihser had the best sales in each region?
-Which developer had the best sales in each region?
-Which region has the most sales?
-Which is the most succesful year for the video game industry?
-What's the time period of the data and how far is it from today?
-What are the sales of every platform in each of the years that they had games in?
-Calculate the year_over_year sales growth for each paltform
-Rank games by their sales within each release year(rank)
-Calculate the trailing 3-year average sales for all the developers released a game in the most
	recent year(lag)
-Identify publishers with consistently increasing or decreasing sales over the years(lag and lead)
-Rank each platform by total global sales(rank)
-Are there platform prefferences when it comes to geographical allocation? If so, which platform 
	supported the most sales in which region?
-What is the top 3 best selling games for each platform?(Row_number)
*/
--What is the game that has the most versions?
--Which developer has the best Sales/volume ratio?
--Which publisher has the best sale/volume ratio?
--Do ratings geared towards a younger demographic sell more?
--Rank games within each genre based on their sales in North America(rank or dense_rank)
--Identify the highest and second highest selling games for each publisher(rank)
--Identify the first game by each publisher to reach 1 million in global sales(row_number)

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

--Value with the highest frequency for categorical variables

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

--Which is the most succesful year for the video game industry?
SELECT year_of_release, SUM(global_sales) FROM Sales
GROUP BY year_of_release
ORDER BY SUM(global_sales) DESC
LIMIT 1;

--What's the time period of the data and how far is it from today?
SELECT MIN(year_of_release) AS low_limit, MAX(year_of_release) AS high_limit,
	EXTRACT(YEAR FROM current_timestamp) - MAX(year_of_release) AS diff_from_current_day
FROM Sales;

--What are the sales of every platform in each of the years that they had games in?
SELECT platform,year_of_release, SUM(global_sales) AS Sales FROM Sales
GROUP BY CUBE(platform, year_of_release)
ORDER BY year_of_release;

--Calculate the year_over_year sales growth for each paltform
WITH Agg_year_platform_sales AS
(
	SELECT platform, year_of_release, SUM(global_sales) AS Sales FROM Sales
	GROUP BY platform, year_of_release
)
SELECT *, LAG(sales) OVER(PARTITION BY platform ORDER BY year_of_release) AS previous_sales,
	sales - LAG(sales) OVER(PARTITION BY platform ORDER BY year_of_release) AS Yoy_growth
FROM Agg_year_platform_sales;

--Rank games by their sales within each release year
WITH Agg_year_game_sales AS
(
	SELECT game_name, year_of_release, SUM(global_sales) AS sales FROM Sales
	GROUP BY year_of_release, game_name
)
SELECT *, RANK() OVER(PARTITION BY year_of_release ORDER BY sales DESC)
FROM Agg_year_game_sales;

--Calculate the trailing 3-year average sales for all the developers that released a game in the 
--most recent year(lag)
WITH developers_recent_sales AS
(
	SELECT developer, year_of_release, Sales as Y1,
		LAG(Sales) OVER(PARTITION BY developer ORDER BY year_of_release) AS Y2,
		LAG(Sales, 2) OVER(PARTITION BY developer ORDER BY year_of_release) AS Y3
	FROM(
		SELECT developer, year_of_release, SUM(global_sales) as Sales FROM Developers d
		JOIN Sales s
		ON d.game_version_id = s.game_version_id
		WHERE developer IN
		(
			SELECT DISTINCT(developer) FROM Developers dev
			JOIN Sales s
			ON dev.game_version_id = s.game_version_id
			WHERE year_of_release = 2016
		)
		GROUP BY developer, year_of_release
		ORDER BY developer, year_of_release
	)
)
SELECT developer, ROUND((y1 + y2 + y3) / 3, 2) AS Trailing_Sales_3Y FROM developers_recent_sales
WHERE year_of_release = 2016
AND y2 IS NOT NULL
AND y3 IS NOT NULL
ORDER BY Trailing_Sales_3Y DESC

--Identify the publishers and years in which they had both a 3 year streak of growing or declining 
--sales
WITH publishers_recent_sales AS
(
	SELECT publisher, year_of_release, Sales AS Y1,
		LAG(Sales) OVER(PARTITION BY publisher ORDER BY year_of_release) AS Y2,
		LAG(Sales, 2) OVER(PARTITION BY publisher ORDER BY year_of_release) AS Y3
	FROM (
		SELECT publisher, s.year_of_release, SUM(global_sales) AS sales FROM Sales s
		JOIN Games gm
		ON s.game_name = gm.game_name
		AND s.platform = gm.platform
		AND s.year_of_release = gm.year_of_release
		GROUP BY publisher, s.year_of_release
		ORDER BY publisher ASC, s.year_of_release DESC
	)
)
SELECT publisher, year_of_release,
	CASE
		WHEN Y1 > Y2 AND Y2 > Y3 THEN 'Growing'
		WHEN Y1 < Y2 AND Y2 < Y3 THEN 'Declining'
	END
FROM publishers_recent_sales
WHERE (Y1 > Y2 AND Y2 > Y3)
OR (Y1 < Y2 AND Y2 < Y3);

--Rank each platform by total global sales
SELECT platform, RANK()OVER(ORDER BY total_sales DESC)
FROM
(
	SELECT platform, SUM(global_sales) AS total_sales
	FROM Sales
	GROUP BY platform
);

--Are there platform prefferences when it comes to geographical allocation? If so, which platform
--	supported the most sales in which region?
(
	SELECT 'Na', platform FROM Sales
	GROUP BY platform
	ORDER BY SUM(na_sales) DESC
	LIMIT 1
)
UNION
(
	SELECT 'Eu', platform FROM Sales
	GROUP BY platform
	ORDER BY SUM(eu_sales) DESC
	LIMIT 1
)
UNION 
(
	SELECT 'Jp', platform FROM Sales
	GROUP BY platform
	ORDER BY SUM(jp_sales) DESC
	LIMIT 1
)
UNION
(
	SELECT 'Other', platform FROM Sales
	GROUP BY platform
	ORDER BY SUM(other_sales) DESC
	LIMIT 1
)

--What is the top 3 best selling games for each platform?
SELECT platform, game_name, rnk
FROM
(
	SELECT platform, game_name, 
		DENSE_RANK() OVER(PARTITION BY platform ORDER BY global_sales DESC) AS Rnk
	FROM Sales
)
WHERE rnk <= 3
ORDER BY platform, rnk