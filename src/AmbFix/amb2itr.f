C
c   subroutine amb2itr
c
      subroutine amb2itr(nsat, pntr_isat, nrec_isat)
c
c=======================================================================
c     ****f* AmbFix/amb2itr
c
c   FUNCTION   
c   
c     Transform the observation data file from HPRNX format to 
c     internal used formats, which are: 
c     
c     1) HPRNX Level1 format:
c
c        irec, EPOCH, cPRN, (obs, lli, snr)
c         *
c
c     2) HPRNX Level2 format:
c
c        irec, EPOCH, cPRN, (obs, lli, snr)
c                       *
c
c   Notes
c   =====
c
c     Level1 and Level2 are similiar, the difference are:
c     Level1 is arranged according to the record        number.
c     Level2 is arranged according to the satellite PRN number.
c
c   INPUTS
c
c     NONE
c
c   OUTPUT
c
c     nsat       integer          number of satellites in HPRNX
c     pntr_isat  character        PRN number for isat 
c     nrec_isat  integer          record number for isat 
c
c   COPYRIGHT
c
c     Copyright(c) 2006-          Shoujian Zhang,
c                                 School of Geodesy and Geomatics,
c                                 Wuhan University.
c     ***
c
C     $Id: amb2itr.f,v 1.0 2009/09/13 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
c
c     input/output
c
      integer       nsat
      integer       pntr_isat(MAX_SAT_NUM)
      integer       nrec_isat(MAX_SAT_NUM)
c
c     local 
c
      integer       isat
      integer       iepo, nepo, irec, nrec
      integer       i, j, k
      integer       ios
c
c     hprnx header file
c
      integer       NREC_iPRN(MAX_PRN)
c
c     hprnx observation data block
c
      real*8        EPOCH
      integer       EPOCH_nsat
c
      integer       iPRN
      character*3   cPRN
      integer       EPOCH_iPRN
      character*3   EPOCH_cPRN
c
      real*8        EPOCH_rP3
      real*8        EPOCH_rL3
      integer       EPOCH_flag
      real*8        EPOCH_Nw
      real*8        EPOCH_N3
      real*8        EPOCH_sig_N3
      real*8        EPOCH_elv
c
c     lvl1
c
      integer       lvl1_PNTR  (MAX_OBS_REC)
      real*8        lvl1_Time  (MAX_OBS_REC)
      integer       lvl1_iPRN  (MAX_OBS_REC)
c
      real*8        lvl1_rP3   (MAX_OBS_REC)
      real*8        lvl1_rL3   (MAX_OBS_REC)
      integer       lvl1_flag  (MAX_OBS_REC)
      real*8        lvl1_Nw    (MAX_OBS_REC)
      real*8        lvl1_N3    (MAX_OBS_REC)
      real*8        lvl1_sig_N3(MAX_OBS_REC)
      real*8        lvl1_elv   (MAX_OBS_REC)
c
c     lvl2
c
      integer       lvl2_PNTR  (MAX_PRN,MAX_OBS_REC)
c
      real*8        lvl2_rP3   (MAX_OBS_REC)
      real*8        lvl2_rL3   (MAX_OBS_REC)
      integer       lvl2_flag  (MAX_OBS_REC)
      real*8        lvl2_Nw    (MAX_OBS_REC)
      real*8        lvl2_N3    (MAX_OBS_REC)
      real*8        lvl2_sig_N3(MAX_OBS_REC)
      real*8        lvl2_elv   (MAX_OBS_REC)
c
      do i=1, MAX_PRN
         NREC_iPRN(i) = 0
      enddo
c
      do i=1, MAX_SAT_NUM
         nrec_isat(i) = 0
         pntr_isat(i) = 0
      enddo
c
      do i=1, MAX_OBS_REC
         lvl1_Nw(i) = 0.0d0
         lvl1_N3(i) = 0.0d0
      enddo
c
c     HPRNX to hprnx_level1
c     =====================
c
      irec = 0    
      nrec = 0
      iepo = 0
      nepo = 0
c
 100  continue
c
c++   read observ data block header 
c
      read(101, *, end=200, iostat=ios) 
     &     EPOCH, EPOCH_nsat
c
c     EPOCH number increment
      iepo = iepo + 1
c
      do i=1, EPOCH_nsat
c
c        read a record
         read(101, fmt=1000) 
     &        EPOCH_iPRN, EPOCH_rP3, EPOCH_rL3, 
     &        EPOCH_FLAG, EPOCH_Nw,  EPOCH_N3, EPOCH_sig_N3, EPOCH_elv
c
 1000    format((I3),2F8.3,I4,4F8.3)
c
         iPRN            = EPOCH_iPRN
         NREC_iPRN(iPRN) = NREC_iPRN(iPRN) + 1
c
c        record number increment
         irec = irec + 1
c
c++      write HPRNX into lvl1 format
c
         write(111, fmt=2000)
     +         irec, 
     &         EPOCH,EPOCH_iPRN,EPOCH_FLAG,EPOCH_Nw,EPOCH_N3
c
 2000    format(I6,F18.7,(X,I3),I4,2F8.3)
c
c
c++      save lvl1 observation data into array, which
c++      is used to create lvl2 format data file.
c
         lvl1_PNTR(irec)  = irec
c
         lvl1_Time(irec)  = EPOCH
         lvl1_iPRN(irec)  = EPOCH_iPRN
         lvl1_flag(irec)  = EPOCH_FLAG
c
         lvl1_Nw  (irec)  = EPOCH_Nw
         lvl1_N3  (irec)  = EPOCH_N3
c
         lvl2_PNTR(iPRN,NREC_iPRN(iPRN)) = irec
c
      enddo
c
c     read a new observation data block
c
      goto 100
c
 200  continue
c
      nrec = irec
      nepo = iepo
c
      write(*,*)        'number of epoch:'
      write(*,'(x,I6)')  nepo
c
c++   satellite PRNs 
c   
      isat = 0
      do iPRN=1, MAX_PRN
         if(NREC_iPRN(iPRN).gt.0)then
            isat            = isat + 1
            pntr_isat(isat) = iPRN
            nrec_isat(isat) = NREC_iPRN(iPRN)
         endif
      enddo
c
c++   satellite number
c
      nsat = isat
c
      if(nsat.gt.40)then
         write(*,*) 'AmbFix/amb2itr'
         write(*,*) '  satellite number are more than', nsat
         write(*,*) '  please modify the MAX_PRN in include/rinex.h'
         stop
      endif
c
c     hprnx_level1 to hprnx_level2
c     ============================
c
      do isat=1, nsat
c
         iPRN = pntr_isat(isat)
         nrec = nrec_isat(isat)
c
         do i=1, nrec
c
            irec = lvl2_PNTR(iPRN,i)
c
            write(211, fmt=3000)
     &      lvl1_PNTR(irec), 
     &      lvl1_Time(irec),lvl1_iPRN(irec),
     &      lvl1_flag(irec),lvl1_Nw(irec)  ,lvl1_N3(irec)
c
 3000       format(I6,F18.7,(X,I3),I4,2F8.3)
c
         enddo
c
      enddo
c
      return
c
      end
