#!/bin/sh

GPIO_PIN=17
GPIO_PATH=/sys/class/gpio/gpio$GPIO_PIN

cd "`dirname $0`"

init_door() {
	echo $GPIO_PIN > /sys/class/gpio/export
}

unlock_door() {
	echo out > $GPIO_PATH/direction
	echo 0 > $GPIO_PATH/value
}

lock_door() {
	echo in > $GPIO_PATH/direction
}

access_denied() {
	echo Access Denied: $AUTH_DN

	# TODO: Log the incident.

	# Beep three times with red LED to indicate failure
	opensc-tool --send-apdu FF:00:40:5D:04:01:01:03:01 > /dev/null 2> /dev/null

	# Disable starting beep
	opensc-tool --send-apdu FF:00:52:00:00 > /dev/null 2> /dev/null

}

access_granted() {
	echo Access Granted: $AUTH_DN

	unlock_door

	# Beep once with green LED to indicate success
	opensc-tool --send-apdu FF:00:40:2E:04:01:01:01:01 > /dev/null 2> /dev/null

	# Disable starting beep
	opensc-tool --send-apdu FF:00:52:00:00 > /dev/null 2> /dev/null

	sleep 4

	lock_door
}

verify_access() {
	# TODO: Look up and verify that $AUTH_DN has access to this zone!
	true
}

init_door

echo Starting Auth Loop

# Main access control loop
while true ;
do
	lock_door
	if AUTH_DN=`./simple-card-auth.sh`
	then if verify_access
		then access_granted
		else access_denied
		fi
	else access_denied
	fi
	sleep 3
done
