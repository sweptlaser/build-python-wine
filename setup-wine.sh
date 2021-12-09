#!/bin/sh
# WARNING: make sure that you _source_ this script and do not run it directly. Otherwise the Wine
# environment will get cleaned up when this script completes.

# get the directory where this script lives
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "${DIR}"/lock-util.sh

export WINEPREFIX=$(mktemp -d -t build-py.XXXXXXXXXX);
export WINEDLLOVERRIDES="mscoree=n;mshtml=";
export WINE=$(which wine);
# we use Xvfb to work around an issue where the Python installer will not run headlessly
. "${DIR}"/setup-xvfb.sh "${WINEPREFIX}"

SCRIPTS_TO_HASH=$(echo "\
  ${DIR}/setup-wine-2.sh \
  ${DIR}/setup-wine-install-python.sh \
  ${DIR}/setup-wine-install-py2exe.sh\
  ")

SCRIPT_HASH=$(echo "${SCRIPTS_TO_HASH}" | xargs cat  | md5sum - | cut -d' ' -f 1)
CALLBACK_HASH=$(md5sum "${INSTALL_CALLBACK}" 2>/dev/null | cut -d' ' -f 1)
WINECACHE="${HOME}"/.wine-build-py_${SCRIPT_HASH}-${CALLBACK_HASH}-${WINEARCH}
lock "${WINECACHE}.lock"
echo "Setting up Wine environment...";
if [ -d "${WINECACHE}" ]; then
    cp -a "${WINECACHE}"/* "${WINEPREFIX}"/
else
    "${DIR}"/setup-wine-2.sh
    mkdir -p "${WINECACHE}"
    cp -a "${WINEPREFIX}"/* "${WINECACHE}"/
fi
unlock
echo "Opening Wine environment...";
"${WINE}boot" -i;
cleanup_wine()
{
	## Cleanup Wine environment
	"${WINE}boot" -ef;
	sleep 1;
	"${WINE}boot" -ek;
	sleep 1;
	rm -Rf "${WINEPREFIX}" || true;
	rm -Rf "${WINEPREFIX}";
}
trap cleanup_wine EXIT;

