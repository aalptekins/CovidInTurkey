--Selecting Data that we will be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths
--The possibility of dying if you contract covid in Turkey

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Turkey'
ORDER BY 5 DESC

--Total Cases vs Population
--Rate of people who got covid

SELECT location,date,total_cases,population,(total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths
WHERE location = 'Turkey'
ORDER BY 1,2

--The country that has highest infection rate compared to population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as InfectedPercentage
FROM CovidDeaths
GROUP BY location,population
ORDER BY InfectedPercentage DESC

--Countries with highest death count per population

SELECT location,population,MAX(total_deaths) as HighestDeathCount,MAX(total_deaths/population)*100 as DeathPercentage
FROM CovidDeaths
GROUP BY location,population
ORDER BY DeathPercentage DESC

--Continents with the number of people who died from Covid

SELECT location as TheContinent,MAX(cast(total_deaths as int)) as DeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY DeathCount DESC

  
--Calculating total death percentage with using the number of total cases and total deaths


SELECT SUM(new_cases) as TotalCases ,SUM(cast(new_deaths as int )) as TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Joining these two tables and looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location = 'Turkey' AND new_vaccinations is not null
ORDER BY 2,3;



--USE CTE

WITH POPvsVAC (Continent,Location,Date,Population,New_vaccinations,Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL AND dea.location = 'Turkey'
)
SELECT *, (rolling_people_vaccinated/population)*100 AS RateOfVaccinatedPeople
FROM POPvsVAC


--TempTable


DROP TABLE IF EXISTS #RatePopulationVaccinated 
CREATE TABLE #RatePopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)


INSERT INTO #RatePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL --AND dea.location = 'Turkey'

SELECT *, (Rolling_People_Vaccinated/population)*100 AS RateOfVaccinatedPeople
FROM #RatePopulationVaccinated


--Creating View for later visualizations operations
--PercentPopulationVaccinatedinTurkey
CREATE VIEW PercentPopulationVaccinatedinTurkey AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND new_vaccinations IS NOT NULL AND dea.location = 'Turkey'

SELECT *
FROM PercentPopulationVaccinatedinTurkey

--
