Select*
From PortfolioProject..[Covid-death-data]
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..[Covid-vaccinations-data]
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[Covid-death-data]
Where continent is not null
order by 1, 2

-- looking At Total cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..[Covid-death-data]
Where location like '%India%'
order by 1, 2

-- looking At Total cases vs Population
Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectedPercentage
From PortfolioProject..[Covid-death-data]
Where location like '%India%'

order by 1, 2 

-- looking At Contries with highest infection rate compared to Population
Select Location, MAX(cast(total_cases as int)) as HighestInfectionCount, population, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)))*100 as InfectedPopulationPercentage
From PortfolioProject..[Covid-death-data]
--Where location like '%India%'
Where continent is not null
group by location, population
order by InfectedPopulationPercentage desc

-- Looking at Contries with highest Deat Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid-death-data]
--Where location like '%India%'
Where continent is not null
group by location
order by TotalDeathCount desc

-- Looking at Continents with highest Deat Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCountContinent
From PortfolioProject..[Covid-death-data]
--Where location like '%India%'
Where continent is not null
group by continent
order by TotalDeathCountContinent desc

-- Global Numbers

Select SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(NULLIF(new_cases,0))*100 as DeathPercentage
From PortfolioProject..[Covid-death-data]
Where continent is not null
--group by date
order by 1, 2

--JOIN BOTH TABLES

select *
from PortfolioProject..[Covid-death-data] death
join PortfolioProject..[Covid-vaccinations-data] vaccination
	on death.location=vaccination.location
	and death.date=vaccination.date

-- Looking at Total Population vs Vaccinations

select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, 
SUM(cast(vaccination.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-death-data] death
join PortfolioProject..[Covid-vaccinations-data] vaccination
	on death.location=vaccination.location
	and death.date=vaccination.date
where death.continent is not null
order by 2,3

-- use CTE 

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, 
SUM(cast(vaccination.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-death-data] death
join PortfolioProject..[Covid-vaccinations-data] vaccination
	on death.location=vaccination.location
	and death.date=vaccination.date
where death.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

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

select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, 
SUM(cast(vaccination.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-death-data] death
join PortfolioProject..[Covid-vaccinations-data] vaccination
	on death.location=vaccination.location
	and death.date=vaccination.date
where death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating vew for later visualizations

Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccination.new_vaccinations, 
SUM(cast(vaccination.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..[Covid-death-data] death
join PortfolioProject..[Covid-vaccinations-data] vaccination
	on death.location=vaccination.location
	and death.date=vaccination.date
where death.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated
