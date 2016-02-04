#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10
echo "running update.php..."
php /var/www/wiki/maintenance/update.php && echo "update.php finished"
