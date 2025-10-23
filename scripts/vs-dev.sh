#!/bin/sh

set -e

# If network isn't compiled, exit
if [ ! -d "network" ]; then
    echo "Network folder missing. Exiting."
    exit 1
fi

# If Packages aren't installed, exit
if [ ! -d "Packages" ]; then
    echo "Packages folder missing. Exiting."
    exit 1
fi

rojo serve default.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
