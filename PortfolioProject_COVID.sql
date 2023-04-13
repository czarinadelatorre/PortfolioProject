-- PHASE 1: DATA EXPLORATION


SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4



SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


-- Select data that we're going to use


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Looking at total_cases vs total_deaths


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- Change data types for total_cases and total_deaths to float so death_percentage can be calculated


ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT


-- Looking at total_cases vs total_deaths: second attempt
-- Using ROUND() to limit to 2 decimal places
-- death_percentage shows likelihood of dying if you contract COVID in your country


SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date


-- Looking at total_cases vs population
-- Shows what percentage of population got COVID


SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS case_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date


-- Looking at countries with highest infection count per population


SELECT location, population, MAX(total_cases) AS highest_infectioncount, MAX(ROUND((total_cases/population)*100,2))AS infection_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_percentage DESC


-- Looking at countries with highest death count per population


SELECT location, MAX(total_deaths) as totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC


-- Looking at highest death count per population by continent


SELECT continent, MAX(total_deaths) as totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC


-- Showing continents with the highest death count per population


SELECT continent, MAX(total_deaths) as totaldeathcount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC


-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- Using CTE


WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)

AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)

SELECT *, ROUND((rolling_vaccinations/population)*100,2) AS percent_vaccinated
FROM PopvsVac


-- Looking at Total Population vs Vaccinations
-- Using temp table


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *, ROUND((rolling_vaccinations/population)*100,2) AS percent_vaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * FROM PercentPopulationVaccinated