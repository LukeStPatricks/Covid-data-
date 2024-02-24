

Select *
From Practice..CovidDeaths
order by 3,4

--Select *
--From Practice..CovidVaccinations
--order by 3,4

--select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From Practice..CovidDeaths
order by 1,2

--looking at Total cases vs Total deaths
--shows the liklihood on dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Practice..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
--showss what % of the population has covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From Practice..CovidDeaths
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidPercentage
From Practice..CovidDeaths
--where location like '%states%'
Group by location, population
order by CovidPercentage desc

--Lets break thin gs down by continent 


--showing the continents with the highest death count
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing countries with the highest death count over population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Practice..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select Sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Practice..CovidDeaths
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2

--Using CTE
--looking at total population vs vacination
with PopsVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Practice..CovidDeaths dea
join Practice..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
From PopsVsVac


--Using TEMP TABLE 
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Practice..CovidDeaths dea
join Practice..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- creatting a view
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Practice..CovidDeaths dea
join Practice..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
From PercentPopulationVaccinated