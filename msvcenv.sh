#!/bin/bash

#
# Adapted from msvc-wine wrapper script file to our specific configuration
#

MSVCVER="14.30.30705"
SDKVER="10.0.19041.0"
ARCH=x64

BASE="c:\\msvc"
SDKBASE="${BASE}\\kits\\10"

MSVCDIR="$BASE\\vc\\tools\\msvc\\$MSVCVER"
SDKINCLUDE="$SDKBASE\\include\\$SDKVER"
SDKLIB="$SDKBASE\\lib\\$SDKVER"

export INCLUDE="$MSVCDIR\\include;$SDKINCLUDE\\shared;$SDKINCLUDE\\ucrt;$SDKINCLUDE\\um;$SDKINCLUDE\\winrt"
export LIB="$MSVCDIR\\lib\\$ARCH;$SDKLIB\\ucrt\\$ARCH;$SDKLIB\\um\\$ARCH"
export LIBPATH="$LIB"
export WINEPATH="${MSVCDIR}\\bin\\Hostx64\\${ARCH};${SDKBASE}\\bin\\${SDKVER}\\x64;${MSVCDIR}\\bin\\Hostx64\\x64"
