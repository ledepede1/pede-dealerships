# Pede Dealerships
Har nu siddet og hygget mig med det her script i en godt 3 dages tid nu og føler
selv at det er klar til at blive udgivet. Dog skal i lige huske at det ikke er testet
helt igennem så fejl kan godt forekomme.

### Dependencies
- oxmysql
- ox_target
- ox_lib
- esx_society
- esx_garage

### Setup
1. Start med at impoter db.sql ind i jeres database (I kan selv oprette og fjerne biler i pede-vehicles)
2. Sæt config.lua op til jeres servers behov.
3. Sæt webhook urlet i SV_Config.lua op til jeres webhook url.
4. Opret alle de jobs som i har angivet inde i configgen i jeres jobs og job_grades databaser
5. Start eller genstart serveren og hyg jer.

### Features lige nu:
> <p>Hav så mange forskellige dealerships som du føler for</p>
> <p>Et dealership kan være 4 forskellige ting men primært 3 (all, cars, bikes, boats)</p>
> <p>Katalog hvor man kan se de biler som dealershipsne kan sælge</p>
> <p>Mulighed for at fremvise de køretøjer som dealershippet har på lager</p>
> <p>Fremvisning af køretøj har to customizable ting lige nu (Farve og hvorvidt de skal dreje rundt når de bliver fremvist)</p>
> <p>Bossmenu</p>
> <p>Salg af biler til folk</p>
> <p>Køb af biler til ens dealerships lager</p>
> <p>Ændre priser på de biler man har i sit lager (Kan ikke være under indkøbsprisen)</p>
> <p>Retunere biler fra sit lager (Procent firmaet får kan sættes op i config)</p>
> <p>Se hvor meget ens lager er værd</p>
> <p>Godt optimeret og køre lavt ms (Som kan ses i videon)</p>
> <p>Forhandleren som sælger et køretøj får et cut af prisen resten får firmaet (Procent kan sættes op i Config)</p>
> <p>Mulighed for at sætte nummerpladen op til (DK, SWE, GER) flere kommer i fremtiden.</p>
> <p>Mulighed for at vælge hvor stort et grade man skal være for at købe biler hjem til sit lager</p>
> <p>Sætter automatisk dealershippets society op (Ikke jobbet det skal man selv ind og oprette.)</p>
> <p>Mulighed for at tage en bil fra sit lager ud til testkørsel</p>
**Har helt sikkert glemt noget i er velkommne til at stille spørgsmål og give feedback!**


