#!/bin/bash
#
#	Function
# 
#	  Precise Point Positioning for static, kinematic, dynamic receiver with
#	  SmartSPP software
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
    
while read line
do 
#
	hpxfile=`echo $line | awk '{print $1}'`
	sp3file=`echo $line | awk '{print $2}'`
	clkfile=`echo $line | awk '{print $3}'`
	attfile=`echo $line | awk '{print $4}'`
	posfile=`echo $line | awk '{print $5}'`
#
SmartSPP -ihpx $hpxfile -isp3 $sp3file -iclk $clkfile -iatt $attfile -opos $posfile 
exit
#
done < filelist.spp
#
#	SmartSPP -ihpx ../../data/rinex/1240/joze1240.09o.hp.cln \
#	  		 -isp3 ../../data/ephemeris/COD15301.EPH	  	\
#			 -iclk ../../data/ephemeris/COD15301.CLK        \
#			 -opos ../../data/pos/joze1240.pos.spp < SmartSPP.in 
#
#	END
#
