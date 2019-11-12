#!/bin/sh

BUILDTOOLS_INSTALLER_URL="http://download.microsoft.com/download/5/F/7/5F7ACAEB-8363-451F-9425-68A90F98B238/visualcppbuildtools_full.exe";

# Python 3.7.3
if [ "${WINEARCH}" = "win32" ]; then
    PYTHON_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Windows-x86.exe";
else
    PYTHON_INSTALLER_URL="https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Windows-x86_64.exe";
fi
# py2exe 0.9.3.1
if [ "${WINEARCH}" = "win32" ]; then
    PY2EXE_INSTALLER_URL="https://github.com/albertosottile/py2exe/releases/download/v0.9.3.1/py2exe-0.9.3.1-cp37-none-win32.whl"
else
    PY2EXE_INSTALLER_URL="https://github.com/albertosottile/py2exe/releases/download/v0.9.3.1/py2exe-0.9.3.1-cp37-none-win_amd64.whl"
fi

## Download Python
PYTHON_INSTALLER=$(echo "${PYTHON_INSTALLER_URL}" | sed "s|^.*/|${CACHEDIR}/|");
if [ ! -f "${PYTHON_INSTALLER}" ]; then
    mkdir -p "${CACHEDIR}" 2>/dev/null || true;
    wget "${PYTHON_INSTALLER_URL}" -O "${PYTHON_INSTALLER}";
fi

## Download py2exe
PY2EXE_INSTALLER=$(echo "${PY2EXE_INSTALLER_URL}" | sed "s|^.*/|${CACHEDIR}/|");
if [ ! -f "${PY2EXE_INSTALLER}" ]; then
    mkdir -p "${CACHEDIR}" 2>/dev/null || true;
    wget "${PY2EXE_INSTALLER_URL}" -O "${PY2EXE_INSTALLER}";
fi

## Download Visual C++ Build Tools
# MS does not contain a version number in their executable *sigh*
BUILDTOOLS_INSTALLER=$(echo "${BUILDTOOLS_INSTALLER_URL}" | sed "s|^.*/\([^/]*\)/.*|${CACHEDIR}/\1.exe|");
if [ ! -f "${BUILDTOOLS_INSTALLER}" ]; then
    mkdir -p "${CACHEDIR}" 2>/dev/null || true;
    wget "${BUILDTOOLS_INSTALLER_URL}" -O "${BUILDTOOLS_INSTALLER}";
fi

# get the directory where this script lives
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
echo "Creating fresh Wine environment...";
"${WINE}boot" -i;
cleanup_wine()
{
	## Wait for Wine to finish running and save the prefix
	"${WINE}boot" -ef;
	sleep 10;
	"${WINE}boot" -ek;
	sleep 10;
	"${WINE}server" -w
}
trap cleanup_wine EXIT;

## Install .NET
WINETRICKS="${DIR}"/winetricks/src/winetricks
"${WINETRICKS}" -q dotnet452
"${WINETRICKS}" win7

version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

## Install MSVC Build Tools
# launch the installer
"${WINE}" "${BUILDTOOLS_INSTALLER}" /Quiet &
PID=$!
WINE_VERSION=$("${WINE}" --version | sed 's/wine-\([0-9\.]*\).*/\1/')
if version_gt "5.0" "${WINE_VERSION}"; then
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
fi
# wait for the installer to finish
wait $PID

## Install Python
"${WINE}" "${PYTHON_INSTALLER}" /S /RegisterPython=1 /AddToPath=1
export WINE_PYTHON_PATH=$("${WINE}" python -c 'import os; import sys; print(os.path.dirname(sys.executable));' 2>/dev/null | tr --delete '\r\n');
export PYTHON_PATH=$(echo "${WINEPREFIX}/${WINE_PYTHON_PATH}" | sed -e 's|C:|drive_c|' -e 's|\\|/|g');

## Work around wine missing "chcp" (change codepage)
if [ ! -f "${WINEPREFIX}"/drive_c/windows/system32/chcp.com ]; then
    echo "#!/bin/bash" > "${WINEPREFIX}"/drive_c/windows/system32/chcp.com
    chmod +x "${WINEPREFIX}"/drive_c/windows/system32/chcp.com
    if [ "${WINEARCH}" != "win32" ]; then
        echo "#!/bin/bash" > "${WINEPREFIX}"/drive_c/windows/syswow64/chcp.com
        chmod +x "${WINEPREFIX}"/drive_c/windows/syswow64/chcp.com
    fi
fi

## Setup all the Python packages that we need for common builds
DEPENDENCIES="\
    python=3.7 \
    boost=1.68.0 \
    numpy=1.15.4 \
    cython=0.29.13 \
    pkgconfig=1.3.1 \
    python-dateutil=2.8.0 \
";
"${WINE}" conda install -y -c conda-forge ${DEPENDENCIES}
DEPENDENCIES="\
    scipy=1.3.1 \
";
"${WINE}" conda install -y ${DEPENDENCIES}

## Setup py2exe for building executables
# Note: these fixes need to get pushed upstream
"${WINE}" pip install "${PY2EXE_INSTALLER}"
patch -d "${WINEPREFIX}"/drive_c/ProgramData/Miniconda3/Lib/site-packages/py2exe/ -p0 --binary -i "${DIR}"/py2exe.diff

if [ "${INSTALL_CALLBACK}" != "" ] && [ -f "${INSTALL_CALLBACK}" ]; then
    # Place a build-callback.sh file in the same directory as the calling script to allow
    # customization to the WINEPREFIX or PYTHON_PROJECT just prior to build.  All environment
    # variables exported from this script are available to the callback.
    "${INSTALL_CALLBACK}"
fi
