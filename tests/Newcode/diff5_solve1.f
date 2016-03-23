c
c   subroutine diff5_solve1
c
      subroutine diff5_solve1(m,n,df5Ts,Ts0,lsat,Ts1)
c
c=======================================================================
c     ****f* qualicontr/diff5_solve1
c
c   FUNCTION   
c
c     sovle the 5th-order difference equation forward.
c
c   INPUTS
c     
c     m             (I)         first record of df5Ts
c     n             (I)         last  record of df5Ts
c     df5Ts         (R)         5-th order difference of Ts
c     Ts0           (R)         raw time series
c
c   OUTPUT
c
c     Ts1           (R)         recovered time series
c
c   COPYRIGHT
c
c     Copyright(c) 2006-        Shoujian Zhang,
c                               School of Geodesy and Geomatics,
c                               Wuhan University.
c     ***
c
C     $Id: diff5_solve1.f,v 1.0 2009/07/20 $
c=======================================================================
c
      implicit none
c
c     include
c
      include      '../../include/rinex.h'
c
c     input/output
c
c     input
      integer       m, n
c
      real*8        df5Ts(MAX_OBS_REC)
      real*8        Ts0  (MAX_OBS_REC)
      integer       lsat (MAX_OBS_REC)
c     output
      real*8        Ts1  (MAX_OBS_REC)
c
      integer       i,j,k
c
c     nobs X nparams
c     nparams = n-(m-5) + 1              = n-m+6
c     nobs    = n- m    + 1 + (n-m+1+5)(initial) = 2*(n-m+1)+5
c
      real*8        A   ( 2*(n-m+1)+5,   N-M+6   )
      real*8        P   ( 2*(n-m+1)+5,2*(n-m+1)+5)
      real*8        L   ( 2*(n-m+1)+5,       1)
      real*8        AT  (    N-M+6   ,2*(n-m+1)+5)
      real*8        ATP (    N-M+6   ,2*(n-m+1)+5)
      real*8        ATPA(    N-M+6   ,   N-M+6   )
      real*8        ATPL(    N-M+6   ,       1)
      real*8        X   (    N-M+6   ,       1)
c
      integer       nobs, npms
      integer       ncol, nrow
c
      do i=1,2*(n-m+1)+5
      do j=1,   N-M+6
         A(i,j)   = 0.0d0
      enddo
      enddo
c
      do i=1,2*(n-m+1)+5
      do j=1,2*(n-m+1)+5
         P(i,j)   = 1.0d0
      enddo
      enddo
c
      do i=1,2*(n-m+1)+5
         L(i,1)   = 0.0d0
      enddo
c
      do i=1,   N-M+6
      do j=1,2*(n-m+1)+5
         AT(i,j)  = 1.0d0
      enddo
      enddo
c
      do i=1,   N-M+6
      do j=1,2*(n-m+1)+5
         ATP(i,j) =0.0d0
      enddo
      enddo
c
      do i=1,N-M+6
      do j=1,N-M+6
         ATPA(i,j)=0.0d0
      enddo
      enddo
c
      do i=1,N-M+6
         ATPL(i,1)=0.0d0
      enddo
c
      do i=1,N-M+6
         X(i,1)   =0.0d0
      enddo
c
c     nobs : actual obseravtion
c
      nobs = n-m+1
      npms = n-m+6
c
      do i=1,nobs
c
      A(i,i  )   =  -1
      A(i,i+1)   =   5
      A(i,i+2)   = -10
      A(i,i+3)   =  10
      A(i,i+4)   =  -5
      A(i,i+5)   =   1
c
      if(dabs(df5Ts(i+m-1)).gt.30.0d0)then
         L(i,1)     =  0
         P(i,i)     =  0.0001**2/200**2
      else
         L(i,1)     =  df5Ts(i+m-1)
         P(i,i)     =  0.0001**2/0.02**2
      endif
c
c     write(*,'(20F8.3)') (A(i,k),k=1,npms),L(i,1),df5Ts(i+m-1)
c
      enddo
c
c     initial for is the parameter to be estimated
c
      do i=1,(n-m+6)
c
         A(i+nobs,i     )  = 1
c
c        L(i+nobs,1     )  = Ts0(i+m-1-5)
         L(i+nobs,1     )  = 0.0d0
         P(i+nobs,i+nobs)  = 0.0001**2/10.0**2
c
      enddo
c
      nrow = 2*(n-m+1)+5
      ncol =    n-m+6
c
      call mtxtrs(A,  AT,      nrow,ncol)
c
      call mtxmul(AT, P, ATP,  ncol,nrow,nrow)
      call mtxmul(ATP,A, ATPA, ncol,nrow,ncol)
      call mtxmul(ATP,L, ATPL, ncol,nrow,1)
c
      call mtxinv(ATPA,ncol)
c
      call mtxmul(ATPA,ATPL,X,ncol,ncol,1)
c
      do i=1,N-M+6
c
      Ts1(i+M-6) = X(i,1)
c
      enddo
c
      return
c
      end
