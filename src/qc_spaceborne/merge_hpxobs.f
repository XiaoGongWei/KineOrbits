c
c   subroutine merge_hpxobs
c
      subroutine merge_hpxobs(rnxvsn,nobs_typ,cobs_typ,isat,nrec_isat,
     &                        iflag,Nw,Sw,lvl2_LLI,lvl2_Nw,lvl2_Sw)
c
c=======================================================================
c     ****f* qualicontr/merge_hpxobs
c
c   FUNCTION   
c   
c     write flags of PRN(isat) into flag for all PRN
c
c   INPUTS
c
c     isat        (I)           The satellite sequence number 
c     nrec_isat   (I)           Record number for the list of PRNs
c                               PRN(isat)
c     iflag       (I)           cycle-slip and outlier flags for PRN(isat)
c
c   OUTPUT
c
c     lvl2_LLI   (I)            cycle-slip and outlier flags for all PRN in level2B file
c                               satellite systems.
c
c
c   COPYRIGHT
c
c     Copyright(c) 2006-        Shoujian Zhang,
c                               School of Geodesy and Geomatics,
c                               Wuhan University.
c     ***
c
C     $Id: merge_hpxobs.f,v 1.0 2009/07/15 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
c
c     input/output variables
c
      real*8        rnxvsn
      integer       nsat_sys
      character*3   csat_sys(MAX_SAT_SYS)
      integer       nobs_typ(MAX_SAT_SYS)
      character*3   cobs_typ(MAX_SAT_SYS, MAX_OBS_TYP)
c
      integer       isat
      integer       nrec_isat(MAX_PRN)
      integer       iflag(MAX_OBS_REC)
c
      real*8        Nw(MAX_OBS_REC)
      real*8        Sw(MAX_OBS_REC)
c
c     output
c
      integer       lvl2_LLI(MAX_OBS_REC, MAX_OBS_TYP)
c
      real*8        lvl2_Nw (MAX_OBS_REC)
      real*8        lvl2_Sw (MAX_OBS_REC)
c
c     local variables
c
      integer       irec, nrec, i, j, ik
      integer       idx_L1, idx_L2, idx_LA 
      integer       idx_C1, idx_P1, idx_P2
      integer       idx_S1, idx_S2, idx_SA
      integer       arec, zrec
c
      if(rnxvsn.lt.3.00)then
c
         do i=1, nobs_typ(1)
           if(    trim(cobs_typ(1,i)).eq.'L1')then
             idx_L1 = i
           elseif(trim(cobs_typ(1,i)).eq.'L2')then
             idx_L2 = i
           elseif(trim(cobs_typ(1,i)).eq.'LA')then
             idx_LA = i
           elseif(trim(cobs_typ(1,i)).eq.'C1')then
             idx_C1 = i
           elseif(trim(cobs_typ(1,i)).eq.'P1')then
             idx_P1 = i
           elseif(trim(cobs_typ(1,i)).eq.'P2')then
             idx_P2 = i
           elseif(trim(cobs_typ(1,i)).eq.'S1')then
             idx_S1 = i
           elseif(trim(cobs_typ(1,i)).eq.'S2')then
             idx_S2 = i
           elseif(trim(cobs_typ(1,i)).eq.'SA')then
             idx_SA = i
           endif
         enddo
c
c        double-frequency receiver ??
         if(idx_L1.EQ.0.or.idx_L2.EQ.0)then
           write(*,*) 'qualicontr/extrobs'
           write(*,*) '  not double-frequency GPS receiver'
           stop
         endif
c
      else
         write(*,*) "qualicontr/extrobs"
         write(*,*) '  Please modifiy to process rinex 3.00' 
         stop
      endif
c
c     calculate the first(arec) and last (zrec) record for PRN(isat)
c
      arec = 0
      zrec = 0
c
      do i=1, isat-1
      arec = arec + nrec_isat(i)
      zrec = zrec + nrec_isat(i)
      enddo
c
      arec = arec + 1
      zrec = zrec + nrec_isat(isat)
c
      ik = 0
      do i=arec, zrec
         ik = ik + 1
         lvl2_Nw (i)        = Nw   (ik)
         lvl2_Sw (i)        = Sw   (ik)
         if(iflag(ik).NE.0)then
         lvl2_LLI(i,idx_L1) = iflag(ik)
         endif
      enddo
c
      return
c
      end
