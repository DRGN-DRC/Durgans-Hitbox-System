; Created by Daniel Cappel (Durgan)


    ; Acronyms:
    ;
    ; CM8 = Camera Mode 8



		; Table of Contents:


	; Get CM8 Position: 		Ctrl + Shift + c

	; Set CM8 Position: 		Ctrl + Shift + v

	; Reload/Cancel Script:		Ctrl + Shift + s



    ; Required Conditions and Set-up
    ; ==============================

; 0) Both Debug Dolphin and the game should be running. Make sure the Memory tab 
;    appears second in the tabs shown in Dolphin's interface.
; 1) Scroll down to the "Variables" section below, and give a name for the camera 
;    mode ('PositionName') and a path to the Gecko codes .ini file ('PositionsFile').
;    (The file is appended to, so other codes in the file will not be lost.)
; 2) Get CM8 to the desired position and press the hotkey (above) to run this script.
; 3) Scroll down to the "codeNumber" variable, and set it depending on how many codes
;    are already in the Gecko codes .ini file.


	; Controls Reference Table
	; ========================
			
;
; TAS Input Window relative mouse coordinates:
 ;	- These are relative to the input window, not the screen.
;	- Send these to the Press() function to emulate pressing a button.
;
; Joysticks axis fields:
;
;	Main Stick -		C-Stick -
;		x: 161, 54		x: 376, 54
;		y: 200, 174		y: 416, 174
;
; Buttons (with D-pad):
;
;	  A:	162, 234	Left:	162, 299
;	  B:	208, 234	Right:	268, 299
;	  X:	254, 234	Up: 	215, 279
;	  Y:	300, 234	Down:	215, 319
;	  L:	162, 250
;	  R:	208, 250
;	  Z: 	254, 250
; 	Start: 	300, 250
;
;
;      = Dolphin's Free Look camera controls:
;
; Right-click + move mouse = panning
; Middle-click + move mouse = strafing
; Shift + WASD keys = step camera position LRUP
; 
; Shift + 0 for faster movement
; Shift + 9 for slower movement
; Shift + R to reset position
;
;
;      = Dolphin Debug Mode Main Window Interface
;
;  - Memory tab (when placed second from the left): 89, 145
;
;  - To get to the Address field, click on the Memory tab and
;    hit tab twice.
;
;  - And of course tab three times after clicking on the
;    Memory tab to get to the hex entry field.


TrayTip, , The 'Get and Set Camera Postion' script has been loaded., 2


		; ======================================
		; =  Get Camera Mode 8 (CM8) Position  =
		; ======================================


^+c::	; Ctrl + Shift + c


	; Variables
	; =========

		; v Can contain spaces and numbers.

PositionName = Zelda casting magic (CM8 Pos)

			; v Include quotes!

PositionsFile := "C:\Users\Danny\Documents\Dolphin Emulator\GameSettings\DHSE01.ini"


	; Functions
	; =========

FocusDolphin() ; Confirms the emulator is running and moves focus to the main emulator window
{
    IfWinExist Dolphin 4.0 | ; Check that the game is running.
    {
        IfWinExist, Dolphin 4.0, , Dolphin 4.0 | ; Excludes selection of the game window.
        {
            WinActivate
        }
        else
        {
            TrayTip, , Dolphin was not found to be running., 2
            soundbeep
            sleep 40
            soundbeep
            exit
        }
    }
    else
    {
        TrayTip, , The game was not found to be running., 2
        soundbeep
        sleep 40
        soundbeep
        exit
    }
}

GetValueFor(address) ; Get the hex value from a specified memory address.
{
    FocusDolphin()
    Sleep 100
    Click 89, 145, 2 ; Double-click on the Memory tab.
    Sleep 100
    Send, {TAB 2} ; Advance focus to the address entry field
    Sleep 100
    Send, % "80" . address ; Input the memory address to find.
    Sleep 100
    Click 142, 210 ; Give focus to the line.
    Sleep 100
    Click right 142, 210 ; Right click on the memory address/value line.
    Sleep 100
    Click 240, 246 ; Select "Copy Hex" to copy the value into the clipboard.
    ClipWait, 3 ; Wait for the clipboard to be populated.
    return clipboard
}

    ; Confirm that Dolphin's main window is correct.
    ; ==============================================

