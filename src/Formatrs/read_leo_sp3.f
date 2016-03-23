*
*  subroutine read_sp3
*      
      subroutine read_sp3()
c
c=======================================================================
c     ****f* SmartPPP/read_sp3
c
c   FUNCTION   
c   
c     read IGS SP3 precise ephemeris data from file.
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
C     $Id: read_sp3.f,v 1.0 2009/07/27 $
c=======================================================================
c
      implicit none
c
      include      '../../include/rinex.h'
      include      '../../include/rinex.conf.h'
      include      '../../include/SmartPPP.h'
      include      '../../include/SmartPPP.conf.h'
      include      '../../include/igs.h'
c         
      real*8        cal2sec
c
      integer       nsat
      integer       NREC_SP3(MAX_PRN) 
      integer       PRN(MAX_PRN)
      integer       date(3)
c
      REAL*8        EPH(MAX_PRN, MAX_REC_SP3, 4)
c
c     Declaration_of_the_Local_Variables
c
      integer       i, j, k
      integer       iPRN
      integer       index_iPRN
      integer       isat
      integer       year, month, day, hour, minu
      integer       sec_int
      logical       find
c
      real*8        sec
      real*8        sec_dec
      real*8        tepo
      real*8        X, Y, Z
c
      character*60  line
      character*02  version
      character*02  flag
      character*01  sys
c
      common /SP3/  NREC_SP3, EPH
c
c     initial
c
      nsat = 0
c  
      do i=1, MAX_PRN
         PRN(i) = 0
      enddo
c
      do i=1, MAX_PRN
         NREC_SP3(i) = 0
      enddo
c
      do i=1, MAX_PRN
      do j=1, MAX_REC_SP3
         EPH(i, j, 1) = 0.0d0
         EPH(i, j, 2) = 0.0d0
         EPH(i, j, 3) = 0.0d0
         EPH(i, j, 4) = 0.0d0
      enddo
      enddo
c
      nsat = 0
c
c     read SP3 header
c
100   continue
c   
      read(102, '(A60)', end=200) line 
c
c     Read flag
c
      flag = line(1:2)
c
c     read version and time
c
      if(flag.eq.'#c'.or.flag.eq.'#b'.or.flag.eq.'#a')then
c
c        read file date
c
         read(line, fmt=1000) date(1), date(2), date(3)
c
1000     format(2X,  x, I4, X, I2, X, I2, 47x)
c
c        read a new line
c
         goto 100
c
      endif
c
c     read iPRN
c
      if(flag.EQ.'+ ')then
c
c        loop all the satellite numbers
         do i=1, 17
c
*           c.f. IGS ephemeris file conventions
            sys = line((9+3*(i-1)+1):(9+3*(i-1)+1))
c
c           only for LEO satellites
            if(sys.eq.'L')then
c
               flag = line( (9+3*(i-1)+2):(9+3*(i-1)+3) )      
               read(flag, '(I2)') iPRN
c
c              search iPRN in PRN array
               find = .false.
c
               call linear_search(iPRN,MAX_PRN,PRN,index_iPRN,find)
c
c              if iPRN is not found in the PRN list, then write it
c              into PRN array 
               if(.NOT.find)then
                  nsat      = nsat + 1
                  PRN(nsat) = iPRN
               endif
c
            endif
c
          enddo
c
c         satellite number more than MAX_PRN
c
          if(nsat.gt.MAX_PRN)then
             write(*,*) ' read_sp3 '
             write(*,*) ' please modify MAX_PRN in rinex.h'
             stop
          endif
c
c         read a new line
c
          goto 100
c
      endif
*
*     read ephemeris time header
*   
      if(flag.eq.'* ')then
*
*        read time 
*
         read(line, fmt=3000) year,month,day,hour,minu,sec
c
3000     format(2x, 1x, I4, 4(1x, I2),1x, F11.8)
c
c        time conversion
c
         sec_int  = int(sec)
         sec_dec  = sec - sec_int
         tepo     = cal2sec(year,month,day,hour,minu,sec_int,sec_dec)
c
c        read a new line
c
         goto 100
c
      endif
c
c     read goce ephemeris data
c
      if(flag.eq.'PL'.or.flag.eq.'P ')then
c
c        read xyz       
c
         read(line,fmt=4000) flag, iPRN, x, y, z
c
4000     format(A2, I2, 3F14.6, 14x)
c
c        accumulate record for iPRN
c
         NREC_SP3(iPRN) = NREC_SP3(iPRN) + 1 

c        write(*,*) iPRN, NREC_SP3(iPRN)
c
c        number for iPRN exceeds ?
c
         if(NREC_SP3(iPRN).gt.MAX_REC_SP3)then
            write(*,*) 'SmartPPP/read_sp3'
            write(*,*) 'please modify MAX_REC_SP3 in igs.h'
            write(*,*) 'NREC =', NREC_SP3(iPRN)
            stop
         endif
c
         EPH(iPRN, NREC_SP3(iPRN), 1) = tepo
         EPH(iPRN, NREC_SP3(iPRN), 2) = X
         EPH(iPRN, NREC_SP3(iPRN), 3) = Y
         EPH(iPRN, NREC_SP3(iPRN), 4) = Z
c
c        read a new line
c
         goto 100
c
      endif
c
c     read a new line
c
      goto 100
c
200   continue
c     
      return
c
      end
