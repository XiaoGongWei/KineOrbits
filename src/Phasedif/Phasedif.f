c
c   program Phasedif
c
      program Phasedif
c
c=======================================================================
c     ****f* SmartPPP/Phasedif
c
c   FUNCTION   
c   
c     calculate the position variation with phase differnece between
c     consecutive epochs.
c   
c   Notes
c
c     The standard input format is HPRNX, not RINEX. 
c
c   Reference
c
c     1. Kouba, J.       2001, Precise Point Positioning Using IGS Orbit and
c                              Clock Products.
c     2. Montenbruck, O. 2003, In flight performance analysis of the 
c                              CHAMP BlackJack GPS receiver. 
c     3. Montenbruck, O. 2003, Satellite Orbits: Models, Methods And
c                              Applications.
c     4. Kroes,R.        2006, Precise Relative Positioning of Formation
c                              Flying Spacecraft using GPS.
c
c   USAGE
c
c     Phasedif -ihpx Argument  -isp3 Argument -iclk Argument [-iatt Argument]
c              -osvr Argument
c
C   ARGUMENTS
C
C     -ihpx                    input rinex file with hprnx format
c     -isp3                    input IGS sp3 file
c     -iclk                    input IGS clock file
c     -iatt                    input receiver attitude file on 
c                              moving platform
c     -osvr                    output state variation file with 
c                              sp3 format
C
c
c   COPYRIGHT
c
c     Copyright(c) 2006-       Shoujian Zhang,
c                              School of Geodesy and Geomatics,
c                              Wuhan University.
c     ***
c
C     $Id: SmartPPP.f,v 1.0 2009/08/21 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
c
c     variables in getopts     
c
      integer       MAX_OPTS
      integer       nopts
      integer       stat
      parameter    (MAX_OPTS = 20)
      parameter    (nopts    = 12)
c
c     variables from getargvs
c
      integer       nargv
      character*200 argvs(MAX_OPTS)
c
      character*200 ihpx_file
      character*200 isp3_file
      character*200 iclk_file
      character*200 ipos_file
      character*200 iatt_file
      character*200 osvr_file
c
      integer       iargv
      integer       ios
c
c     variables for rinex 3.00 processing
c
      character*3   yes
c  
c     rinex header
c   
      real*8        rnxvsn
      integer       nsat_sys
      character*3   csat_sys(MAX_SAT_SYS)
      integer       nobs_typ(MAX_SAT_SYS)
      character*3   cobs_typ(MAX_SAT_SYS, MAX_OBS_TYP)
c
c     information file
c
      character*200 line
      character*100 file_amb
      character*100 file_sum
      character*100 file_sta
c
c     loop
c
      integer       i, j, k
      integer       nepo, iPRN, nrec
      integer       isat
      character*3   cPRN
c
c     system path
c
      character*100 HOPES_HOME
      character*100 SmartPPP_conf
      character*100 rinex_conf
c
c     read arguments from command line
c     ================================
c
      call getargvs(nargv, argvs, stat)
c
      if(stat /=0 )then
c
         write(*,*)
         write(*,*)'Usages: Phasedif -ihpx f -isp3 f -iclk f -ipos',
     &             '[-att f] -osvr f'
c
         write(*,*)
         write(*,*)'Arguments:'
         write(*,*)
         write(*,*)'  -ihpx input  rinex file'
         write(*,*)'  -isp3 input  IGS sp3 file'
         write(*,*)'  -iclk input  IGS clock file'
         write(*,*)'  -ipos input  receiver position file'
         write(*,*)'  -iatt input  receiver attitude file'
         write(*,*)'  -osvr output state variation file'
         write(*,*)
         write(*,*)'AUTHOR'
         write(*,*)
         write(*,*)'  Programmed by Shoujian Zhang'
         write(*,*)
c
         stop
c
      endif
c
      if(nargv.gt. nopts)then
         write(*,*) 'SmartPPP/SmartPPP.f'
         write(*,*) 'input argments not correct'
         stop
      endif
c
      iargv = 1
      do while(iargv <= nargv) 
         if(    argvs(iargv)=='-ihpx')then
            iargv = iargv + 1
            ihpx_file = argvs(iargv)
         elseif(argvs(iargv)=='-isp3')then
            iargv = iargv + 1
            isp3_file = argvs(iargv)
         elseif(argvs(iargv)=='-iclk')then
            iargv = iargv + 1
            iclk_file = argvs(iargv)
         elseif(argvs(iargv)=='-ipos')then
            iargv = iargv + 1
            ipos_file = argvs(iargv)
         elseif(argvs(iargv)=='-iatt')then
            iargv = iargv + 1
            iatt_file = argvs(iargv)
         elseif(argvs(iargv)=='-osvr')then
            iargv = iargv + 1
            osvr_file = argvs(iargv)
         endif
         iargv = iargv + 1
      end do   
