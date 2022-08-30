
		; The Ripper. v2.0
		; Created by Daniel Cappel (DRGN)
		;
		; Used to capture screenshots (frames) from Dolphin for hitbox visualization.
		; See the 'Set-up and Usage.txt' file for set-up instructions.



	; Run Ripper:                     Ctrl + Shift + r

	; Reload this script:             Ctrl + Shift + d

	; Abort and exit this script      Ctrl + Esc




	; Controls Reference Table
	; ========================

;
; TAS Input Window relative mouse coordinates:
;	- These are relative to the top-left corner of the input window.
;	- Send these to the Press() function to emulate pressing a button.
;
; Joysticks axis fields:
;
;	Main Stick -		C-Stick -
;		x: 161, 54		x: 376, 54
;		y: 200, 174		y: 416, 174
;	  center: 93, 136	   center: 295, 136
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


	; Functions
	; =========

#Include commonFunctions.ahk

MoveFramesTo(newFolder)
{
    ;Sleep 100
    ;IfWinExist GALE02
    ;{
    ;    WinActivate
    ;}
    ;else
    ;{
    ;    Run, Explorer H:\Games\- Emulators -\Dolphin\Dolphin (5.0-5491)\User\ScreenShots\DHSE02
    ;    Sleep 1600

    ;    IfWinNotExist GALE02
    ;    {
    ;        TrayTip, , Unable to find the Dolphin screenshots output folder.
    ;        Exit
    ;    }
    ;}

    ;; CTRL-A, CTRL-X
    ;Sleep %SleepTimer2%
    ;send ^a
    ;Sleep %SleepTimer2%
    ;send ^x
    ;Sleep %SleepTimer2%

    ;Return

;    IfWinExist WIP
;    {
;        WinActivate
;    }
;    else
;    {
;        Run, Explorer C:\Users\Danny\Desktop\DHS Frames\WIP
;        Sleep 1600
;    }
    sourceFolder = H:\Games\- Emulators -\Dolphin\Dolphin (5.0-5491)\User\ScreenShots\DHSE01
	destinationFolder = C:\Frames\

    ;RenameFrames(sourceFolder)

    i = 1
    newDir = %destinationFolder%\%newFolder%
    while (FileExist(newDir) = "D")
    {
        i := ++%i%
        newFolder = %newFolder% %i%
        newDir = %destinationFolder%\%newFolder%
    }
    ;FileCreateDir, %newDir%

    ;Run, Explorer %newDir%
    ;sleep 1600
    ;send ^v

    FileMoveDir, %sourceFolder%, %newDir%

    sleep 2000
    ;send !{F4}

    ; Rename the files in the output
}


