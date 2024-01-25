

/*
  COVID 19 DATA EXPLORATION
  SKILLS USED : JOINS , CTE's , Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM dbo.CovidDeaths$
where continent is not null
order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE STARTINF W

SELECT location, date, total_cases ,
new_cases , total_deaths, population 
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
Order by 1,2

-- Loocking at total cases vs total deaths (death percentage)
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases ,
total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
FROM PortfolioProject.dbo.CovidDeaths$
where location like  '%states%'
and continent is not null
Order by 2

-- Looking at Total cases vs population
-- shows what percentage of population infected with covid

SELECT location, date, total_cases ,
population, (total_cases/population)*100 as 'Percent Population Infected'
FROM PortfolioProject.dbo.CovidDeaths$
--where location like  'morocco'
where continent is not null
Order by 1,2


-- looking at countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) 'Highest Infection Count', 
MAX((total_cases/population))*100 as 'Percent Population Infected'
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group by population, location
Order by 'Percent Population Infected' desc

-- showing Countries with highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as 'Total Death Count'
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group by location
Order by 'Total Death Count' desc


-- Let's break things down by continent
-- showing continents with th heighest death count per population 
SELECT continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group by continent
Order by 'Total Death Count' desc

-- GLOBAL NUMBERS 
SELECT SUM(new_cases) as 'total cases', SUM(cast(new_deaths as int)) 'total death' , 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as 'death percentage'
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null


-- loocking at total population vs vaccinations

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent , dea.location , dea.date , 
dea.population , vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as bigint) ) 
OVER (partition by dea.location order by dea.location, dea.date)
as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE to perform calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
