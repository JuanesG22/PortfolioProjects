--SELECT *
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--WHERE continent is not null
--ORDER BY 3,4

-- Select Data that we are going to be using

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--ORDER BY 1,2

-- looking at the Total Cases vs Total Deaths

--SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--WHERE location like '%Colombia%'
--ORDER BY 1,2

-- Looking at Total Cases vs Population

--SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--ORDER BY 1,2

-- Looking at countries with Highest Infection Rate Compared to Population

--SELECT Location, population,MAX(total_cases) AS HighestInfectionCount,   MAX((total_cases/population)*100) AS PercentPopulationInfected
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
----WHERE location like '%Colombia%'
--GROUP BY location,population
--ORDER BY PercentPopulationInfected desc

-- Showing countries With Highest Death per Population

--SELECT Location,MAX(CAST(Total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--GROUP BY location
--ORDER BY TotalDeathCount desc

-- Let's break things down by continent

--SELECT location ,MAX(CAST(Total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount desc

--SELECT continent ,MAX(CAST(Total_deaths as int)) as TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount desc

-- Global numbers

--SELECT  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--WHERE continent is not null
----GROUP BY date
--ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths$ dea
--JOIN  PortfolioProject..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

-- USE CTE

--WITH popvsvac(continent, location, date, population,New_Vaccinations ,RollingPeopleVaccinated)
--AS( 
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths$ dea
--JOIN  PortfolioProject..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null
--)
--SELECT *, (RollingPeopleVaccinated/population)*100
--FROM popvsvac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

--CREATE VIEW PercentPopulationVaccinated as 
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths$ dea
--JOIN  PortfolioProject..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	and dea.date = vac.date
--WHERE dea.continent is not null