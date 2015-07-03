#!/bin/sh

GPIO_PIN=17

GPIO_PATH=/sys/class/gpio/gpio$GPIO_PIN

access_denied() {
	echo Access Denied: $AUTH_DN

	# TODO: Log the incident.

	# Beep three times with red LED to indicate failure
	opensc-tool --send-apdu FF:00:40:5D:04:01:01:03:01 > /dev/null 2> /dev/null

}

access_granted() {
	echo Access Granted: $AUTH_DN

	# TODO: Open the door!
	echo out > $GPIO_PATH/direction

	# Beep once with green LED to indicate success
	opensc-tool --send-apdu FF:00:40:2E:04:01:01:01:01 > /dev/null 2> /dev/null

	sleep 4

	echo in > $GPIO_PATH/direction
}

verify_access() {
	# TODO: Look up and verify that $AUTH_DN has access to this zone!
	true
}

echo $GPIO_PIN > /sys/class/gpio/export
echo in > $GPIO_PATH/direction
echo 0 > $GPIO_PATH/value

echo Starting Auth Loop

# Main access control loop
while true ;
do
	echo in > $GPIO_PATH/direction
	echo 0 > $GPIO_PATH/value
	modprobe -r pn533
	modprobe -r nfc
	if AUTH_DN=`./simple-card-auth.sh`
	then if verify_access
		then access_granted
		else access_denied
		fi
	else access_denied
	fi
	sleep 3
done
