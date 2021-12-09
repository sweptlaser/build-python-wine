#!/bin/bash

version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

## Download Visual C++ Build Tools
# MS does not contain a version number in their executable *sigh*
BUILDTOOLS_INSTALLER_URL="http://download.microsoft.com/download/5/F/7/5F7ACAEB-8363-451F-9425-68A90F98B238/visualcppbuildtools_full.exe";

BUILDTOOLS_INSTALLER=$(echo "${BUILDTOOLS_INSTALLER_URL}" | sed "s|^.*/\([^/]*\)/.*|${CACHEDIR}/\1.exe|");
if [ ! -f "${BUILDTOOLS_INSTALLER}" ]; then
    mkdir -p "${CACHEDIR}" 2>/dev/null || true;
    wget "${BUILDTOOLS_INSTALLER_URL}" -O "${BUILDTOOLS_INSTALLER}";
fi

## Install MSVC Build Tools
# launch the installer
echo "-------------- MSVC BUILD TOOLS ---------------"
"${WINE}" "${BUILDTOOLS_INSTALLER}" /Quiet &
PID=$!
WINE_VERSION=$("${WINE}" --version | sed 's/wine-\([0-9\.]*\).*/\1/')
#if version_gt "5.0" "${WINE_VERSION}"; then
    # wait for the installer to get to where it attempts to create a system restore point
    sleep 180 # TODO: wait by watching for svchost.exe instead of three minute constant delay ?
    echo "*****************************************************"
    echo "info proc" | "${WINE}" winedbg
    echo "*****************************************************"
    SVCHOST_PID=$(printf "%d\n" 0x0$(echo "info proc" | "${WINE}" winedbg | grep "'svchost.exe'" | cut -d' ' -f 2))
    echo "*****************************************************"
    echo "SVCHOST_PID: ${SVCHOST_PID}"
    echo "*****************************************************"
    printf "attach ${SVCHOST_PID}\nkill\n" | "${WINE}" winedbg
#fi
# wait for the installer to finish
wait $PID
