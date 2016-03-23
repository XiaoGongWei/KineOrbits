c
c   subroutine  ppossub
c
         subroutine ppossub(time,nsat,aPRN,flag,L3,P3,x1,sig_x1)
c
c=======================================================================
c     ****f* SmartPPP/ppossub
c
c   FUNCTION   
c   
c     point positioning with P3 combination 
c
c   INPUTS
c
c
c   OUTPUT
c
c
c   COPYRIGHT
c
c     Copyright(c) 2006-        Shoujian Zhang,
c                               School of Geodesy and Geomatics,
c                               Wuhan University.
c     ***
c
C     $Id: ppossub.f,v 1.0 2009/07/27 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
c
      real*8        time
c
      integer       nsat
      integer       flag(MAX_SAT_NUM)
      integer       aPRN(MAX_SAT_NUM)
c
      real*8        L3(MAX_SAT_NUM)
      real*8        P3(MAX_SAT_NUM)
c
      real*8        A(MAX_SAT_NUM,6)
      real*8        P(MAX_SAT_NUM,MAX_SAT_NUM)
      real*8        L(MAX_SAT_NUM,1)
c
      real*8        x1(*)
      real*8        sig_x1(*)
c
c     local
c
      integer       ndim     
      integer       nobs
      integer       iter
      logical       convgd
      integer       ii,jj,kk
      logical       debug
c
      real*8         x0(6)
      real*8        dx0(6)
c
      real*8        Qxx(6,6)
      real*8        sig
c
      debug = .false.
c
      call x_dim1(ndim)
      call x_ini1(ndim,x1,x0,dx0)
      iter = 1
      convgd = .false.
c
      do while(iter.lt.MAX_ITER)
c
         write(*,*) ' iter times',iter
c
         call x_update1(ndim,x0,dx0)
c
c+++     compose observation equation: NOTES tmp_time_fore !!!
c
         call compsObsEq1(nsat,aPRN,L3,P3,flag,time,ndim,x0,A,P,L)
c
         if(debug)then
         write(*,*) 'compsObsEq1'
         write(*,*) 'A'
         do ii=1,nsat
            write(*,*) (A(ii,kk),kk=1,5)
         enddo
         write(*,*) 'P'
         do ii=1,nsat
            write(*,*) (P(ii,ii))
         enddo
         write(*,*) 'L'
         do ii=1,nsat
            write(*,*) (L(ii,1))
         enddo
         endif
c
c+++     solve   observation equation
c   
         call solveObsEq1(nsat,ndim,A,P,L,dx0,sig,Qxx)
c
c+++     converged?
c
         call x_convgd1(ndim,dx0,convgd)
c
         if(convgd)then
            EXIT
         endif
c
         iter = iter + 1
c
      enddo
c
      x1(1) = x0(1)
      x1(2) = x0(2)
      x1(3) = x0(3)
      x1(4) = x0(4)
c
      sig_x1(1) = sig*dsqrt(Qxx(1,1))
      sig_x1(2) = sig*dsqrt(Qxx(2,2))
      sig_x1(3) = sig*dsqrt(Qxx(3,3))
      sig_x1(4) = sig*dsqrt(Qxx(4,4))
c
      return
c
      end
