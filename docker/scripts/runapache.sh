#!/bin/sh

# This script runs apache and makes sure logs are spat out for our perusal

source /etc/apache2/envvars
tail -F /var/log/apache2/error.log /var/log/apache2/access.log &
exec /usr/sbin/apache2ctl -D FOREGROUND
