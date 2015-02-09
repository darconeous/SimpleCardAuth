#!/bin/sh

access_denied() {
	echo Access Denied: $AUTH_DN
}

access_granted() {
	echo Access Granted: $AUTH_DN
}

verify_access() {
	# TODO: Look up and verify that $AUTH_DN has access to this zone!
	return 0
}

while true ;
do
	sleep 4
	if AUTH_DN=`./simple-card-auth.sh`
	then if verify_access
		then access_granted
		else access_denied
		fi
	else access_denied
	fi
done
