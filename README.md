SeMaWi bygger på MediaWiki og Semantic MediaWiki med formålet at implementere en model for forvaltning af en kommunal softwareportefølje. SeMaWi indeholder:

1. En levende datamodel der afspejler praktisk og anvendeligt softwareportefølje domænet i de danske kommuner, med udgangspunkt i en prototype som Ballerup Kommunes Center for Miljø og Teknik har bidraget med, og
2. Analytiske elementer der har formålet at understøtte evidensbaseret og kvantitativ porteføljeforvaltning.

SeMaWi er udviklet i samarbejde med [Josef Assad](mailto:josef@josefassad.com).

# Infrastruktur
1. Debian 8
2. Apache, MySQL, og php fra standard Debian repositorier
3. Mediawiki (herefter MW) 1.24.2; [installationsvejledning](https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki)
4. Semantic Mediawiki (hereafter SMW) 2.2 [installationsvejledning](https://semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.22%2B)

# Installation
1. Installer [Semantic Mediawiki](https://semantic-mediawiki.org/wiki/Help:Installation/Using_Composer_with_MediaWiki_1.22%2B)
2. Installer  [DataTransfer](https://www.mediawiki.org/wiki/Extension:Data_Transfer) udvidelsen til MW; installationsvejledning på samme side
3. Installer [SemanticForms](https://www.mediawiki.org/wiki/Extension:Semantic_Forms/Download_and_installation)
4. Installer [Semantic Result formats](https://semantic-mediawiki.org/wiki/Semantic_Result_Formats#Installation).
5. Deaktiver property caching i SMW; i SemanticMediawiki.settings.php skift `'smwgPropertiesCache' => true,` til `'smwgPropertiesCache' => false,`.
6. I SMW Special:Import, importer filen structure.xml
7. I Linux kommandolinjen, navigér til MW maintenance folderen og kør kommandoen `php runJobs.php`
8. Skift sidelogo efter behov; instruktioner [her](https://www.mediawiki.org/wiki/Manual:$wgLogo).
9. I filen `SemanticMediaWiki.settings.php` skift værdien af variablen `smwgQMaxSize` til 100.
10. I filen `SemanticMediaWiki.settings.php` skift værdien af variablen `smwgQMaxDepth` til 10.
11. Installer [MasonryMainPage](https://github.com/enterprisemediawiki/MasonryMainPage).
12. I filen `LocalSettings.php` tilføj `$wgIncludejQueryMigrate = true;`.

## KLE Emneplan 2.0

Hvis det ønskes kan elementerne fra KLE Emneplan 2.0 indlæses så de kan anvendes til tagging og dermed klassificering, søgning, filtrering, og analyse på tværs af resten af datamodellen.

Der er 4 trin i processen. Først importeres XML filen `KLE-struktur.xml`. Derefter importeres de 4 CSV filer som ligger i mappen KLE-data. Efter import af struktur og data anbefales det at refreshe SMW ved at køre de to backend scripts `SMW_refreshData.php` og derefter `runJobs.php`.

Da dette er optionelt skal der manuelt tilføjes felter der peger på KLE-struktur elementer i de øvrige klasser.

## Mapcentia GC2 Tabeller

SeMaWi understøtter integration til Mapcentia GeoCloud2. Geodata tabeller kan vises som sider i Geodata kategoriet i SeMaWi, hvilket gør det muligt at lave analyser på de tabeller og at se dem i sammenhæng med øvrige entiteter som KLE emner eller systemer eller brugere.

### Batchimport

Der er udviklet et python script som skal køre i cronjob på SeMaWi serveren for at opdatere SeMaWi med de geodata tabeller GC2 indeholder. Installation foregår således:

1. I `LocalSettings.php` skal der tilføjes `$wgRawHtml = true;`. Det er så kortene kan vises.
2. I SeMaWi skal der oprettes en ny bruger med brugernavn Sitebot. Denne bruger skal være medlem af følgende brugergrupper: robot, administrator, bureaukrat
3. Scriptet `gc2/gc2smwdaemon.py` skal kaldes fra et cronjob så det kører på et passende tidspunkt med de korrekte SeMaWi Sitebot login og GC2 API oplysninger. Oplysningerne om Sitebot og GC2 API endpoint skrives i de relevante variabler i `gc2/gc2smwdaemon.py` filen. Bemærk, `gc2/gc2smwdaemon.py` skal køre fra et `virtualenv` som har alle afhængigheder fra `gc2/requirements.txt` installeret korrekt. Det er ude for scope i denne vejledning at dokumentere hvordan man anvender `virtualenv` eller opretter et cronjob i Linux.

Optionelt kan det anbefales at køre de to maintenance scripts `SMW_refreshData.php` og derefter `runJobs.php` efter.

### Engangsimport

Hvis det ønskes kan tabellerne fra Mapcentia GC2 indlæses en gang og derefter holdes ajour manuelt på begge sider, SeMaWi og GC2. Det er langt de færreste tilfælde hvor dette er ønskværdigt.

1. I `LocalSettings.php` skal der tilføjes `$wgRawHtml = true;`. Det er så kortene kan vises.
2. Download json filen fra GC2
3. Anvend scriptet `gc2/gc2smw.py` som genererer en CSV fil med tabellerne. Det anbefales at bruge et python virtualenv; filen `gc2/requirements.txt` lister krævede biblioteker.
4. Indlæs `gc2/geodata-struktur.xml`
5. Indlæs den genererede CSV fil
6. Kør de to backend scripts `SMW_refreshData.php` og derefter `runJobs.php`.

## Datamodel for Indsatser og strategiske ophæng

En enkel datamodel kan tilvælges som skaber rammer for indsatsregistrering, overblik, og opfølgning. Generelle trin for installation:

1. Installer  [Header Tabs](https://www.mediawiki.org/wiki/Extension:Header_Tabs) udvidelsen til MediaWiki
2. Installer  [Semantic Forms Inputs](https://www.mediawiki.org/wiki/Extension:Semantic_Forms_Inputs) udvidelsen til MediaWiki
3. Importer XML filen `indsatser/indsats-struktur.xml`.

# Noter

MediaWiki som er fundamentet for SeMaWi er designet til store sites. Mange deployments kan være relativ små ift. MediaWiki's primære use case som er WikiPedia. Som følge kan det blive nødvendigt med nogle små workarounds som fx. kørsel af `runJobs.php` og/eller `SMW_refreshData.php` i cronjobs.

# Licens

SeMaWi er open source. Der er frit valg mellem [GPLv3](http://www.gnu.org/licenses/gpl-3.0.en.html) licensen eller [Creative Commons Attribution-ShareAlike 3.0 Unported](http://creativecommons.org/licenses/by-sa/3.0/).
