Select 
*
from [Portfolio Project1] ..CovidDeaths
where continent is not null
order by 3, 4


--Select 
--*
--from [Portfolio Project1] ..CovidVax
--order by 3, 4

--Select the data that we are going to be using 

Select 
[location], [date], [total_cases], [total_deaths]
from [Portfolio Project1] ..CovidDeaths
where continent is not null
order by 1, 2

---Looking at total cases vs total deaths
--- shows the likelihood of dying if you contract covid in your country 

Select 
[location], [date], [total_cases],  [total_deaths], 
(convert(float, total_deaths)/nullif(convert(float,total_cases), 0)) * 100 as DeathPercentage
from [Portfolio Project1] ..CovidDeaths
where [location] like '%States%'
order by 1, 2

--looking at the total cases vs the population 
-- shows what percentage of population has got covid 

Select 
[location], [date], [total_cases],[population], 
(convert(float, total_cases)/nullif(convert(float,population), 0)) * 100 
as PercentagePopulationInfected
from [Portfolio Project1] ..CovidDeaths
---where [location] like '%States%'
order by 1, 2


---Looking at countries with higher infection rate compared to population 
Select [location],  [population],
max([total_cases]) as HighestInfectionCount , 
max((convert(float, total_cases)/nullif(convert(float,population), 0))) * 100 as PercentagePopulationInfected
from [Portfolio Project1] ..CovidDeaths
group by [location], [population]
order by PercentagePopulationInfected desc


--showing the countries with the highest death count per population

--- casting total_deaths as integer in case it is assigned nvarchar data type below:
--Select [location],  max(cast(total_deaths as int)) as TotalDeathCount
--from [Portfolio Project1] ..CovidDeaths
-----where [location] like '%States%'
--group by [location]
--order by TotalDeathCount desc

Select [location],  max(total_deaths) as TotalDeathCount
from [Portfolio Project1] ..CovidDeaths
where continent is not null
group by [location]
order by TotalDeathCount desc


---LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent,  max(total_deaths) as TotalDeathCount
from [Portfolio Project1] ..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--showing the continents with the hightest death count per population

Select continent,  max(total_deaths) as TotalDeathCount
from [Portfolio Project1] ..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--- Global Numbers
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
(sum(convert(float, new_deaths))/sum(nullif(convert(float,new_cases),0)))* 100
as DeathPercantage
from [Portfolio Project1] ..CovidDeaths
where continent is not null
group by date
order by 1, 2

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
(sum(convert(float, new_deaths))/sum(nullif(convert(float,new_cases),0)))* 100
as DeathPercantage
from [Portfolio Project1] ..CovidDeaths
where continent is not null
--group by [date]
order by 1, 2




--Looking at total population vs vaccinations

Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
from [Portfolio Project1] ..CovidDeaths dea
join [Portfolio Project1] ..CovidVax vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE 


With PopVsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project1] ..CovidDeaths dea
join [Portfolio Project1] ..CovidVax vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,  (RollingPeopleVaccinated/Population)* 100
from PopVsVac




---Temp Table 
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project1] ..CovidDeaths dea
join [Portfolio Project1] ..CovidVax vac 
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *,  (RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated



--creating view to store data in later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
--sum(convert(float, vac.new_vaccinations)) over (Partition by dea.location)
from [Portfolio Project1] ..CovidDeaths dea
join [Portfolio Project1] ..CovidVax vac 
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated
