#!/bin/sh

validate_pidfile() 
{
	local pid
	local pspid
	if [ -f /var/run/xupnpd.pid ]; then
		pid=$(cat /var/run/xupnpd.pid)
		pspid=$(ps -p $pid --no-headers)
		if [ -z "$pspid" ]; then
			/bin/rm /var/run/xupnpd.pid
		fi
	fi
}

wait_for_webif()
{
	local cnt=10
	netstat -lnt | grep -wq :80
	local success=$?
	until [ $cnt -eq 0 -o $success -eq 0 ]
	do
		sleep 2
		netstat -lnt | grep -wq :80
		success=$?
		cnt=$((cnt-1))
	done
}

case $1 in
start)  
	validate_pidfile
        if [ -e /etc/xupnpd.lua ]; then
        	wait_for_webif
                /usr/bin/xupnpd
        fi
        ;;
stop)
        if [ -e /etc/xupnpd.lua ]; then
                killall -qw xupnpd
        fi
	validate_pidfile
        ;;
restart)
        if [ -e /etc/xupnpd.lua ]; then
                killall -qw xupnpd
                validate_pidfile
                /usr/bin/xupnpd
        fi
        ;;
status)
	running=$(pidof xupnpd)
	if [ -n "$running" ]; then
		echo "xupnpd (pid $running) is running..."
		exit 0
	else
		echo "xupnpd is stopped"
	fi
	exit 3
	;;
	
esac
