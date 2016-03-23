c
c  subroutine x_dim1
c
      subroutine x_dim1(ndim)
c
c=======================================================================
c     ****f* SmartPPP/x_dim1
c
c   FUNCTION   
c   
c     determine the parameter dimension for Point Positioning   
c
c   INPUTS
c
c     NONE
c
c   OUTPUT
c
c     ndim       integer        observable number
c
c   COPYRIGHT
c
c     Copyright(c) 2006-        Shoujian Zhang,
c                               School of Geodesy and Geomatics,
c                               Wuhan University.
c     ***
c
C     $Id: x_dim1.f,v 1.0 2009/07/27 $
c=======================================================================
c
      implicit none
c
c     include
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
c
c     input/output
c
      integer       ndim
c
c     local
c
      integer       i,j,k
c
c     spacebore: not affected by tropospheric
c
      if(    MARKER_TYPE.EQ.'SPACEBORNE')then
c
c        3 pos + 1 clock   
c
         ndim = 3 + 1    
c
c     other types,such as geodetic,should consider tropospheric zpd
c
      elseif(MARKER_TYPE.EQ.'GEODETIC'  )then
c
c        3 pos + 1 clock + 1 tropospheric zpd
c
         ndim = 3 + 1 + 1
c
         write(*,*) 'SmartPPP/x_dim1'
         write(*,*) '  please modify for this Marker Type'
         stop
c
      else
c
         write(*,*) 'SmartPPP/x_dim1'
         write(*,*) '  please modify for this Marker Type'
         stop
c
      endif
c
      return
c
      end
