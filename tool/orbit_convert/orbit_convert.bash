#!/bin/bash
#
#
#	Funtion
#	=======
#	
#	transform orbit difference from ECF to RAC
#	
#	author
#	======
#
#	-----------+-----------+---------------------------------------------------
#
#	S.J. Zhang	2008/04/08	build this shell script
#
################################################################################
#
    while read line
    do 
        rcv_rst_file=`echo $line | awk '{print $1}'`
        diforb1_file=`echo $line | awk '{print $2}'`
        diforb2_file=`echo $line | awk '{print $3}'`
		echo $rcv_rst_file
		echo $diforb1_file
		echo $diforb2_file
#
#       quality control for every file in IGS_file.list
#
 		orbit_convert -rcv_rst $rcv_rst_file -diforb1 $diforb1_file -diforb2 $diforb2_file 
#
     	cat $diforb2_file | awk '{print $2}' > zz
		statis < zz >  $diforb2_file.rms
#
	 	cat $diforb2_file | awk '{print $3}' > zz
    	statis < zz >> $diforb2_file.rms
#
	 	cat $diforb2_file | awk '{print $4}' > zz
    	statis < zz >> $diforb2_file.rms
#
#
    done < filelist.orbcvt_new
#
#
#	END
#

