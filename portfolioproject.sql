use portfolioproject;

-- Select everything from CovidDeaths where continent is not null
SELECT *
FROM portfolioproject.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4;

-- Select specific columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM portfolioproject.CovidDeaths
WHERE location LIKE '%states%'
  AND continent IS NOT NULL 
ORDER BY 1, 2;

-- Total Cases vs Population
SELECT location, date, population, total_cases, 
       (total_cases / population) * 100 AS PercentPopulationInfected
FROM portfolioproject.CovidDeaths
ORDER BY 1, 2;

-- Countries with Highest Infection Rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM portfolioproject.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolioproject.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Count
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM portfolioproject.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, 
       (SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM portfolioproject.CovidDeaths
WHERE continent IS NOT NULL;

-- Total Population vs Vaccinations (Rolling Total)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolioproject.CovidDeaths dea
JOIN portfolioproject.CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3;

-- Using CTE to Calculate Percent Vaccinated
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
               OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM portfolioproject.CovidDeaths dea
    JOIN portfolioproject.CovidVaccinations vac
      ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PopvsVac;

-- Temp Table for Vaccination Calculation
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    population BIGINT,
    new_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);



SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;

-- Creating a View for Reuse
CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM portfolioproject.CovidDeaths dea
JOIN portfolioproject.CovidVaccinations vac
  ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
