#!/usr/bin/env sh

docker run -d \
       --volume /srv/semawi/LocalSettings.php:/var/www/wiki/LocalSettings.php \
       --volume /srv/semawi/php.ini:/etc/php5/apache2/php.ini \
       --volume /srv/semawi/images/:/var/www/wiki/images/ \
       --volume /srv/semawi/nanlogo.png:/var/www/wiki/resources/assets/nanlogo.png \
       --volume /srv/semawi/gc2smw.cfg:/opt/gc2/gc2smw.cfg \
       --volume /srv/semawi/freetds.conf:/etc/freetds/freetds.conf \
       --volume /srv/semawi/odbcinst.ini:/etc/odbcinst.ini \
       --volume /srv/semawi/odbc.ini:/etc/odbc.ini \
       --name semawi-container \
       --hostname semawi-container \
       --publish 80:80 \
       semawi
