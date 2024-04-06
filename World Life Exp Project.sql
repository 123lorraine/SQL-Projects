# World Life Expectancy Project 
-- Data Cleaning and Exploratory Data Analysis --



-- -------------------------------------------- Cleaning Data in SQL queries -------------------------------------------------------------------

# Identifying and Removing Duplicates

-- Identifying Duplicates
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

-- Removing Duplicates 
SELECT *
FROM (
    SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
 ;
 
 DELETE FROM world_life_expectancy
 WHERE Row_ID IN (
	SELECT Row_ID
FROM (
    SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_table
WHERE Row_Num > 1
)
 ;
 
 
 
 # Identifying and Fixing Blanks
 
 -- 1. Identifying Blanks in Status --
 SELECT *
 FROM world_life_expectancy
 WHERE Status = '' 
 ;
 
-- 2. Identifying the status types when not blank --
SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> '' 
;

-- 3. Identifying the countries with the first status type --
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

-- 4. Updating blank statuses of countries we just identified as 'Developing' through a self join--
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developing'
WHERE t1.status= ''
AND t2.status <> ''
AND t2.Status = 'Developing'
;

-- 5. Updating blank statuses of countries identified as 'Developed' through a self join--
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developed'
WHERE t1.status= ''
AND t2.status <> ''
AND t2.Status = 'Developed'
;



 -- 1. Identifying Blanks in Life Expectancy --
 SELECT *
 FROM world_life_expectancy
 WHERE `Life expectancy`= ''
 ;
 
 
 SELECT Country, Year, `Life expectancy`
 FROM world_life_expectancy
 #WHERE `Life expectancy`= ''
 ;
 
 -- 2. Using the average of the year before and the year after the missing blanks through joins -- 
SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND ((t2.`Life expectancy` + t3.`Life expectancy`) /2, 1)
FROM world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.country= t2.country
		AND t1.Year = t2.Year - 1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
        AND t1.Year = t3.Year + 1
	WHERE t1.`Life expectancy` = ''
 ;
 
 -- 3. Updating the blanks in Life Expectancy from the previous calculations -- 
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
		ON t1.country= t2.country
		AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
        AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND ((t2.`Life expectancy` + t3.`Life expectancy`) /2, 1)
WHERE t1.`Life expectancy`=''
 ;
 
 
 
 
 
 
 -- ------------------------------------------------------Exploratory Data Analysis ------------------------------------------------------------------------
 
 #All DATA
 
 SELECT *
 FROM world_life_expectancy
 ;
 
 
 
 # How have well have countries done in increasing their life expectancy in the past 15 years?
 
SELECT Country, 
MIN(`Life Expectancy`) , 
MAX( `Life Expectancy`),
Round (MAX( `Life Expectancy`) - MIN(`Life Expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life Expectancy`) <> 0
AND MAX( `Life Expectancy`) <> 0
ORDER by Life_Increase_15_Years DESC
;


# What is the average life expectancy of each year?

SELECT Year, ROUND (AVG (`Life Expectancy`),2) 
FROM world_life_expectancy
WHERE `Life Expectancy` <> 0
AND `Life Expectancy` <> 0
GROUP BY Year
ORDER BY Year
;


# Is there a correlation between life expectancy and GDP?

SELECT Country, ROUND(AVG(`Life Expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP ASC
;

-- Countries vs GDP
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
ORDER BY GDP
;


# What is the average life expectancy between the different stauses (ie Developed vs Developing)?

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life Expectancy`),1) AS Life_Exp
FROM world_life_expectancy
GROUP BY Status
;




# Is there a correlation between life expectancy and BMI? 

SELECT Country, ROUND(AVG(`Life Expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;


-- Adult mortality rolling total

SELECT Country,
Year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;




