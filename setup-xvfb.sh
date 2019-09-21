#!/bin/sh

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd);
xvfb-run -a "${DIR}"/setup-xvfb-2.sh "${WINEPREFIX}" "$$" &
sleep 5
export DISPLAY=$(cat "${WINEPREFIX}"/.DISPLAY)
export XAUTHORITY=$(cat "${WINEPREFIX}"/.XAUTHORITY)
