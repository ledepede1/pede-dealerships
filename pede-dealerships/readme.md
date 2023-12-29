# Pede Dealerships
Har nu siddet og hygget mig med det her script i en godt 3 dages tid nu og føler
selv at det er klar til at blive udgivet. Dog skal i lige huske at det ikke er testet
helt igennem så fejl kan godt forekomme.

### Dependencies
- oxmysql
- ox_target
- ox_lib
- esx_society

### Setup
1. Start med at impoter db.sql ind i jeres database (I kan selv oprette og fjerne biler i pede-vehicles)
2. Sæt config.lua op til jeres servers behov.
3. Sæt webhook urlet i SV_Config.lua op til jeres webhook url.
4. Opret alle de jobs som i har angivet inde i configgen i jeres jobs og job_grades databaser
5. Start eller genstart serveren og hyg jer.

### Features lige nu:
> Hav så mange forskellige dealerships som du føler for
> Et dealership kan være 4 forskellige ting men primært 3 (all, cars, bikes, boats)
> Katalog hvor man kan se de biler som dealershipsne kan sælge
> Mulighed for at fremvise de køretøjer som dealershippet har på lager
> Fremvisning af køretøj har to customizable ting lige nu (Farve og hvorvidt de skal dreje rundt når de bliver fremvist)
> Bossmenu
> Salg af biler til folk
> Køb af biler til ens dealerships lager
> Ændre priser på de biler man har i sit lager (Kan ikke være under indkøbsprisen)
> Retunere biler fra sit lager (Procent firmaet får kan sættes op i config)
> Se hvor meget ens lager er værd
> Godt optimeret og køre lavt ms (Som kan ses i videon)
> Forhandleren som sælger et køretøj får et cut af prisen resten får firmaet (Procent kan sættes op i Config)
> Mulighed for at sætte nummerpladen op til (DK, SWE, GER) flere kommer i fremtiden.
> Mulighed for at vælge hvor stort et grade man skal være for at købe biler hjem til sit lager
> Sætter automatisk dealershippets society op (Ikke jobbet det skal man selv ind og oprette.)
> Mulighed for at tage en bil fra sit lager ud til testkørsel
**Har helt sikkert glemt noget i er velkommne til at stille spørgsmål og give feedback!**

Download:
Showcase:


