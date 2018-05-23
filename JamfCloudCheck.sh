#!/bin/bash

# Define variables
server="[jamf pro URL]"
serverCheck="https://$server/healthCheck.html"
awsTest="23.23.255.255"
email="[your email address]"

# Runs a healthcheck
checkConn=$( curl -s --max-time 20 $serverCheck )

if [ "$checkConn" == "[]" ]; then

	# Check average ping time for AWS
	awsPing=$( ping $awsTest -c 4 2>&1 | tail -1 | awk -F '/' '{print $5}' )
	# Check average ping time for Jamf Pro
	jssPing=$( sudo hping3 -S $server -c 4 -p 443 2>&1 >/dev/null | tail -1 | awk -F '/' '{print $4}' )
	# Determine delta between ping times to determine if everything is slow, or just Jamf Pro
	pingDelta=$( echo "$jssPing - $awsPing" | bc )

	# If the ping delta is above 500ms, trigger an email with the delta and the Jamf Pro ping times. Otherwise, exit
	if [ ${pingDelta%.*} -gt 500 ]; then
		echo "High Latency - $pingDelta ms, with Jamf Pro ping of $jssPing ms." | mail  -s "High Latency Event" -t $email
	else
		exit 0
		echo "Delta was $pingDelta, truncated value was ${pingDelta%.*}. Jamf Pro latency was $jssPing ms. " | mail -s "Everything is fine." -t $email
	fi
else
	# If healthcheck fails, check AWS to see if it responds to ping
	awsConn=$( ping $awsTest -c 4 -p 443 -q 2>&1 | awk 'FNR == 5 {print $6}' | cut -f1 -d'%' )

	# Send an email if more than 0% of the 4 pings fail
        if [ $awsConn -gt 0 ]; then
                echo "Jamf Pro Outage - possible AWS Outage, $awsConn percent ping failure." | mail -s "AWS Jamf Pro Outage" -t $email
	else
	# If AWS comes back fine, send an email alert.
		echo "Jamf Pro Outage Event Detected" | mail -s "Jamf Pro Outage" -t $email
	fi
fi
