#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10

# We'll need a Sysop/Beaureaucrat
echo "Creating user SeMaWi..."
php /var/www/wiki/maintenance/createAndPromote.php --force --bureaucrat --sysop SeMaWi SeMaWiSeMaWi

# We'll need a bot for the GC2 sync
echo "Creating user Sitebot..."
php /var/www/wiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --bot Sitebot SitebotSitebot
