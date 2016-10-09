#!/bin/bash

# This script expects 3 command line parameters: DB host, user, and pass

# The extensions will probably be expecting a functional MW installation, so...
mysql -h $1 -u $2 -p$3 wiki < /tmp/db.sql

