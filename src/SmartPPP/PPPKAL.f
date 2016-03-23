c
c  subroutine pppkal
c
      subroutine pppkal(rnxvsn,nsat_sys,csat_sys,nobs_typ,cobs_typ)
c
c=======================================================================
c     ****f* SmartPPP/pppkal
c
c   FUNCTION   
c   
c     kalman filter for PPP (Precise Point Positioning)
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
C     $Id: pppkal.f,v 1.0 2009/08/25 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
c
      integer       nmax
      parameter    (nmax=MAX_SAT_NUM+5)
      real*8        sigma_trop
      parameter    (sigma_trop=sqrt(0.005))
      real*8        tau_trop
      parameter    (tau_trop = 3600.0d0)
c
c     input
c
      real*8        rnxvsn
      integer       nsat_sys
      character*3   csat_sys(MAX_SAT_SYS)
      integer       nobs_typ(MAX_SAT_SYS)
      character*3   cobs_typ(MAX_SAT_SYS, MAX_OBS_TYP)
c
c     local
c
      real*8        EPOCH
      integer       EPOCH_nsat
      integer       EPOCH_flag
      integer       iPRN
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
      integer       tmp_nsat
c
      real*8        tmp_time
      real*8        tmp_time_fore
      integer       tmp_flag(MAX_SAT_NUM)
      integer       tmp_aPRN(MAX_SAT_NUM)
c
      real*8        tmp_L1, tmp_L2, tmp_P1, tmp_P2
      real*8        tmp_L3(MAX_SAT_NUM)
      real*8        tmp_P3(MAX_SAT_NUM)
c
      logical       more
c
c     variables for phasedif
c
      real*8        time_lst
c
      integer       iobs_lst, iepo_lst, iamb_lst, nobs_lst
      integer       nsat_lst
      integer       flag_lst(MAX_SAT_NUM)
      integer       aPRN_lst(MAX_SAT_NUM)
c
      real*8        L3_lst(MAX_SAT_NUM)
      real*8        P3_lst(MAX_SAT_NUM)
c!
      real*8        time_new
c
      integer       iobs_new, iepo_new, iamb_new,nobs1
      integer       nsat_new
      integer       flag_new(MAX_SAT_NUM)
      integer       aPRN_new(MAX_SAT_NUM)
c
      real*8        L3_new(MAX_SAT_NUM)
      real*8        P3_new(MAX_SAT_NUM)
c
c     pppkal
c
      integer       nvar
      integer       nobs 
      integer       flag
c
      real*8        A  (MAX_SAT_NUM,nmax)
      real*8        AT (nmax       ,MAX_SAT_NUM)
      real*8        W  (MAX_SAT_NUM,MAX_SAT_NUM)
      real*8        y  (MAX_SAT_NUM,1)
      real*8        APA(MAX_SAT_NUM,MAX_SAT_NUM  )
c
c     Kalman filter, similar to least square 
c
      real*8        AWy(nmax       ,1)
      real*8        AWA(nmax       ,nmax)
      real*8        PX (nmax       ,1)
      real*8        yy (nmax       ,1)
c
      real*8        Phi(nmax       ,nmax)
      real*8        Q  (nmax       ,nmax)
      real*8        P  (nmax       ,nmax)
c
c     Extended kalman filter
c
      real*8        Ki (nmax       ,MAX_SAT_NUM  )        
      real*8        KT (MAX_SAT_NUM,nmax)        
      real*8        Ky (nmax       ,1)
      real*8        KA (nmax       ,nmax)
      real*8        KAT(nmax       ,nmax)
      real*8        KWK(nmax       ,nmax)
      real*8        KPK(nmax       ,nmax)
c
      real*8        x0 (nmax)
      real*8        sig_x0(nmax)
      real*8        x1 (nmax,1)
c
c     loop
      integer       i, k, irec
      integer       ii,jj,kk
      logical       debug
c
      debug = .true.