RenameFrames(targetFolder)
{
    Loop, %targetFolder%\*.*
    {
        Sleep 500
        ;newName := SubStr(A_LoopFileName, 1, 6)
        ;MsgBox, ,, %newName%
        ;nameParts := StrSplit(A_LoopFileName, "-") ; A_LoopFileName = e.g. DHSE01-1.png
        ;frameNumberAndExt := nameParts[nameParts._MaxIndex()] ; e.g. 1.png
        ;MsgBox, ,, %frameNumberAndExt%
        ;frameNumberAndExtParts := StrSplit(frameNumberAndExt, `.)
        ;MsgBox, , Title, nameParts
        ;frameNumber := frameNumberAndExtParts[0]
        ;frameNumber := RegExReplace(A_LoopFileName, ".*-([0-9]*)\.(.*)", $1)
        ;MsgBox, ,, %frameNumber%

        StringSplit, nameParts, A_LoopFileName, 01
        MsgBox, ,, %nameParts%
        TrayTip, , %nameParts%
        frameNumberAndExt := nameParts[nameParts._MaxIndex()] ; e.g. 1.png

        MsgBox, ,, frameNumberAndExt: %frameNumberAndExt%
        StringSplit, frameNumberAndExtParts, frameNumberAndExt, .
        frameNumber := frameNumberAndExtParts[0]
        MsgBox, ,, frameNumber: %frameNumber%

        ; Rename file
        FileMove, %A_LoopFileFullPath%, %targetFolder%\(%frameNumber%).%A_LoopFileExt%

        ; Confirm
        ;msgBox, File renamed!
    }
    Sleep 1000
}


; Rip(numToRip)
; {
;     Rip4
; }


Rip4DHS(numToRip) ; This Rip function is for the DHS. Uses static camera positions and also captures overhead shots.
{
    Loop %numToRip%
    {
        ; Record the current frame (taking a snapshot)
        FocusGameWindow() ; This is the only window that will take hotkeys unfortunately
        Send {F9} ; Rip frame.
        Sleep %SleepTimer2%

        ; Switch to the overhead camera
        FocusCheatsManager()
        ToggleCode(3) ; Should be CM9, Overhead Static Mode. Code will be applied, and camera moved.
        Sleep %SleepTimer1%

        ; Camera is set at this point. Now unapply the code.
        Send, {Space} ; The last modified code is still highlighted; untoggle it

        ; Hit apply on the Cheats Manager to unapply
        Send !a ; Alt-A (Save)
        Sleep %SleepTimer1%

        ; Record another frame (this one from above)
        FocusGameWindow()
        Send {F9} ; Rip frame.
        Sleep %SleepTimer2%

        ; Switch back to the standard camera
        FocusCheatsManager()
        ToggleCode(3) ; Should be CM9, Overhead Static Mode. Code will be applied.
        Sleep %SleepTimer1%

        ; Camera is set at this point. Now unapply the code.
        Send, {Space} ; The last modified code is still highlighted; untoggle it

        ; Hit apply on the Cheats Manager to unapply
        Send !a ; Alt-A (Save)
        Sleep %SleepTimer1%

        ;Send {F11} ; Advance frame.
        FocusTas(1)
        PressButton("Z")
        SLeep %SleepTimer2%
    }
}


Rip(numToRip) ; This Rip function is for Melee Light. Uses horizontal tracking and does not capture overhead shots
{
    Loop %numToRip%
    {
        ; Record the current frame (taking a snapshot)
        FocusGameWindow() ; This is the only window that will take hotkeys unfortunately
        Send {F9} ; Rip frame.
        Sleep %SleepTimer2%

        ;Send {F11} ; Advance frame.
        FocusTas(1)
        PressButton("Z")
        SLeep %SleepTimer2%
    }
}



                        idle(move) ; idle standing or falling animation (wait)
{
    FocusTas(1)
    PressButton("START") ; Freeze the game

    ;      -= == Reset the current idle animation position == =-
    SetStickAxis( "Main", "Y", 0 ) ; Set the Main-stick Y-axis field to down
    Loop 9 ; Have the character start to go into a crouch position
    {
        PressButton("Z") ; Advance frame.
        SLeep %SleepTimer2%
    }
    SetStickAxis( "Main", "Y", 128 ) ; Set the Main-stick Y-axis field back to neutral
    SLeep %SleepTimer2%
    Loop 11 ; Reverse the crouch to have the character go back to standing
    {
        PressButton("Z") ; Advance frame.
        SLeep %SleepTimer2%
    }
    ; The character should now be at frame 0 of wait
    ; The character should now be at frame 0 of wait

    ;      -= == Advance/Rip frames == =-
    Rip(200)

    ;      -= == Clean-up (unpause game, reset character) == =-

    EnsureDolphinNotPaused()
    FocusTas(1)
    PressButton("START") ; Un-freeze the game (in-game freeze, not Dolphin pause)

    MoveFramesTo(move)

    TrayTip, , %move% ripped!
    Sleep %SleepTimer2%
}

						neutralA(move) ; jab 1 or nair
{
    FocusTas(1)
    PressButton("START") ; Freeze the game

    ToggleButton("A") ; Press down A button

    ;      -= == Advance/Rip frames == =-
    Rip(1)

    ToggleButton("A") ; Release A button

    ;      -= == Advance/Rip frames == =-
    Rip(30)

    ;      -= == Clean-up (unpause game, reset character) == =-

    EnsureDolphinNotPaused()
    FocusTas(1)
    PressButton("START") ; Un-freeze the game (in-game freeze, not Dolphin pause)

    MoveFramesTo(move)

    TrayTip, , %move% ripped!
    Sleep %SleepTimer2%
}

						upA(move) ; up tilt or uair
{
    send {F10}
    Sleep %SleepTimer2%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer2%

    ;      -= == Set Input == =-

    click 162, 234 ; Press down A button

    click 93, 114 ; set main joystick up lightly (128, 172)

    ;      -= == Advance/Rip frames == =-

    Loop 3
    {
        Send {F11}
        Sleep %SleepTimer1%
        Send {F9} ; Rip frame.
        Sleep %SleepTimer1%
    }

    ;      -= == Reset input == =-

    click 162, 234 ; Release A button

    click 93, 136 ; center main joystick

    ;      -= == Advance/Rip frames == =-

    Rip(40)
    sleep 400

    ;      -= == Clean-up (unpause game, reset character) == =-

    send {F10}

    MoveFramesTo(move)

    FocusDolphin()

    TrayTip, , %move% ripped!
}

						ftiltHigh()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 115, 114 ; set main joystick forward and up (172, 172)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(40)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward tilt (H)")

FocusDolphin()

TrayTip, , Forward tilt (H) ripped!

}


						ftiltHighMid()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 115, 125 ; set main joystick forward and slightly up (172, 150)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(40)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward tilt (HM)")

FocusDolphin()

TrayTip, , Forward tilt (HM) ripped!

}

						sideA(move) ; forward tilt (M) or fair
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 115, 136 ; set main joystick forward (172, 128)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!

}

						bair()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 71, 136 ; set main joystick back (84, 128)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("back air")

FocusDolphin()

TrayTip, , back air ripped!

}


						ftiltLowMid()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 115, 147 ; set main joystick forward and slightly down (172, 106)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(40)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward tilt (LM)")

FocusDolphin()

TrayTip, , Forward tilt (LM) ripped!

}



						ftiltLow()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 115, 158 ; set main joystick forward and down (172, 84)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button


;      -= == Advance/Rip frames == =-

Rip(40)
sleep 400


;      -= == Reset input 2 == =- (Main stick is held down during move to grab frame 0 of crouch)

click 93, 136 ; center main joystick


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward tilt (L)")

FocusDolphin()

TrayTip, , Forward tilt (L) ripped!

}

						downA(move) ; down tilt or dair
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 93, 158 ; set main joystick down lightly (128, 84)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!
}


						upsmash()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 93, 92 ; set main joystick strongly up (128, 216)

;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("up smash")

FocusDolphin()

TrayTip, , up smash ripped!
}


						fsmashHigh()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 137, 92 ; set main joystick strongly forward and up (216, 216)


;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward smash (H)")

FocusDolphin()

TrayTip, , Forward smash (H) ripped!

}


						fsmashHighMid()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 137, 114 ; set main joystick strongly forward and slightly up (216, 172)


;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward smash (HM)")

FocusDolphin()

TrayTip, , Forward smash (HM) ripped!

}

						fsmashMid()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 137, 136 ; set main joystick strongly forward (216, 128)


;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward smash (M)")

FocusDolphin()

TrayTip, , Forward smash (M) ripped!

}


						fsmashLowMid()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 137, 158 ; set main joystick strongly forward and slightly down (216, 84)


;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward smash (LM)")

FocusDolphin()

TrayTip, , Forward smash (LM) ripped!

}



						fsmashLow()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 137, 180 ; set main joystick strongly forward and down (216, 40)


;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("forward smash (L)")

FocusDolphin()

TrayTip, , Forward smash (L) ripped!

}


						downsmash()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 162, 234 ; Press down A button

click 93, 180 ; set main joystick strongly down (128, 40)

;      -= == Advance/Rip frames == =-

Loop 1
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 162, 234 ; Release A button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(60)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("down smash")

FocusDolphin()

TrayTip, , Down smash ripped!
}

						grab()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 254, 250 ; Press down Z button


;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 254, 250 ; Release Z button


;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("grab")

FocusDolphin()

TrayTip, , Grab ripped!
}
						neutralb(move) ; aerial or grounded
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

click 208, 234 ; Press down B button
	

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

click 208, 234 ; Release B button


;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!
}

						upb(move)
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 234 ; Press down B button

click 93, 92 ; set main joystick up (128, 216)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 114 ; Release B button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(80)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!
}

						sideb(move)
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 234 ; Press down B button

click 137, 136 ; set main joystick forward (216, 128)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 234 ; Release B button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400


;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!

}

						downb(move)
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 234 ; Press down B button

click 93, 180 ; set main joystick strongly down (128, 40)

;      -= == Advance/Rip frames == =-

Loop 6
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 234 ; Release B button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo(move)

FocusDolphin()

TrayTip, , %move% ripped!
}

						spotdodge()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 250 ; Press down R button

click 93, 180 ; set main joystick down lightly (128, 40)

;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 250 ; Release R button

click 93, 136 ; center main joystick

;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("spot dodge")

FocusDolphin()

TrayTip, , Spot dodge ripped!
}

						airdodge()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 250 ; Press down R button


;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 250 ; Release R button


;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("air dodge")

FocusDolphin()

TrayTip, , air dodge ripped!
}


						taunt()
{
send {F10}
Sleep %SleepTimer2%
Send {F9} ; Rip frame.
Sleep %SleepTimer2%

;      -= == Set Input == =-

click 208, 250 ; Press down R button


;      -= == Advance/Rip frames == =-

Loop 3
{
    Send {F11}
    Sleep %SleepTimer1%
    Send {F9} ; Rip frame.
    Sleep %SleepTimer1%
}

;      -= == Reset input == =-

click 208, 250 ; Release R button


;      -= == Advance/Rip frames == =-

Rip(50)
sleep 400

;      -= == Clean-up (unpause game, reset character) == =-

send {F10}

MoveFramesTo("taunt")

FocusDolphin()

TrayTip, , Taunt ripped!
}

; End of function definitions

; Show script successful loaded confirmation. 

TrayTip
Sleep 20
thisScriptName := SubStr(A_ScriptName, 1, -4)
TrayTip, , %thisScriptName% is ready., 2
return


^+d::

Reload
Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
MsgBox, 4,, The Ripper could not be reloaded. Would you like to open it for editing?
IfMsgBox, Yes, Edit
return

				;================================================
				;======#           Capture List           #======
				;================================================
				;
				; - = Perform and record the following moves: = -
				;         (Comment out move to disable.)
				;     (Game must be running and not frozen.)

^+r:: ; CTRL-SHIFT-R
;FocusDolphin()

	; Grounded moves (ACS 1):

idle("ground wait")
;neutralA("jab 1")

;upA("up tilt")

;ftiltHigh()
;ftiltHighMid()
;sideA("forward tilt (M)")
;ftiltLowMid()
;ftiltLow()

;downA("down tilt")

;upsmash()

;fsmashHigh()
;fsmashHighMid()
;fsmashMid()
;fsmashLowMid()
;fsmashLow()

;downsmash()

;neutralb("grounded neutral b")
;upb("grounded up b")
;sideb("grounded side b")
;downb("grounded down b")


;grab()
;taunt()
;spotdodge()


; Other grounded moves that need capture:
; All other jabs
; dash attack
; dash grab
; rolls (forward and back)


	; Aerial Moves (ACS 2):

;airdodge()

;neutralA("neutral air")

;upA("up air")

;bair()

;sideA("forward air")

;downA("down air")


;neutralb("aerial neutral b")

;upb("aerial up b")

;sideb("aerial side b")

;downb("aerial down b")


	; Get-up attacks (ACS 3):

;neutralA("get-up attack (front)")

;neutralA("get-up attack (back)")


	; Ledge attacks (ACS 4):

;neutralA("ledge attack ("ledge attack ()

IfWinExist GALE01
{
    WinActivate
    Sleep 100
    Send {F5}
}

; -----------------------

SoundBeep ; [, Frequency, Duration]

Sleep 1000
TrayTip, , Ripping complete!

return


^Escape::    ; Press CTRL + ESC to stop current script execution.
ExitApp
Return