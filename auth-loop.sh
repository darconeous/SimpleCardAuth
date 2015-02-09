#!/bin/sh

access_denied() {
	echo Access Denied: $AUTH_DN
}

access_granted() {
	echo Access Granted: $AUTH_DN
}


while true ;
do
	sleep 4
	if AUTH_DN=`./simple-card-auth.sh`
	then access_granted
	else access_denied
	fi
done
