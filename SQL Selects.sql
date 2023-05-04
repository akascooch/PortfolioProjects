/***************************************************************************************************************************************/
-- SELECT DATA THAT WE ARE GOING TO USE IT .
Select   continent
,        location
,        date
,        total_cases
,        new_cases
,        total_deaths
,        population
From     dbo.CovidDeaths
Where    continent Is Not Null
Order By 1
,        2 ;
/***************************************************************************************************************************************/
-- LOOKING AT TOTAL CASES VS. TOTAL DEATHS .
Select   location
,        date
,        total_cases
,        total_deaths
,        ( convert(float, total_deaths) / convert(float, total_cases)) * 100 As DeathPercentage
From     dbo.CovidDeaths
Where    continent Is Not Null
Order By 1
,        2 ;
/***************************************************************************************************************************************/
-- LOOKING AT TOTAL CASES VS. POPULATION .
Select   location
,        date
,        population
,        total_cases
,        ( total_cases / population ) * 100 As PercentagePopulationInfected
From     dbo.CovidDeaths
Where    location Like '%States%'
         And continent Is Not Null
Order By 1
,        2 ;
/***************************************************************************************************************************************/
-- LOOKING AT CONTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION .
Select   location
,        population
,        max(total_cases)                        As HighestInfectionCount
,        max(( total_cases / population )) * 100 As PercentagePopulationInfected
From     dbo.CovidDeaths
Where    continent Is Not Null
Group By location
,        population
Order By PercentagePopulationInfected Desc ;
/***************************************************************************************************************************************/
-- SHOW CONTRIES WITH HIGHEST DEATH COUNT PER POPULATION .
Select   location
,        max(cast(total_deaths As int)) As TotalDeathCount
From     dbo.CovidDeaths
Where    continent Is Not Null
Group By location
Order By TotalDeathCount Desc ;
/***************************************************************************************************************************************/
-- LET'S BRING THINGS DOWN BY CONTINENT .
Select   continent
,        max(cast(total_deaths As int)) As TotalDeathCount
From     dbo.CovidDeaths
Where    continent Is Not Null
Group By continent
Order By TotalDeathCount Desc ;
/***************************************************************************************************************************************/
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION .
Select   continent
,        max(cast(total_deaths As int)) As TotalDeathCount
From     dbo.CovidDeaths
Where    continent Is Not Null
Group By continent
Order By TotalDeathCount Desc ;
/***************************************************************************************************************************************/
-- GLOBAL NUMBERS
Select   sum(new_cases)                                               As SumNewCases
,        sum(new_deaths)                                              As SumNewDeaths
,        sum(nullif(new_deaths, 0)) / sum(nullif(new_cases, 0)) * 100 As DeathPercentage
--,        total_cases
--,        total_deaths
--,        ( convert(float, total_deaths) / convert(float, total_cases)) * 100 As DeathPercentage
From     dbo.CovidDeaths
Where    continent Is Not Null
--Group By date
Order By 1
,        2 ;
/***************************************************************************************************************************************/
-- LOOKING AT TOTAL POPULATION VS. VACCINATION
Select   CD.continent
,        CD.location
,        CD.date
,        CD.population
,        CV.new_vaccinations
,        sum(nullif(cast(CV.new_vaccinations As float), 0)) Over ( Partition By CD.location Order By CD.location, CD.date ) As RollingPeopleVaccinated
,        ( RollingPeopleVaccinated / CD.population ) * 100
From     dbo.CovidDeaths              CD
         Inner Join CovidVaccinations CV
               On CV.location = CD.location
                  And CV.date = CD.date
Where    CD.continent Is Not Null --And CD.location = 'Iran'
Order By 2
,        3 ;
/***************************************************************************************************************************************/
-- USE CTE FOR PREVIOUS SELECT COLUMN = RollingPeopleVaccinated
With PopvsVac ( Continent, location, date, Population, NewVaccinations, RollingPeopleVaccinated )
As ( Select CD.continent
     ,      CD.location
     ,      CD.date
     ,      CD.population
     ,      CV.new_vaccinations
     ,      sum(nullif(cast(CV.new_vaccinations As float), 0)) Over ( Partition By CD.location Order By CD.location, CD.date ) As RollingPeopleVaccinated
     --, (RollingPeopleVaccinated/CD.population)*100
     From   dbo.CovidDeaths              CD
            Inner Join CovidVaccinations CV
                  On CV.location = CD.location
                     And CV.date = CD.date
     Where  CD.continent Is Not Null --And CD.location = 'Iran'
)
Select *
,      ( PopvsVac.RollingPeopleVaccinated / PopvsVac.Population ) * 100 As VaccinatedPercentage
From   PopvsVac ;
/***************************************************************************************************************************************/