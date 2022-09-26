
	; Created by DRGN
	; Version 1.1


            ; VARIABLE DEFINITIONS
            ; ====================

global dolphinDirectory := "D:\Games\- Emulators -\Dolphin\Dolphin (5.0-5491)"
global dolphinWindowName := "Dolphin 5.0-5491"
;global discPath := "D:\Games\GameCube\- - SSB Melee - -\Hacks\20XX Hack Pack\20XXHP 5.0\SSBM, 20XXHP 5.0.1 - with new SDR files 4.iso"
;global discPath := "D:\Games\GameCube\- - SSB Melee - -\v1.02 (original)\Copy for Slippi.iso"
global discPath := "D:\Projects\DHS\Super Smash Bros. Melee (NTSC v1.02).iso"

global destinationFolder := "C:\Frames\"

global tasWindowName := "TAS Input - GameCube Controller"

global SleepTimer1 := 150 ; For giving time between "intensive" tasks, such as emulator processing (advancing frames).

global SleepTimer2 := 40  ; For other simple tasks where little processing is expected.


; There are also two other major wait times you can tweak, if needed:
; 1) After going to the stage select screen. My default is 800.
; 2) After starting the match (waiting for the stage/characters to
;    load and the "GO!" text to disappear). My default is 4200.
;
; You should be able to find these in the ACS MEM script with the 'Sleep' lines.

SetKeyDelay, , 100 ; Extends the time keys are "pressed" (2nd arg), to ensure they're captured


            ; FUNCTION DEFINITIONS
            ; ====================

;Press(x, y)
;{
;	Click %x%, %y%
;	Sleep 300
;	Click %x%, %y%
;	Sleep %SleepTimer1%
;}


ToggleButton( buttonToToggle )
{
    PressButton( buttonToToggle, True )
}


