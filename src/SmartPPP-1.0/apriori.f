c
c  subroutine apriori
c
      subroutine apriori(rnxvsn,
     &                   nsat_sys,csat_sys,
     &                   nobs_typ,cobs_typ,ndim,x0,
     &                   NNZA,NRA,NCA,RA,CA,A,NNZP,NRP,NCP,RP,CP,P,
     &                   NNZL,NRL,NCL,RL,CL,L)
c
c=======================================================================
c     ****f* SmartPPP/apriori
c
c   FUNCTION   
c   
c     Add a priori information equation into observation equation 
c     ***********************************************************
c
c   INPUTS
c
c     rnxvsn     real*8         rinex version
c     csat_sys   characeter     returned satellite systems in rinex 
c                               file
c     nobs_typ   integer        observation types number for existed 
c                               satellite systems.
c     cobs_typ   character      observation types for existed 
c                               satellite systems.
c
c   OUTPUT
c
c     NONE
c
c   COPYRIGHT
c
c     Copyright(c) 2006-        Shoujian Zhang,
c                               School of Geodesy and Geomatics,
c                               Wuhan University.
c     ***
c
C     $Id: apriori.f,v 1.0 2009/08/20 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
c
c     input
c
      real*8        rnxvsn
      integer       nsat_sys
      character*3   csat_sys(MAX_SAT_SYS)
      integer       nobs_typ(MAX_SAT_SYS)
      character*3   cobs_typ(MAX_SAT_SYS, MAX_OBS_TYP)
c
c     output
c
      integer       NRA,  NRP,  NRL
      integer       NCA,  NCP,  NCL
      integer       NNZA, NNZP, NNZL
c
      integer       CA(MAX_NNZA), RA(MAX_NRA+1)
      integer       CP(MAX_NNZP), RP(MAX_NRP+1)
      integer       CL(MAX_NNZL), RL(MAX_NRL+1)
c
      real*8        A (MAX_NNZA)
      real*8        P (MAX_NNZP)
      real*8        L (MAX_NNZL)
c
c     local
c
      real*8        EPOCH
      integer       EPOCH_nsat
      integer       EPOCH_flag
      character*3   cPRN
      integer       EPOCH_iPRN
      character*3   EPOCH_cPRN
      real*8        EPOCH_OBS(MAX_OBS_TYP)       
      integer       EPOCH_LLI(MAX_OBS_TYP)
      integer       EPOCH_SNR(MAX_OBS_TYP)
c
      integer       idx_L1, idx_L2, idx_LA 
      integer       idx_C1, idx_P1, idx_P2
      integer       idx_S1, idx_S2, idx_SA
c
c     read data block
c
      integer       tmp_nsat
      integer       tmp_flag(MAX_SAT_NUM)
      integer       tmp_iPRN(MAX_SAT_NUM)
c
      real*8        tmp_time
      real*8        tmp_time_fore
      real*8        tmp_L1, tmp_L2, tmp_P1, tmp_P2
      real*8        tmp_L3(MAX_SAT_NUM)
      real*8        tmp_P3(MAX_SAT_NUM)
c
c     apriori
c
      integer       iter
      logical       convgd
      logical       more
c
      integer       ndim
      integer       iobs, irec, iepo, iamb
      integer       iPRN, isat
      integer       flag
      integer       iAMB_iPRN(MAX_PRN), iAMB_iSAT(MAX_PRN)
      integer       Namb_base
      integer       idx_iamb
c
      real*8        x0(MAX_PMS)
      real*8        xrcv(3),crcv,xtrs(3),vtrs(3),ctrs
      real*8        L3, P3
      real*8        time
      real*8        elv
      real*8        N3
      real*8        ap_N3
c
c     loop
      integer       i, k 
c
c     common
c     ******
c
      integer       NSAT, NEPO
      integer       NAMB, NREC
      integer       iSAT_iPRN(MAX_PRN), iPRN_iSAT(MAX_PRN)
      integer       NAMB_iPRN(MAX_PRN), NAMB_iSAT(MAX_PRN)
      integer       NREC_iPRN(MAX_PRN), NREC_iSAT(MAX_PRN)
c
      character*3   cPRN_iSAT(MAX_PRN)
c
      real*8        TIME_SPAN(2)
      real*8        aEPO(MAX_EPO)
c
      common /obs/  NSAT,      NEPO,     
     &              NAMB,      NREC, 
     &              iPRN_iSAT, iSAT_iPRN,
     &              NREC_iPRN, NREC_iSAT,
     &              NAMB_iPRN, NAMB_iSAT, 
     &              cPRN_iSAT, TIME_SPAN,
     &              aEPO
c
c     Initialization
c
      do i=1,MAX_SAT_NUM
         tmp_L3(i) = 0.0d0
         tmp_P3(i) = 0.0d0
      enddo
c
      idx_L1 = 0
      idx_L2 = 0
c
      if(rnxvsn.lt.3.00)then
