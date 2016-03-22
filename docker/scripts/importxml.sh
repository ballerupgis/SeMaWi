#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10

# Import SeMaWi elements
php /var/www/wiki/maintenance/importDump.php < /tmp/struktur.xml

