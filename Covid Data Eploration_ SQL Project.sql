--- I tried importing the excel file of this dataset but observed that some columns where missing , so i decided to convert the file to csv 
--- and imported as a flat file and then worked on the datatypes

-- Checking to see the contents of the table
select *
from [dbo].[Covid_Deaths]
order by 3,4

select *
from [dbo].[Covid_Vaccinations]
order by 3,4

--CHOOSING THE COLUMN TO USE

select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[Covid_Deaths]
order by 1,2


--to know thepercentage of people who died from covid in Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from [dbo].[Covid_Deaths]
where location like 'Nigeria'
order by 1,2
-- we see that towards the enf of April 2021, where total cases was 165110 and total deaths 2063, the percentage of death was about 1.3%

--- total cases vs population
--- what percentage of nigerians got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulation
from [dbo].[Covid_Deaths]
where location = 'Nigeria'
order by 1,2

--- looking at the percentage of population who got covid 

select location, max(total_cases) as TotalCases, population, max(total_cases/population)*100 as PercentagePopulation
from [dbo].[Covid_Deaths]
group by location, population
order by PercentagePopulation desc

-- checking by Continent
select continent,location, max(total_cases) as TotalCases, population, max(total_cases/population)*100 as PercentagePopulation
from [dbo].[Covid_Deaths]
where continent is not null
group by continent,location, population
order by continent, PercentagePopulation desc

---- Checking countries with highest death rates Per Population
select continent,location, max(total_cases) as TotalCases, population, max(total_cases/population)*100 as PercentagePopulation
from [dbo].[Covid_Deaths]
where continent is not null
group by continent,location, population
order by continent, PercentagePopulation desc

--by continent
select distinct continent, max(total_deaths) as TotalDeath
from [dbo].[Covid_Deaths]
where continent is not null
group by continent
order by TotalDeath desc

select continent, max(total_deaths) as TotalDeath
from [dbo].[Covid_Deaths]
where continent is null
group by continent
order by TotalDeath desc

---by location
select location, max(total_deaths) as TotalDeath
from [dbo].[Covid_Deaths]
where continent is not null
group by location
order by TotalDeath desc

select location, max(total_deaths) as TotalDeath
from [dbo].[Covid_Deaths]
where continent is null
group by location
order by TotalDeath desc

---- HAVING A PEEK AT THE VACCINATION TABLE

select *
from Covid_Vaccinations

--- Checking Total Population Vaccinated

select d.continent, d.location, d.date, d.population
from [dbo].[Covid_Deaths] d
join [dbo].[Covid_Vaccinations] v
on d.location = v.location
and d.date = v.date

 ---  Also checking New Vaccinated 
 select d.continent, d.location, d.date, d.population, v.new_vaccinations
from [dbo].[Covid_Deaths] d
join [dbo].[Covid_Vaccinations] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by  2,3

select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.date, d.location) as RollingPopulationVaccinated
from [dbo].[Covid_Deaths] d
join [dbo].[Covid_Vaccinations] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1, 2,3


-- USING CTE

with PopulationVsVaccinated (continent, date,population, new_vaccinations,location, RollingPopulationVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.date, d.location) as RollingPopulationVaccinated
from [dbo].[Covid_Deaths] d
join [dbo].[Covid_Vaccinations] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
)
select *,(RollingPopulationVaccinated/population)*100
from PopulationVsVaccinated

