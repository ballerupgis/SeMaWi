# Installing SeMaWi

This guide assumes you have intermediate understanding of docker
concepts and basic usage.

## Preparing your database

SeMaWi is an application container. The persistent data is stored outside of the container. It is up to you to decide whether to persist data in a MySQL container or to store persistent data in a host MySQL. In either case, SeMaWi requires a MySQL database and a user with appropriate credentials. As an example to create a database on a Debian Stable Docker host:

```bash
docker run --name semawi-mariadb \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE=wiki \
  -e MYSQL_USER=wiki \
  -e MYSQL_PASSWORD=wiki \
  -p 3306:3306 -d mariadb:latest
```
Alternatively:

```bash
mysql -u root -p
CREATE DATABASE wiki;
GRANT ALL PRIVILEGES ON wiki.* To 'wiki'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

Remember to have the correct MySQL host, db name, user, and password as `--build-arg`s in the build command.

You will need to instruct MySQL to listen on the interface the docker daemon uses. Unfortunately there doesn't seem to be a way to specify multiple interfaces to listen to; it's either one interface or all. You will need to set in `/etc/mysql/my.cnf`:

```
bind-address = 0.0.0.0
# or just uncomment any bind-address line you find in there
```

You will probably also need to add a directive `skip-name-resolve` in the `[mysqld]` section of the same file. Remember to restart the mysql service after.

## Building the SeMaWi image

1. Download the docker source files.
2. Stand in the parent directory of the directory containing the Dockerfile
3. You should have prepared your MySQL database in the earlier section.
4. Apply the configuration changes also listed earlier.
5. Issue the following command:

        docker build --build-arg DBHOST=172.17.0.1 \
          --build-arg DBNAME=wiki \
          --build-arg DBUSER=wiki \
          --build-arg DBPASS=wiki \
          -t semawi -f Dockerfile .

   Make sure you have the correct values for the 4 build arguments
   `DBHOST`, ``DBNAME`, `DBUSER`, and `DBPASS`.

## Deployment configuration

The `Dockerfile` contains a sample `docker run` command which you can adapt for your purposes.

As part of the run command, you will need to mount several types of mutable data to the running container:

1. `LocalSettings.php`
2. `php.ini`
3. `images` folder with `www-data:www-data` ownership
4. Logo file

If you are running SeMaWi for the first time and do not have these elements,
you can run a SeMawi container without mounting these elements and then
`docker copy` them to the host to obtain blank templates for you to adapt.
Then you can stop and remove that container, and run another one, mounting
these elements from the host.

If you have access to the SeMaWi source, the `LocalSettings.php`, `php.ini`,
and logo file are provided for you to copy over in the `mutables` folder.

In the docker host, you should be able to access the SeMaWi container
now through your browser, with an address like
`http://semawi.example.com`. Please note that you **must** have
entered a correct address for `$wgServer$` in the earlier section;
otherwise, all wiki pages appear empty. A default user _SeMaWi_
(member of groups _SysOp_ and _Bureaucrat_) has been created for you
with the case-sensitive password `SeMaWiSeMaWi`. You should change
this password as your first action in the running system.

### Localsettings.php

Set `$wgServer` to the external IP of the container, obtained with docker inspect `$CONTAINERID` like so:

```php
$wgServer="http://semawi.example.com";
```

You may have to specify for SeMaWi how to connect to the database you have provided for it, if you have
used different settings in the image build. Look for the section which looks as follows:

```php
## Database settings
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "wiki";
$wgDBuser = "wiki";
$wgDBpassword = "wiki";
```

You must edit the `$wgSMTP` in `LocalSettings.php` to reflect where the SMTP server is which SeMaWi can use.

If you're running SeMaWi in production, you will need to edit the line in `LocalSettings.php` which looks
like `enableSemantics( 'localhost' );`, replacing localhost with the domain name you are using.

### php.ini

In this file it is recommended to increase the upload and post max file sizes.

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

### MediaWiki secrets

Your SeMaWi Docker image has been pre-seeded with random values for `$wgSecretKey` and `$wgUpgradeKey` configuration parameters in `LocalSettings.php`. These are regenerated each time you build the image. For each container that you run off an image you built for yourself, you are strongly urged to change these two values in the container. `$wgSecretKey` takes a 64 character alphanumeric string, and `$wgUpgradeKey` takes a 16 character alphanumeric string.

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

### Other

You are encouraged to examine LocalSettings.php and adapt it to your needs.

If you need to restart a running SeMaWi container (e.g. php.ini tweaks):

```bash
docker kill --signal="SIGUSR1" your-semawi-container-name
```
