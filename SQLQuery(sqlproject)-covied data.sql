select location,date,total_deaths,total_cases,(total_deaths/total_cases)*100 AS deathpct
From coviddeath
order by 1,2

select location,date,total_deaths,total_cases,(total_deaths/total_cases)*100 AS deathpct
From coviddeath
where location like '%states%'
order by 1,2

-- looking for total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 AS deathpct
From coviddeath
where location like '%states%'
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 AS deathpct
From coviddeath
order by 5

-- looking at country with higher infection rate as compare to the population

select location,population,MAX(total_cases) as MAX_total_case,MAX((total_cases/population))*100 AS pctofpopulationinf
From coviddeath
--where location = 'India'
group by location, population
order by 4 desc

-- Showing the country with hifgest death count

select location,MAX(total_deaths) as MAX_total_death
From coviddeath
where continent is not null
group by location
order by 2 desc

-- let's break is down by continates

select continent,MAX(total_deaths) as MAX_total_death
From coviddeath
where continent is not null
group by continent
order by 2 desc

select location,MAX(total_deaths) as MAX_total_death
From coviddeath
where continent is null
group by location
order by 2 desc

-- global number

select date,sum(new_cases),sum(new_deaths),sum(new_deaths)/sum(new_cases)*100 AS deathpct
from coviddeath
where continent is not null and new_cases <> 0
group by date
order by 1,2

select sum(new_cases) as total_new_cases,sum(new_deaths) as total_new_deaths,sum(new_deaths)/sum(new_cases)*100 AS deathpct
from coviddeath
where continent is not null
order by 1,2


-- join the covid datasets

select *
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date

-- Looking for total vac vs total population

select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null
order by 2,3

select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by 2,3

select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location) as total_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by 2,3

select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by 2,3

select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac,
(sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date)/population)*100 as pct
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
order by 2,3

-- With CTE

with popvsvac(continent,location,date,population,new_vaccinations,total_rolling_pct)
as (
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
)
select *,(total_rolling_pct/population)*100
from popvsvac
order by 2,3

-- Temp Table

create table #pctpopvac
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_rolling_pct numeric
)
insert into #pctpopvac
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null

select *,(total_rolling_pct/population)*100
from #pctpopvac
order by 2,3


drop table if exists #pctpopvac
create table #pctpopvac
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_rolling_pct numeric
)
insert into #pctpopvac
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
--where cd.continent is not null and cv.new_vaccinations is not null

select *,(total_rolling_pct/population)*100
from #pctpopvac
order by 2,3

-- Creating view to store data

create view pctpopvac as
select cd.continent,cv.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location,cd.date) as total_rolling_vac
from coviddeath cd
Join covidvactination cv
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null

select * 
from pctpopvac