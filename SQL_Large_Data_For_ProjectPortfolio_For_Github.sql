SELECT *
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2

--looking at total cases vs total deaths
-- looing at the likelihood of someone getting contracted with covid

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%' and continent is not null 
order by 1,2

--looking at total cases vs population 
-- shows percentage of population that got covid

SELECT Location, date, population, total_cases,(total_cases/ population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%' and continent is not null 
order by 1,2

--looking at country with the highest infection rate compared to population 
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentOfPopulationInfected 
From PortfolioProject..CovidDeaths$
Where continent is not null 
--Where location like '%states%'
Group by Location, population
order by PercentOfPopulationInfected desc


--- showing countries with highest death counts per population
SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null 
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc


--- showing continent with the highest totaldeathscounts
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null 
--Where location like '%states%'
Group by continent 
order by TotalDeathCount desc

--- acurate numbers
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
--Where location like '%states%'
Group by location  
order by TotalDeathCount desc

-- Shows the total mumber world wide
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
--Where location like '%states%'
--Group by date  
order by 1,2 


-- joining both table 
SELECT *
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date 


-- looking at total popilations vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated ---(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated ---(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date 
--Where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From  #PercentPopulationVaccinated


--- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION 
USE PortfolioProject
Go
Create View PercentPopVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated ---(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';
