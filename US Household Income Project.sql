# US Household Income Project
-- Data Cleaning and Exploratory Data Analysis --


SELECT * 
FROM us_household_income_project.us_household_income;

SELECT * 
FROM us_household_income_project.us_household_income_statistics;



-- -------------------------------------------- Cleaning Data in SQL queries -------------------------------------------------------------------

# Fixing Columns

ALTER TABLE us_household_income_project.us_household_income_statistics
RENAME COLUMN `ï»¿id` TO `id` 
;



#Check # of rows for both tables 

SELECT COUNT(id)
FROM us_household_income_project.us_household_income;

SELECT COUNT(id)
FROM us_household_income_project.us_household_income_statistics;



#Identify & Remove Duplicates in US Household Income Table

SELECT id, COUNT(id)
FROM us_household_income_project.us_household_income
GROUP BY id
HAVING COUNT(id) > 1
;


SELECT *
FROM (
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
	FROM us_household_income
	) duplicates
WHERE row_num >1
;


DELETE FROM us_household_income
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_household_income
		) duplicates
	WHERE row_num >1)
;


#Identify & Remove Duplicates in US Household Income Statistics Table

SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;
-- No duplicates identified 


#Identifying and Fixing Errors in State Names

SELECT State_Name, COUNT(State_Name)
FROM us_household_income
GROUP BY State_Name
;

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;


#Identifying and Fixing Errors in State Abbreviations

SELECT DISTINCT State_ab
FROM us_household_income
ORDER BY 1
;

#Identifying and Fixing Errors in Place

SELECT *
FROM us_household_income
WHERE Place =''
ORDER BY 1
;

SELECT *
FROM us_household_income
WHERE County = 'Autauga County' 
ORDER BY 1
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County' 
AND City = 'Vinemont'
;


#Identifying and Fixing Errors in Type

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
ORDER BY 1
;

UPDATE us_household_income
SET TYPE = 'Borough'
WHERE TYPE = 'Boroughs'
;



 -- ------------------------------------------------------Exploratory Data Analysis ------------------------------------------------------------------------
 
 # Which States have the largest amount of land and water?
 
SELECT State_Name, County, City, ALand, AWater
FROM us_household_income
;

# Identifying the top ten by land mass

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;
;

 # Identifying the top ten by water

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;
;
 
 
 #Join the two tables together
 
 SELECT *
 FROM us_household_income u
 JOIN us_household_income_statistics us
	ON u.id = us.id
;
 
 
 # InnerJoin
SELECT *
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0;
;
 
 
 
# Which states have the highest average household incomes? 
 
SELECT u.State_Name, ROUND(AVG(MEAN),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 10
;
 
 
# Which states have the lowest median household incomes? 
 
SELECT u.State_Name, ROUND(AVG(MEAN),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 
LIMIT 10
;



# Is there a correlation between type and average household income?
 
SELECT Type, COUNT(Type), ROUND(AVG(MEAN),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 3 DESC
;
 
 
 #Checking above again, filtering out the high outliers
 
SELECT Type, COUNT(Type), ROUND(AVG(MEAN),1), ROUND(AVG(Median),1)
FROM us_household_income u
INNER JOIN us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
;
 
 
 
 
 # Exploring community 
 
 SELECT *
 FROM us_household_income
 WHERE Type = 'Community'
 ;
 
 
 # Looking at household incomes at the city level
 
SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income u
JOIN us_household_income_statistics us
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY 3 DESC
;
 
 
 
 