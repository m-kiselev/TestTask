#!/bin/bash

NAME=test-task
PID=/var/run/$NAME.pid
LOCK=/var/lock/subsys/$NAME
APPJAR='/lib/TestTask.jar'

#=== FUNCTION ================================================================
#        NAME: checkRootRight
# DESCRIPTION: Check - this script must run as root
#=============================================================================
checkRootRight()
{
    local user=`whoami`
    if [ "$user" != "root" ] ; then
        echo
        echo "ERROR: This script must be run as the root user or by using sudo!"
        echo
        exit 1
    fi
}

#=== FUNCTION ================================================================
#        NAME: status
# DESCRIPTION: Display current status
#=============================================================================
status()
{
	echo "Status of $NAME..."

	if [ -s $PID ]; then
		pid=`cat $PID`
		kill -0 $pid > /dev/null 2>&1
		RET=$?
		if [ $RET -eq 0 ]; then
			echo -en '\E[32;40m\033[1m[Running]\033[0m'
			tput sgr0
		else
			echo -en '\E[32;40m\033[1m[Stopped]\033[0m'
			tput sgr0
		fi	
	else
		echo -en '\E[33;40m\033[1m[Not running]\033[0m'
		tput sgr0
	fi
	
	echo
	return $RET
}

#=== FUNCTION ================================================================
#        NAME: start
# DESCRIPTION: Start service
#=============================================================================
start()
{
	if [ -z '$JAVA_HOME' ]; then
		echo "no JDK found - please set JAVA_HOME"
		exit 1
    fi

    echo "Starting $NAME..."
	if [ -s $PID ]; then
		echo -en '\E[33;40m\033[1m[Is Running, Try to restart]\033[0m'
		tput sgr0
	else
	    java -jar $APPJAR & 
	    echo $! >$PID
	 
	    RET=$?
	    if [ $RET -eq 0 ]; then
	        touch $LOCK >/dev/null 2>&1
		sleep 1
	 	echo -en '\E[32;40m\033[1m[Done]\033[0m'
		tput sgr0
	    else
		echo -en '\E[31;40m\033[1m[Error]\033[0m'
		tput sgr0
	    fi
	fi

	echo
        return $RET
}

#=== FUNCTION ================================================================
#        NAME: stop
# DESCRIPTION: Stop service
#=============================================================================
stop()
{
       echo "Stopping $NAME..."
       if [ -s $PID ]; then

	    STOPTIMEOUT=10
	    while [ $STOPTIMEOUT -gt 0 ]; do
	    	/bin/kill `cat $PID` >/dev/null 2>&1 
		RET=$?

		echo -n .
	    	sleep 1
	    	let STOPTIMEOUT=${STOPTIMEOUT}-1

		if [ $RET -eq 0 ]; then
		     break
		fi
	    done

	    rm -f $LOCK 
	    RET=$?
	    if [ $RET -ne 0 ]; then
		echo -en '\E[31;40m\033[1m[Error remove lock file "$LOCK"]\033[0m'
		tput sgr0
            fi

	    rm -f $PID 
	    RET=$?
	    if [ $RET -ne 0 ]; then
		echo -en '\E[31;40m\033[1m[Error remove pid file "$PID"]\033[0m'
		tput sgr0
	    fi

	    echo -en '\E[32;40m\033[1m[Done]\033[0m'
            tput sgr0
        else
	        echo -en '\E[33;40m\033[1m[Not Running]\033[0m'
            tput sgr0
	        RET=0
        fi
	
       echo 
       return $RET
}

#=== FUNCTION ================================================================
#        NAME: restart
# DESCRIPTION: Restart service
#=============================================================================
restart()
{
	if [ -f "$PID" ]; then
		stop
	else 
		echo -en '\E[33;40m\033[1m[Not Running]\033[0m'
        tput sgr0
	fi
    start
}

###############################################################################
## MAIN
###############################################################################
checkRootRight

case "$1" in
'start')
        start
        ;;
'stop')
        stop
        ;;
'restart')
        restart
        ;;
'status')
        status
        ;;
*)
        echo "Usage: $0 { start | stop | restart | status }"
        ;;
esac

exit $RET

