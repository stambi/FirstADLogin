#!/bin/bash

#####
# Run once: Show message, run jamf policy, unload & delete LaunchAgent & LaunchDaemon
# /Library/LaunchDaemons launches firstadlogin_d.sh -> load when any user logs in, and run as that user. (jamf recon, policy, etc)
# /Library/LaunchAgents launches firstadlogin_a.sh -> load when your Mac starts up, and run as the root user. (jamfHelper message)
# Version: 0.1
# 19.05.2017 /STA
# Edit:
#####


# Define variables
# Set logfile path
logfile="/tmp/SC_firstadlogin_a.log"
message="This Mac is being configured. Do not interrupt or power off. This process takes up to 15 minutes, your device will reboot when finished. "

#extended logging
set -x
exec > $logfile 2>&1

# Get current date and time for logfile and write it
runtime=$(date)
echo " " >> $logfile
echo "*** Script: $0 ***" >> $logfile
echo "$runtime" >> "$logfile"
whoami >> "$logfile"

# Check if AD or local user is logged in
UniqueID=$(dscl . list /Users UniqueID | grep "$3" | cut -c 25- | tail -n1)
if [ "$UniqueID" -lt "1000" ]; then
	echo "Local account logged in. Exit script." >> $logfile
	exit 0
else
	echo "AD account logged in. Going on..." >> $logfile
	echo "UniqueID = $UniqueID" >> $logfile
fi

# Check if first login
if [ ! -f /Library/Application\ Support/SC/FirstADLogin/run_a.txt ] ; then
  echo "runscript" >> $logfile
  exit 0
else
  echo "File exist. Going on..." >> $logfile
fi

# Dialog message
echo "We are finished here. Show message and wait for /Library/LaunchDaemons/com.sc.firstadlogin_d.plist to finish and reboot " >> $logfile
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Please wait..." -description "$message" -icon "/Library/Application Support/SC/FirstADLogin/Icon.icns"
