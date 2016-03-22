#!/bin/bash

/usr/bin/mysqld_safe &

sleep 10

# First we need the mediawiki tables
mysql -u root -pwiki -e "CREATE DATABASE wiki"
mysql -u root -pwiki -e "GRANT ALL PRIVILEGES ON wiki.* To 'wiki'@'%' IDENTIFIED BY 'wiki';"
mysql -u root -pwiki wiki < /var/www/wiki/maintenance/tables.sql

