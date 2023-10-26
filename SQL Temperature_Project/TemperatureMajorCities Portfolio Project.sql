/*
Major cities Average Temperature exploration

Skills used: Temp tables,CTE,Join's, windows Functions, Aggregate functions, Creating views, Converting Data Types
*/

SELECT *
FROM TemperatureMajorCities..city_temperature
ORDER BY 2,6

-- Exploration of data, looking for empty, null values or missing data. 
-- Region Column

SELECT *
FROM TemperatureMajorCities..city_temperature
WHERE Region = '' OR Region is Null

--	Country column

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE Country = '' OR Country is Null 

-- State column 

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE State = '' OR State is Null 

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE State is Null 

-- On State column is empty for all the countries except US 

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE State != ''

-- City Column

SELECT *
FROM TemperatureMajorCities..city_temperature
WHERE City = '' or City is Null

-- Month Column

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE Month= '' or Month is Null

-- It should be expected that the query above shows 12 rows 

SELECT DISTINCT Month 
FROM TemperatureMajorCities..city_temperature

-- From previous queries, the months are typed with numbers, however, the Column type is varchar. Casting the Month column as int:

SELECT DISTINCT CAST(Month AS int)  as Month_Number
FROM TemperatureMajorCities..city_temperature
ORDER BY CAST(Month AS int) asc

-- Casting could be used to the following columns
-- Year Column

SELECT CAST(Year AS int) , COUNT(Year) as YearApperance
FROM TemperatureMajorCities..city_temperature
GROUP BY CAST(Year AS int)
ORDER BY CAST(Year AS int) asc
 
-- Query above shows 200 and 201 years. Let's see all the data related to these values:

SELECT *
FROM TemperatureMajorCities..city_temperature
WHERE CAST(Year AS int) = 200 OR CAST(Year AS int) = 201

-- Data related to this years values shows an AvgTemperature of -99, which appearance of be the indicator of missing values
-- Day Column

SELECT Day 
FROM TemperatureMajorCities..city_temperature
WHERE Day is Null or Day = ''

--  It should be expected that the query above shows 31 rows 

SELECT DISTINCT CAST(Day AS int) as Day_Numbers
FROM TemperatureMajorCities..city_temperature
ORDER BY CAST(Day AS int) asc

-- Query above shows that there is a Day 0 in the data, which may be wrong cause there is no 0 day in calendar. So lets look at this value

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE CAST(Day AS int) = 0

-- Same thing that before, the Select above shows missing values

--  Select the count of AvgTemperature values equals to -99

SELECT *
FROM TemperatureMajorCities..city_temperature
WHERE CAST(AvgTemperature AS float) = -99

-- So there is 79672 of 2906327 with -99 of AvgTemperature, the 2.7% of the dataset are missing values

-- Select the total cities

SELECT Region,Country,State, City
FROM TemperatureMajorCities..city_temperature
GROUP BY Region,Country,State, City
ORDER BY 1,2

/*
There is 325 different cities. We already know that the collection period of the data is between 1995-2020 (26 years). In this order, if the collection has been done by every year
the lenght of the data should be 8450. Following through, by month 101400, by day 37011000 rows of data. However, the dataset has 2906327 (considering the -99 missing values)
records, 7,85% if we consider all the data that should be recorder. 

So next, the idea is to select those cities that has all the records for every year, calculate the average temperature for each year and insert it into a view.
*/

-- Using Temp Tables to obtain the data without -99 AvgTemperature values

DROP TABLE IF EXISTS WithOut99
CREATE TABLE WithOut99 
(
Region nvarchar(50),
Country nvarchar(50),
State nvarchar(50),
City nvarchar(50),
Year int,
Month int,
Day int,
AvgTemperature float
)
--
INSERT INTO WithOut99
SELECT Region,Country,State,City, Year, Month, Day, AvgTemperature 
FROM TemperatureMajorCities..city_temperature
WHERE CAST(AvgTemperature AS float) != -99
ORDER BY Country, CAST(Year AS int), CAST(Month AS int)

SELECT *
FROM WithOut99
WHERE City = 'Algiers'
ORDER BY 2,5,6,7

--	Using a Temp Table to Select the countries with full years and months data

DROP TABLE IF EXISTS FullCountries
CREATE TABLE FullCountries
(
Region nvarchar(50),
Country nvarchar(50),
State nvarchar(50),
City nvarchar(50),
NumberofYears int,
NumberofMonths int
) 
INSERT INTO FullCountries
SELECT Region, Country, State, City, COUNT(DISTINCT Year) AS NumberofYears, COUNT(DISTINCT Month) AS NumberOfMonths
FROM WithOut99
GROUP BY Region, Country, State, City
HAVING COUNT(DISTINCT Year) = 26 AND COUNT(DISTINCT Month) = 12
ORDER BY 2,3,4

-- Using CTE to perform calculation of AverageTemperature by month in Celcius

WITH AvgByYear AS (
SELECT a.Region, a.Country, a.State, a.City,a.Year,a.Month, AVG(a.AvgTemperature) AS AverageTemperaturebyMonth
FROM WithOut99 a RIGHT JOIN FullCountries b ON a.City = b.City  
GROUP BY a.Region, a.Country, a.State, a.City,a.Year,a.Month

)

