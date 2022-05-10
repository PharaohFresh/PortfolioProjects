SELECT*
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

SELECT*
FROM CovidVaccinations$
ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
Order By 1,2 

--Looking at Total Cases vs Population
--Shows what % of population got covid AKA Infection Rate

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
Order By 1,2 

--What countries have the highest infection rate compared to population?

SELECT location, CAST(population as bigint) as Population, MAX(total_cases) AS HighestCaseCount, MAX((total_cases/population))*100 AS HighestInfectionRate
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
GROUP BY location, population
Order By Population DESC
 
-- Showing countries with highest death count
--needed to add the CAST function to change the data type in order to sort 

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
Order By TotalDeathCount DESC

--Let's break things down by continent!

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
Order By TotalDeathCount DESC



--Showing the continents with highest death count



SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
Order By TotalDeathCount DESC



--Global Numbers



SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathRate
FROM [Portfolio Project]..CovidDeaths$
--where location like '%states%'
WHERE continent is not null
--GROUP BY date
Order By 1,2 



-- Looking at new cases vs vaccinations




SELECT Dea.date, SUM(CAST(Dea.new_cases as bigint)) AS TotalNewCases, SUM(CAST(Vac.new_vaccinations as bigint)) AS TotalNewVacc
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.date = Vac.date
GROUP BY dea.date
ORDER BY 1



--Covid Vaccinations
-- Looking at Total Population Vs Vaccinations using Joins



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaxxed
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE TIME, Looking at Population vs New Vaccinations,Rolling People Vaxxed, and Vaccination Rate

with PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaxxed)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaxxed
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaxxed/Population)*100 AS VAXXRATE
FROM PopvsVac
WHERE location = 'United States'

----CTE TIME, Looking at Population vs New Cases,Rolling People Infected, and Infection Rate

with PopvsInfected (Continent, location, Date, Population, new_cases, RollingPeopleInfected)
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_cases
,	SUM(CAST(dea.new_cases as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleInfected
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (RollingPeopleInfected/Population)*100 AS InfectionRate
FROM PopvsInfected




--Finding the countries with the highest % of population lost




with PopsvsDeath (continent, location, population, TotalDeaths)
AS
(
SELECT continent, location, population, SUM(CAST(new_deaths as int)) AS TotalDeaths
FROM CovidDeaths$
WHERE continent is not null AND
	total_deaths is not null
GROUP BY continent, location, population
--ORDER BY 4 DESC
)
SELECT*, (TotalDeaths/Population)*100 AS PopLost
FROM PopsvsDeath
ORDER BY 4 DESC




--Using a temp table

DROP TABLE IF EXISTS #PercentPopulationVaxxed
CREATE TABLE #PercentPopulationVaxxed
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaxxed numeric)

INSERT INTO #PercentPopulationVaxxed
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaxxed
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (RollingPeopleVaxxed/Population)*100 AS VaxxRate
FROM #PercentPopulationVaxxed



-- Creating view to store data for later to visualize in Tableau

Create View PercentPopulationVaxxed as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaxxed
FROM CovidDeaths$ AS Dea
JOIN CovidVaccinations$ AS Vac
	ON Dea.location = Vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaxxed

Create View PercentPopulationLost as
with PopsvsDeath (continent, location, population, TotalDeaths)
AS
(
SELECT continent, location, population, SUM(CAST(new_deaths as int)) AS TotalDeaths
FROM CovidDeaths$
WHERE continent is not null AND
	total_deaths is not null
GROUP BY continent, location, population
--ORDER BY 4 DESC
)
SELECT*, (TotalDeaths/Population)*100 AS PopLost
FROM PopsvsDeath
--ORDER BY 4 DESC

SELECT*
FROM PercentPopulationLost
ORDER BY 4 DESC












