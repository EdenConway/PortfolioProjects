select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population 
-- Showing the percentage of the population that contracted covid
Select Location, date, Population, total_cases, (total_cases/Population)*100 as ContractionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing the countries with the Highest count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Broken down by Continent  highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM( new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(new_cases)*100 as deathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccinations


Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
order by 2,3


--Using CTE to perform calculation on partitiom in previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) *100
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
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date= vac.date
Where dea.continent is not null
 


