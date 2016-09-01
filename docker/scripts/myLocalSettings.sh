#!/bin/bash

# This script performs buildtime modifications to the LocalSettings.php file
# Which ships with SeMaWi. It takes 3 command line parameters:
# DB host, DB username, DB password

TARGET="/var/www/wiki/LocalSettings.php"
SED="/bin/sed"

# For $wgSecretKey in LocalSettings.php
WGSECRETKEY=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;)
$SED -i'' "s/CHANGEWGSECRETKEY/$WGSECRETKEY/" $TARGET

# For $wgUpgradeKey in LocalSettings.php
WGUPGRADEKEY=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;)
$SED -i'' "s/CHANGEWGUPGRADEKEY/$WGUPGRADEKEY/" $TARGET

# Database settings, obtained from --build-arg
$SED -i'' "s/CHANGEDBHOST/$1/" $TARGET
$SED -i'' "s/CHANGEDBUSER/$2/" $TARGET
$SED -i'' "s/CHANGEDBPASS/$3/" $TARGET
