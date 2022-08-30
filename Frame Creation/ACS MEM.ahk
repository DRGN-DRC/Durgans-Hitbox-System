	; Automatic Camera Set-up - Memory Edit Method
	; Created by DRGN
	; Version 2.2


		; Table of Contents:


	; Environment Initialization:          Ctrl + Shift + ` (tild)

	; ACS MEM (Memory Edit Method):        Ctrl + Shift + 1

	; ACS MEM, Tracking Mode:              Ctrl + Shift + 2

	; ACS MEM, Overhead Static Mode:       Ctrl + Shift + 3

	; ACS MEM, Overhead Tracking Mode:     Ctrl + Shift + 4

	; Reload this script:                  Ctrl + Shift + s

	; Abort and exit this script           Ctrl + Esc



			; FUNCTION DEFINITIONS
			; ====================

#Include commonFunctions.ahk

InitMatch()							; Initializes a VS match within the game, and activates Camera Mode 8 (required for all other camera modes)
{
    ; Ensure Dolphin is running and playing a game
    ; ============================================
    if not FocusGameWindow()
        Exit

    ; Open and move focus to the TAS Input window for Player 1
    ; ========================================================
    FocusTas(1) ; Causes the emulator window to come to the front upon first calling, because these are opened for the first time
    Sleep 50
    FocusGameWindow() ; This line just to bring the game window back to the forefront before continuing
    FocusTas(1)

    ; Start the match (stage should be auto-selected)
    ; ===============================================
    PressButton("START")
    Sleep 3800

    ; Pause Dolphin
    ; =============
    FocusGameWindow()
    Send {F10}

    ; Adjust camera zoom slightly
    ; (to activate camera mode 8)
    ; ===========================
    FocusTas(1)

    SetStickAxis( "C", "Y", 255 ) ; Set the C-stick y-axis field to 255
    Sleep %SleepTimer2%

    ToggleButton("D-Pad-Left") ; Hold down Left on the D-pad

    ;      -= == Advance frames == =-
    FocusGameWindow()
    Loop 2
    {
        Send {F11}
        Sleep %SleepTimer1%
    }

    Sleep 100
    FocusTas(1)

    ToggleButton("D-Pad-Left") ; Release Left on D-pad
    
    SetStickAxis( "C", "Y", 128 ) ; Set the C-stick Y-axis field back to neutral
    Sleep %SleepTimer2%

    ;      -= == Remove focus from text field == =-

    ;click 268, 300 ; Click on "Right" checkbox to remove focus from text box
    ;Sleep %SleepTimer2%
    ;click 268, 300 ; Click again on Right checkbox
    ;Sleep %SleepTimer2%

    ; Unpause Dolphin
    ; ===============
    FocusGameWindow()
    Send {F10}
    Sleep %SleepTimer1%
} 					; End of InitMatch()


ConfigureEnvironment()						; ConfigureEnvironment()
{
    FocusGameWindow() ; Bring the game window to the foreground

    ; Freeze the game
    ; ===============
    FocusTas(1)
    PressButton("START")
    Sleep %SleepTimer2%

    ; Show Develop text
    ; =================
    ToggleButton("Y") ; Hold down
    Sleep %SleepTimer2%
    PressButton("D-Pad-Down")
    ToggleButton("Y") ; Release
    Sleep %SleepTimer2%


	; Turn on hitbox visibility
	; =========================
    ; ToggleButton("R") ; Hold down
    ; Sleep %SleepTimer2%
    ; PressButton("D-Pad-Up")
    ; PressButton("D-Pad-Up")
    ; ToggleButton("R") ; Release


	; Show environment parts (keeping ability to bring up camera info) 
	; (Disabled so B moves don't bring up camera info)
	; ================================================================

;(R button is still held down)
;Loop 3
;{
;    Press(215, 319) ; Press down on d-pad
;    Sleep %SleepTimer2%
;}
;Click 208, 250 ; Release R button
;Sleep %SleepTimer2%


	; Turn off environment visibility (part 1)
	; ===============================

;Click 254, 234 ; Hold down X button
;Sleep %SleepTimer2%
;Press(215, 319) ; Press down on D-pad
;Click 254, 234 ; Release X button
;Sleep %SleepTimer2%


	; Take Sample Snapshot (for comparison against the Master Plate)
	; ==============================================================

;FocusDolphin()
;Send {F9}
;Sleep %SleepTimer1%


	; Turn off environment visibility (part 2)
	; ===============================

;FocusTas(1)
;Click 254, 234 ; Hold down X button
;Sleep %SleepTimer2%
;Loop 2
;{
;    Press(215, 319) ; Press down on D-pad
;}
;Click 254, 234 ; Release X button
;Sleep %SleepTimer2%


	; Bring up camera info (Disabled)
	; ====================

;Press(208, 234) ; Press B button
;Sleep %SleepTimer2%


    RollP4OutOfFrame()

	; Unfreeze the game
	; =================
    PressButton("START")

    WinActivate %dolphinWindowName% | ; Seek the game window
} ; End of ConfigEnvironment()


RollP4OutOfFrame(){ ; Has Player 4 roll backwards so they're not visible in the current frame
    FocusTas(4)

    ; Press inputs to roll back
    ToggleButton("L") ; Hold Down
    SetStickAxis( "MAIN", "X", 255 ) ; Set the Main-stick X-axis to the right
    Sleep 80

    ; Advance a few frames
    PressButton("Z")
    Sleep 80
    PressButton("Z")
    Sleep 80

    ; Release the inputs
    ToggleButton("L") ; Release
    SetStickAxis( "MAIN", "X", 128 ) ; Set back to neutral
    Sleep 80
}


; Show script successful loaded confirmation. 

TrayTip
Sleep 20
thisScriptName := SubStr(A_ScriptName, 1, -4)
TrayTip, , %thisScriptName% is ready., 2
return




^+s::

Reload
Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
TrayTip, Error, "ACS MEM could not be reloaded."
;MsgBox, 4,, "ACS MEM could not be reloaded. Would you like to open it for editing?"
;IfMsgBox, Yes, Edit
return


		; ====================================================
		; =  Beginning of Environment Initialization script  =
		; ====================================================

^+`::   ; CTRL + SHIFT + ` (tild)


	; Ensure Dolphin is running and playing the game
	; ==============================================

StartMelee()
IfWinNotExist %dolphinWindowName% | ; Seek the game window
{
	TrayTip, , "Dolphin and the game could not be started."
	Return
}

	; Close all TAS Input windows (to prevent freezing upon savestate load)    <- bug fixed?? no longer needed?
	; =====================================================================

; CloseTAS(tasWindowName, 1)
; CloseTAS(tasWindowName, 2)
; CloseTAS(tasWindowName, 3)
; CloseTAS(tasWindowName, 4)

	; Load Savestate 1
	; ================

;WinActivate %dolphinWindowName% | ; Seek the game window

EnsureDolphinNotPaused() ; Otherwise might load state but still be paused.

;Send {F1} ; For DHS
;Send {F2} ; For ML
Sleep 900

TrayTip, , "Initialization complete."

SoundBeep ; [, Frequency, Duration]

Return



		; ==========================
		; =  ACS MEM, Static Mode  =
		; ==========================

^+1::

InitMatch()

; Bring up the Cheats Manager.
FocusCheatsManager()

; Enable/disable various gecko codes.
ToggleCode(1) ; Should be CM9, Static Mode
Sleep %SleepTimer1%

; Camera is set at this point. Now change the code state back to default (should still be highlighted).
;return
;Send, {TAB 2}
Send {Space}
;ToggleCode(1)
; Hit apply again and close the Cheats Manager.
Send !a ; Alt-A (Save)

;Send !{F4}
;Sleep 200

ConfigureEnvironment()

SoundBeep ; [, Frequency, Duration]

TrayTip, , "Camera set-up (Static Mode) complete!"

Return

		; ============================
		; =  ACS MEM, Tracking Mode  =
		; ============================

^+2::

InitMatch()

; Bring up the Cheats Manager.
;FocusCheatsManager()

; Enable/disable various gecko codes.
;ToggleCode(2) ; Should be CM9, Tracking Mode (should stay on)
;Sleep %SleepTimer1%

ConfigureEnvironment()

; Done! Inform the user
SoundBeep ; [, Frequency, Duration]
;TrayTip, , Camera set-up (Tracking Mode) complete!

Return



		; ==================================
		; =  ACS MEM, Overhead Static Mode =
		; ==================================

^+3::

InitMatch()

; Bring up the Cheats Manager.

FocusCheatsManager()

; Enable/disable various gecko codes.

ToggleCode(3) ; Should be CM9, Overhead Static Mode
Sleep %SleepTimer1%

; Camera is set at this point. Now change the code state back to default (should still be highlighted).
Send, {Space}

; Hit apply again
Send !a ; Alt-A (Save)

ConfigureEnvironment()

SoundBeep ; [, Frequency, Duration]

;TrayTip, , Camera set-up (Overhead Static Mode) complete!

Return



		; ====================================
		; =  ACS MEM, Overhead Tracking Mode =
		; ====================================

^+4::

InitMatch()

; Bring up the Cheats Manager.

FocusCheatsManager()

; Enable/disable various gecko codes.

ToggleCode(4) ; Should be CM9, Overhead Tracking Mode
Sleep %SleepTimer1%

; Camera is set at this point. Now change the code state back to default (should still be highlighted).
Send, {Space}

; Hit apply again
Send !a ; Alt-A (Save)

ConfigureEnvironment()

SoundBeep ; [, Frequency, Duration]

;TrayTip, , Camera set-up (Overhead Tracking Mode) complete!

Return




^Escape::    ; Press CTRL + ESC to stop current script execution.
ExitApp
Return