#!/bin/sh

# The GPS should be turned on to get an accurate fix...otherwise you get the tower location
# Is the GPS turned on? 
$(luna-send -n 1 palm://com.palm.location/getUseGps '{}' 2>&1 | grep 'true' > /dev/null)
grep_ret=$?
if [ $grep_ret -eq 0 ]        # Test exit status of "grep" command.
then
   # gps is on
   gps_on=1
else
   #gps is off...let's turn it on and remember to turn it back off later
   gps_on=0
   $(luna-send -n 1 palm://com.palm.location/setUseGps '{"useGps":true}' > /dev/null 2>&1)
   # wait for 60 seconds so gps gets a good lock
   sleep 60
fi

# Location services must be turned on, or startTracking will not work (you get a {"errorCode":7})
# Are locations service turned on? 
$(luna-send -n 1 palm://com.palm.location/getAutoLocate '{}' 2>&1 | grep 'true' > /dev/null)
grep_ret=$?
if [ $grep_ret -eq 0 ]        # Test exit status of "grep" command.
then
   # location service is on
   location_service=1
else
   #location service is off...let's turn it on and remember to turn it back off later
   location_service=0
   $(luna-send -n 1 palm://com.palm.location/setAutoLocate '{"autoLocate":true}' > /dev/null 2>&1)
fi

pos=$(luna-send -n 2 palm://com.palm.location/startTracking '{"appId": "ILovePalm", "subscribe": true}' 2>&1 | tail -1 | cut -d, -f4,5,6,7,8,9,10 | sed -r 's/[^-\.0-9,]//g')

# turn off GPS?
if [ $gps_on -eq 0 ]
then
   # the GPS was off when we started the script...turn it back off
   $(luna-send -n 1 palm://com.palm.location/setUseGps '{"useGps":false}' > /dev/null 2>&1)
fi

# turn off location service?
if [ $location_service -eq 0 ]
then
   # location service was off when we started the script...turn it back off
   $(luna-send -n 1 palm://com.palm.location/setAutoLocate '{"autoLocate":false}' > /dev/null 2>&1)
fi


lat=$(echo $pos | cut -d, -f1)
lon=$(echo $pos | cut -d, -f2)
posacc=$(echo $pos | cut -d, -f3)
heading=$(echo $pos | cut -d, -f4)
spd=$(echo $pos | cut -d, -f5)
alt=$(echo $pos | cut -d, -f6)
altacc=$(echo $pos | cut -d, -f7)
bat=$(cat /sys/devices/w1_bus_master1/32-000840bf1648/getpercent)
now=$(date -u +'%Y-%m-%d %H:%M:%S')
# Enable this below if you want to keep logs - not sure where to write them /var/home/root not the best place.
msg1=$(printf "%s,%f,%f,%2.2f,%2.2f,%2.2f,%2.2f,%3.1f,%3.0f%%" "$now" "$lat" "$lon" "$posacc" "$alt" "$altacc" "$spd" "$heading" "$bat")
echo $msg1 >>mygpsdata.log
exit
