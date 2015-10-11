#!/bin/sh

GPIO_STRIKE_PIN=17
GPIO_STRIKE_PATH=/sys/class/gpio/gpio$GPIO_STRIKE_PIN

GPIO_DB_OPEN_PIN=27
GPIO_DB_OPEN_PATH=/sys/class/gpio/gpio$GPIO_DB_OPEN_PIN

GPIO_DB_CLOSE_PIN=22
GPIO_DB_CLOSE_PATH=/sys/class/gpio/gpio$GPIO_DB_CLOSE_PIN

cd "`dirname $0`"

init_door() {
	echo $GPIO_STRIKE_PIN > /sys/class/gpio/export
	echo $GPIO_DB_OPEN_PIN > /sys/class/gpio/export
	echo in > $GPIO_DB_OPEN_PATH/direction
	echo $GPIO_DB_CLOSE_PIN > /sys/class/gpio/export
	echo in > $GPIO_DB_CLOSE_PATH/direction
}

unlock_door() {
	echo out > $GPIO_STRIKE_PATH/direction
	echo 0 > $GPIO_STRIKE_PATH/value

	(
		echo out > $GPIO_DB_OPEN_PATH/direction
		echo 1 > $GPIO_DB_OPEN_PATH/value
		sleep 1
		echo in > $GPIO_DB_OPEN_PATH/direction
	) &
}

lock_door() {
	echo in > $GPIO_STRIKE_PATH/direction
}

access_denied() {
	echo Access Denied: $AUTH_DN

	# TODO: Log the incident.

	# Disable starting beep
	opensc-tool --send-apdu FF:00:52:00:00 > /dev/null 2> /dev/null

	# Beep three times with red LED to indicate failure
	# opensc-tool --send-apdu FF:00:40:5D:04:01:01:03:01 > /dev/null 2> /dev/null
	# sleep 1
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
done