c
         do i=1, nobs_typ(1)
           if(    trim(cobs_typ(1,i)).eq.'L1')then
             idx_L1 = i
           elseif(trim(cobs_typ(1,i)).eq.'L2')then
             idx_L2 = i
           elseif(trim(cobs_typ(1,i)).eq.'P1')then
             idx_P1 = i
           elseif(trim(cobs_typ(1,i)).eq.'P2')then
             idx_P2 = i
           endif
         enddo
c
c        double-frequency receiver ??
         if(idx_L1.EQ.0.or.idx_L2.EQ.0)then
            write(*,*) 'SmartPPP/apriori'
            write(*,*) 'not double-frequency GPS receiver'
            stop
         endif
c
      else
c
         write(*,*) "SmartPPP/apriori"
         write(*,*) 'Please modifiy to process rinex 3.00' 
         stop
c
      endif
c
c     ambiguity
c
      do i=1,MAX_PRN
         iAMB_iPRN(i) = 0
         iAMB_iSAT(i) = 0
      enddo
c
c     *************************
c     adding information matrix
c     *************************
c
      iobs = 0
      iepo = 0
      iamb = 0
c
      more = .true.
      tmp_nsat = 0
      tmp_time = 0.0d0
      tmp_time_fore = 0.0d0
c
 100  continue
c
      read(111, fmt=2000, end=300)
     +      irec, 
     +      EPOCH,       EPOCH_iPRN, (EPOCH_OBS(k),
     +      EPOCH_LLI(k),EPOCH_SNR(k),k=1,nobs_typ(1))
c
 2000 format(I6, F18.7, (X,I3), 12(F14.3,I1,I1))
c
      tmp_time = EPOCH
c
c     continue reading observables at the same epoch
c
 110  continue
c
c     finish this epoch reading ???
c
      if(tmp_time.gt.tmp_time_fore.and.tmp_nsat.gt.0)then
c
         goto 200
c
      endif
c
c     pass the outliers
c
      if(EPOCH_LLI(idx_L1).EQ.9)then
c
         goto 100
c
      endif
c
      tmp_nsat           = tmp_nsat + 1
      tmp_flag(tmp_nsat) = EPOCH_LLI(idx_L1)
      tmp_iPRN(tmp_nsat) = EPOCH_iPRN
c
      tmp_L1             = EPOCH_OBS(idx_L1)*lam_L1_GPS
      tmp_L2             = EPOCH_OBS(idx_L2)*lam_L2_GPS
      tmp_P1             = EPOCH_OBS(idx_P1)
      tmp_P2             = EPOCH_OBS(idx_P2)
c
c     LC combination
c
      tmp_L3(tmp_nsat)   = 
     &      (f1_GPS**2*tmp_L1-f2_GPS**2*tmp_L2)/(f1_GPS**2-f2_GPS**2)
      tmp_P3(tmp_nsat)   =
     &      (f1_GPS**2*tmp_P1-f2_GPS**2*tmp_P2)/(f1_GPS**2-f2_GPS**2)
c
c     store last epoch time
c
      tmp_time_fore = tmp_time
c
      goto 100
c
c     END of reading data block
c     *************************
c
 200  continue
c
c     compose observation equation: NOTES tmp_time_fore !!!
c     =====================================================
c
      if(tmp_nsat.GE.5)then
c
         iepo = iepo + 1
c        time
         Time = tmp_time_fore
c
         if(Time.NE.aEPO(iepo))then
         write(*,*) 'SmartPPP/apriori'
         write(*,*) 'Time and iepo not match'
         stop
         endif
c
c**      compose obseq one by one at the same epoch
c
         do i=1,tmp_nsat
c
c        flag, iPRN
c
         iPRN = tmp_iPRN(i)
c
         isat = iSAT_iPRN(iPRN)
c
c**      ambiguity for isat increase
c
         flag = tmp_flag(i)
c
         if(flag.EQ.1)then
c
            iamb            = iamb +1
            iAMB_iSAT(isat) = iAMB_iSAT(isat) + 1
c
            Namb_base = 0
            do k=1,(isat-1)
            Namb_base= Namb_base + NAMB_iSAT(k)
            enddo
c
c           iobs index for this ambiguity
            iobs     = 1*NREC + iamb
c
c           index of iamb in parameter X0
            idx_iamb = 4*NEPO + Namb_base + iAMB_iSAT(isat) 
c
c++         ambiguity
            N3    = x0(idx_iamb)
            ap_N3 = tmp_L3(i) - tmp_P3(i)
c
c++         coefficent of the apriori Equation
c
            call apriori_coeff( iepo,iobs,idx_iamb,
     &                          NNZA,NRA,RA,CA,A)
c
c++         Observed Minus Computed
c
            call apriori_OMC(   iepo,iobs,idx_iamb,N3,ap_N3,
     &                          NNZL,NRL,RL,CL,L)
c
c++         weight matrix
c
            call apriori_weight(iepo,iobs,idx_iamb,
     &                          NNZP,NRP,RP,CP,P)
c
         endif
c
         enddo
c
      endif
c
      tmp_nsat = 0
c
c     END of DATA
c
      if(.not.more)then
c
         goto 400
c
      endif
c
      goto 110
c
  300 continue
c
      more = .false.
c
c     read the last EPOCH observation data block
      goto 200
c
  400 continue
c
      return
c
      end
