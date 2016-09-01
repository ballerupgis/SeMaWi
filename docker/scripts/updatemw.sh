#!/bin/bash

echo "running update.php..."
php /var/www/wiki/maintenance/update.php && echo "update.php finished"
