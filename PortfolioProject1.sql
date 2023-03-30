SELECT *
From dbo.CovidDeaths$
Where continent is not null
order by 3,4


--SELECT *
--From dbo.CovidVaccinations$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2
-- Looking at the total cases vs population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

--

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

WITH PopvsVac(Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinaed)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--Order  by 2,3
)
Select *,(RollingPeopleVaccinaed/Population)*100
From PopvsVac





--Temp Table


DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
ON dea.location = vac.location
	and dea.date = vac.date
 dea.continent is not null
Order  by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
ON dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order  by 2,3


Select *
From PercentPopulationVaccinated

