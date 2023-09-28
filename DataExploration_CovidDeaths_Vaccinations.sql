/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 
Creating Views, Converting Data Types
*/


select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeaths]
order by 1,2

--- Total Cases Vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from [dbo].[CovidDeaths]
where location like '%india%'
order by 1,2

--- -- Total Cases Vs Population 
-- Shows what percentage of population infected with Covid
select location,date,Population,total_cases,(total_cases/population) * 100 as Covid_Infected_Percentage
from [dbo].[CovidDeaths]
--where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
select location,Population,max(total_cases),max(total_cases/population) * 100 as Covid_Infected_Percentage
from [dbo].[CovidDeaths]
group by location,Population
order by Covid_Infected_Percentage desc

-- Continents with Highest Death Count per Population
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global death percentage 
select sum(new_cases) as TotalCasesCount,sum(cast(new_deaths as int)) as TotalDeathCount,
		(sum(cast(new_deaths as int)) / sum(new_cases))*100 as DeathPercentage
from [dbo].[CovidDeaths]
where continent is not null
--group by date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v
	 on  d.location = v.location 
	 and d.date = v.date
where d.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths] as d
join [dbo].[CovidVaccinations] as v
	 on  d.location = v.location 
	 and d.date = v.date
where d.continent is not null
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac
order by 1,2


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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



