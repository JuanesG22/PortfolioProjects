-- Size of the dataset

SELECT COUNT(Country) 
FROM TemperatureMajorCities..city_temperature

SELECT * 
FROM [TemperatureMajorCities].[dbo].[city_temperature]

--Looking for missing values

SELECT Region 
FROM TemperatureMajorCities..city_temperature
WHERE Region is Null

SELECT Country 
FROM TemperatureMajorCities..city_temperature
WHERE Country is Null 

SELECT State FROM TemperatureMajorCities..city_temperature
WHERE State is Null 

SELECT Month 
FROM TemperatureMajorCities..city_temperature
WHERE Month is Null

SELECT DISTINCT CAST(Month AS int) 
FROM TemperatureMajorCities..city_temperature
ORDER BY CAST(Month AS int) asc

SELECT Day 
FROM TemperatureMajorCities..city_temperature
WHERE Day is Null

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





