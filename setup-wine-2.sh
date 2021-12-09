#!/bin/sh

echo "WINE = ${WINE}"
echo "WINEARCH = ${WINEARCH}"

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

WINETRICKS="${DIR}"/winetricks/src/winetricks
${WINETRICKS} win7 # create WinePrefix

. "${DIR}"/setup-wine-install-python.sh
. "${DIR}"/setup-wine-install-py2exe.sh
