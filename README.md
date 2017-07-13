# Installing SeMaWi

This guide assumes you have intermediate understanding of docker
concepts and basic usage.

## Building the SeMaWi image

1. Download these docker and docker-compose source files.
2. Stand in the parent directory of the directory containing `docker-compose.yml`
5. Issue the following command: `docker-compose build`

## Running SeMaWi

SeMaWi requires docker-compose. As this version supports multiple concurrent
environments, you will need to provide docker-compose with some environment
variables to keep the concurrent deployments separated. A docker-compose run
command will look like this:

```bash
CLIENT="BALK" \
SEMAWIENV="PROD" \
SEMAWI_WEB_PORT=81 \
SEMAWI_DB_PORT=3307 \
SEMAWI_MUTABLES_ROOT=/srv/semawi2 \
docker-compose -p SEMAWI_BALK_PROD up -d
```

Please make sure each of these command line values - including the project name - are
unique. If they are not unique, you WILL overwrite data and/or containers.

As part of the `docker-compose up` command, several types of mutable data will be
mounted for you to the running container:

1. `LocalSettings.php`
2. `php.ini`
3. `images` folder with `www-data:www-data` ownership
4. Logo file
5. gc2 sync configuration file `gc2smw.cfg`
6. Various conf files for unixodbc so the wiki can query a SQL Server

These files are expected to be in the location `SEMAWI_MUTABLES_ROOT`. You can find usable
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

There are four settings you need to modify to activate the [Mapcentia GeoCloud2](https://github.com/mapcentia/geocloud2) geodata table import into SeMaWi. SeMawi exposes the GC2 sync config in a volume, find it with `docker inspect your-container-name`. In this volume you will fine the cfg file, and the following settings need to be set correctly:

1. username: a valid SeMaWi login. The default docker build establishes a login Sitebot for this purpose
2. password: the password for the above bot account; usually SitebotSitebot
3. site: the URL to the SeMaWi container. Unless you know what you are doing, leave it as-is
4. gc2_url: The URL to the GC2 API

The image has a script `/usr/local/bin/gc2smwdaemon.py` which needs to be called in order to initiate a pull from GC2. You will want the docker host to have a cron job for this purpose. An example of such a command could be:

```cron
0 5 * * * docker exec your-container-name /usr/local/bin/gc2smwdaemon.py
0 6 * * * docker exec your-container-name /usr/bin/php /var/www/wiki/maintenance/runJobs.php
```

It is strongly recommended you coordinate the time at which the import runs with Mapcentia.

### Logo

You will likely want to change your logo. Follow the guidelines [here](https://www.mediawiki.org/wiki/Manual:$wgLogo) to incorporate your logo.
