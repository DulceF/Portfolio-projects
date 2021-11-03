Select *
From [Dulcissima project]..['Covid deaths$']
Where continent is not null
Order by 1,2

--Select the data that we are going to be using
--Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage, population
From [Dulcissima project]..['Covid deaths$']
Where location like 'United Kingdom'
Order by 1,2

-- Looking at the total cases vs the population
--Shows what percentage of the population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as death_percentage
From [Dulcissima project]..['Covid deaths$']
--Where location like 'United Kingdom'
Order by 1,2

--Look at Countries with the highest infection rate compared to population

Select Location, Population, Max(total_cases) as Highest_infection_count, Max((total_cases/population))*100 as highest_percent_pop_infected
From [Dulcissima project]..['Covid deaths$']
Group by Location, Population
Order by highest_percent_pop_infected DESC
--Where location like 'United Kingdom' 

--Showing countries with the highest death count per population

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as Total_death_count
From [Dulcissima project]..['Covid deaths$']
Where continent is not null
Group by continent
Order by Total_death_count DESC

-- Global numbers


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
From [Dulcissima project]..['Covid deaths$']
where continent is not null
Group by date
Order by 1,2

--Looking at total population vs vaccinations
--Creating view to store data for later visualizations
Create View #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ) as Rolling_people_vaccinated
From [Dulcissima project]..['Covid deaths$'] dea
Join [Dulcissima project]..['Covid vaccinations$'] vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3 

-- Looking at Total Population vs Vaccinations
--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingpeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
From [Dulcissima project]..['Covid deaths$'] dea
Join [Dulcissima project]..['Covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingpeopleVaccinated/Population)*100 as percentage_pop_vaccinated
From PopvsVac
-- USE CTE

--Temp Table

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric, 
New_vaccinations numeric
RollingpeopleVaccinated numeric
)

