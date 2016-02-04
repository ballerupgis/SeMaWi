#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10

# Import SeMaWi elements
curl -o /tmp/struktur.xml https://raw.githubusercontent.com/JosefAssad/SeMaWi/4a468b3e8b1bd93c39e6d9bd3e7bad173d26b306/struktur.xml && php /var/www/wiki/maintenance/importDump.php < /tmp/struktur.xml && rm /tmp/struktur.xml
curl -o /tmp/kle-struktur.xml https://raw.githubusercontent.com/JosefAssad/SeMaWi/4a468b3e8b1bd93c39e6d9bd3e7bad173d26b306/KLE-struktur.xml && php /var/www/wiki/maintenance/importDump.php < /tmp/kle-struktur.xml && rm /tmp/kle-struktur.xml

