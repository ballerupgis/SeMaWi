#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10

# We'll need a Sysop/Beaureaucrat
echo "Creating user SeMaWi..."
php /var/www/wiki/maintenance/createAndPromote.php --bureaucrat --sysop SeMaWi SeMaWiSeMaWi
