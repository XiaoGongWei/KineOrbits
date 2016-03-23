#!/bin/bash
#
#	Function
# 
#   Quality control for GPS data 
#
#	Author
#
#	  Shoujian Zhang
#
#	COPYWRIGHT
# 
#	  Copyright(c) 2006- 	School of Geodesy and Geomatics,
#	  					    Wuhan University
#
################################################################################
#
while read line
do 
#
irnxfile=`echo $line | awk '{print $1}'`
ornxfile=`echo $line | awk '{print $2}'`
#
echo $irnxfile $ornxfile
#
./qualicontr -i $irnxfile -o $ornxfile
#
done < filelist.rnx
#
#	  END
#

