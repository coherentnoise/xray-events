FUNCTION make_nicer_lc, file, dt=dt, T0=t0, TIME=time, SEG_LIST=seg_list;,$

                     
 ; ----------------------------------------------------------
;+
; NAME:
;       MAKE_NICER_LC
;
; PURPOSE:
;       Extract time series from NICER events file
;       events have been filtered using e.g. XSELECT
;
; AUTHOR:
;       William Alston
;
; CALLING SEQUENCE:
;        = MAKE_NICER_LC("events.fit")
;
; CALLS:
;    LOAD_EVENTS_NICER

; set the GTI 'pruning' parameters if not set already

  IF NOT KEYWORD_SET(t_clip_start) THEN t_clip_start = 1.0D
  IF NOT KEYWORD_SET(t_clip_end) THEN t_clip_end = 1.0D




; load the source event file for instrument i

      t_s = LOAD_EVENTS_NICER(file, fileroot=rootpath, t0=t0_i, $
                        chan_lim=chan_lim, gti=gti, pi=pi_s, $
                        CHATTER=chatter, PATT_LIM=patt_lim, $
                        FRAME_TIME=frame_time, N_WINDOW=N_window)

; need to loop over each gti window - assumes these are good windows - previously filtered
 i=0
    FOR i = 0, N_window-1 DO BEGIN

          t0 = t0_i 
          tstart = gti[i,0]
          tend = gti[i,1]
          
          ; apply 'pruning' of exposure
         
          tstart = tstart; + t_clip_start
          tend = tend; - t_clip_end
          n_timebins = FLOOR((tend-tstart) / dt)



          ; use HISTOGRAM to make a time series, i.e. counts per time bin

          hist = HISTOGRAM(t_s, BINSIZE=dt, MIN=tstart, MAX=tend, LOCATIONS=t_ij)

          N_bin = N_ELEMENTS(t_ij)
          bin_N = N_bin - 2 ;; HISTOGRAM gives one too many bins - last empty
;help, bin_N
    ob_rate = hist[0:bin_N]
    N = N_ELEMENTS(ob_rate)
;help, ob_rate

; make seg_list variable 
IF (i eq 0) THEN seg_list = MAKE_ARRAY(N_window, 2, /LONG)
  IF (i eq 0) THEN BEGIN 
    seg_list[0,*] = [0, N-1]
    
    data_x = ob_rate
  ;;  data_e = ob_rerr
    Nrun = N
  ENDIF ELSE BEGIN

    seg_list[i,*] = [Nrun,Nrun+N-1]

    data_x   = [data_x, ob_rate]
    help, data_x
  ;;  data_e   = [[data_e], [ob_rerr]]
    
    Nrun = Nrun + N
  ENDELSE 


  ENDFOR


;;; need to work out error = sqrt(counts/bin)/dt

; convert from count/bin to count/sec 

  data_x = TEMPORARY(data_x) / DOUBLE(dt)



; ---------------------------------------------------------
; Return to user

  RETURN, data_x

END



