Select * from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

Select * from PortfolioProject.dbo.CovidVaccinations
order by 3,4

--Select Data 

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by 1,2

--look total case and total deaths
Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
order by 1,2

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
Select location, date, total_cases, population, total_deaths, ((cast(total_cases as int))/population)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate to population
Select location,population, MAX(cast(total_cases as int)) as HighestInfectionCount,Max((cast(total_cases as int)/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

--Showing continents with maximum death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc
 
-- Global numbers
Select date, sum(cast(new_cases as int)) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
 sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
Order by 1,2

Select sum(cast(new_cases as int)) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, 
 (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
order by 2,3

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--sum(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION by cd.location)
sum(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location order by cd.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
order by 2,3

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--sum(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION by cd.location)
sum(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location order by cd.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
order by 2,3


--Use CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollinPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--sum(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION by cd.location)
sum(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location order by cd.location, cd.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
 --order by 2,3
)
Select *, (RollinPeopleVaccinated/Population)*100
From PopVsVac

--Tem Table

DROP Table if exists #PercentPopulationVaccinated

create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollinPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--sum(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION by cd.location)
sum(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location order by cd.location, cd.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
 
Select *, (RollinPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
--sum(CONVERT(int, cv.new_vaccinations)) OVER (PARTITION by cd.location)
sum(cast(cv.new_vaccinations as int)) OVER (PARTITION by cd.location order by cd.location, cd.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

Select * 
from PercentPopulationVaccinated
