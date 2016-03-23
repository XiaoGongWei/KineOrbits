*
*  subroutine OMC1
*      
      subroutine OMC1(xrcv,crcv,xtrs,vtrs,ctrs,zwd,elv,
     &                time,iPRN,iobs,P3,L)
c
c=======================================================================
c     ****f* SmartPPP/OMC1.f
c
c   FUNCTION   
c   
*     OMC1 of the observation equation
c
c   INPUTS
c
c     xrcv        real*8           coordinates of receiver
c     xtrs        real*8           coordinates of GPS
c     vtrs        real*8           velocity of GPS 
c     ctrs        real*8           clock error of GPS 
c
c   OUTPUT
c
c     L           real*8           Observed Minus Computed value
c
c   COPYRIGHT
c
c     Copyright(c) 2006-           Shoujian Zhang,
c                                  School of Geodesy and Geomatics,
c                                  Wuhan University.
c   REVISION
c
c     2009/08/03                   build
c
c     ***
c
C     $Id: OMC1.f.f,v 1.0 2009/07/28 $
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
      include      '../../include/igs.h'
      include      '../../include/atx.h'
      real*8        sec2mjd
c
      real*8        pi
      parameter (   pi = 3.1415926535897932D0 )
c
c     input/output
c
      integer       iobs
c
      real*8        xrcv(3),crcv,xtrs(3),vtrs(3),ctrs
      real*8        zwd
      real*8        elv
      real*8        time
      real*8        P3
      real*8        L(MAX_SAT_NUM,1)
c
c     local
c
      real*8        dis
      real*8        dis_observed
      real*8        dis_computed
      real*8        dis_dTs
      real*8        dis_dPCO
      real*8        dis_PCV
      real*8        dis_rel
      real*8        dis_dry_trop
      real*8        dis_wet_trop
      real*8        dis_windup
c
      real*8        drou_dx,drou_dy,drou_dz
      integer       iPRN
      logical       debug
c
c     loop
c
      integer       i,j,k
c
      character*10  MF  ! Mapping Fucntion Type
      real*8        MJD ! Modified Julian Date
c
      real*8        zd  ! zenith distance in radian
      real*8        site_geod(3)
      real*8        slat, slon, shgt
      real*8        gmfh, gmfw
      real*8        hydro_zpd
c
c     common
c
      real*8        rcv_pco  (MAX_FREQ,3)
      real*8        dpco     (3)
      real*8        xZEN     (MAX_REC_ZEN)
      real*8        yant_pcv1(MAX_FREQ,MAX_REC_ZEN)
      real*8        yant_pcv2(MAX_FREQ,MAX_REC_AZI,MAX_REC_ZEN)
      integer       nrec_zen
c
      real*8        trs_pco  (MAX_PRN,3)
c*
      common /atx/  rcv_pco,dpco,xzen,yant_pcv1,yant_pcv2,nrec_zen,
     &              trs_pco
c
c     initial
c
      dis          = 0.0d0
      dis_observed = 0.0d0 
      dis_computed = 0.0d0 
      dis_dTs      = 0.0d0  
      dis_dPCO     = 0.0d0 
      dis_PCV      = 0.0d0 
      dis_rel      = 0.0d0 
      dis_dry_trop = 0.0d0
      dis_windup   = 0.0d0  
c
      debug = .false.
c
c     distance from receiver to transmitter
c
      call distance(xrcv,xtrs,dis)
c
c     partial derivative with respect to the receiver
c
      drou_dx    = -(xtrs(1)-xrcv(1))/dis
      drou_dy    = -(xtrs(2)-xrcv(2))/dis
      drou_dz    = -(xtrs(3)-xrcv(3))/dis
c
c     Observed Minus Computed
c     =======================
c
c     SPACEBORNE
c
      if(    MARKER_TYPE.EQ.'SPACEBORNE')then
c
c        distance of GPS transimtter clock error
c
         dis_dTs  = ctrs*c_light
c
c        distance of relativity
c
         dis_rel  = -2.0d0*( xtrs(1)*vtrs(1)+
     &                       xtrs(2)*vtrs(2)+
     &                       xtrs(3)*vtrs(3)  )/c_light
