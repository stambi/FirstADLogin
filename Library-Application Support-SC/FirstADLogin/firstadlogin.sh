#!/bin/bash

##########################################################################################
# Run once if AD User logs in: Show message, run jamf policy                             #
# falls textfile run.txt existiert wird das script ausgeführt, wenn erfolgreich wird das script und die zugehörigen daten gelöscht. #
# Version: 0.1                                                                           #
# 19.05.2017 /STA                                                                        #
# Edit:                                                                                  #
##########################################################################################


# Dialog message
# set suit (2755) auf das script, damit es mit root ausgeführt wird


# Todo:
# Items in /Library/LaunchAgents load when any user logs in, and run as that user.
# Items in /Library/LaunchDaemons load when your Mac starts up, and run as the root user.
# -> LaunchDaemon erstellen welcher das Script lädt com.swisscom.firstadlogin.plist und beim Installer hinzufügen (wird in /Library/LaunchDaemons installiert)


# Define variables
# Set logfile path
logfile="/tmp/swisscom_firstadlogin.log"
message="This Mac is being configured. Do not interrupt or power off. This process takes up to 15 minutes, your device will reboot when finished. "

# Get current date and time for logfile and write it
runtime=$(date)
echo " " >> $logfile
echo "*** Script: $0 ***" >> $logfile
echo $runtime >> $logfile
echo $(whoami) >> $logfile

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
if [ ! -f /Library/Application\ Support/Swisscom/FirstADLogin/run.txt ] ; then
  echo "runscript" >> $logfile
  exit 0
else
  echo "File exist. Going on..." >> $logfile
fi

# Dialog message
/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Please wait..." -description "$message" -icon "/Library/Application Support/Swisscom/FirstADLogin/Swisscom.icns" &

echo "display message ok" >> $logfile

# Cleanup: Remove files and LaunchDaemons
# rm -rf /Library/Application\ Support/Swisscom/FirstADLogin/run.txt
echo "rm run.txt" >> $logfile

# Unload LaunchAgents
# launchctl unload -w /Library/LaunchAgents/com.swisscom.firstadlogin.plist
echo "launchctl unload" >> $logfile

#Delete LaunchAgents
# rm -rf /Library/LaunchAgents/com.swisscom.firstadlogin.plist
echo "rm /Library/LaunchAgents/com.swisscom.firstadlogin.plist" >> $logfile

# run jamf recon
jamf recon
sleep 5
# run jamf policy
jamf policy
sleep 5

# Reboot the device
echo "We are finished here. Reboot the device..." >> $logfile
reboot

exit 0
