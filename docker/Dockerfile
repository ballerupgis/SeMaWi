# BUILD-USING:        docker build -t semawi -f docker/Dockerfile .
# RUN-USING:          docker run  -d --name semawi-container -h semawi-container -p 12345:80 semawi
# INSPECT-USING:      docker run -t -i semawi-container /bin/bash

FROM debian:jessie
MAINTAINER Josef Assad <josef@josefassad.com>
LABEL version="2016-01"

ENV DEBIAN_FRONTEND noninteractive

# We'll need the deb-src repositories since we're apt-get build-dep'ing python-lxml
# as part of getting gc2smwdaemon's virtualenv prepped
COPY docker/sources.list.d/jessie-deb-src.list /etc/apt/sources.list.d/jessie-deb-src.list

# Get stack up
RUN echo 'mysql-server mysql-server/root_password password wiki' | debconf-set-selections && echo 'mysql-server mysql-server/root_password_again password wiki' | debconf-set-selections && apt-get update && apt-get -y install mysql-server mysql-client apache2 curl php5 supervisor git php5-mysql libapache2-mod-php5 virtualenv cron && apt-get -y build-dep python-lxml

# Install MediaWiki
RUN cd /var/www/ && curl https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz | tar xvzf - && mv mediawiki-1.26.2 wiki && chown -R root:root wiki
COPY docker/LocalSettings.php /var/www/wiki/LocalSettings.php

# Change $wgSecretKey and $wgUpgradeKey in LocalSettings.php
COPY docker/scripts/gensecrets.sh /tmp/gensecrets.sh
RUN /tmp/gensecrets.sh && rm /tmp/gensecrets.sh

# seed MediaWiki
ADD docker/scripts/initdb.sh /tmp/initdb.sh
RUN /tmp/initdb.sh && rm /tmp/initdb.sh

# Install extensions
RUN cd /var/www/wiki/ && curl -sS https://getcomposer.org/installer | php && \
    cd /var/www/wiki/extensions/ && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/ImportUsers.git && cd ImportUsers && git checkout -q REL1_26 && \
    cd /var/www/wiki/extensions/ && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/DataTransfer.git && cd DataTransfer && git checkout -q REL1_26 && \
    cd /var/www/wiki/extensions/ && git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/HeaderTabs.git && cd HeaderTabs && git checkout -q REL1_26 && \
    cd /var/www/wiki/ && php composer.phar require mediawiki/semantic-media-wiki "~2.1" --update-no-dev && \
    cd /var/www/wiki/extensions/ && git clone https://git.wikimedia.org/git/mediawiki/extensions/SemanticForms.git && cd SemanticForms && \
    cd /var/www/wiki/extensions/ && git clone https://git.wikimedia.org/git/mediawiki/extensions/SemanticFormsInputs.git && \
    cd /var/www/wiki/ && php composer.phar require mediawiki/semantic-result-formats "2.3.*" --update-no-dev && \
    cd /var/www/wiki/extensions/ && git clone https://github.com/enterprisemediawiki/MasonryMainPage.git && \
    cd /var/www/wiki/ && php composer.phar require mediawiki/chameleon-skin "1.*" --update-no-dev
ADD docker/scripts/updatemw.sh /tmp/updatemw.sh
RUN /tmp/updatemw.sh && rm /tmp/updatemw.sh

# NaN logo. Just because.
COPY docker/nanlogo.png /var/www/wiki/resources/assets/nanlogo.png

# We'll need a susop/bureaucrat account
ADD docker/scripts/makeadmin.sh /tmp/makeadmin.sh
RUN /tmp/makeadmin.sh && rm /tmp/makeadmin.sh

# Apache needs a virtualhost
ADD docker/001-semawi.conf /etc/apache2/sites-available/001-semawi.conf
RUN a2dissite 000-default && a2ensite 001-semawi

# Not always SOP, but for apache might need write permissions if debug is turned on for a file in the www dir for example
RUN chown -R www-data:www-data /var/www/wiki/images/

# Expose the few files we want to be mutable in a volume
VOLUME /var/www/wiki/

# Import SeMaWi XML and KLE XML
COPY struktur.xml /tmp/struktur.xml
COPY KLE/KLE-struktur.xml /tmp/KLE-struktur.xml
COPY docker/scripts/importxml.sh /tmp/importxml.sh
RUN /tmp/importxml.sh && rm /tmp/struktur.xml /tmp/KLE-struktur.xml /tmp/importxml.sh

# Installing the GC2 daemon
COPY docker/scripts/installgc2daemon.sh /tmp/
COPY gc2 /opt/gc2
RUN /tmp/installgc2daemon.sh && rm /tmp/installgc2daemon.sh

# Slim down the image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start up services
ADD docker/my.cnf /etc/mysql/my.cnf
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]
