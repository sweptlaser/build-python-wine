#!/bin/sh
# WARNING: The Wine environment will get cleaned up when this script completes.

export SETUP_ARGS="bdist_wheel"
export BUILD_CALLBACK=""
export INSTALL_CALLBACK=""
export CHILD_BUILD="."
export WINEARCH="win64"
SHIFT=1
while [ "${SHIFT}" -ne "0" ]; do
    SHIFT=1;
    case "$1" in
        --32-bit) export WINEARCH="win32"; SHIFT=1;;
        --build-callback|-b) export BUILD_CALLBACK="$2"; SHIFT=2;;
        --child-build|-c) export CHILD_BUILD="$2"; SHIFT=2;;
        --install-callback|-i) export INSTALL_CALLBACK="$2"; SHIFT=2;;
        --setup-arguments|-s) export SETUP_ARGS="$2"; SHIFT=2;;
    *) SHIFT=0;;
    esac
    shift ${SHIFT};
done
PROJECT_PATH="$1"; shift $(($# > 0 ? 1 : 0));
DEST_PATH="$1"; shift $(($# > 0 ? 1 : 0));
if [ "${PROJECT_PATH}" = "" ] || [ "${DEST_PATH}" = "" ]; then
    echo "usage: $0 [OPTION...] PROJECT_PATH DEST_PATH"
    echo "\t-s, --setup-arguments 'arguments': passed to setup.py, assumed to be 'sdist bdist_wheel' when unset"
    exit 1
fi

# get the directory where this script lives
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

## Setup Wine environment
. "${DIR}"/setup-wine.sh

## Compile the project
echo "Building Python project...";
export PYTHON_PROJECT="${WINEPREFIX}"/python-project
cp -a "${PROJECT_PATH}" "${PYTHON_PROJECT}"/
cd "${PYTHON_PROJECT}"
# build customization callback
if [ "${BUILD_CALLBACK}" != "" ] && [ -f "${BUILD_CALLBACK}" ]; then
    "${BUILD_CALLBACK}"
fi
# build
cd "${CHILD_BUILD}"
eval "${WINE}" python setup.py ${SETUP_ARGS}
echo "Copying build artifacts...";
mkdir -p "${DEST_PATH}"
cp -a "${PYTHON_PROJECT}"/"${CHILD_BUILD}"/dist/* "${DEST_PATH}"/
cd - 2>/dev/null
echo "Python project build complete.";
