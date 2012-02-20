#!/bin/sh
#
#	Start Stop Restart script for CrossLight
#	Andrew Niemantsverdriet

#Set the root directory to be where the script is run from
ROOTDIR="`pwd`"

PORT=3000
ALL=
LOGS=( "big-static.log" "big-static.error.log" "big-jefri.log" "big-jefri.error.log" "big-scheduler.log" "big-scheduler.error.log" "big-reports.log" "big-reports.error.log" "big-stream.log" "big-stream.error.log" "big-legacy.log" "big-legacy.error.log" )

ACT=$1
shift

usage()
{
	echo "$0: Crosslight Cross-platform PHP development environment."
	echo "Usage:"
	echo "	$0 {start|restart|debug} [-p port]	Start, and optionally choose port."
	echo "	$0 stop [-a]	Stop crosslight. -a force-kills all running instances."
	echo "	$0 status	Print status info about Crosslight."
}

#Parse Arguments
while getopts "ap:" OPT ; do
    case $OPT in
        h) usage; exit 1 ;;
        p) PORT=$OPTARG ;;
        a) ALL="ALL" ;;
    esac
done

findport()
{
	#Find available Port
	netstat --tcp --listening --numeric-hosts --numeric-ports | awk '{print $4}' | grep ":$PORT " 2>&1 > /dev/null
	AVAIL=$?
	while [ $AVAIL -eq 0 ] ; do
		PORT=$(($PORT + 1))
		netstat --tcp --listening --numeric-hosts --numeric-ports | awk '{print $4}' | grep ":$PORT " 2>&1 > /dev/null
		AVAIL=$?
	done
}

case "$ACT" in
	start)
		#Make sure our logs are good.
		for i in "${LOGS[@]}"
		do
			touch $ROOTDIR/var/log/$i
			chown crosslight:crosslight $ROOTDIR/var/log/$i
			chmod 640 $ROOTDIR/var/log/$i
		done

		if [ -e $ROOTDIR/var/tmp/lighttpd.pid ]
		then
				echo "CrossLight is already running"
				$ROOTDIR/crosslight.sh stop
				$ROOTDIR/crosslight.sh start
		else
#			findport
#			echo "rootdir = \"$ROOTDIR\"" > $ROOTDIR/etc/lighttpd.conf.local
#			echo "server.port = $PORT" >> $ROOTDIR/etc/lighttpd.conf.local
			$ROOTDIR/bin/lighttpd -f $ROOTDIR/etc/lighttpd.conf -m ./bin/lib/
			echo "CrossLight started"
		fi
	;;

	stop)
		if [ -e $ROOTDIR/var/tmp/lighttpd.pid ]
		then
			if [ -e $ROOTDIR/var/tmp/lighttpd.pid ]
			then
				kill `cat var/tmp/lighttpd.pid` 2>&1 > /dev/null
				`rm -f $ROOTDIR/var/tmp/lighttpd.pid`
				echo "CrossLight has been stopped"
			fi
			else echo "CrossLight not currently running"
#			if [ "$ALL" = "ALL" ]
#			then
#				killall lighttpd
#				echo "Force-killed all lighttpds."
#				echo "If a different lighttpd was open, its pid did not get cleaned up."
#				echo "If you run a different crosslight install, and get 'already running'"
#				echo "you will need to run ./crosslight.sh stop or ./crosslight.sh restart."
#			fi
		fi
	;;

	status)
		if [ -e $ROOTDIR/var/tmp/lighttpd.pid ]
			then echo "CrossLight is running"
			else echo "CrossLight is stopped"
		fi
	;;

	 debug)
		if [ -e $ROOTDIR/var/tmp/lighttpd.pid ]
			then echo "CrossLight is running, stop first before running in debug mode"
		else
#			findport
#			echo "rootdir = \"$ROOTDIR\"" >| $ROOTDIR/etc/lighttpd.conf.local
#			echo "include \"lighttpd.debug.conf\"" >> $ROOTDIR/etc/lighttpd.conf.local
#			echo "server.port = $PORT" >> $ROOTDIR/etc/lighttpd.conf.local
			echo "CrossLight debugging at localhost:$PORT"
			$ROOTDIR/bin/lighttpd -D -f $ROOTDIR/etc/lighttpd.conf -m ./bin/lib/
		fi
	;;

	restart)
		$ROOTDIR/crosslight.sh stop
		$ROOTDIR/crosslight.sh start
	;;

	*)
		usage
		exit 1
esac

