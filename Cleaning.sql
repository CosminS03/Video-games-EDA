--Creating the table for the data to be inserted into
CREATE TABLE Video_Games
(
	Game_Name TEXT,
	Platform TEXT,
	Year_of_release INT,
	Genre TEXT,
	Publisher TEXT,
	NA_sales DECIMAL(4, 2),
	EU_sales DECIMAL(4, 2),
	JP_sales DECIMAL(4, 2),
	Other_sales DECIMAL(4, 2),
	Global_sales DECIMAL(4, 2),
	Critic_score INT,
	Critic_count INT,
	User_score DECIMAL(4, 2),
	User_count INT,
	Developer TEXT,
	Rating TEXT
);

/*Due to varying values which represent null in columns with different data types, another table with
with all the columns having the text type will be created in which the data will be inserted and
than filtered*/

--Creating the staging table
CREATE TABLE Video_Games_Staging
(
	Game_Name TEXT,
	Platform TEXT,
	Year_of_release TEXT,
	Genre TEXT,
	Publisher TEXT,
	NA_sales TEXT,
	EU_sales TEXT,
	JP_sales TEXT,
	Other_sales TEXT,
	Global_sales TEXT,
	Critic_score TEXT,
	Critic_count TEXT,
	User_score TEXT,
	User_count TEXT,
	Developer TEXT,
	Rating TEXT
);

--Copying the csv data into the staging table
COPY Video_Games_Staging 
FROM 'C:\Program Files\PostgreSQL\16\data\Video_Games_Sales_as_at_22_Dec_2016.csv'
DELIMITER ','
CSV HEADER;

--Replacing the "N/A" values and empty strings with NULL
UPDATE Video_Games_Staging
SET Year_of_release = NULLIF(Year_of_release, 'N/A'),
	Critic_score = NULLIF(Critic_score, ''),
	Critic_count = NULLIF(Critic_count, ''),
	User_score = NULLIF(User_score,''),
	User_count = NULLIF(User_count, '');
	
--Inserting the data from staging into the Video_Games table
INSERT INTO Video_Games
SELECT Game_Name, Platform, Year_of_release::INT, Genre, Publisher, NA_sales::DECIMAL(4, 2),
	EU_sales::DECIMAL(4, 2), JP_sales::DECIMAL(4, 2), Other_sales::DECIMAL(4, 2), 
	Global_sales::DECIMAL(4, 2), Critic_score::INT, Critic_count::INT, User_score::DECIMAL(4, 2),
	User_count::INT, Developer, Rating
FROM Video_Games_Staging;

--Dropping the staging table
DROP TABLE Video_Games_Staging;

--Checking every feature for null values
SELECT * FROM Video_Games
WHERE game_name IS NULL;
--The rows with missing names of the games will have to be deleted
DELETE FROM Video_Games
WHERE game_name IS NULL;
/*
In this dataset there are rows which depict a certain game but with added details about their sales
written in between two parenthesis at the end of the name(examples: weekly sales, US sales, old sales)
Rows which contain weekly sales will be deleted so that the consistency of the data is maintained
*/
DELETE FROM Video_Games
WHERE game_name LIKE '%eekly%';
/*
Rows which contain old sales will also be deleted because rows with updated sales of the same game
exist
*/
DELETE FROM Video_Games
WHERE game_name LIKE '%(old%'
OR game_name LIKE '%(Old%';
/*
Rows which specify that the sales are from all the regions will have the additional info deleted from 
their name, so that it remains only the name of the game.
*/
UPDATE Video_Games
SET game_name = SUBSTRING(game_name FROM 1 FOR POSITION('(' IN game_name) - 1)
WHERE game_name LIKE '%(_ll _egion_%';
/*
The rows which depict only sales from a certain region for a game while that game has a separate row
for all of its sales will be deleted
*/
DELETE FROM Video_Games
WHERE game_name IN(
	SELECT t2.game_name FROM (
		SELECT game_name, platform FROM Video_Games
		WHERE game_name NOT LIKE '%(%'
	) AS t1
	INNER JOIN (
		SELECT game_name, platform FROM Video_Games
		WHERE RIGHT(game_name, 6) = 'sales)'
	) AS t2
	ON t1.platform = t2.platform
	AND t1.game_name = TRIM(SUBSTRING(t2.game_name FROM 1 FOR POSITION('(' IN t2.game_name)-1))
);
/*
The sales of some games are divided into more rows based on their region. These rows will have all of
their sales added up then deleted so that remains only one row for a game
*/
UPDATE Video_Games AS t1
SET na_sales = t1.na_sales + t2.na_sales,
eu_sales = t1.eu_sales + t2.eu_sales,
jp_sales = t1.jp_sales + t2.jp_sales,
other_sales = t1.other_sales + t2.other_sales,
global_sales = t1.global_sales + t2.global_sales,
game_name = TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION('(' IN t1.game_name) - 1))
FROM Video_Games AS t2
WHERE RIGHT(t1.game_name, 6) = 'sales)'
AND RIGHT(t2.game_name, 6) = 'sales)'
AND TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION('(' IN t1.game_name) - 1)) = 
TRIM(SUBSTRING(t2.game_name FROM 1 FOR POSITION('(' IN t2.game_name) - 1))
AND t1.game_name <> t2.game_name;

DELETE FROM Video_Games
WHERE CTID IN (
	SELECT CTID FROM(
		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY game_name, platform) AS rn,
		CTID
		FROM Video_Games) X
	WHERE X.rn > 1
);

/*
There still are rows with sales from certain regions which don't have other rows to complete their
information, so they will be deleted
*/
DELETE FROM Video_Games
WHERE RIGHT(game_name, 6) = 'sales)';