#!/bin/bash

TARGET="/var/www/wiki/LocalSettings.php"
SED="/bin/sed"

# For $wgSecretKey in LocalSettings.php
WGSECRETKEY=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-64};echo;)
$SED -i'' "s/CHANGEWGSECRETKEY/$WGSECRETKEY/" $TARGET

# For $wgUpgradeKey in LocalSettings.php
WGUPGRADEKEY=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-16};echo;)
$SED -i'' "s/CHANGEWGUPGRADEKEY/$WGUPGRADEKEY/" $TARGET
