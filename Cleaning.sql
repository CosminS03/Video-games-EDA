--UPDATE POSTGRESQL
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
WHERE RIGHT(t1.game_name, 5) = 'ales)'
AND RIGHT(t2.game_name, 5) = 'ales)'
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


SELECT * FROM Video_Games
WHERE platform IS NULL;
--There are no null values for platform


SELECT * FROM Video_Games
WHERE year_of_release IS NULL;
/*
The rows with games that have missing years of release will be filled with the years from rows of the
same game but on different platforms
*/
UPDATE Video_Games AS t1
SET year_of_release = t2.year_of_release
FROM (
	SELECT * FROM Video_Games
	WHERE year_of_release IS NOT NULL
) AS t2
WHERE t1.game_name = t2.game_name;
/*
Some games have their year of release at the end of their names, so the years will be filled in from
their names
*/
UPDATE Video_Games
SET year_of_release = RIGHT(game_name,4)::INTEGER
WHERE RIGHT(game_name, 4) LIKE '20%'
AND year_of_release IS NULL;
/*
The rest of the missing values will be calculated by making the average of the release years of the 
next and previous games in the series of the one with null value. The way in which wether the game in
question is in a series is by ordering the whole dataset by game name and checking wether the game 
before and after starts with the same words.
*/
WITH sorted_data AS 
(
	SELECT *, 
	LAG(game_name) OVER (ORDER BY game_name) AS prev_game,
	LEAD(game_name) OVER (ORDER BY game_name) AS next_game,
	CAST(AVG(CASE WHEN year_of_release IS NOT NULL THEN year_of_release ELSE NULL END)
	OVER (ORDER BY game_name ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS INTEGER) AS avg_release_year
  	FROM Video_Games
)
UPDATE Video_Games AS t1
SET year_of_release =  
(
	SELECT avg_release_year FROM sorted_data
	WHERE TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
	TRIM(SUBSTRING(prev_game FROM 1 FOR POSITION(' ' IN prev_game)))
	AND TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
	TRIM(SUBSTRING(next_game FROM 1 FOR POSITION(' ' IN next_game)))
	LIMIT 1
)
WHERE year_of_release IS NULL;
/*
The rest of the missing years of release will be replaced with the average year of release of the
platform that it appeared on
*/
WITH platform_avg_years AS
(
	SELECT platform, 
	CAST(AVG(year_of_release) AS INTEGER) AS avg_year FROM Video_Games
	GROUP BY platform
)
UPDATE Video_Games AS t1
SET year_of_release = avg_year
FROM platform_avg_years AS t2
WHERE t1.platform = t2.platform
AND year_of_release IS NULL;


SELECT * FROM Video_Games
WHERE genre IS NULL;

SELECT * FROM Video_Games
WHERE publisher IS NULL;

SELECT * FROM Video_Games
WHERE na_sales IS NULL;

SELECT * FROM Video_Games
WHERE eu_sales IS NULL;

SELECT * FROM Video_Games
WHERE jp_sales IS NULL;

SELECT * FROM Video_Games
WHERE other_sales IS NULL;

SELECT * FROM Video_Games
WHERE global_sales IS NULL;
/*
The genre, publisher, NA, EU, JP, Other and Global sales have no null values
*/


SELECT * FROM Video_Games
WHERE critic_score IS NULL
AND critic_count IS NULL
AND user_score IS NULL
AND user_count IS NULL;
/*
The scores and counts of both critics and users will be deleted as nearly half of the dataset misses
these values and these features aren't truly important in this analysis
*/
ALTER TABLE Video_Games DROP COLUMN critic_score;
ALTER TABLE Video_Games DROP COLUMN critic_count;
ALTER TABLE Video_Games DROP COLUMN user_score;
ALTER TABLE Video_Games DROP COLUMN user_count;


SELECT * FROM Video_Games
WHERE developer IS NULL;
/*
Some games with null values in the developer columns may have been released on different consoles,
thus being depicted on another row where the developer may be specified
*/
UPDATE Video_Games AS t1
SET developer = t2.developer
FROM
(
	SELECT * FROM Video_Games
	WHERE developer IS NOT NULL
) AS t2
WHERE t1.game_name = t2.game_name;
/*
Some games may be sequels or part of a series. The ones with missing developers will have the values 
replaced with the developers from the other games in their series. In the publisher column, which will
be used for determining wether a game is in a series or not, there are 'N/A' values. These values 
will have to be replaced or deleted in order to properly replace some of the null values from the 
developer column
*/
--Replacing N/A
UPDATE Video_Games AS t1
SET publisher = t2.publisher
FROM 
(
	SELECT * FROM Video_Games
	WHERE publisher <> 'N/A'
) AS t2
WHERE t1.game_name = t2.game_name
AND t1.publisher = 'N/A';
--Deleting rows with N/A
DELETE FROM Video_Games
WHERE publisher = 'N/A';
--Replacing the null values from the developer column
WITH sorted_data AS 
(
	SELECT *,
	LAG(game_name) OVER(ORDER BY game_name) AS prev_game,
	LAG(publisher) OVER(ORDER BY game_name) AS prev_publish,
	LAG(developer) OVER(ORDER BY game_name) AS prev_dev,
	LEAD(game_name) OVER (ORDER BY game_name) AS next_game,
	LEAD(publisher) OVER (ORDER BY game_name) AS next_publish,
	LEAD(developer) OVER (ORDER BY game_name) AS next_dev
	FROM Video_Games
	WHERE developer IS NOT NULL
)
UPDATE Video_Games AS t1
SET developer = COALESCE(
	(
		SELECT prev_dev FROM sorted_data
		WHERE TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
		TRIM(SUBSTRING(prev_game FROM 1 FOR POSITION(' ' IN prev_game)))
		AND prev_publish = t1.publisher
		LIMIT 1
	),
	(
		SELECT next_dev FROM sorted_data
		WHERE TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
		TRIM(SUBSTRING(next_game FROM 1 FOR POSITION(' ' IN next_game)))
		AND next_publish = t1.publisher
		LIMIT 1
	)
)
WHERE developer IS NULL;
/*
Due to there being no other reliable way of inferring the developer, the rest of the data will be
deleted
*/
DELETE FROM Video_Games
WHERE developer IS NULL;


SELECT * FROM Video_Games
WHERE rating IS NULL;
/*
As it had been done above, some of the null values from the rating column will be replaced with the
values of the same game depicted on a different row
*/
UPDATE Video_Games AS t1
SET rating = t2.rating
FROM 
(
	SELECT * FROM Video_Games
	WHERE rating IS NOT NULL
) AS t2
WHERE t1.game_name = t2.game_name
AND t1.rating IS NULL;
/*
The games will be checked to see if they are part of a series and then based on that the rating will 
be replaced
*/
WITH sorted_data AS 
(
	SELECT *,
	LAG(game_name) OVER(ORDER BY game_name) AS prev_game,
	LAG(publisher) OVER(ORDER BY game_name) AS prev_pub,
	LAG(rating) OVER(ORDER BY game_name) AS prev_rating,
	LEAD(game_name) OVER(ORDER BY game_name) AS next_game,
	LEAD(publisher) OVER(ORDER BY game_name) AS next_pub,
	LEAD(rating) OVER(ORDER BY game_name) AS next_rating
	FROM Video_Games
	WHERE rating IS NOT NULL
)
UPDATE Video_Games AS t1
SET rating = COALESCE
(
	(
		SELECT prev_rating FROM sorted_data
		WHERE TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
		TRIM(SUBSTRING(prev_game FROM 1 FOR POSITION(' ' IN prev_game)))
		AND t1.publisher = prev_pub
		LIMIT 1
	),
	(
		SELECT next_rating FROM sorted_data
		WHERE TRIM(SUBSTRING(t1.game_name FROM 1 FOR POSITION(' ' IN t1.game_name))) = 
		TRIM(SUBSTRING(next_game FROM 1 FOR POSITION('' IN next_game)))
		AND t1.publisher = next_pub
		LIMIT 1
	)
)
WHERE rating IS NULL;
--The rest of the rows will be deleted
DELETE FROM Video_Games
WHERE rating IS NULL;

--remove duplicates
DELETE FROM Video_Games
WHERE CTID IN 
(
	SELECT MAX(CTID) FROM Video_Games
	GROUP BY game_name, platform, year_of_release
	HAVING COUNT(*) > 1
);

SELECT DISTINCT game_name FROM Video_Games;
/*
On visual inspection of the dataset, there still are values in the game_name column that have 
additional informtaion inside parenthesis. These will be updated as to not have the additional info
anymore. Exceptions are the games Dance Dance Revolution and World Soccer Winning Eleven 7
International because these games have different versions for different regions and thus the 
additional info will not be deleted
*/
UPDATE Video_Games 
SET game_name = TRIM(SUBSTRING(game_name FROM 1 FOR POSITION('(' IN game_name) - 1))
WHERE game_name LIKE '%(%'
AND game_name  NOT IN
('Dance Dance Revolution (Japan)', 'World Soccer Winning Eleven 7 International (JP version)',
'Dance Dance Revolution (North America)');


SELECT DISTINCT platform FROM Video_Games;
SELECT DISTINCT year_of_release FROM Video_Games;
/*
There is one outlier in this dataset regarding the year of release. The game Imagine: Makeup Artist
is the only game released in 2020 and no other game in this dataset has a year of release between
2017 and 2020
*/
DELETE FROM Video_Games
WHERE year_of_release = 2020;


SELECT DISTINCT genre FROM Video_Games;
SELECT DISTINCT publisher FROM Video_Games;
/*
Some games have unknown publishers which cannot be inferred and will be deleted
*/
DELETE FROM Video_Games
WHERE publisher = 'Unknown';


SELECT DISTINCT developer FROM Video_Games;
SELECT DISTINCT rating FROM Video_Games;
/*
The column developer has multiple values in a single cell, thus it must be reduced to 1NF. To do that,
another table named Developers will be created with the columns game_name, platform and developers.
*/
CREATE TABLE Developers AS
SELECT game_name,platform, TRIM(developer) AS developer
FROM Video_Games;

/*
For some games, the developers' name have commas in them used before the suffixes "Inc", "Ltd" and 
"LLC". These suffixes will be deleted from names only if they have a comma in front so that they don't
interfere with the division of the cells with multiple developers.
*/
UPDATE Developers
SET developer = 
	CASE
		WHEN developer LIKE '%, Inc.' THEN LEFT(developer, LENGTH(developer) - 6)
		WHEN developer LIKE '%, Inc' THEN LEFT(developer, LENGTH(developer) - 5)
		WHEN developer LIKE '%, Ltd.' THEN LEFT(developer, LENGTH(developer) - 6)
		WHEN developer LIKE '%, LLC' THEN LEFT(developer, LENGTH(developer) - 5)
		WHEN developer LIKE '%,Ltd.' THEN LEFT(developer, LENGTH(developer) - 5) 
		WHEN developer LIKE '%, Lda' THEN LEFT(developer, LENGTH(developer) - 5)
	END
WHERE developer LIKE '%, Inc.'
OR developer LIKE '%, Ltd.'
OR developer LIKE '%, LLC'
OR developer LIKE '%,Ltd.'
OR developer LIKE '% Inc'
OR developer LIKE '%, Lda';

/*
The following sequence of querries will take the first developer of the cells with multiple ones and 
insert it on a new line along with the game name and platform of the original line. After that, the 
first developer from the original cell will be deleted. This process will be done a second time
because within this dataset the games can have a maximum of 3 developers.
*/
BEGIN TRANSACTION;
--Separating the first developer of the cells that have 3
INSERT INTO Developers
SELECT game_name, platform,
TRIM(SUBSTRING(developer FROM 1 FOR POSITION(',' IN developer) - 1))
FROM Developers
WHERE developer LIKE '%,%,%';

--Deleting the first developer from the cells that have 3 of them
UPDATE Developers
SET developer = TRIM(SUBSTRING(developer FROM POSITION(',' IN developer) + 1 FOR LENGTH(developer)))
WHERE developer LIKE '%,%,%';

/*
Due to deleting the first developers from the cells with 3 based on commas, a cell now start with
"Inc," and another one starts with "Ltd.,". These prefixes will be deleted
*/
UPDATE Developers
SET developer = TRIM(SUBSTRING(developer FROM POSITION(',' IN developer) + 1 FOR LENGTH(developer)))
WHERE developer LIKE 'Ltd.,%'
OR developer LIKE 'Inc,%';

--Separating the first developer of the cells that have 2
INSERT INTO Developers
SELECT game_name, platform,
TRIM(SUBSTRING(developer FROM 1 FOR POSITION(',' IN developer) - 1))
FROM Developers
WHERE developer LIKE '%,%';

--Deleting the first developer from the cells that have 2
UPDATE Developers
SET developer = TRIM(SUBSTRING(developer FROM POSITION(',' IN developer) + 1 FOR LENGTH(developer)))
WHERE developer LIKE '%,%';

COMMIT;

/*
In the original dataset there were games that had in the developer columns the name of the company
with and without the suffixes like "Inc". By deleting those suffixes when seperating the developers
duplicate rows might have been produced.
*/
DELETE FROM Developers
WHERE CTID IN
(
	SELECT MAX(CTID)
	FROM Developers
	GROUP BY game_name, platform, developer
	HAVING COUNT(*) > 1
);

ALTER TABLE Video_Games
DROP COLUMN developer;

/*
The current video_games table has the genre and rating column which depends only on the game_name, 
while the primary key is composed of both game_name and platform, thus it must be reduced to the 2NF.
*/

--RENORMALIZE, BUT KEEP THE 2NF-ING OF VIDEO_GAMES
--RECREATE THE WHOLE PROJECT

--2NF
ALTER TABLE Video_Games RENAME TO Sales;

CREATE TABLE Games AS
SELECT game_name, platform, year_of_release, publisher, genre, rating 
FROM Sales;

ALTER TABLE Sales
DROP COLUMN genre;

ALTER TABLE Sales
DROP COLUMN rating;

ALTER TABLE Sales
DROP COLUMN publisher;

DELETE FROM Games
WHERE CTID IN 
(
	SELECT MAX(CTID) FROM Games
	GROUP BY game_name, platform
	HAVING COUNT(*) > 1
);

--3NF CHECK
--4NF CHECK

--Adding constraints
ALTER TABLE Sales
ADD COLUMN game_version_id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY;

ALTER TABLE Games
ADD CONSTRAINT Games_primary_key PRIMARY KEY(game_name, platform, year_of_release);

ALTER TABLE Sales
ADD CONSTRAINT unique_game_versions UNIQUE(game_name, platform, year_of_release);

ALTER TABLE Games
ADD CONSTRAINT Games_foreign_key FOREIGN KEY(game_name, platform, year_of_release)
REFERENCES Sales(game_name, platform, year_of_release);

CREATE TABLE Dev_bckp
AS
SELECT D.game_name, D.platform, developer, game_version_id 
FROM Developers D
JOIN Sales S
ON D.game_name = S.game_name
AND D.platform = S.platform;

DROP TABLE Developers;

ALTER TABLE Dev_bckp RENAME TO Developers;

ALTER TABLE Developers
ADD CONSTRAINT Developers_primary_key PRIMARY KEY(game_name, platform, developer, game_version_id);

ALTER TABLE Developers
ADD CONSTRAINT Developers_foreign_key FOREIGN KEY(game_version_id) 
REFERENCES Sales(game_version_id);

SELECT * FROM Developers;