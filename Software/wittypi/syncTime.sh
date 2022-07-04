#!/bin/bash
# file: syncTime.sh
#
# This script can syncronize the time between system and RTC
#

# delay if first argument exists
if [ ! -z "$1" ]; then
  sleep $1
fi

# include utilities script in same directory
my_dir="`dirname \"$0\"`"
my_dir="`( cd \"$my_dir\" && pwd )`"
if [ -z "$my_dir" ] ; then
  exit 1
fi
. $my_dir/utilities.sh


# if RTC presents
log 'Synchronizing time between system and Witty Pi...'

# get RTC time
rtctime="$(get_rtc_time)"

rtcok=false

log "$rtctime"
# if RTC time is OK, write RTC time to system first
if [[ $rtctime != *"N/A"* ]] && [[ $rtctime != *"1999"* ]] && [[ $rtctime != *"2000"* ]]; then
  rtc_to_system
  rtcok=true
  log 'RTC OK'
else
  log 'RTC FAIL'
fi

# if internet is not accessible, wait a moment
if ! $(has_internet) ; then
                sleep 10
fi

if $(has_internet) ; then
  # now take new time from NTP
  log 'Internet detected, apply network time to system and Witty Pi...'
  net_to_system
  system_to_rtc
  log 'TIME OK ('"$INTERNET_SERVER"')'
else
  if [ "$rtcok" == false ]; then
    log 'TIME FAIL ('"$INTERNET_SERVER"')'
  else
    log 'TIME OK ('"$INTERNET_SERVER"')'
  fi
fi
