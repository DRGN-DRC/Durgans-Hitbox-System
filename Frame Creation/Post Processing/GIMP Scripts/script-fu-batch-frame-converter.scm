(define (script-fu-batch-frame-converter globPath destination cropWidth cropHeight offx offy inThreshold)
	(define (add-alpha totalFiles f)
		(let*	(
; Define variables
			(fileName (car f))
			(theImage (car (gimp-file-load 1 fileName fileName))) ; get image name
			(theLayer (car (gimp-image-get-active-layer theImage))) ; get layer
                     
; Get filename, parse for frame number, and append destination filepath with the current frame number and file extension
			(thisFileName (car (last (cdr (strbreakup (car (gimp-image-get-filename theImage)) "\\")))))
			(thisFrameNumber (cadr (strbreakup (car (strbreakup thisFileName ")")) "(")))
			(fullDestination (string-append destination thisFrameNumber ".png")
			)
;		theLayer
                )
		(gimp-message (string-append "Beginning processing of " thisFileName "..."))
; modify file
		(script-fu-single-frame-converter theImage cropWidth cropHeight offx offy inThreshold)

; save file
		(file-png-save2 1 theImage theLayer fullDestination fullDestination FALSE 9 FALSE TRUE FALSE TRUE TRUE FALSE FALSE)
		(gimp-image-delete theImage)
;probably dont need (gimp-image-undo-enable theImage)
		(gimp-message (string-append thisFileName " completed."))
			
		)
		(if (= totalFiles 1) 1 (add-alpha (- totalFiles 1) (cdr f)))
	)

	(let*	(
                (files (file-glob globPath 0)
		)
	)

	(add-alpha (car files) (car (cdr files)))
    )
)



;(file-png-save-defaults 1 inputImage originalBoxLayer filename filename)




	;Interesting:

;gimp-edit-paste arg2


;============================================
; Script registration
;============================================

	
(script-fu-register
  "script-fu-batch-frame-converter"				;func name
  "Convert batch"						;menu label
  "Removes a selected frame's black\ 
  background, and replaces the hitboxes\ 
  with transparent ones."					;description
  "Daniel R. Cappel (DRGN)"					;author
  "copyright 2012, Daniel R. Cappel"				;copyright notice
  "March 25, 2012"						;date created
  ""								;image type that the script works on
  SF-STRING   "Source file path with wildcard"	"C:\\example\\originals\\*.png"	;Source path
  SF-STRING   "Destination folder (end with '\\')"		"C:\\example\\"	;Destination path
  SF-VALUE	"Crop width"			"1170"		; New width after crop
  SF-VALUE	"Crop height"			"840"		; New height after crop
  SF-VALUE	"X-axis crop offset"		"230"
  SF-VALUE	"Y-axis crop offset"		"121"
  SF-VALUE	"Selection Threshold"		"1"		; Threshold for color selection
)
(script-fu-menu-register "script-fu-batch-frame-converter" "<Image>/Frame Rebuilding")
