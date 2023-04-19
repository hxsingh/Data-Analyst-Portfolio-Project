SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2;

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2;

SELECT location, population, MAX(total_deaths) AS Highest_Death_Count, MAX(((total_deaths) / population)) * 100 AS Max_Death_Infected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

SELECT continent, MAX(total_deaths) AS Highest_Death_Count
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC;

SELECT SUM(new_cases) AS New_Cases, SUM(new_deaths) AS New_Deaths, 
	CASE 
		WHEN SUM(new_cases) = 0 THEN 0 
		ELSE (SUM(new_deaths)/SUM(new_cases)) * 100 
	END AS Death_Percentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated,
	(Rolling_People_Vaccinated / d.population) * 100 AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
	JOIN CovidVaccinations AS v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL AND d.location = 'Albania'
ORDER BY 2, 3;

WITH PopvsVac (
    continent,
    location,
    date,
    population,
    new_vaccinations,
    Rolling_People_Vaccinated
) AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS d
	JOIN CovidVaccinations AS v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL);

SELECT *, (Rolling_People_Vaccinated / population) * 100
FROM PopvsVac;


DROP VIEW IF EXISTS PercentPopVac;

CREATE VIEW PercentPopVac AS 
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CAST(v.new_vaccinations AS DECIMAL(18, 2))) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated
	FROM CovidDeaths AS d
		JOIN CovidVaccinations AS v
		ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL;

SELECT *
FROM PercentPopVac;