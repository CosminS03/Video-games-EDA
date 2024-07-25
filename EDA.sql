--outlier detection
--mean, median, mode, standard deviation
--Which are the games that sold the best in every part of the world?
--Is there a difference between the prefferences of genre from one region to another?
--Which publihser had the best sales in each region?
--Which developer had the best sales in each region?
--Which is the most succesful year for the video game industry?
--Which region has the most sales?

CREATE VIEW categorical_counts
AS
SELECT COUNT(*) AS Total, COUNT(DISTINCT(Gam.game_name)) AS Game_names, 
	COUNT(DISTINCT(Gam.platform)) AS Platforms, COUNT(DISTINCT(Dev.developer)) AS Devs, 
	COUNT(DISTINCT(Gam.genre)) AS Genres, COUNT(DISTINCT(Gam.rating)) AS Ratings, 
	COUNT(DISTINCT(Pub.publisher)) AS Publishers
FROM developers Dev
JOIN publishers Pub
ON Dev.game_name = Pub.game_name
AND Dev.platform = Pub.platform
JOIN games Gam
ON Pub.game_name = Gam.game_name
AND Pub.platform = Gam.platform;

SELECT * FROM Games;