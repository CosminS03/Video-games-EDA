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