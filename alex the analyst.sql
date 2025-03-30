select *
from Portfolioproject..CovidDeaths$

--- select data that we are going to be using	

select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths$
order by 1,2


-- looking at the totak cases versus the total deaths
-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from Portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2


-- looking  at the total cases versus population
-- shows what percentage of  population got covid
select location, date, total_cases,  population, (total_cases/population)*100 as deathpercentage 
from Portfolioproject..CovidDeaths$
where location like '%igeri%'
order by 1,2


-- looking at countries with highest infection rate compared to population	
select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from Portfolioproject..CovidDeaths$
group by location, population
order by percentpopulationinfected desc

-
-- LETS BREAK THINGS DOWN BY CONTINENT




-- looking at countries with the highest death rate compared to population
select location,  max(cast(total_deaths as int)) as maximumdeaths, max(total_deaths/population)*100 as maximumdeathpercentage
from Portfolioproject..CovidDeaths$
where continent is  null
group by location
order by maximumdeaths desc 


-- showing the continents with the highest death counts per population
select continent,  max(cast(total_deaths as int)) as maximumdeaths, max(total_deaths/population)*100 as maximumdeathpercentage
from Portfolioproject..CovidDeaths$
where continent is not null
group by continent
order by maximumdeaths desc 


-- Global numbers
select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



select *
from Portfolioproject..Covidva$


-- looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidva$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- using CTES
with popvsvac (continent, location,date, population, new_vaccinations, rollingpeoplevaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidva$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as populationovervaccination
from popvsvac

-- Temp tables
drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into  #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidva$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 select *, (rollingpeoplevaccinated/population)*100
 from  #percentpopulationvaccinated

 -- creating view to store data for later visualizations

 create view percentpopulationvccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidva$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvccinated