# Installing SeMaWi

This guide assumes you have intermediate understanding of docker
concepts and basic usage.

## Building the SeMaWi image

1. Download these docker source files.
2. Stand in the parent directory of the directory containing `docker-compose.yml`
4. Apply the configuration changes listed below.
5. Issue the following command: `docker-compose up -d`

## Deployment configuration

As part of the `docker-compose up` command, several types of mutable data will be
mounted for you to the running container:

1. `LocalSettings.php`
2. `php.ini`
3. `images` folder with `www-data:www-data` ownership
4. Logo file
5. gc2 sync configuration file `gc2smw.cfg`
6. Various conf files for unixodbc so the wiki can query a SQL Server

These files are expected to be in the location `/srv/semawi/`. You can find usable
versions of these files in the `mutables` folder distributed with the source.

Please make sure you review the provided configuration files to adapt the system
to your needs. Notably, you will want to secure the following settings:

- `$wgSecretKey`
- `$wgUpgradeKey`
- `$wgServer`

In the docker host, you should be able to access the SeMaWi container
now through your browser, with an address like
`http://semawi.example.com`. Please note that you **must** have
entered a correct address for `$wgServer$` in the earlier section;
otherwise, all wiki pages appear empty. A default user _SeMaWi_
(member of groups _SysOp_ and _Bureaucrat_) has been created for you
with the case-sensitive password `SeMaWiSeMaWi`. You should change
this password as your first action in the running system.

### Localsettings.php

Set `$wgServer` to the external address of the container like so:

```php
$wgServer="http://semawi.example.com";
```

You must edit the `$wgSMTP` in `LocalSettings.php` to reflect where the SMTP server is which SeMaWi can use.

If you're running SeMaWi in production, you will need to edit the line in `LocalSettings.php` which looks like `enableSemantics( 'localhost' );`, replacing localhost with the domain name you are using.

## Optional features

### Pulling geodata from a GeoCloud2 instance

First make sure you have followed the instructions for configuring the GC2 sync in SeMaWi. That is documented in this file in the section "GeoCloud2 Import Cronjob".

The image has a script `/opt/syncgc2.sh` which needs to be called in order to initiate a pull from GC2. You will want the docker host to have a cron job for this purpose. An example of such a command could be:

```cron
0 5 * * * docker exec your-container-name /opt/syncgc2.sh
0 6 * * * docker exec your-container-name /usr/bin/php /var/www/wiki/maintenance/runJobs.php
```

Keep in mind, the cronjob will need sufficient privileges to execute docker commands.

### Migration of content

This section describes the process for migrating content from a SeMaWi to a newly established docker container.

#### Approach A: lots of pages which are not in recognised categories, lots of local user accounts

When migrating content to a newly deployed docker build, we are essentially moving the wiki. Therefore, we follow the instructions for backing up and updating the wiki, then we re-deploy the SeMaWi XML dump.

1. Back up the old wiki; instructions [here](https://www.mediawiki.org/wiki/Manual:Backing_up_a_wiki).
2. Deploy the SeMaWi docker according to the instructions on this page.
3. Execute an upgrade; instructions [here](https://www.mediawiki.org/wiki/Manual:Upgrading).
4. Re-read the structure.xml manually from SeMaWi's github in Speciel:Importere (Special:Import)
5. Execute `maintenance/rebuildall.php` and `maintenance/runJobs.php`
6. Remember to `chown -R www-data:www-data /var/www/wiki/images/` in the docker image (with docker exec) after moving the image directory contents.

#### Approach B: accounts are external, no uncategorised pages to move

1. From the old wiki, use Special:Export to obtain XML dumps of all the pages in the categories we want transferred
2. Deploy the SeMaWi docker according to the instructions on this page.
3. Import the XML dumps in the newly deployed SeMaWi container using Speciel:Importere (Special:Import)

### Logo

You will likely want to change your logo. Follow the guidelines [here](https://www.mediawiki.org/wiki/Manual:$wgLogo) to incorporate your logo.

### Data Model

I recommend you examine the list of Forms to identify which parts of the SeMaWi functionality is required in your case. You can link to the Categories created by these Forms in MediaWiki:Sidebar.

### MediaWiki Skin

This dockerized version of SeMaWi ships with the [Chameleon skin](https://www.mediawiki.org/wiki/Skin:Chameleon). To activate it, find the line in `LocalSettings.php` which says:

`$wgDefaultSkin = "vector";`

and change it to

`$wgDefaultSkin = "chameleon";`

### GeoCloud2 Import Cronjob

There are four settings you need to modify to activate the [Mapcentia GeoCloud2](https://github.com/mapcentia/geocloud2) geodata table import into SeMaWi. SeMawi exposes the GC2 sync config in a volume, find it with `docker inspect your-container-name`. In this volume you will fine the cfg file, and the following settings need to be set correctly:

1. username: a valid SeMaWi login. The default docker build establishes a login Sitebot for this purpose
2. password: the password for the above bot account; usually SitebotSitebot
3. site: the URL to the SeMaWi container. Unless you know what you are doing, leave it as-is
4. gc2_url: The URL to the GC2 API

When you have done this, you must exec into the container to install the GC2 sync environment:

```bash
docker exec -ti name-of-your-running-container /bin/bash
cd /opt/
./installgc2daemon.sh

```

Having set the integration up, you must instruct the docker host to call the script from the host's cronjob. Refer to the section "Pulling geodata from a GeoCloud2 instance" in this document to see how to do this.

It is strongly recommended you coordinate the time at which the import runs with Mapcentia.
