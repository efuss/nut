#!/sbin/sh

#
# nut-upsmon: NUT ups monitor start-up and shutdown script
#

# Allowed exit values:
#       0 = success; causes "OK" to show up in checklist.
#       1 = failure; causes "FAIL" to show up in checklist.
#       2 = skip; causes "N/A" to show up in the checklist.
#           Use this value if execution of this script is overridden
#           by the use of a control variable, or if this script is not
#           appropriate to execute for some other reason.
#       3 = reboot; causes the system to be rebooted after execution.

# Input and output:
#       stdin is redirected from /dev/null
#
#       stdout and stderr are redirected to the /etc/rc.log file
#       during checklist mode, or to the console in raw mode.

umask 022

PATH=/usr/sbin:/usr/bin:/sbin
export PATH

WHAT='NUT UPS monitor (Network UPS Tools -- http://www.exploits.org/nut)'
WHAT_PATH=/opt/nut/sbin/upsmon
WHAT_CONFIG=/etc/rc.config.d/nut-upsmon

# NOTE: If your script executes in run state 0 or state 1, then /usr might
#       not be available.  Do not attempt to access commands or files in
#       /usr unless your script executes in run state 2 or greater.  Other
#       file systems typically not mounted until run state 2 include /var
#       and /opt.

rval=0

# Check the exit value of a command run by this script.  If non-zero, the
# exit code is echoed to the log file and the return value of this script
# is set to indicate failure.

set_return() {
	x=$?
	if [ $x -ne 0 ]; then
		echo "EXIT CODE: $x"
		rval=1	# script FAILed
	fi
}

case $1 in
'start_msg')
	echo "Starting $WHAT"
	;;

'stop_msg')
	echo "Stopping $WHAT"
	;;

'start')
	if [ -f $WHAT_CONFIG ] ; then
		. $WHAT_CONFIG
	else
		echo "ERROR: $WHAT_CONFIG defaults file MISSING"
	fi
	

	if [ "$NUT_START" -eq 1 -a -x $WHAT_PATH ]; then
		 $WHAT_PATH $UPSMON_ARGS && echo $WHAT $UPSMON_ARGS started
		set_return
	else
		rval=2
	fi
	;;

'stop')
	$WHAT_PATH -c stop
	if [ $? -eq 0 ]; then
		echo "$WHAT stopped"
	else
		rval=1
		echo "Unable to stop $WHAT"
	fi
	;;

*)
	echo "usage: $0 {start|stop|start_msg|stop_msg}"
	rval=1
	;;
esac

exit $rval