c
c        distance of difference of L1 and L2 phase center
c        transform to f2**2*dpco/(f1**2-f2**2)
c
         dis_dPCO = (f2_GPS**2/(f1_GPS**2-f2_GPS**2))*
     &              (drou_dx*dpco(1) + drou_dy*dpco(2)+drou_dz*dpco(3))
c
c        distance of difference of phase variations:
c        notes: ignore azimuth-dependent variations
c
         call lagrange(xZEN,yant_pcv1,nrec_zen,elv,dis_PCV)   
c
c        observed         
c         
         dis_Observed = P3  
     &                + dis_dPCO     ! difference of PCO
     &                + dis_PCV      ! PCV
c
c        computed
c
         dis_Computed = dis 
     &                + crcv
     &                - dis_dTs      ! GPS clock error
     &                - dis_rel      ! GPS relativity
c
c        observed minus computed
c        =======================
c
         L(iobs,1)    = dis_Observed - dis_Computed
c
c     GEODETIC
      elseif(MARKER_TYPE.EQ.'GEODETIC')then
c
c        distance of GPS transimtter clock error
c
         dis_dTs  = ctrs*c_light
c
c        distance of relativity
c
         dis_rel  = -2.0d0*( xtrs(1)*vtrs(1)+
     &                       xtrs(2)*vtrs(2)+
     &                       xtrs(3)*vtrs(3)  )/c_light
c
c        distance of difference of L1 and L2 phase center
c        transform to f2**2*dpco/(f1**2-f2**2)
c
         dis_dPCO = (f2_GPS**2/(f1_GPS**2-f2_GPS**2))*
     &              (drou_dx*dpco(1) + drou_dy*dpco(2)+drou_dz*dpco(3))
c
c        distance of difference of phase variations:
c        notes: ignore azimuth-dependent variations
c
         call lagrange(xZEN,yant_pcv1,nrec_zen,elv*180.0d0/pi,dis_PCV)   
c
c        distance of tropospheric hydrostatic delay
c
c>1      Mapping Function
c        default value
         MF = 'gmf'
c        Modified Julian Date
         MJD = sec2mjd(time)
c        zenith distance in radian
         zd = pi/2 - elv
c        geodetic coordinate
         call xyz2geod(xrcv,site_geod)
         slat = site_geod(1)
         slon = site_geod(2)
         shgt = site_geod(3)
c        MF
c>2      drou/dtrop
c        Global Mapping Function
         if(    trim(MF).EQ.'gmf')then
            call gmf(mjd,slat,slon,shgt,zd,gmfh,gmfw)
         elseif(trim(MF).EQ.'vmf1')then
            write(*,*) 'Not support the vmf1 now'
         endif
c
c>3      zenith path delay
         call trop_hydro_zpd(xrcv,hydro_zpd)
c>4
         dis_dry_trop = hydro_zpd*gmfh
         dis_wet_trop = zwd*gmfw
c
         if(debug)then
            write(*,*) 'iPRN,slat,slon,shgt,hydro_zpd,gmfh,gmfw'
            write(*,*)  iPRN,slat,slon,shgt,hydro_zpd,gmfh,gmfw 
         endif
c
c        observed         
c         
         dis_Observed = P3  
     &                + dis_dPCO     ! difference of PCO
     &                + dis_PCV      ! PCV
c
         if(debug)then
            write(*,*) 'observed'
            write(*,*)  P3, dis_dPCO, dis_PCV,dis_Observed
         endif
c
c        computed
c
         dis_Computed = dis 
     &                + crcv
     &                - dis_dTs      ! GPS clock error
     &                - dis_rel      ! GPS relativity
     &                + dis_dry_trop ! dry tropopsheric delay
     &                + dis_wet_trop ! wet tropopsheric delay
         if(debug)then
            write(*,*) 'computed'
            write(*,*)  dis, crcv, dis_dTs, dis_rel, 
     &                  dis_dry_trop, dis_wet_trop, dis_Computed
         endif
c
c        observed minus computed
c        =======================
c
         L(iobs,1)    = dis_Observed - dis_Computed
         if(debug)then
            write(*,*) L(iobs,1)
         endif
c
      else
c
         write(*,*) 'SmartPPP/OMC1'
         write(*,*) 'Please make modification for tropospheric deriv'
c
      endif
c
      return
c
      end
