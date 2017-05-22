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
logfile="/tmp/sc_firstadlogin_d.log"

#extended logging
set -x
exec > $logfile 2>&1

# Get current date and time for logfile and write it
runtime=$(date)
echo " " >> $logfile
echo "*** Script: $0 ***" >> $logfile
echo "$runtime" >> "$logfile"
whoami >> "$logfile"

# Check if first login
if [ ! -f /Library/Application\ Support/SC/FirstADLogin/run_d.txt ] ; then
  echo "File does not exist, unload & delete LaunchAgent & LaunchDaemon..." >> $logfile
	launchctl unload /Library/LaunchAgents/com.sc.firstadlogin_a.plist &
  sleep 5
	launchctl unload /Library/LaunchDaemons/com.sc.firstadlogin_d.plist &
  sleep 5
	rm -rf /Library/LaunchAgents/com.sc.firstadlogin_a.plist
	rm -rf /Library/LaunchDaemons/com.sc.firstadlogin_d.plist
	echo "launchctl unload & delete" >> $logfile
  exit 0
else
  echo "File exist. Going on..." >> $logfile
fi

# Check if User is logged in, else loop until user logs in
while [ ! -f /tmp/sc_firstadlogin_a.log ]; do
  sleep 30
done

# Run the jamf commands, repeat four times
for i in {1..4}; do
# run jamf recon
/usr/local/bin/jamf recon
sleep 5
# run jamf manage
/usr/local/bin/jamf manage
sleep 5
# run jamf policy
/usr/local/bin/jamf policy
sleep 180
done
echo "jamf recon, policy, manage done" >> $logfile

# Unload LaunchAgents & LaunchDaemons
# Unload seems not working, script hangs after unloading LaunchDaemons
# launchctl unload /Library/LaunchAgents/com.sc.firstadlogin_a.plist &
# sleep 5
# launchctl unload /Library/LaunchDaemons/com.sc.firstadlogin_d.plist &
# sleep 5
# echo "launchctl unload" >> $logfile

# Delete LaunchAgents & LaunchDaemons
rm -rf /Library/LaunchAgents/com.sc.firstadlogin_a.plist
rm -rf /Library/LaunchDaemons/com.sc.firstadlogin_d.plist
echo "LaunchAgent & Launch Daemon deleted" >> $logfile

# Cleanup: Remove files and LaunchAgents & LaunchDaemons
rm -rf /Library/Application\ Support/SC/FirstADLogin/run_d.txt
rm -rf /Library/Application\ Support/SC/FirstADLogin/run_a.txt
echo "rm run_x.txt" >> $logfile

# Reboot the device
echo "We are finished here. Reboot the device..." >> $logfile
reboot
