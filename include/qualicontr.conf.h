c
c     ischeme
c
      integer   ischeme
c
c     minimum signal strength
c
      integer   min_snr
c
c     minimum satellite elevation(elevation mask angle)
c
      integer   min_elv 
c
c     min_snr or min_elv
c
      integer   snr_or_elv
c
c     maximum internal point gap interval of an arc
c
      integer   max_arc_gap
c
c     minimum arc point number
c
      integer   min_arc_pnt
c
c     COMMON
c
      common /qualicontr_conf/ ischeme, min_snr, min_elv, 
     +                         snr_or_elv, max_arc_gap, min_arc_pnt
c
c     END
c
