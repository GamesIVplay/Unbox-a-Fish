#!/bin/sh

set -e

# If Packages aren't installed, install them.
if [ ! -d "Packages" ]; then
    sh scripts/installPackages.sh
fi

rojo sourcemap default.project.json -o sourcemap.json

rojo serve default.project.json
