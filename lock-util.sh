#!/bin/sh

LOCKFD=9;
_lock()             { flock -$1 $LOCKFD; }
_no_more_locking()  { _lock u; _lock xn && rm -f "${LOCKFILE}" || true; }
_prepare_locking()  { eval "exec $LOCKFD>\"${LOCKFILE}\""; trap _no_more_locking EXIT; }

lock() {
    export LOCKFILE="$1";
    _prepare_locking;
    echo "Waiting for '${LOCKFILE}' lock...";
    _lock x; # obtain an exclusive lock, wait if another instance is running
    echo "Lock obtained.";
}
unlock() {
    _no_more_locking
}
