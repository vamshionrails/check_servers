#!/bin/bash
# Script to check firewall connectivity.

if [ "$1" = "" ]; then
	echo "Host and port(s) to check required."
	echo "`basename $0` <hostname> <portlist>"
	echo "`basename $0` host.domain.com 22,80,443,8080"
	exit;
fi

if [ "$2" = "" ]; then
	echo "Port(s) to check required."
	echo "`basename $0` <hostname> <portlist>"
	echo "`basename $0` host.domain.com 22,80,443,8080"
	exit;
fi

fqdn=${1}

# host.domain.com get the hostname for ansible host resolution
#host=`echo ${fqdn} | awk -F. '{ print $1 }'`

host=`echo ${fqdn} | awk -F. '{ print }'`
# ports assumed in a comma separated list (no space) 22,80,44,8080
ports=${2}

# log stderr, stdout to $logfile
logfile=./check_ports.log
exec 3>&1 1>>${logfile} 2>&1

# turn off globbing for breaking up port list. Set fieldspace character to ",".
set -f; IFS=,

# loop through list of ports
for port in ${ports}; do

	# call netcat to scan for daemon listening on port
	if ! nc -w 1 -z ${fqdn} ${port} 2>/dev/null ; then
	    echo "${host}:${port}  - CLOSED" | tee /dev/fd/3  
		case ${port} in
			# restarting sshd
			22)
				#ansible ${host} -m service -a "name=sshd state=restarted"
				#echo "${host}:${port} RESTARTED" | tee /dev/fd/3
			;;
			# restarting web app
			80,443,8080)
				#ansible ${host} -m service -a "name=httpd state=restarted"
				#echo "${host}:${port} RESTARTED" | tee /dev/fd/3
			;;
		esac
	else
		echo "${host}:${port} - OPENED" | tee /dev/fd/3
	fi
done
# reset globbing and fieldspace char.
set =f; unset IFS

