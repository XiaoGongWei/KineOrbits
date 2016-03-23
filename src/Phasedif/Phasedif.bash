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
#
	  Phasedif -ihpx ../../data/rinex/grace/GPS1B_2008-08-01_A_01.rnx.hp.cln \
	  		   -isp3 ../../data/ephemeris/COD14905.EPH	\
			   -iclk ../../data/ephemeris/COD14905.CLK  \
			   -iatt ../../data/att/GA-OG-1B-SCAATT+JPL-SCA1B_2008-08-01_A_01.asc \
			   -ipos ../../data/pos/GA-OG-1B-NAVSOL+JPL-GNV1B_2008-08-01_A_01.sp3     \
			   -osvr ../../data/pos/GPS1B_2008-08-01_A_01.svr 
#
#	  END
#

