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

# Noter

MediaWiki som er fundamentet for SeMaWi er designet til store sites. Mange deployments kan være relativ små ift. MediaWiki's primære use case som er WikiPedia. Som følge kan det blive nødvendigt med nogle små workarounds som fx. kørsel af `runJobs.php` og/eller `SMW_refreshData.php` i cronjobs.

# Licens

SeMaWi er open source. Der er frit valg mellem [GPLv3](http://www.gnu.org/licenses/gpl-3.0.en.html) licensen eller [Creative Commons Attribution-ShareAlike 3.0 Unported](http://creativecommons.org/licenses/by-sa/3.0/).
