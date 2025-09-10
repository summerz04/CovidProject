select *
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4 

-- Select the data I want to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


-- Looking at Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location = 'United Kingdom'
order by 1,2


-- Looking at Total Cases vs Population
select Location, date, total_cases, Population, (total_cases/Population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths$
--Where location = 'United Kingdom'
order by 1,2

-- Which countries have the highest infection rates compared to total population?
select Location, Population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by location, population
order by PercentPopulationInfected DESC


-- Which countries have the highest death count per population?
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null 
Group by location
order by TotalDeathCount DESC


-- Death Count by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null 
Group by continent
order by TotalDeathCount DESC


-- Global statistics
-- Calculating global death percentage
select SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- CovidVaccinations Table
Select *
From PortfolioProject..CovidVaccinations

-- Joining CovidDeaths and CovidVaccinations together and
-- Looking at Total Population vs New Vaccinations per day
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumulativeSumofVac

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

-- using CTE to calculate % Global vaccinations

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, CumulativeSumofVac)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumulativeSumofVac
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)

Select *, (CumulativeSumofVac/Population)*100 as PercentPopVac
From PopVsVac

-- Alternatively, using TEMP TABLE
Drop table if exists #RollingVacPop
Create table #RollingVacPop
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
CumulativeSumofVac numeric,
)

Insert into #RollingVacPop

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumulativeSumofVac
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select *, (CumulativeSumofVac/Population)*100 as PercentPopVac
From #RollingVacPop





-- Creating View to store data for later visualisations

Create View RollingVacPop as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as CumulativeSumofVac
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select *
From RollingVacPop