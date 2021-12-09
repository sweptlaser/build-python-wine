#!/bin/bash

echo "----------------- INSTALLING PY2EXE --------------"
"${WINE}" pip install py2exe

if [ "${INSTALL_CALLBACK}" != "" ] && [ -f "${INSTALL_CALLBACK}" ]; then
    # Place a build-callback.sh file in the same directory as the calling script to allow
    # customization to the WINEPREFIX or PYTHON_PROJECT just prior to build.  All environment
    # variables exported from this script are available to the callback.
    "${INSTALL_CALLBACK}"
fi
