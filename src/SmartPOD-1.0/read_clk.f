*
*  subroutine read_clk
*      
      subroutine read_clk()
c
c=======================================================================
c     ****f* SmartPPP/read_clk
c
c   FUNCTION   
c   
c     read IGS clock data from file.
c
c   INPUTS
c
c     NONE
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
C     $Id: read_clk.f,v 1.0 2009/07/29 $
c=======================================================================
*
*     enviroment variable
*         
      IMPLICIT NONE
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
      include      '../../include/igs.h'
c
      real*8        cal2sec
c
c     input/output variable
c
      integer       NREC_CLK(MAX_PRN)
c
      real*8        clk(MAX_PRN, MAX_REC_CLK, 2)
c
c     local
c
      integer       i, j, k
      integer       iPRN, nrec_all, nsat
      integer       npms
      integer       PRN(MAX_PRN)
      integer       year, month, day, hour, minu, sec_int
c
      real*8        sec, sec_dec
      real*8        tepo, tepo_last
      real*8        tclk(2)
c
      character*80  line, line_continue
      character*20  flag
      character*01  sys
      character*02  cha
      character*04  stat
      character*02  ctype
c
c     common
c
      common /CLK/  NREC_CLK, clk
c
c     read header, PRN from header
c
      nsat = 0
      tepo  = 0.0d0
      tepo_last  = 0.0d0
c
      do i=1, MAX_PRN
      do j=1, MAX_REC_CLK
         clk(i, j, 1) = 0.0d0
         clk(i, j, 2) = 0.0d0
      enddo
      enddo
c
      do i=1, MAX_PRN
        NREC_CLK(i) = 0
      enddo
c
100   continue
c
c     read line
c
      read(103, '(A80)', end=444) line      
c
      flag = line(61:80)
c
      if(flag.eq.'PRN LIST            ')then
         do i=1, 15
           sys = line(4*(i-1)+1:4*(i-1)+1)
           if(sys.eq.'G')then
              nsat = nsat + 1  
              cha  = line(4*(i-1)+2:4*(i-1)+3)
              read(cha, '(I2)') PRN(nsat)
           endif
         enddo 
c
        if(nsat.gt.MAX_PRN)then
c
           write(*,*) ' read_clk '
           write(*,*) ' please enlarge the parameter MAX_PRN in igs.h'
           stop
c
        endif
c
      endif
c
      if(flag.eq.'END OF HEADER       ')then
c
         goto 200
c
      endif
c
      goto 100
c
c     read clock correction data
c
200   continue      
c
      read(103, '(A80)', end=444) line 
*
*     read the type flag and parameter number to detimine which line is
*     for the satellite clock correction
*
      read(line, 1000) ctype, stat, year, month, day, hour, minu, sec,
     +                 npms,(tclk(i),i=1, 2)
c
c     format
c
1000  format(A2,1X,A4,1X,I4,4I3,F10.6,I3,3X,E19.12,X,E19.12)
c
c     if parameter great than 2, then read a new line
c
      if(npms.gt.2)then
c
         read(103, '(A80)', end=444) line_continue
c
      endif   
c
c     Time conversion
c
      sec_int  = int(sec)
      sec_dec  = sec - sec_int
      tepo     = cal2sec(year,month,day,hour,minu,sec_int,sec_dec)
c
c     "AS", clock correction for satellite
c
      if(ctype.eq.'AS')then
*
*        read PRN from statation string
*
         read(stat, '(A1,I2)') sys, iPRN
*     
*        accumulate the number for each satellite
*   
         NREC_CLK(iPRN) = NREC_CLK(iPRN) + 1 
*
c        output warning if maximum number of clock is not enough
*
         if(NREC_CLK(iPRN).gt.MAX_REC_CLK)then
c
            write(*,*) ' read_clk '
            write(*,*) ' please modify MAX_REC_CLK in igs.h '
            write(*,*)   NREC_CLK(iPRN)
            stop
c
         endif
*
*        store the clock data
*
         clk(iPRN, NREC_CLK(iPRN), 1) = tepo
         clk(iPRN, NREC_CLK(iPRN), 2) = tclk(1)
c
      endif
*
*     read a new line
*
      goto 200
c
444   continue
c
      return
c
      end
