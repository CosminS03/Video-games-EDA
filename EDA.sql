--Which are the games that sold the best in every part of the world?
--Is there a difference between the prefferences of genre from one region to another?
--Which publihser had the best sales in each region?
--Which developer had the best sales in each region?
--Which is the most succesful year for the video game industry?
--Which region has the most sales?

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