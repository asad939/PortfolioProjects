--COVID Data from 5 November  


SELECT * 
FROM PortfolioProject..coviddeaths
WHERE continent is not null
ORDER By 3,4

--SELECT * 
--FROM PortfolioProject..covidvaccinations
--ORDER By 3,4


-- Select Data that we are going to use 


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER By 1,2

-- Total cases Vs total Deaths 
-- Country wise deathpercentage


SELECT location, date, total_cases, total_deaths,
(CAST(total_deaths AS float)/CAST(total_cases AS float))*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE Location like '%germany%' 
ORDER By 1,2


-- Total cases Vs population

SELECT location, date, population,total_cases, 
(CAST(total_cases AS float)/CAST(population AS float))*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE Location like '%germany%' 
ORDER By 1,2

--Infection rate , popultion comparison 


SELECT location, population,MAX(total_cases) as highestinfectioncount, 
MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 as Populationinfectionpercentage
FROM PortfolioProject..coviddeaths
Group By  location, population
ORDER By Populationinfectionpercentage DESC

--Infection rate , country  comparison 

SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not null
Group By location
ORDER By TotalDeathCount DESC



-- Continent WISE comparison

SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is not null
Group By continent
ORDER By TotalDeathCount DESC

-- Global Numbers
-- new deaths vs new cases
SELECT  sum(cast(new_cases as float))as total_cases, sum(cast(new_deaths as float)) as total_deaths,
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as deathpercentage
FROM PortfolioProject..coviddeaths
WHERE continent is not null 
--Group By date
ORDER By 1,2

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (Partition BY  dea.location Order by  dea.location, dea.date ) as RollingCountPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER By 2,3

-- population vacci percentaion
--Use CTE 

WITH PopvsVac (continent, Location, date, population,new_vaccinations, RollingCountPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (Partition BY  dea.location Order by  dea.location, dea.date ) as RollingCountPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
select *, (RollingCountPeopleVaccinated/population)*100 FROM PopvsVac


-- Temp Table 

DROP TAble if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Vew_vaccinations numeric,
RollingCountPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (Partition BY  dea.location Order by  dea.location, dea.date ) as RollingCountPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null 
ORDER By 2,3

select *, (RollingCountPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization 

Create View PercentPopulationVaccinated as 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations )) OVER (Partition BY  dea.location Order by  dea.location, dea.date ) as RollingCountPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
