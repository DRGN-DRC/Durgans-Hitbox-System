#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.



		; Table of Contents:


	; Toggle Gravity On/Off: 	Ctrl + Shift + g

	; Get Character Postion: 	Ctrl + Shift + x

	; Reload/Cancel Script:		Ctrl + Shift + s


; No Gecko code dependencies. Just make sure the game is running.



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

SizeDolphin()
{
        ; Confirm that Dolphin's main window is correct.
        ; ==============================================

    ; Debug Dolphin's main window needs to be shrunk down to
    ; 400 x 300, so that the lines of memory to click on are
    ; consistently in the same place.

    WinGetPos, , , width, height, Dolphin 4.0, , | ; The pipe excludes selection of the game window.

    if (width != 700 OR height != 300)
        WinMove, Dolphin 4.0, , , , 700, 300, |
}


GetValueFor(address) ; Get the hex value from a specified memory address.
{
    SleepTimer=100

    FocusDolphin()

    Sleep %SleepTimer%
    ;Click 89, 124 ; Double-click on the Memory tab (when second tab).
    Click 160, 126 ; Double-click on the Memory tab (when third tab).

    Sleep %SleepTimer%
    Send, {TAB 2} ; Advance focus to the address entry field

    Sleep %SleepTimer%
    SetFormat, Integer, Hex
    StringTrimLeft, address, address, 2 ; Remove the 0x
    Send, %address% ; Input the memory address to find.

    Sleep %SleepTimer%
    Click 148, 200 ; Give focus to the line.

    Sleep %SleepTimer%
    SetFormat, Integer, D
    Click right 148, 200 ; Right click on the memory address/value line.
    clipboard =

    Sleep %SleepTimer%
    Click 240, 246 ; Select "Copy hex" to copy the current value into the clipboard.
    ClipWait, 3, 1 ; Wait for the clipboard to be populated.
    ;return clipboard
    Return "0x" . clipboard
}


SetValueFor(address, value) ; Get the hex value from a specified memory address.
{
    SleepTimer=100

    FocusDolphin()

    Sleep %SleepTimer%
    ;Click 89, 124 ; Double-click on the Memory tab (when second tab).
    Click 160, 126 ; Double-click on the Memory tab (when third tab).

    Sleep %SleepTimer%
    Send, {TAB 2} ; Advance focus to the address entry field

    Sleep %SleepTimer%
    StringTrimLeft, address, address, 2 ; Remove the "0x" at the beginning of the address.
    Send, %address% ; Input the memory address to find.

    Sleep %SleepTimer%
    Send, {TAB}

    Send, %value%
    Send, {TAB}
    Send, {Enter}
}

AddHex(val1, val2)
{
    SetFormat, Integer, Hex
    result := val1 + val2
    SetFormat, Integer, D
    return result
}

;AscToHex(S) {
;  Return S="" ? "":Chr((*&S>>4)+48) Chr((x:=*&S&15)+48+(x>9)*7) AscToHex(SubStr(S,2))
;}

;GravAddress2 := AscToHex("a")





		; ====================
		; =  Toggle Gravity  =
		; ====================


^+g::



FocusDolphin()

SizeDolphin()

P1Offset:=GetValueFor("0x80453130")

;msgbox, % P1Offset

;SetFormat, Integer, Hex

;P1HexOffset = 0x%P1Offset%


GravAddress := AddHex(P1Offset, 0x1cc)

SetValueFor(GravAddress, 0)

SoundBeep ; [, Frequency, Duration]

return




;SetFormat, Integer, D


;a:=0x9+0xB

;b:=9+11



;SetFormat, Integer, Hex

;c:=0x9+0xb

;d:=9+11

;msgbox, %a%  %b% %c% %d%





		; ===========================
		; = Get Character Position  =
		; ===========================


^+x::


FocusDolphin()

SizeDolphin()

P1Offset:=GetValueFor("0x80453130") ; Checks the Static Player Block, and gets the pointer for the Player Entity block

xAddress := AddHex(P1Offset, 0x110)

yAddress := AddHex(P1Offset, 0x114)

x := GetValueFor(xAddress)

y := GetValueFor(yAddress)

;SetFormat, Integer, D

msgbox, %x%`, %y%


return

		; ==========================
		; =  Reload/Cancel Script  =
		; ==========================


^+s::
;exitApp
;return

Sleep 50
Reload
Sleep 1200 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
IfMsgBox, Yes, Edit
return