c
c     SmartPPP confiugre file name
c     =========================
c
      rinex_conf    = 'etc/rinex.conf'
      SmartPPP_conf = 'etc/SmartPPP.conf'
c
      call getenv('HOPES_HOME',HOPES_HOME)
c
      rinex_conf    = trim(HOPES_HOME)//trim(rinex_conf)
      SmartPPP_conf = trim(HOPES_HOME)//trim(SmartPPP_conf)
c
c     parse the parameters in SmartPPP.conf
c
      call parse_conf(rinex_conf)
      call parse_conf(SmartPPP_conf)
c
c     open rinex file
c     ===============
c
      open(unit=101,file=ihpx_file,status='old',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open rinex file error'
         stop
      endif
c
      open(unit=102,file=isp3_file,status='old',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open sp3 file error'
         stop
      endif
c
      open(unit=103,file=iclk_file,status='old',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open clock file error'
         stop
      endif
c
      if(     trim(MARKER_TYPE).NE.'GEODETIC'
     &   .and.trim(MARKER_TYPE).NE.'NON_GEODETIC')then
c
      open(unit=104,file=iatt_file,status='old',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open attitude file error'
         stop
      endif
c
      endif
c!
      open(unit=105,file=ipos_file,status='old',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open position file error'
         stop
      endif
c
c     open output position file
c     =========================
c
      open(unit=201,file=osvr_file,status='replace',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/Phasedif.f'
         write(*,*) 'open state variation file error'
         stop
      endif
c
c     sta, tropospheric and ambiguity file
c
      file_sum = trim(osvr_file)//'.sum'
      file_sta = trim(osvr_file)//'.sta'
c
      open(unit=301,file=file_sum,  status='replace',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/SmartPPP.f'
         write(*,*) 'open summary file error'
         stop
      endif
c
      open(unit=303,file=file_sta,status='replace',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/SmartPPP.f'
         write(*,*) 'open sta file error'
         stop
      endif
c
c!!
      open(unit=111,status='scratch',iostat=ios)
c
      if(ios.ne.0)then
         write(*,*) 'SmartPPP/SmartPPP.f'
         write(*,*) 'open rinex file error'
         stop
      endif
c
c     BEGIN time 
c     ==========
c
      write(*,*)
      write(*,*) 'PROCESSING ... ...'
      write(*,*) '=================='
c
      write(*,*)
      call timestamp()
      write(*,*)
c
c     hpx2itr and read observations
c     =============================
c
      call hpx2itr(rnxvsn,nsat_sys,csat_sys,nobs_typ,cobs_typ)
c
      write(*,*)              'rinex version'
      write(*,'(  (x,F6.2))')  rnxvsn
c
      write(*,*)              'satellite systems number:'
      write(*,'(  (x,I6)  )')  nsat_sys
c
      do i=1, nsat_sys
c
      write(*,*)              'satellite system:'
      write(*,'(  (x,A6)  )')  trim(csat_sys(i))
      write(*,*)              'observation types number:'
      write(*,'(  (x,I6)  )')  nobs_typ(i)
      write(*,*)              'observation types:'
      write(*,'(15(x,A3)  )') (cobs_typ(i,k),k=1,nobs_typ(i))
c
      enddo
c
      write(*,*)
      write(*,*)              'Marker Type:'
      write(*,'(  (x,A )  )')  trim(MARKER_TYPE)
      write(*,*)              'Observation Model:'
      write(*,'(  (x,I6)  )')  observ_model
      write(*,*)              'Estimation Method:'
      write(*,'(  (x,A6)  )')  trim(estimator)
c
c     read SP3
c     ========
c
      call read_sp3()
c
c     read CLK
c     ========
c
      call read_clk()
c
c     read ATT
c     ========
c
      if(     trim(MARKER_TYPE).NE.'GEODETIC'
     &   .and.trim(MARKER_TYPE).NE.'NON_GEODETIC')then
c
      call read_att()
c
      endif
c
c     read ipos file
c     ==============
c
      call read_pos()
c
c     read antex file
c
      call read_atx()
c
c     Standard Point Positioning
c     ==========================
c
      rewind(111)
c
      call phasediflib(rnxvsn,nsat_sys,csat_sys,nobs_typ,cobs_typ)
c
c     close file
c     ==========
c
      close(101)
      close(102)
      close(103)
c
      if(     trim(MARKER_TYPE).NE.'GEODETIC'
     &   .and.trim(MARKER_TYPE).NE.'NON_GEODETIC')then
c
      close(104)
c
      endif
      close(105)
c
      close(201)
      close(301)
      close(303)
c
      close(111)
c
      write(*,*) 'Stop Normally'
      write(*,*)
c
c     END time 
c     ========
c
      call timestamp()
c
      stop
c
      end
