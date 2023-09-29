select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccination
--order by 3,4

--extracting required data from the table
select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

--total deaths/total cases rate(in percentage)
select location,date,total_cases,total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPerCase
from CovidDeaths
Where location='india' and continent is not null
order by 1,2

--total cases per population
select location,date,population,total_cases, (total_cases/population)*100 as CasePercentage
from CovidDeaths
--Where location='india'
where continent is not null
order by 1,2

--countries with highest population infected
select location,population,MAX(total_cases) HighestCaseReported,(max(total_cases)/population)*100 as PopulationInfectdPercent
from CovidDeaths
where continent is not null
group by location,population
order by PopulationInfectdPercent desc

--countries with Highest Death Count
select location,MAX(cast(total_deaths as int)) HighestDeathReported
from CovidDeaths
where continent is not null
group by location
order by HighestDeathReported desc

--Highest Death Count by Continent
select continent,MAX(cast(total_deaths as int)) HighestDeathReported
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathReported desc

--Global Numbers
select SUM(new_deaths) total_deaths,SUM(new_cases) total_cases,SUM(new_deaths)/SUM(new_cases)*100 DeathPerCase
from CovidDeaths
where continent is not null
--group by date
order by 1,2


--Covid Vaccination table
select *
from CovidVaccination

--Vaccination w.r.t Population
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dth.location Order by dth.location,dth.date) as PeopleVaccinated
from CovidDeaths dth
join CovidVaccination vac
on dth.location = vac.location
	and dth.date = vac.date
where vac.new_vaccinations is not null and dth.continent is not null 
order by 2,3


--Using CTE
With popVSvac (Continent,Location,Date,Population,new_vaccinations,PeopleVaccinated)
as
(select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dth.location Order by dth.location,dth.date) as PeopleVaccinated
from CovidDeaths dth
join CovidVaccination vac
on dth.location = vac.location
	and dth.date = vac.date
where vac.new_vaccinations is not null and dth.continent is not null
)
select *,(PeopleVaccinated/Population)*100 as VaccinatedPercent
from popVSvac
order by 2,3


--Using Temp Table
Drop table if exists #VaccinatedPercent
create table #VaccinatedPercent
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #VaccinatedPercent
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dth.location Order by dth.location,dth.date) as PeopleVaccinated
from CovidDeaths dth
join CovidVaccination vac
on dth.location = vac.location
	and dth.date = vac.date
where vac.new_vaccinations is not null and dth.continent is not null

select *,(PeopleVaccinated/Population)*100 as VaccinatedPercent
from #VaccinatedPercent
order by 1,2,3



--Created a view for later visualization purpose.
Create View PeopleVaccinatedPercent 
as
select dth.continent,dth.location,dth.date,dth.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dth.location Order by dth.location,dth.date) as PeopleVaccinated
from CovidDeaths dth
join CovidVaccination vac
on dth.location = vac.location
	and dth.date = vac.date
where vac.new_vaccinations is not null and dth.continent is not null

select * 
from PeopleVaccinatedPercent