#!/bin/sh
#
# Transfer gps logging data to mcow

cd /home/root
scp mygpsdata.log youruser@hostname:/dest/dir/
today=`date +'%Y%m%d'`
start='mygpsdata-'
end='.log'
newname=$start$today$end
mv mygpsdata.log $newname