; Debug Dolphin's main window needs to be shrunk down to
; 400 x 300, so that the lines of memory to click on are
; consistently in the same place.

WinGetPos, , , width, height, Dolphin 4.0, , | ; The pipe excludes selection of the game window.

;if (width != 400 OR height != 300)
;{
    WinMove, Dolphin 4.0, , , , 400, 300, , |
    Sleep 50
;}


    ; Create the head of the camera position entry.
    ; =============================================

fileread, iniFile, %PositionsFile%  ; Get the text from the file into a variable (iniFile).

; Check if the ini file already has a [Gecko] codes section.
; If it has a [Gecko] section (assumed to be at the end), nothing needs to be done.
; If there is no [Gecko] section, add one.
; Begin the entry with a line break either way.

geckoSectionFound = False
loop, parse, iniFile, `r`n, `r`n
{
    if(a_loopfield = "[Gecko]")
    {    
        geckoSectionFound = True
        newGeckoCode = `r`n
        break
    }
}

if (%geckoSectionFound% = False)
{
    newGeckoCode = `r`n[Gecko]`r`n
}

newGeckoCode = %newGeckoCode%$%PositionName%`r`n04452c6c 00000008`r`n


    ; Create the body of the camera position entry.
    ; =============================================

; Collect the camera position values (in hex) for each of the CM8 memory addresses,
; and compose the body of the camera position entry.

ClipSaved := ClipboardAll   ; Save the entire clipboard to a variable so it may be restored later.

AddressArray := ["453040", "453044", "453048", "45304c", "453050", "453054"]
i := 1
loop 6
{
    address := AddressArray[i]
    value := GetValueFor(address)
    newGeckoCode = % newGeckoCode . "04" . address . " " . value . "`r`n"
    i++
}


    ; Add the entry to the ini file and restore the clipboard.
    ; ========================================================


FileAppend, %newGeckoCode%, %PositionsFile%

if ErrorLevel ; i.e. it' not blank or zero.
    msgbox, There was a problem with adding the entry to the file.`r`nYou may want to double-check the file path.

Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).

ClipSaved =   ; Free the memory in case the clipboard was very large.


IfWinExist Dolphin 4.0 |
{
    WinActivate
}

soundbeep

TrayTip, , %PositionName% has been saved., 2

return


		; ======================================
		; =  Set Camera Mode 8 (CM8) Position  =
		; ======================================


^+v::

codeNumber := 6 ; This is the position in the Gecko codes list for the desired code or camera position
		 ; Position starts with 1. So if your camera mode is the 12th code, use 12.



FocusDolphin()


; Bring up the Cheats Manager.

OpenManager()
{
    Send, !t ; Alt + T, to open the Tools menu
    Send, c
    Sleep 5000
    Send, {Right}
    Send, {TAB}
}

; Enable/disable various camera positions.

ToggleCam(positionNumber)
{
    positionNumber--
    Send, {Home}
    Send, {Down %positionNumber%}
    Send, {Space}
}

OpenManager()

; Toggle the camera positions of your choice (reference them by number, using 
; the order that they appear in the list, starting with 0). 
; e.g. "ToggleCam(1)" to toggle the first camera position on/off.
; 
; You'll have to keep track of how many there are and the state each is in 
; yourself, since there are no really great, reliable methods for the script 
; to check these things.
;
; You can place multiple of such lines below to toggle each camera position you want.
; As an example, if the state of the two camera positions below are different when 
; this is run (one is on while the other is off), then the camera will switch between 
; these two positions every time this script is run.

ToggleCam(%codeNumber%)

Click 432, 574 ; Click Apply.

Send, {TAB 3}

ToggleCam(%codeNumber%)


; Apply the changes and close the Cheats Manager.

Click 432, 574 ; Click Apply.
Send !{F4}

return



; And of course, you could also set up hotkeys to toggle other effects in the game.
; For example, if you had another Gecko code as the third code, you could write:

^+g::

OpenManager()

ToggleCam(3) ; In this example, this might toggle character gravity on/off

Click 432, 574 ; Click Apply.
Send !{F4}

return



		; ==========================
		; =  Reload/Cancel Script  =
		; ==========================


^+s::
;exitApp
;return

Sleep 50
Reload
Sleep 1200 
; If successful, the reload will close this instance during the Sleep above, 
; so the line below will never be reached.
MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
IfMsgBox, Yes, Edit
return