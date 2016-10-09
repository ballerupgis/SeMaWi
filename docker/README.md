It is assumed you have intermediate understanding of docker concepts and basic usage.

# Preparing your database

SeMaWi is an application container. The persistent data is stored outside of the container. It is up to you to decide whether to persist data in a MySQL container or to store persistent data in a host MySQL. In either case, SeMaWi requires a MySQL database and a user with appropriate credentials. As an example to create a database on a Debian Stable Docker host:

```bash
mysql -u root -p
CREATE DATABASE wiki;
GRANT ALL PRIVILEGES ON wiki.* To 'wiki'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

Note that for the sake of simplicity your database must be named `wiki`. You can change username and password later using the `docker build --build-arg` parameter; see the top of the Dockerfile for an example.

You will need to instruct MySQL to listen on the interface the docker daemon uses. Unfortunately there doesn't seem to be a way to specify multiple interfaces to listen to; it's either one interface or all. You will need to set in `/etc/mysql/my.cnf`:

```
bind-address = 0.0.0.0
# or just uncomment any bind-address line you find in there
```

You will probably also need to add a directive `skip-name-resolve` in the `[mysqld]` section of the same file. Remember to restart the mysql service after.

# Building the SeMaWi image

1. Download the docker source files.
2. Stand in the parent directory of the directory containing the Dockerfile
3. In MySQL, create a database and database user which will contain the SeMaWi database; you should have done this in the previous section.
3. Issue the following command: `docker build --build-arg DBHOST=172.17.0.1 --build-arg DBUSER=wiki --build-arg DBPASS=wiki -t semawi -f docker/Dockerfile .` Make sure you have the correct values for the 3 build arguments DBHOST, DBUSER, and DBPASS.
4. Make a cup of tea, it takes a while. On my development VM, it takes about 30 minutes.

## Running a container for testing/development

The command will resemble the following:

```bash
docker run -d --name semawi-container -h semawi-container -p 12345:80 semawi
```

In the docker host, you should be able to access the SeMaWi container now through your browser, with an address like http://127.0.0.1:12345 . A default user SeMaWi (member of groups SysOp and Bureaucrat) has been created for you with the password "SeMaWiSeMaWi"; this password is case sensitive. This password should be changed as your first action in the running system.

You can then import the SeMaWi data model and pages by importing struktur.xml from the git repository.

## Pulling geodata from a GeoCloud2 instance

First make sure you have followed the instructions for configuring the GC2 sync in SeMaWi. That is documented in this file in the section "GeoCloud2 Import Cronjob".

The image has a script `/opt/syncgc2.sh` which needs to be called in order to initiate a pull from GC2. You will want the docker host to have a cron job for this purpose. An example of such a command could be:

```cron
0 5 * * * docker exec your-container-name /opt/syncgc2.sh
```

Keep in mind, the cronjob will need sufficient privileges to execute docker commands.

## For production

A detailed description of deploying docker containers to production is beyond the scope of this document.

# Post deploy configuration

## Obligatory

After the container is run from the built image, you will need to manually tweak a few settings. The container exports /var/www/wiki/ as a volume. Find it's location using docker inspect semawi. Set $wgServer to the IP of the container, obtained with docker inspect $CONTAINERID like so: $wgServer="http://172.17.0.2";

You may have to specify for SeMaWi how to connect to the database you have provided for it, if you have used different settings in the image build. This can be done in the `LocalSettings.php` file in the exported volume. Look for the section which looks as follows:

```php
## Database settings
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "wiki";
$wgDBuser = "wiki";
$wgDBpassword = "wiki";
```

If you're running SeMaWi in production, you will need to edit the line in `LocalSettings.php` which looks like `enableSemantics( 'localhost' );`, replacing localhost with the domain name you are using.

## Optional

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
