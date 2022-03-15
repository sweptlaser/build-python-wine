#!/bin/bash

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

## Install MSVC Build Tools
echo "-------------- MSVC BUILD TOOLS ---------------"
PYTHONUNBUFFERED=1 python3 "${DIR}"/msvc-wine/vsdownload.py --accept-license --major=17 --msvc-version="17.0" --dest "${WINEPREFIX}"/drive_c/msvc
