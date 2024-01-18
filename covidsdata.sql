
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- noticing Total Cases vs Total Deaths
--shows an increase in the number of covid cases with no death yet
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%kenya%'
and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- shows what percentage of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentpopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%kenya%'
order by 1,2


-- Looking at countries with highest infection rates  compared to population

SELECT
    location,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((CAST(total_cases AS float) / CAST(population AS float)) * 100) AS PercentPopulationInfected
FROM
    PortfolioProject..CovidDeaths
--WHERE location LIKE '%kenya%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing countries with the highest Death Count per population if any

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location LIKE '%kenya%'
where continent is not null
GROUP BY location 
ORDER BY TotalDeathCount desc;



--  BREAK DOWN BY CONTINENT
-- showing the continents with highest death count if any per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location LIKE '%kenya%'
where continent is not null
GROUP BY continent 
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%kenya%'
where continent is not null
--Group By date
order by 1,2



--JOIN OF THE TWO TABLES
-- Looking at the Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3




--USE CTE

With PopvsVac (continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store Data for later visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
