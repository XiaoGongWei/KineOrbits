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
        orb1=`echo $line | awk '{print $1}'`
        orb2=`echo $line | awk '{print $2}'`
        odif=`echo $line | awk '{print $3}'`
#
#       quality control for every file in IGS_file.list
#
 		orbit_compare -iorb $orb1 -iorb  $orb2 -odif $odif
#
#
    done < filelist.orbcmp
#
#
#	END
#

