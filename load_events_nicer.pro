FUNCTION load_events_nicer, filename, fileroot=fileroot, t0=t0, texp=texp, $
     chan_lim=chan_lim, gti=gti, CHATTER=chatter, $
     pi=pi, PATT_LIM=patt_lim, FRAME_TIME=frame_time, N_WINDOW=n_window
     

   ; ----------------------------------------------------------
   ;+
   ; NAME:
   ;       LOAD_EVENTS
   ;
   ; PURPOSE:
   ;       Read NICER events from filtered events file (FITS)
   ;       Need to change col_list depending on how events.fits was created
   ;       
   ; AUTHOR:
   ;       William Alston
   ;
   ; CALLING SEQUENCE:
   ;       t = LOAD_EVENTS_NICER("events.fits")

   ; INPUTS:
   ;       FILENAME  - (string) file name
   ;
   ; OPTIONAL INPUTS:
   ;       CHATTER      - (integer) amount of output to screen
   ;       CHAN_LIM     - (array) set lower and upper PI channel boundaries
   ;       PATT_LIM     - (array) set lower and upper PATTERN ranges
   ;
   ; OUTPUTS:
   ;       T         - vector of event arrival times
   ;
   ; OPTIONAL OUTPUTS:
   ;       T0        - (double) time (MET sec) of first event
   ;       TEXP      - (float) Expsure time (from LIVETIME keyword)
   ;       GTI       - (array) two column table of good start/stop times
   ;       PI        - (vector) list of event PI (energy in eV)
   ;       FRAME_TIME - (float) frame time of event file (in sec)
   ;
   ; PROCEDURES CALLED:
   ;       READFITS, TBGET, SXPAR, FITS_INFO  
   
   
; options for compilation (recommended by RSI)
     
  COMPILE_OPT idl2
   
; watch out for errors
   
   ON_ERROR, 0
   
; ----------------------------------------------------------
; Check the arguments
   
; is the file name defined?
   
   IF (n_elements(filename) eq 0) THEN BEGIN
     filename = ''
     READ,'-- Enter file name (Hit ENTER to list current directory): ',filename
     IF (filename eq '') THEN BEGIN
       list = findfile()
       PRINT, list
       READ,'-- Enter events file name: ',filename
     ENDIF
   ENDIF 
   
 ;;  file = "events_gtifilt.fits"
 
 
; ----------------------------------------------------------
; call READFITS to read the data from FITS file
   
   IF KEYWORD_SET(fileroot) THEN BEGIN
     file = fileroot+filename
   ENDIF ELSE BEGIN
     file = filename
   ENDELSE
 
 
 
   filedata = READFITS(file, htab, EXTEN_NO=1, SILENT=silent)
   
   
     col_list = [1, 12]
     col_list = [1, 2] ;;; modified for different events file.
   
   time = TBGET(htab, filedata, col_list[0], /NOSCALE)
   pi = TBGET(htab, filedata, col_list[1])
   
   
;------
; get gti
; call READFITS to read the data from FITS file
   
   filedata = READFITS(file, htab, EXTEN_NO=2, SILENT=silent)
   
   
     ; how many rows are there in the file?
   
   n_row = SXPAR(htab, "NAXIS2")
   n_window = n_row
   ; prepare data array for output
   
   gti = MAKE_ARRAY(n_row, 2, /DOUBLE)
   
   ; now convert two columns - start, stop times -
   ; from binary to floating point
   
   x = TBGET(htab, filedata, 1)
   gti[0,0] = x[*]
   x = TBGET(htab, filedata, 2)
   gti[0,1] = x[*]
   x = 0
   
   ; define t0 as start of first listed GTI
   ;  and subtract this from the time arrays
   
   t0 = gti[0,0]
   gti = gti - t0
   time = time - t0
 ;;print, t0 
 
; ----------------------------------------------------------
; apply the channel limits if required
   
   IF KEYWORD_SET(chan_lim) THEN BEGIN
   
     mask = WHERE(pi ge chan_lim[0] and pi le chan_lim[1], count)
     time = time[mask]
     pi = pi[mask]
     pattern = pattern[mask]
     
   ENDIF 
   
   
; ----------------------------------------------------------
   
   RETURN, time
   
 END  
   
   
   
   
   
