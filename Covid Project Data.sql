SELECT *
FROM covid-deaths-441220.covid_deaths.covid_deaths
WHERE continent is not null
order by 3,4;

--SELECT *
--FROM covid-deaths-441220.covid_deaths.covid_vaccinations
--order by 3,4;

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid-deaths-441220.covid_deaths.covid_deaths
WHERE continent is not null
Order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM covid-deaths-441220.covid_deaths.covid_deaths
Where location like'%States%'
Order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (Total_cases/population)*100 as PercentPopulationInfected
FROM covid-deaths-441220.covid_deaths.covid_deaths
Where location like'%States%'
Order by 1,2;

-- Looking at  Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM covid-deaths-441220.covid_deaths.covid_deaths
--Where location like'%States%'
Group by Location, Population
Order by PercentPopulationInfected desc;

-- Showing countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM covid-deaths-441220.covid_deaths.covid_deaths
--Where location like'%States%'
WHERE continent is not null
Group by Location
Order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Below gives more accurate continents but the tutorial says to proceed with the next query
--SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--FROM covid-deaths-441220.covid_deaths.covid_deaths
--Where location like'%States%'
----WHERE continent is null
--Group by location
--Order by TotalDeathCount desc;


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM covid-deaths-441220.covid_deaths.covid_deaths
--Where location like'%States%'
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc;



-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM covid-deaths-441220.covid_deaths.covid_deaths
--Where location like'%States%'
WHERE continent is not null
--group by date
Order by 1,2;


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid-deaths-441220.covid_deaths.covid_vaccinations vac
JOIN covid-deaths-441220.covid_deaths.covid_deaths dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

-- Use CTE

WITH PopvsVac --(continent, location, date, population, new_vaccintations) this did not work in big query
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid-deaths-441220.covid_deaths.covid_vaccinations vac
JOIN covid-deaths-441220.covid_deaths.covid_deaths dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac;



-- Temp Table

--DROP Table if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
  Continent STRING,
  Location STRING,
  Date DATE,
  Population NUMERIC,
  New_vaccinations NUMERIC,
  RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid-deaths-441220.covid_deaths.covid_vaccinations vac
JOIN covid-deaths-441220.covid_deaths.covid_deaths dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null;
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

Create View covid-deaths-441220.covid_deaths.PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid-deaths-441220.covid_deaths.covid_vaccinations vac
JOIN covid-deaths-441220.covid_deaths.covid_deaths dea
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null;
--order by 2,3


Select *
From `covid-deaths-441220.covid_deaths.PercentPopulationVaccinated`


--Create more views for tableu