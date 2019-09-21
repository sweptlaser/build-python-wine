#!/bin/sh

TMPFOLDER="$1";
PID="$2";

echo ${DISPLAY} > "${TMPFOLDER}"/.DISPLAY
echo ${XAUTHORITY} > "${TMPFOLDER}"/.XAUTHORITY
tail --pid=${PID} -f /dev/null
