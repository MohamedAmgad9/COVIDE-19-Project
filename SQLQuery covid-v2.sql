SELECT *
FROM PortfolioProject..['covid-death']
WHERE continent IS NOT NULL
ORDER BY 1,2


SELECT location , date ,total_cases , new_cases , total_deaths , population
FROM PortfolioProject..['covid-death']
WHERE continent IS NOT NULL
ORDER BY 1,2

-- looking at total cases vs total death

SELECT location , date ,total_cases  , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['covid-death']
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

-- looking at total cases vs population

SELECT location , date ,total_cases  ,  population ,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..['covid-death']
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population
SELECT location ,population , MAX(total_cases ) as HighestInfectionCount  ,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['covid-death']
WHERE continent IS NOT NULL
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location , MAX(CAST(total_deaths as int)) as TotalDeathCount  
FROM PortfolioProject..['covid-death']
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount  
FROM PortfolioProject..['covid-death']
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['covid-death']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location , dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location 
ORDER BY dea.location , dea.date) as RollingPeopleVac

FROM PortfolioProject..['covid-death']  as dea
JOIN PortfolioProject..['covid-vac'] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH POPvsVAC  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location , dea.date ,dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..['covid-death']  as dea
JOIN PortfolioProject..['covid-vac'] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VacPeoplePercentage
From POPvsVAC


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid-death']  as dea
JOIN PortfolioProject..['covid-vac'] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid-death']  as dea
JOIN PortfolioProject..['covid-vac'] as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated