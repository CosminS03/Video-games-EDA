# Video Game Exploratory Data Analysis
## Introduction
This exploratory data analysis examines the video game industry, focusing on the performance of key players. By analyzing sales data and market trends, it provides a foundational understanding of the market. This analysis serves as a starting point for further in-depth investigations. 

## Project Description
The enitre analysis was produced with the help of the PostgreSQL RDBMS(Relational Database Management System) used for data management and the pgAdmin GUI(Graphical User Interface), which facilitated the interaction with the RDBMS.
The dataset was obtained from kaggle.com and contains the following columns: name, platform, year of release, genre, publisher, North America sales, Europe sales, Japan sales, other countries sales, global sales, critics score, critics count, users score, users count, developer and rating(ESRB). All sales are in millions of dollars. It's important to acknowledge that the overall quality of this analysis heavily depends on the quality of the data.
The project is divided into 2 phases with dedicated files: 
* Data Cleaning: This phase consists of handling missing data and normalization as to ensure minimmum redundancy for an easier and more reliable analysis.
* Exploratory Data Analysis: This phase provides basic statistical metrics for all of the variables and aims to asnwer questions regarding certain aspects of the data.

### Data Cleaning
Recommendation: To prevent potential issues, it's recommended to execute the script queries one at a time.

After the dataset is imported into PostrgreSQL, every column is checked for null values. Where there's no reliable way to infer the missing values, the tuples that contain them will be deleted.
While the game_name column had only two instances of missing values, it can be observed that there are tuples with additional information in the game_name column which indicate inconsistencies in the data.
![Example](images/name_irreg.png)
The tuples with weekly sales, old sales or ones that depict only sales from a certain region for a game that has a separate row
for all of its sales will be deleted, while the ones with "All regions" in the game_name column will be updated to remove the explanation.
The rows that show sales of the same game but only for a certain region, as shown in the photo below, will be added up into one tuple.
![Example](images/Divided_sales.png)
After adding these tuples, some duplicate rows will be generated. These rows will be deleted along with the ones that show the sales of a game from a certain region but have no complementary tuples.

To address missing values in other key columns, the following approaches were used:
*Cross-referencing platforms: Missing data on release year, developer, and rating were filled by referencing the same game on other platforms.
*Extracting from other columns: Some release years were parsed from the game title column.
*Series inference: For games that are part of a series, alphabetical sorting allowed identification of consecutive entries, with missing developer and rating values being inferred from adjacent titles. Missing release years for games in a series were filled by averaging the years of neighboring games.
*Platform-based averages: Missing release years were replaced with the average release year of the respective platform.
*Dropping columns: Columns with substantial missing data (critic_score, critic_count, user_score, user_count) and limited analytical value were removed.
*Dropping rows: Rows with missing values that couldn't have been inferred were deleted.

Upon visual inspection, it can be observed that some game names still contain additional information in parentheses.
![Remaining names](images/Remaining_names.png) 
These will be updated to remove the extra details, except for 'Dance Dance Revolution' and 'World Soccer Winning Eleven 7 International', which have region-specific versions and will retain the additional info.
Also through visual inspection, an outlier was spotted(there is only one game released in 2020 while the second most recent year is 2017) and it was discovered that some games have "unknown" publishers which will be deleted.
![Outlier](images/2020.png)  