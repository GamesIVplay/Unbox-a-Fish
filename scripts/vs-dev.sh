#!/bin/sh

set -e

# If Packages aren't installed, install them.
if [ ! -d "Packages" ]; then
    sh scripts/installPackages.sh
fi

# If network isn't compiled, compile it
if [ ! -d "network" ]; then
    sh scripts/blink.sh
fi

rojo serve default.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
