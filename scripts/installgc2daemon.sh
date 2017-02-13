#!/bin/bash

# This script installs the gc2 daemon. It leaves it deactivated but ready for
# action.

echo "Starting installation of GC2 sync script"

# Create a virtualenv to work with
/usr/bin/virtualenv /opt/gc2/

# Activate it so we can install dependencies from requirements.txt
. /opt/gc2/bin/activate
pip install -r /opt/gc2/requirements.txt
deactivate

# Do a merry dance
echo "Completed installation of GC2 sync script."
