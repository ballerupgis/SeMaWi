#!/bin/bash

# This script installs the gc2 daemon. It leaves it deactivated but ready for
# action.

# Create a virtualenv to work with
virtualenv /opt/gc2/

# Activate it so we can install dependencies from requirements.txt
source /opt/gc2/bin/activate
pip install -r /opt/gc2/requirements.txt
deactivate

# Add cronjob
GC2_CMD='#0 5 * * * echo "source /opt/gc2/bin/activate; python /opt/gc2/gc2/gc2smwdaemon.py" | /bin/bash'
echo "$GC2_CMD" >> /var/spool/cron/crontabs/root

# Do a merry dance
echo "Completed installation of GC2 sync daemon."
