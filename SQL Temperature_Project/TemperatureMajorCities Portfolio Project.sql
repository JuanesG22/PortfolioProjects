-- Size of the dataset

SELECT COUNT(Country) 
FROM TemperatureMajorCities..city_temperature

SELECT * 
FROM [TemperatureMajorCities].[dbo].[city_temperature]

--Looking for missing values

SELECT Region 
FROM TemperatureMajorCities..city_temperature
WHERE Region is Null

--	Country column

SELECT Country 
FROM TemperatureMajorCities..city_temperature
WHERE Country is Null 

-- There is not null values

SELECT State FROM TemperatureMajorCities..city_temperature
WHERE State = ''

-- There is a lot of data (Almost the half) related to the state which is empty but we dont care about that as we are interest just in Countries and Regions

SELECT DISTINCT Month 
FROM TemperatureMajorCities..city_temperature

-- Something about the data is that all columns are varchar, due to this, on the Month column we have values for 02 and 2, which are the same month but formate different, for this
-- we can CAST those columns and this should be solved

SELECT DISTINCT CAST(Month AS int) 
FROM TemperatureMajorCities..city_temperature
ORDER BY CAST(Month AS int) asc

-- Looking at Year Column

SELECT CAST(Year AS int) , COUNT(Year)
FROM TemperatureMajorCities..city_temperature
GROUP BY CAST(Year AS int)
ORDER BY CAST(Year AS int) asc
 
 --

SELECT CAST(Year AS int) , COUNT(Year)
FROM TemperatureMajorCities..city_temperature
WHERE CAST(Year AS int) = 200 OR CAST(Year AS int) = 201
GROUP BY CAST(Year AS int)
-- We have then some values from 201 and 200, we have 440 records whit 200 and 201, let's see what AVGTemperature value they have

SELECT Year,Month,Day, AvgTemperature
FROM TemperatureMajorCities..city_temperature
WHERE CAST(Year AS int) = 200 OR CAST(Year AS int) = 201

-- As we can see, all these records are missing values from those days

SELECT Day 
FROM TemperatureMajorCities..city_temperature
WHERE Day is Null

--

SELECT DISTINCT CAST(Day AS int) 
FROM TemperatureMajorCities..city_temperature
ORDER BY CAST(Day AS int) asc

-- Query above shows that there is a Day 0 in the data, which may be wrong cause there is no 0 day in calendar. So lets look at those values

SELECT * 
FROM TemperatureMajorCities..city_temperature
WHERE CAST(Day AS int) = 0

-- As we can see, the AvgTemperature registred that Day is -99, which means that this values might be missing. So lets look if there is more AvgTemperature values equals to -99

SELECT COUNT(Region) 
FROM TemperatureMajorCities..city_temperature
WHERE CAST(AvgTemperature AS float) = -99

-- So there is 79672 of 2906327 with -99 of AvgTemperature, the 2.7% of the dataset are missing values



SELECT Country,	CAST(Year AS int) , COUNT(DISTINCT Month) as mes
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, CAST(Year AS int)


SELECT Country, YEAR, COUNT(DISTINCT Month) as No_meses 
FROM TemperatureMajorCities..city_temperature 
group by Country, Year

-- lets look how many countries are

SELECT COUNT(DISTINCT Country)
FROM TemperatureMajorCities..city_temperature

-- 125 countries. From previous queries, the period in which data was collacted is around 26 years. So, lets se if there is some years related to some countries that are missing from
-- data. So the next query will Select the Countries and years and group it, Considering that the dataset has 125 countries from 26 years, then the among of rows might be 3250, if
-- no data is missing

SELECT Country, Year
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, Year

-- So the result was 3101 rows, which means that some countries does not have data in their column years (149 rows).
-- Creating a Temp Table to look the countries with missing data on years column.

DROP TABLE IF EXISTS MissingYears
CREATE TABLE MissingYears
(
Country nvarchar(50),
No_Years numeric
)

INSERT INTO MissingYears
SELECT Country, COUNT(DISTINCT Year) as No_Years
FROM TemperatureMajorCities..city_temperature
GROUP BY Country 

SELECT Country, No_Years
FROM MissingYears
WHERE No_Years != 26

-- So, in case of populate the data that is missing, this could be the first step.

-- Now we repeat the same process with the months and days. For months, without missing values the result should be 39000
SELECT Country, Year, Month
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, Year, Month
ORDER BY Country, CAST(Year AS int), CAST(Month AS int)

-- Query give us 36288, The diference with the virtual result give us 2712 rows missing, which 1788 came from the 149 rows related to the years missing. In this order,
-- we have 924 rows which has year but do not have month. 

SELECT Country,Year, COUNT(DISTINCT CAST(Month as int))
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, Year
ORDER BY Country, CAST(Year AS int)

-- Creating a Temp Table to look the countries with missing data on month column.

DROP TABLE IF EXISTS MissingMonths
CREATE TABLE MissingMonths
(
Country nvarchar(50),
Year numeric,
No_months numeric
)

INSERT INTO MissingMonths
SELECT Country,Year, COUNT(DISTINCT CAST(Month as int))
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, Year
ORDER BY Country, CAST(Year AS int)

SELECT Country, Year, No_months
FROM MissingMonths
WHERE No_months!=12
ORDER BY 1,2

-- In case of populate, the query above shows the number of months that the Country in that year has, (i.e if No_Months = 5, there's missing 7 months, which means 7 rows of missing
-- Data

-- Now the same process for the Days

SELECT Country, Year, Month, Day
FROM TemperatureMajorCities..city_temperature
ORDER BY Country, CAST(Year AS int), CAST(Month AS int), CAST(Day AS int)

-- Following the same process, virtually, from the 125 countries, from the period of 1995-2020, if the data record the avg temperature by day, the data len is 14.325.000, however
-- the dataset has 2.906.237, so in therms of %, we only have aprox the 20,28% of the data.

SELECT Country, Year, Month,AVG(CAST(AvgTemperature AS float)) AS AvgTemperatureMonth
FROM TemperatureMajorCities..city_temperature
GROUP BY Country, Year, Month
ORDER BY Country, CAST(Year AS int), CAST(Month AS int)

CREATE TABLE WithOut99 
(
Country nvarchar(50),
Year numeric,
Month numeric,
Day numeric,
AvgTemperature numeric
)

--

INSERT INTO WithOut99
SELECT Country, Year, Month, Day, AvgTemperature 
FROM TemperatureMajorCities..city_temperature
WHERE CAST(AvgTemperature AS float) != -99
ORDER BY Country, CAST(Year AS int), CAST(Month AS int)

--

SELECT Country, Year, Month, AVG(CAST(AvgTemperature AS float)) AS AvgTemepratureMonth
FROM WithOut99
GROUP BY Country, Year, Month
ORDER BY Country, CAST(Year AS int), CAST(Month AS int)