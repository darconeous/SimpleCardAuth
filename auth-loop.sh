#!/bin/sh

while true ;
do
	sleep 2
	auth_dn=`./simple-card-auth.sh` || continue
	echo access granted
done
