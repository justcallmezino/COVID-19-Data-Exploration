/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from portfolio_project..CovidDeaths
order by 3

select *
from portfolio_project..[CovidVaccinations ]
order by 3,4

-- SELECT THE NEEDED DATA
-- CASE: AFRICA

select location, date, population, total_cases, new_cases, total_deaths
from portfolio_project..CovidDeaths
where continent like 'africa'
order by 1,2

-- TOTAL CASES Vs TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN AFRICA

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
where continent like 'Africa'
order by 1,2

-- TOTAL CASES Vs POPULATION
-- SHOWS PERCENTAGE OF THE POPULATION INFECTED IN AFRICA

select location, date, population, total_cases, (total_cases/population)*100 as infected_population_percentage
from portfolio_project..CovidDeaths
where continent like 'africa'
order by 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION IN AFRICA

select location, population, max(total_cases) as max_total_cases, max(total_cases/population)*100 as max_cases_percentage
from portfolio_project..CovidDeaths
where continent like 'africa' and location is not null
group by location, population
order by max_cases_percentage desc

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION IN AFRICA

select location, population, max(total_deaths) as max_total_deaths, max(total_deaths/population)*100 as max_deaths_percentage
from portfolio_project..CovidDeaths
where continent like 'africa' and location is not null
group by location, population
order by max_deaths_percentage desc


-- BREAKDOWN BY CONTINENT

-- CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

select continent, max(total_deaths) as max_total_deaths, max(total_deaths/population)*100 as max_deaths_percentage
from portfolio_project..CovidDeaths
where continent is not null and location is not null
group by continent
order by max_deaths_percentage desc

-- CONTINENTS WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select continent, max(total_cases) as max_total_cases, max(total_cases/population)*100 as max_cases_percentage
from portfolio_project..CovidDeaths
where continent is not null and location is not null
group by continent
order by max_cases_percentage desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
where continent is not null
--order by 1

-- TOTAL POPULATION Vs VACCINATIONS
-- PERCENTAGE OF POPULATION THAT RECEIVED ATLEAST ONE COVID VACCINE

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as vaccination_growth
--,(vaccination_growth/population)*100 as cumm_vaccination_growth
from portfolio_project..CovidDeaths as dea
join portfolio_project..[CovidVaccinations ] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location is not null
order by 2,3


-- USING CTE TO PERFORM CALCULATION ON PARTITION BY IN THE QUERY ABOVE

with PopulationVsVaccinations (continent, location, date, population, new_vaccinations, vaccination_growth)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as vaccination_growth
from portfolio_project..CovidDeaths as dea
join portfolio_project..[CovidVaccinations ] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent like 'Africa' and dea.location is not null
-- order by 2,3
)
select *, (vaccination_growth/population)*100 as vaccination_growth_percentage
from PopulationVsVaccinations


-- USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

Drop table if exists #PopulationVsVaccinations
create table #PopulationVsVaccinations
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccination_growth numeric
)

insert into #PopulationVsVaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as vaccination_growth
from portfolio_project..CovidDeaths as dea
join portfolio_project..[CovidVaccinations ] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent like 'Africa' and dea.location is not null
-- order by 2,3

select *, (vaccination_growth/population)*100 as vaccination_growth_percentage
from #PopulationVsVaccinations


-- CREATING VIEW FOR VISUALIZATIONS

create view PopulationVsVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as vaccination_growth
from portfolio_project..CovidDeaths as dea
join portfolio_project..[CovidVaccinations ] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent like 'Africa' and dea.location is not null
-- order by 2,3

Select *
from PopulationVsVaccinations
