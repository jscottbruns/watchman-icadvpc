#!/bin/bash
#
# hostsyncd        Startup script for the Apache HTTP Server
#
# chkconfig: 345 20 99
# description: Watchman HostSync Service is used to syncronize incidentes \
#              between HostSync client site and server.
# processname: hostsyncd
# pidfile: /var/run/hostsync.pid

# Source function library.
. /etc/init.d/functions

WATCHMAN_HOST=`hostname -a`
WATCHMAN_DIR=/var/lib/watchman
BIN_DIR=/usr/local/bin/watchman
pidfile=${PIDFILE-/var/run/hostsync.pid}
lockfile=${LOCKFILE-/var/lock/subsys/hostsyncd}
RETVAL=0

start() {
	echo -n "Starting Watchman HostSync Service: "
	PID=`pidof hostsyncd`
	if [ -n "$PID" ]; then
        echo "hostsyncd already running [ $PID ]"
        exit 2;
    else
    	cd $BIN_DIR
		daemon ./hostsyncd
		RETVAL=$?
		echo
		[ $RETVAL = 0 ] && touch ${lockfile}
		return $RETVAL
	fi
}
stop() {
	echo -n "Stopping Watchman HostSync Service "
	killproc hostsyncd
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${lockfile}
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status hostsyncd
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "Usage:  {start|stop|status|restart}"
        exit 1
        ;;
esac
exit $?
