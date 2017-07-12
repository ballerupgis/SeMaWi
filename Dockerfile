FROM debian:stretch
MAINTAINER Josef Assad <josef@josefassad.com>
LABEL version="2017-01"

ENV DEBIAN_FRONTEND noninteractive

# We'll need the deb-src repositories since we're apt-get build-dep'ing
# python-lxml as part of getting gc2smwdaemon's dependencies
COPY sources.list.d/stretch-deb-src.list \
     /etc/apt/sources.list.d/stretch-deb-src.list

# Get stack up
RUN apt-get update && \
    apt-get -y install mysql-client apache2 curl php git php-pear php-mbstring \
    php-mysql php-pgsql libapache2-mod-php cron freetds-bin php-zip \
    zip unzip tdsodbc php-odbc unixodbc odbcinst graphviz graphviz-dev \
    imagemagick python3 && \
    apt-get -y build-dep python3-lxml

# Copy over the Mediawiki configs needed
RUN mkdir /etc/semawi/
COPY composer.local.json /etc/semawi/composer.local.json
COPY db.sql /etc/semawi/db.sql
ADD 001-semawi.conf /etc/apache2/sites-available/001-semawi.conf

# Installing the GC2 daemon
RUN curl -s https://bootstrap.pypa.io/get-pip.py > /tmp/get-pip.py
RUN python3 /tmp/get-pip.py
COPY gc2 /opt/gc2
RUN /usr/local/bin/pip3 install -r /opt/gc2/requirements.txt
RUN cp /opt/gc2/gc2smwdaemon.py /usr/local/bin/gc2smwdaemon.py

# Slim down the image
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy over the apache wrapper
COPY scripts/entrypoint.sh /usr/local/bin/

# Start up apache
env APACHE_RUN_USER    www-data
env APACHE_RUN_GROUP   www-data
env APACHE_PID_FILE    /var/run/apache2.pid
env APACHE_RUN_DIR     /var/run/apache2
env APACHE_LOCK_DIR    /var/lock/apache2
env APACHE_LOG_DIR     /var/log/apache2
env LANG               C
CMD ["/usr/local/bin/entrypoint.sh"]
