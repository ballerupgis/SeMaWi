#!/bin/bash

# This script expects 4 command line parameters: DB host, user, pass, and db name

# The extensions will probably be expecting a functional MW installation, so...
mysql -h $1 -u $2 -p$3 $4 < /tmp/db.sql