SELECT *, ((AverageTemperaturebyMonth-32)*5)/9 AS AverageTemperaturebyMonthCelsius
FROM AvgByYear

-- Creating View to store data for later visualizations 

CREATE VIEW ExportingAvgTemperatureByMonth AS 
WITH AvgByYear AS (
    SELECT a.Region, a.Country, a.State, a.City, a.Year, a.Month, AVG(a.AvgTemperature) AS AverageTemperaturebyMonth
    FROM WithOut99 a 
    RIGHT JOIN FullCountries b ON a.City = b.City  
    GROUP BY a.Region, a.Country, a.State, a.City, a.Year, a.Month
) 
SELECT *, ((AverageTemperaturebyMonth-32)*5)/9 AS AverageTemperaturebyMonthCelsius, CONVERT(DATE,CONCAT(CAST(Year as nvarchar(50)),'-',CAST(Month as nvarchar(50)),'-1')) AS Date
FROM AvgByYear;

-- Using CTE to perform calculation of the Min and Max AvgTemperature on a calendar year along 1995-2020

WITH MinMaxYearByDay AS (
SELECT a.Region, a.Country, a.State, a.City, a.Month, a.Day, MIN(a.AvgTemperature) AS MinAvgTemperature, MAX(a.AvgTemperature) AS MaxAvgTemperature
FROM WithOut99 a RIGHT JOIN FullCountries b ON a.City = b.City  
GROUP BY a.Region, a.Country, a.State, a.City, a.Month, a.Day

)
SELECT *, ((MinAvgTemperature-32)*5)/9 AS MinAvgTemperatureCelsius, ((MaxAvgTemperature-32)*5)/9 AS MaxAvgTemperatureCelsius
FROM MinMaxYearByDay

-- Creating View to store data for later visualizations 

CREATE VIEW ExportingMinMaxYearByDay AS 
WITH MinMaxYearByDay AS (
SELECT a.Region, a.Country, a.State, a.City, a.Month, a.Day, MIN(a.AvgTemperature) AS MinAvgTemperature, MAX(a.AvgTemperature) AS MaxAvgTemperature
FROM WithOut99 a RIGHT JOIN FullCountries b ON a.City = b.City  
WHERE a.Day !=29 
GROUP BY a.Region, a.Country, a.State, a.City, a.Month, a.Day
)
SELECT *, ((MinAvgTemperature-32)*5)/9 AS MinAvgTemperatureCelsius, ((MaxAvgTemperature-32)*5)/9 AS MaxAvgTemperatureCelsius, CONVERT(DATE,CONCAT('2021-',CAST(Month as nvarchar(50)),'-',CAST(Day as nvarchar(50)))) AS Date
FROM MinMaxYearByDay

-- There is something special that I want to mention about the above views. At the beggining of this script, it was show that the dataset has a lot of missing data. The missing 
-- data is not only related to one specific column, in fact, the columns with missing values for our interest are Year, Month, Day and AvgTemperature. By the other hand, the intention
-- with the views that were created is to show the avg temperature by month and the min and max avgTemperature by month over the period 1995-2020 on every city. So we created the 
-- CTE FullCountries that has the cities with all the years and all the months, yet, this isn't true at all, and the query below will explain that. The FullCountries CTE has a column
-- call it umberOfMonths, because it is not partition by at the time to made the count over the months, if a country has a year with 5 months of data and the other 25 years with 12 
-- months of data, when the query calculate the avgTemperature it would pass away from the missing data and continue with the calculation. This is the reason why the views are not empty.
-- The query below calculates the total months that every city has in the period 1995-2020. If, the data from a city is complete at the month column, the sum of months partition by
-- city will show 78*26 = 2028. (78 because if we sum the month values (1+2+...12 =78). The result in AllMonthsAllYears shows that there is not even a country with all the data 
-- at the column month.

SELECT Region, Country, State, City, Year,Month, SUM (Month) OVER (PARTITION BY City) AS No_Months,
CASE 
WHEN  SUM (Month) OVER (PARTITION BY City) = 2028 THEN 'Ok'
ELSE 'Missing Data'
END AS  AllMonthsAllYears
FROM WithOut99
GROUP BY Region, Country, State, City, Year, Month
ORDER BY 2,3,4

-- One last view

CREATE VIEW AvgTemperatureAllYears AS 
WITH AvgByYear AS (
    SELECT a.Region, a.Country, a.State, a.City, a.Year, a.Month,a.Day, a.AvgTemperature
    FROM WithOut99 a 
    RIGHT JOIN FullCountries b ON a.City = b.City  
	WHERE a.Day !=29
    GROUP BY a.Region, a.Country, a.State, a.City, a.Year, a.Month, a.Day, a.AvgTemperature
) 
SELECT *, ((AvgTemperature-32)*5)/9 AS AverageTemperaturebyMonthCelsius, CONVERT(DATE,CONCAT(CAST(Year as nvarchar(50)),'-',CAST(Month as nvarchar(50)),'-',CAST(Day as nvarchar(50)))) AS Date
FROM AvgByYear