c
c     INITIAL FOR Kalman Filter
c
      do i=1,MAX_SAT_NUM
      do k=1,nmax
         A(i,k)  = 0.0d0
      enddo
      enddo
c
      do i=1,nmax
      do k=1,MAX_SAT_NUM
         AT(i,k)  = 0.0d0
      enddo
      enddo
c
c
      do i=1,MAX_SAT_NUM
      do k=1,MAX_SAT_NUM
         W  (i,k) = 0.0d0
         APA(i,k) = 0.0d0
      enddo
      enddo
c
      do i=1,MAX_SAT_NUM
         y(i,1) = 0.0d0
      enddo
c
c     kalman filter similar to least square
c
      do i=1,nmax
      do k=1,nmax
         P  (i,k) = 0.0d0
         Phi(i,k) = 0.0d0
         Q  (i,k) = 0.0d0
      enddo
      enddo
c
      do i=1,nmax
         AWy(i,1) = 0.0d0
         PX (i,1) = 0.0d0
         yy (i,1) = 0.0d0
      enddo
c
      do i=1,nmax
      do k=1,nmax
         AWA(i,k) = 0.0d0
      enddo
      enddo
c
      do i=1,nmax
      do k=1,MAX_SAT_NUM
         Ki(i,k) = 0.0d0
      enddo
      enddo
c
      do i=1,nmax
         x0(i)   = 0.0d0
         x1(i,1) = 0.0d0
      enddo
c
c     INITIAL FOR READ DATA
c
      do i=1,MAX_SAT_NUM
         tmp_L3(i) = 0.0d0
         tmp_P3(i) = 0.0d0
      enddo
c
      idx_L1 = 0
      idx_L2 = 0
      idx_P1 = 0
      idx_P2 = 0
      idx_C1 = 0
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
            write(*,*) 'SmartPPP/extrobs'
            write(*,*) '  not double-frequency GPS receiver'
            stop
         endif
c
      else
c
         write(*,*) "SmartPPP/extrobs"
         write(*,*) '  Please modifiy to process rinex 3.00' 
         stop
c
      endif
c
c     Precise Point Positioning with Kalman Filter
c     ********************************************
c
c++   inital for kalman filtering loop
      iobs_new = 0
      iepo_new = 0
      iamb_new = 0
      iobs_lst = 0
      iepo_lst = 0
      iamb_lst = 0
      time_lst = 0.0d0
      time_new = 0.0d0     
c
c     kalman filter declaration matrix
      nvar = nmax
      nobs = MAX_SAT_NUM
c      
c&&   state transition matrix: phi_xx,yy,zz,tt,trop ..
c
      x0(1)    = 4849202.3940
      x0(2)    = -360328.9929 
      x0(3)    = 4114913.1862 
      x0(4)    =  0.0d0
c     trop
      x0(5)    =  0.0d0  ! trop
c
      Phi(1,1) = 1.0     !x
      Phi(2,2) = 1.0     !y
      Phi(3,3) = 1.0     !z
      Phi(4,4) = 1.0     !t
c     trop
      Phi(5,5) = 1.0     !trop
c
c     dimension from 6 to nvar
      do i=6,nvar
      Phi(i,i) = 1.0d0   ! ambiguity bias
      enddo
c
c&&   A priori covariance values (in meters)...
c
      P  (1,1) = 1.0d+10 !xx
      P  (2,2) = 1.0d+10 !yy
      P  (3,3) = 1.0d+10 !zz
      P  (4,4) = 1.0d+10 !tt
      P  (5,5) = 1.0d+10 !trop
c     dimension 6 to nvar
      do i=6,nvar
      P  (i,i) = 1.0d-10 !ambiguity bias
      enddo
c
c&&   Process noise matrix (in meters).......
c
      Q  (1,1) =1.0d+10 ! zz
      Q  (2,2) =1.0d+10 ! yy
      Q  (3,3) =1.0d+10 ! zz
      Q  (4,4) =1.0d+10 ! tt 
      Q  (5,5) =1.0d+10 ! trop
c
c++   inital for data block reading loop
c
      more = .true.
      tmp_nsat = 0
      tmp_time = 0.0d0
      tmp_time_fore = 0.0d0
c
c++   BEGINNING OF READ DATA BLOCK loop
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
      tmp_aPRN(tmp_nsat) = EPOCH_iPRN
c
      tmp_L1             = EPOCH_OBS(idx_L1)*lam_L1_GPS
      tmp_L2             = EPOCH_OBS(idx_L2)*lam_L2_GPS
      if(    idx_P1.EQ.0.and.idx_C1.NE.0)then
      tmp_P1             = EPOCH_OBS(idx_C1)
      elseif(idx_P1.NE.0)then
      tmp_P1             = EPOCH_OBS(idx_P1)
      endif
      tmp_P2             = EPOCH_OBS(idx_P2)
c
      write(*,*) tmp_L1,tmp_L2, tmp_P1, tmp_P2
c
c     LC combination
c
      tmp_L3(tmp_nsat)   = 
     &      (f1_GPS**2*tmp_L1-f2_GPS**2*tmp_L2)/(f1_GPS**2-f2_GPS**2)
      tmp_P3(tmp_nsat)   =
     &      (f1_GPS**2*tmp_P1-f2_GPS**2*tmp_P2)/(f1_GPS**2-f2_GPS**2)
c
c     store the last epoch time
c
      tmp_time_fore = tmp_time
c
      goto 100
c
c++   END read EPOCH data block
c
 200  continue
c
c++   kalman filtering
c
      if(tmp_nsat.GE.5)then
c
         iepo_new = iepo_new + 1
c
         nsat_new = tmp_nsat
         time_new = tmp_time_fore
c
         do i=1, nsat_new
c           observables           
            L3_new(i)   = tmp_L3(i)
            P3_new(i)   = tmp_P3(i)
c           aPRN
            aPRN_new(i) = tmp_aPRN(i)
            flag_new(i) = tmp_flag(i)
         enddo
c
c++      Completing Phi and Q matrix accoring to flag
c
c      - If a cycle-slip is produced
c        in the sat. PRN=k: fi_bk=0, Qbk= 9e16 m2
c      - If no cycle-slip is produced fi_bk=1, Qbk= 0
c
         do i=1, nsat_new
            flag = flag_new(i)
            iPRN = aPRN_new(i)
            if(observ_model.EQ.1)then
               if(flag.EQ.1)then
                  Q  (iPRN+5,iPRN+5) = 1.0d+10
                  Phi(iPRN+5,iPRN+5) = 0.0d0
               endif
            elseif(observ_model.EQ.2)then
               if(flag.EQ.1)then
                  Q  (iPRN+5,iPRN+5) = 1.0d+4
c                 Phi(iPRN+5,iPRN+5) = 1.0  ! old version
                  Phi(iPRN+5,iPRN+5) = 0.0  ! Modified on 20100329
c                 state parameter update
                  x0 (iPRN+5)        = L3_new(i) - P3_new(i) 
               endif
            endif
         enddo
c
         write(*,*) 'z'
c        only update the coordiante x0(1),x0(2),x0(3)
         call ppossub(time_new,nsat_new,aPRN_new,flag_new,L3_new,P3_new,
     &                x0,sig_x0)
         write(*,*) 'a#'
c
c++      BEGIN forward propagation:
c
         do i=1,nvar
            x0(i) = Phi(i,i)*x0(i)
         enddo
c
         write(*,*)time_new,(x0 (k),k=1,5)
c        ---------------------------------
c        P:= P_(n)=phi(n)*P(n-1)*phi(n)'+Q(n) ................
c
c        coordinate and clock all white noise
         Q(1,1) = 1.0D+10
         Q(2,2) = 1.0D+10
         Q(3,3) = 1.0D+10
         Q(4,4) = 1.0D+10
c
c        random walk process noise for wet tropospheric delay zpd
c        noise spectral density = sigma_trop**2/tau_trop = { 5mm/sqrt(h)}**2
c        reference Kouba 2001.
         Q(5,5) =(sigma_trop**2/tau_trop)*(time_new-time_lst)
c
         do i=1,nvar
            P(i,i)=Phi(i,i)*P(i,i)*Phi(i,i)+Q(i,i)
         enddo
c
         if(debug)then
            write(*,*) 'P'
            do i=1,nvar
               write(*,*) P(i,i)
            enddo
         endif
c
c        END of fordware propagation.
c        =================================
c++      BEGIN design matrix,weight and OMC, A,W,y:
c
         write(*,*) 'b'
         call compsObsEq2(nsat_new,aPRN_new,L3_new,P3_new,flag_new,
     &                    time_new,nvar,x0,A,W,y)
c
         if(debug)then
c           write(*,*) 'A'
c           do ii=1,nsat_new*2
c              write(*,*) (A(ii,kk),kk=1,MAX_SAT_NUM+5)
c           enddo
            write(*,*) 'W'
            do ii=1,nsat_new*2
               write(*,*) (W(ii,ii))
            enddo
            write(*,*) 'y'
            do ii=1,nsat_new*2
               write(*,*) (y(ii,1))
            enddo
         endif
c        END of design matrix,weight and OMC, A,W,y:
c        =================================
         call mtxtrs(A,AT,nobs,nvar)
         call maxbxc(AT,W ,y,AWy,nvar,nobs,nobs,1)
         call maxbxc(AT,W ,A,AWA,nvar,nobs,nobs,nvar)
c
c
         call chlinv(P,nvar)
c
c        PX = inv(P) * x^_(n)
         do i=1,nvar
            x1(i,1) = x0(i)
         enddo
c
         call mtxmul(P,X1,PX,nvar,nvar,1)
c
c        P(n)=inv[inv(P_(n))+A'(n)*W(n)*A(n)]==>  P:=inv[P + AWA]
         do i=1,nvar
         do k=1,nvar
            P(i,k) = P(i,k) + AWA(i,k)           
         enddo
         enddo
c
         if(debug)then
            write(*,*) 'P'
            do i=1,nvar
               write(*,*) P(i,i)
            enddo
         endif
c
c        call mtxinv(P,nvar)
         call chlinv(P,nvar)
c
c        x^(n) = x^(n-1) + dx0 = x^(n-1) + {inv[P + AWA]}*{A'(n)*W(n)*Y(n)}
         call mtxmul(P,AWy,x1,nvar,nvar,1)
c
         do i=1,nvar
            x0(i) = x0(i) + x1(i,1)
         enddo
c
c++      END of Measurement update
c        =================================
c++      Reinitializing variables for the next iteration ...   
c
c        ambiguity
         do i=6,nvar
            Phi(i,i) = 1.0d0   ! ambiguity bias
            Q  (i,i) = 0.0d0
         enddo
c
         do i=1,nobs
         do k=1,nobs
            W  (i,k) = 0.0d0
            APA(i,k) = 0.0d0
         enddo
         enddo
c
c++      write parameters
c           
         write(201,'(6F14.3)') ,time_new,(x0(k),k=1,5)
         write(  *,'(A6,6F14.3)') '###',time_new,(x0(k),k=1,5)
c
c++      store current information into temporary arry
c
         iepo_lst = iepo_new
         nsat_lst = nsat_new 
         time_lst = time_new
c
         do i=1, nsat_lst
c           observables
            L3_lst(i)   = L3_new(i)
            P3_lst(i)   = P3_new(i)
c           aPRN 
            aPRN_lst(i) = aPRN_new(i)
            flag_lst(i) = flag_new(i)
         enddo
c
      endif
c
      tmp_nsat = 0
c
c     END of DATA FILE 
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
