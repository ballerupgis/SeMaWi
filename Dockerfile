# BUILD-USING:        docker build --build-arg DBHOST=172.17.0.1 --build-arg DBNAME=wiki --build-arg DBUSER=wiki --build-arg DBPASS=wiki -t semawi -f Dockerfile .
# RUN-USING:          docker run -d --volume /srv/semawi/LocalSettings.php:/var/www/wiki/LocalSettings.php --volume /srv/semawi/php.ini:/etc/php5/apache2/php.ini --volume /srv/semawi/images/:/var/www/wiki/images/ --volume /srv/semawi/nanlogo.png:/var/www/wiki/resources/assets/nanlogo.png --volume /srv/semawi/gc2smw.cfg:/opt/gc2/gc2smw.cfg --volume /srv/semawi/freetds.conf:/etc/freetds/freetds.conf --volume /srv/semawi/odbcinst.ini:/etc/odbcinst.ini --volume /srv/semawi/odbc.ini:/etc/odbc.ini --name semawi-container --hostname semawi-container --publish 80:80 semawi
# INSPECT-USING:      docker run -t -i semawi-container /bin/bash

FROM debian:jessie
MAINTAINER Josef Assad <josef@josefassad.com>
LABEL version="2017-01"

ENV DEBIAN_FRONTEND noninteractive

ARG DBHOST=172.17.0.1
ARG DBNAME=wiki
ARG DBUSER=wiki
ARG DBPASS=wiki

# We'll need the deb-src repositories since we're apt-get build-dep'ing
# python-lxml as part of getting gc2smwdaemon's virtualenv prepped
COPY sources.list.d/jessie-deb-src.list \
     /etc/apt/sources.list.d/jessie-deb-src.list

# Get stack up
RUN apt-get update && \
    apt-get -y install mysql-client apache2 curl php5 git php-pear \
    php5-mysql php5-pgsql libapache2-mod-php5 virtualenv cron freetds-bin \
    tdsodbc php5-odbc unixodbc odbcinst graphviz graphviz-dev imagemagick && \
    apt-get -y build-dep python-lxml

# Install MediaWiki
RUN cd /var/www/ && \
    curl https://releases.wikimedia.org/mediawiki/1.27/mediawiki-1.27.1.tar.gz \
    | tar xvzf - && \
    mv mediawiki-1.27.1 wiki && \
    chown -R root:root wiki
COPY mutables/LocalSettings.php /var/www/wiki/LocalSettings.php
COPY composer.local.json /var/www/wiki/composer.local.json
RUN chown www-data:www-data /var/www/wiki/images/

# Change $wgSecretKey and $wgUpgradeKey in LocalSettings.php
COPY scripts/myLocalSettings.sh /tmp/myLocalSettings.sh
RUN /tmp/myLocalSettings.sh $DBHOST $DBUSER $DBPASS $DBNAME && rm /tmp/myLocalSettings.sh

# seed MediaWiki
ADD scripts/initdb.sh db.sql /tmp/
RUN /tmp/initdb.sh $DBHOST $DBUSER $DBPASS $DBNAME && rm /tmp/initdb.sh /tmp/db.sql

# Install extensions
RUN cd /var/www/wiki/ && curl -sS https://getcomposer.org/installer | php && \
    cd /var/www/wiki/extensions/SyntaxHighlight_GeSHi/ &&\
       php /var/www/wiki/composer.phar update --no-dev &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/DataTransfer.git &&\
       cd DataTransfer &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/HeaderTabs.git &&\
       cd HeaderTabs &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/enterprisemediawiki/MasonryMainPage.git &&\
    cd MasonryMainPage &&\
       git checkout -q 9837244ccf70f3823e8f5366045e1637e65bd993 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/enterprisemediawiki/ImagesLoaded.git &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/wikimedia/mediawiki-extensions-EditUser.git &&\
       mv mediawiki-extensions-EditUser EditUser &&\
       cd EditUser &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/ExternalData &&\
       cd ExternalData &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/wikimedia/mediawiki-extensions-RevisionSlider.git &&\
       mv mediawiki-extensions-RevisionSlider RevisionSlider &&\
       cd  RevisionSlider &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/OdbcDatabase.git &&\
       cd OdbcDatabase &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/wikimedia/mediawiki-extensions-Maintenance.git &&\
       mv mediawiki-extensions-Maintenance Maintenance &&\
       cd Maintenance &&\
       git checkout -q REL1_27 &&\
    cd /var/www/wiki/extensions/ &&\
       git clone https://github.com/pjkersten/PlantUML.git &&\
    cd /var/www/wiki &&\
       /usr/bin/php /var/www/wiki/composer.phar update

# NaN logo. Just because.
COPY mutables/nanlogo.png /var/www/wiki/resources/assets/nanlogo.png

# We'll need php to accept bigger file uploads
RUN sed -i'' "s/upload_max_filesize = 2M/upload_max_filesize = 50M/" /etc/php5/apache2/php.ini &&\
    sed -i'' "s/post_max_size = 8M/post_max_size = 50M/" /etc/php5/apache2/php.ini

# der er en lille fejl i ODBC udvidelsen som skal fixes
# Se https://www.mediawiki.org/wiki/Extension:OdbcDatabase#Possible_code_changes
RUN sed -i'' "s/public static function getSoftwareLink/public function getSoftwareLink/" /var/www/wiki/extensions/OdbcDatabase/OdbcDatabase.body.php

# Vi skal bruge et par pear biblioteker
# Se https://github.com/JosefAssad/SeMaWi/issues/173
RUN /usr/bin/pear install Mail Net_SMTP

# We'll need a sysop/bureaucrat account
ADD scripts/makeadmin.sh /tmp/makeadmin.sh
RUN /tmp/makeadmin.sh && rm /tmp/makeadmin.sh

# Apache needs a virtualhost
ADD 001-semawi.conf /etc/apache2/sites-available/001-semawi.conf
RUN a2dissite 000-default && a2ensite 001-semawi

# Not always SOP, but for apache might need write permissions if debug is turned on for a file in the www dir for example
RUN chown -R www-data:www-data /var/www/wiki/images/

# Installing the GC2 daemon
COPY scripts/installgc2daemon.sh /opt/installgc2daemon.sh
COPY scripts/syncgc2.sh /opt/syncgc2.sh
COPY gc2 /opt/gc2
RUN sh /opt/installgc2daemon.sh

# Slim down the image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy over the apache wrapper
COPY scripts/apache2-foreground /usr/local/bin/

# Start up apache
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
env APACHE_PID_FILE    /var/run/apache2.pid
env APACHE_RUN_DIR     /var/run/apache2
env APACHE_LOCK_DIR    /var/lock/apache2
env APACHE_LOG_DIR     /var/log/apache2
env LANG               C
CMD ["/usr/local/bin/apache2-foreground"]
