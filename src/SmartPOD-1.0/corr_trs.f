c
c  subroutine corr_trs.f
c
      subroutine corr_trs(Time,iPRN,xrcv,xtrs,vtrs,ctrs)
c
c=======================================================================
c     ****f* SmartPPP/corr_trs.f
c
c   FUNCTION   
c   
c     calculate the Transmitter(GPS) postion, velocity, and clock error
c
c   INPUTS
c
c     time           real*8        second past J2000.0
c     iPRN           integer       PRN number
c     xrcv           real*8        receiver parameter
c
c   OUTPUT
c
c     xtrs           real*8        transmitter position
c     vtrs           real*8        transmitter velocity
c     ctrs           real*8        transmitter clock
c
c
c   COPYRIGHT
c
c     Copyright(c) 2006-           Shoujian Zhang,
c                                  School of Geodesy and Geomatics,
c                                  Wuhan University.
c   REVISION
c
c     2009/08/01                   programmed
c
c     ***
c
C     $Id: corr_trs.f.f,v 1.0 2009/07/28 $
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
c
c     input/output variable
c
c     input
      real*8        Time
      integer       iPRN
      real*8        xrcv(3)
c
c     output
c
      real*8        xtrs(3)
      real*8        vtrs(3)
      real*8        ctrs
c
c     local
c
      integer       i, j, k
      integer       iter
c
      real*8        tol
      real*8        dis
c
      real*8        tr, ts0, ts1
      real*8        dT
      real*8        t0(MAX_REC_SP3)
      real*8        x1(MAX_REC_SP3)
      real*8        x2(MAX_REC_SP3)
      real*8        x3(MAX_REC_SP3)
      real*8        v1(MAX_REC_SP3)
      real*8        v2(MAX_REC_SP3)
      real*8        v3(MAX_REC_SP3)
      real*8        t1(MAX_REC_CLK)
      real*8        c1(MAX_REC_CLK)
c
      real*8        xtrs1,xtrs2,xtrs3
      real*8        vtrs1,vtrs2,vtrs3
c
c     common
c
      integer       NREC_SP3(MAX_PRN) 
      REAL*8        EPH(MAX_PRN, MAX_REC_SP3, 4)
c
      common /SP3/  NREC_SP3, EPH
c
      integer       NREC_CLK(MAX_PRN)
      real*8        clk(MAX_PRN, MAX_REC_CLK, 2)
c
      common /CLK/  NREC_CLK, clk
c
      do i=1,3
      xtrs(i) = 0.0d0
      vtrs(i) = 0.0d0
      enddo
c
      tr = Time
      dT = 0.075d0
c
      do i=1, NREC_SP3(iPRN)
         t0(i) = EPH(iPRN,i,1)
         x1(i) = EPH(iPRN,i,2)*1000.0d0
         x2(i) = EPH(iPRN,i,3)*1000.0d0
         x3(i) = EPH(iPRN,i,4)*1000.0d0
      enddo
c
      do i=1, NREC_CLK(iPRN)
         t1(i) = CLK(iPRN,i,1)
         c1(i) = CLK(iPRN,i,2)
      enddo
c
c     iteration
c     =========
c
      tol = 1.0D-10
c
      do iter=1, MAX_ITER
c
c        transmitter sending time update
c
         ts0 = tr - dT

c        write(*,*) ts0
c
c        position interpolation
c
         call lagrange      (t0,x1,NREC_SP3(iPRN),ts0,xtrs1)  
         call lagrange      (t0,x2,NREC_SP3(iPRN),ts0,xtrs2)  
         call lagrange      (t0,x3,NREC_SP3(iPRN),ts0,xtrs3)  
c
         xtrs(1) = xtrs1
         xtrs(2) = xtrs2
         xtrs(3) = xtrs3

c        write(*,*) 'iter', iter
c        write(*,*)  xtrs(1), xtrs(2), xtrs(3)
c
c        velocity interpolation
c
         call lagrange_deriv(t0,x1,NREC_SP3(iPRN),ts0,vtrs1)  
         call lagrange_deriv(t0,x2,NREC_SP3(iPRN),ts0,vtrs2)  
         call lagrange_deriv(t0,x3,NREC_SP3(iPRN),ts0,vtrs3)  
c
         vtrs(1) = vtrs1
         vtrs(2) = vtrs2
         vtrs(3) = vtrs3

c        write(*,*)  vtrs(1), vtrs(2), vtrs(3)
c
c        clock interpolation
c
         call linear_interp (t1,c1,NREC_CLK(iPRN),ts0,ctrs)

c        write(*,*) ctrs
c
c        tramsimitter's phase center offset correction
c
         call corr_trs_pco(ts0,iPRN,xtrs)

c        write(*,*) 'b'
c        write(*,*)  xtrs(1), xtrs(2), xtrs(3)
c
c        reference frame rotation
c
         call earth_rotation(dT,xtrs)

c        write(*,*) 'c'
c        write(*,*)  xtrs(1), xtrs(2), xtrs(3)
c
c        distance 
c
         call distance(xrcv,xtrs,dis)
c
         dT  = dis/c_light
c
         ts1 = tr - dT
         
c        write(*,*) ts1
c
c        converged??
c
         if(dabs(ts1-ts0).LT.tol)then
c
c           write(*,*) 'corr_trs iteration', iter
c
            exit
c
         endif
c
      enddo
c
      return
c
      end
