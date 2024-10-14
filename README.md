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