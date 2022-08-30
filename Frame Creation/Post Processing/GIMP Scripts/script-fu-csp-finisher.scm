(define (save-png theImage currentLayer fullDestination)
	(file-png-save2 1 theImage currentLayer fullDestination fullDestination FALSE 9 FALSE TRUE FALSE TRUE TRUE FALSE FALSE)
)

(define (script-fu-csp-finisher theImage saveName)
	(let*	(
		(theLayer (car (gimp-image-get-active-layer theImage))) ; get the currently active layer
		)

; preliminary set-up
;	(gimp-image-undo-disable theImage) ; Disable saving of the undo state for improved performance
;	(gimp-layer-add-alpha theLayer) ; give the frame an alpha layer

; create a palette for the image
	

; remove frame data
	(gimp-message " - Removing frame data display and cropping.")
	(gimp-image-select-rectangle theImage 0 48 66 1080 95)
	(gimp-context-set-background '(0 0 0))
	(gimp-edit-fill theLayer 1)
	(gimp-selection-none theImage)

; perform The Crop
	(gimp-image-crop theImage cropWidth cropHeight offx offy)

; establish context for selection operation
	(gimp-message " - Performing selection.")
	(gimp-context-set-antialias TRUE)
	(gimp-context-set-feather TRUE)
	(gimp-context-set-feather-radius 1 1)
;	(gimp-context-set-sample-merged TRUE/FALSE) ; Whether to use selected layer or a merger of all layers
	(gimp-context-set-sample-criterion 4) ; Sets selection criterion to "by Hue" (SELECT-CRITERION-H)
	(gimp-context-set-sample-threshold-int inThreshold) ; Sets selection threshold

; select areas to add transparency to
;	(gimp-image-select-color theImage 0 theLayer '(0 0 0)) ; Seeks hues matching black
	(gimp-message " - Building alpha layer.")
	(gimp-image-select-contiguous-color theImage 0 theLayer 0 0) ; Seeks by seed-fill by hue matching
	(gimp-selection-grow theImage 1)
	(plug-in-colortoalpha 1 theImage theLayer '(0 0 0)) ; Remove traces of black
	(gimp-selection-none theImage)

; reduce image size by factor of 3
	(gimp-message (string-append " - Resizing frame to " (number->string finWidth) " by " (number->string finHeight) "."))
	(gimp-context-set-interpolation 2) ; 0:none, 1:linear, 2:cubic, 3:lanczos
	(gimp-image-scale theImage finWidth finHeight)

; finalization clean-up
;	(gimp-image-undo-enable theImage)

	)
)



;(file-png-save-defaults 1 inputImage originalBoxLayer filename filename)




	;Interesting:

;gimp-edit-paste arg2


;============================================
; Script registration
;============================================

	
(script-fu-register
  "script-fu-single-frame-converter"				; func name
  "Convert individual"								; menu label
  "Removes a selected frame's black\ 
  background, and replaces the hitboxes\ 
  with transparent ones."							; description
  "Daniel R. Cappel (DRGN)"							; author
  "copyright 2012, Daniel R. Cappel"				; copyright notice
  "March 25, 2012"									; date created
  ""												; image type that the script works on
  SF-VALUE	"The target image"			"1"			; Gimp's ID for the target image/project
  SF-VALUE	"Crop width"				"1170"		; New width after crop
  SF-VALUE	"Crop height"				"840"		; New height after crop
  SF-VALUE	"X-axis crop offset"		"230"
  SF-VALUE	"Y-axis crop offset"		"121"
  SF-VALUE	"Selection Threshold"		"1"			; Threshold for color selection
)

(script-fu-menu-register "script-fu-single-frame-converter" "<Image>/Frame Rebuilding")