PressButton( buttonToPress, hold := False )
{
    ; Inputs button presses on the currently focused Dolphin TAS Input window
    ; Assumes the window already has focus
    
    StringUpper, buttonToPress, buttonToPress

    ; TAS Input Window coordinate dictionary; values are relative to the input window, not the screen.
    ;buttonMap := { "A": [147, 279], B: [193, 279], 
    ;            && "Z": [147, 294], L: [193, 294], START: [319, 294] }
    ;buttonCoords := buttonMap[%buttonToPress%]
    ;TrayTip, , Yep: %buttonCoords%
    ;Sleep, 1000
    ;var2 = START
    ;;msgbox >%buttonToPress%<`n>%var2%<

    ;buttonCoords := StrSplit( 319,294, ",")


    ;TrayTip, , ButtonCoords: %buttonCoords%
    ;Sleep 2000
    ;x := buttonCoords[0]
    ;y := buttonCoords[1]
    ;TrayTip, , Pressing %x% %y%


    if (buttonToPress = "A")
    {
        x := 147, y := 279

    } else if (buttonToPress = "B") {
        x := 204, y := 279

    } else if (buttonToPress = "X") {
        x := 261, y := 279

    } else if (buttonToPress = "Y") {
        x := 319, y := 279

    } else if (buttonToPress = "Z") {
        x := 147, y := 294

    } else if (buttonToPress = "L") {
        x := 204, y := 294

    } else if (buttonToPress = "R") {
        x := 261, y := 294

    } else if (buttonToPress = "START") {
        x := 319, y := 294

    } else if (buttonToPress = "D-Pad-Left") {
        x := 147, y := 343

    } else if (buttonToPress = "D-Pad-Up") {
        x := 200, y := 324

    } else if (buttonToPress = "D-Pad-Right") {
        x := 253, y := 343

    } else if (buttonToPress = "D-Pad-Down") {
        x := 200, y := 364

    } Else
    {
        TrayTip, , %buttonToPress% could not be pressed. No coords defined.
        Exit
    }

    ;Click buttonCoords[0], buttonCoords[1]
    ;Sleep 1000
    ;Click buttonCoords[0], buttonCoords[1]
    ;Sleep %SleepTimer1%

    Click %x%, %y%
    Sleep 400

    ; If we're not "holding" or toggling the button, click again to release the button
    if not (hold)
    {
        Click %x%, %y%
        Sleep %SleepTimer1%
    }
}


SetStickAxis( stick, axis, value )
{
    StringUpper, stick, stick
    StringUpper, axis, axis

    ; Determine the target control stick desired, and set the x coordinate of the input field
    if (stick = "MAIN")
    {
        x := 165

    } else if (stick = "C") {
        x := 349

    } Else
    {
        TrayTip, , %stick% is not a valid control stick name. Use "Main" or "C".
        Exit
    }

    ; Determine the control stick axis desired, and set the y coordinate of the input field
    if (axis = "X")
    {
        y := 68

    } else if (axis = "Y") {
        y := 226

    } Else
    {
        TrayTip, , %axis% is not a valid control axis name. Use "X" or "Y".
        Exit
    }

    Click %x%, %y%, 2   ; Double-click in the appropriate field
    Send {Del} ; Removes current value
    Send %value%
}


FocusTas( winNum ) ; Confirms the character control for Player _ is running and moves focus to it
{
    ;global dolphinWindowName

    IfWinNotExist %tasWindowName% %winNum%
    {
        ; TAS Input needs to be opened
        TrayTip, , "Opening TAS window for P" %winNum%
        WinActivate, %dolphinWindowName%, , %dolphinWindowName% | ; Seek the main emulator window
        Sleep 600
        Send !m ; ALT + M to go to 'Movie' tab
        Send {Down 5}
        Send {Enter}     ; Select "TAS Input"
        Sleep 600
    }

    WinActivate %tasWindowName% %winNum%
    Sleep 400

    IfWinNotActive %tasWindowName% %winNum%
    {
        TrayTip ; Called with no arguments forces clearing of old text.
        TrayTip, , "Unable to interface with TAS. Aborting script."
        Exit
    }
}


CloseTAS(winName, winNum)
{
    IfWinExist, %winName% %winNum%
    {
        WinActivate
        Send !{F4} ; Close window
    }
}


StartMelee()
{
	IfWinExist %dolphinWindowName% | ; Seek the game window
	{
		; If here, both Dolphin itself and Melee are running
		TrayTip, , "Dolphin and the game are already running."
		Sleep, 200

		EnsureDolphinNotPaused()
	}
	else    ; The emulator may be running, but the game is not.
	{
		CloseDolphin()

		Run "%dolphinDirectory%\Dolphin.exe" "%discPath%"
		
		; Wait for the game to start and return
		Loop 15
		{
			IfWinExist %dolphinWindowName% | ; Seek the game window
			{
				Sleep 1000
				Return
			}
			Sleep 1000
		}
	}
}


CloseDolphin()
{
	; If Dolphin is running, attempt to close it peacefully
	IfWinExist, %dolphinWindowName%, , %dolphinWindowName% | ; Seek the main emulator window
	{
		WinClose
		Sleep 3000
	}

	; Wait for the program to close and return
	Loop 10
	{
		IfWinNotExist, %dolphinWindowName%, , %dolphinWindowName% | ; Seek the main emulator window
		{
			Return
		}
		Sleep 1000
	}

	; If Dolphin is still running, kill the process
	RunWait, taskkill.exe /F /IM Dolphin.exe
}


FocusGameWindow()
{
    IfWinExist %dolphinWindowName% | ; Seek the game window
    {
        WinActivate ; So that this is the top window in the end, besides TAS windows
        Sleep 500
        return True
    }
    else
    {
        IfWinExist, %dolphinWindowName%, , %dolphinWindowName% | ; Seek the main emulator window
        {
            TrayTip, , "The game is not running. Run Initialization first."
        }
        else
        {
            TrayTip, , "Dolphin is not running. Run Initialization first."
        }
        Sleep 500
        return False
    }
}


FocusDolphin() ; Confirms the emulator is running and moves focus to the main emulator window
{
    IfWinExist %dolphinWindowName% | ; Check that the game is running.
    {
        IfWinExist, %dolphinWindowName%, , %dolphinWindowName% | ; Checks for the main Dolphin window. Excludes selection of the game window.
        {
            Sleep 200
            WinActivate
        }
        else
        {
            TrayTip, , "Dolphin was not found to be running.", 2
            soundbeep
            sleep 40
            soundbeep
            exit
        }
    }
    else
    {
        TrayTip, , "The game was not found to be running.", 2
        soundbeep
        sleep 40
        soundbeep
        exit
    }
}


FocusCheatsManager()
{
    ; Focus it if it's already open, or open it
    IfWinExist Cheat Manager
    {
        WinActivate
        Sleep %SleepTimer2%
    }
    else    ; The emulator may be running, but the game is not.
    {
        FocusDolphin()
        Send, !t    ; Alt + T, to open the Tools menu
        Send, c     ; to open the Cheats Manager
        Sleep %SleepTimer1% ; Give a little time for the window to open.

        ; Move the window to the far right, so that
    }

    ; Make sure the Gecko Codes tab is selected.
    Send, {Home} ; Necessary to set this reference point, since some Dolphin versions default to last used tab
    Sleep %SleepTimer2%
    Send, {Right} ; Move to the Gecko Codes tab

    Send, {TAB}
    Sleep 200
}


ToggleCode(positionNumber)                  ; ToggleCode()
{
    positionNumber-- ; Decrement to match actual list position
    Send, {Home}     ; Reset list position to top
    Send, {Down %positionNumber%}
    Send, {Space}
    Sleep 100

    ; Hit apply. (Don't use the mouse to click, because the TAS windows might be in the way.)
    ;Send, +{TAB 2}     ; SHIFT+TAB twice (iterates over focusable windows backwards twice)
    ;Send, {Space}
    Send !a

    ; Close the Cheats Manager
    ;Send !{F4}
    ;Sleep 100
}


EnsureDolphinNotPaused()
{
	if FocusGameWindow() ; This is the only window that will take hotkeys unfortunately
	{
		Send {F11} ; This will pause and frame advance the game if it's running (whether or not paused), but will not unpause it.
		Sleep %SleepTimer1%
		Send {F10} ; Unpause the game
		Sleep %SleepTimer1%
	}
}