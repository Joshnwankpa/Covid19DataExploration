--Select *
--From PortfolioProject..CovidDeaths1
--where continent is not null
--order by 3,4

--Select *
--From PortfolioProject..CovidVaccination1
--order by 3,4

/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths1
where continent is not null
order by 3,4

-- Data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths1
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying it you contacted covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths1
where location = 'Brazil'
and continent is not null
order by 1,2


-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_deaths/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths1
where location = 'Brazil'
order by 1,2


-- Countries with Highest Infection Rate compared to Population


Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/Population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths1
-- where location = 'Africa'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with the highest death count per population


Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths1
-- where location = 'Africa'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Break things down by continent

-- Showing the continents with the highest death counts per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths1
-- where location = 'Africa'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers per day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths1
-- where location = 'Africa'
where continent is not null
group by date
order by 1,2

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths1
-- where location = 'Africa'
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculations on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp table to perform calculations on partition By in previous query 

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccination1 vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/dea.population)*100 
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccination1 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
