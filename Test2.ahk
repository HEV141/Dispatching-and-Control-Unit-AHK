#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

global CaptureData := []
global Title := "PuTTY"

PuttyLaunch(Title, X, Y, Width, Height)
{
	BlockInput On
	
	Run putty.exe
	Sleep, 250
	Send, !g ; !=Alt
	Send, {Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}
	Send, {Tab} %Title%
	Send, !y ; !=Alt
	Sleep, 250
	Send, {Enter}
	SetTitleMatchMode, 2
	Sleep, 250
	WinMove, %Title%, , %X%, %Y%, %Width%, %Height%

	BlockInput Off
}

PuttySend(WatchText, Command)
{
	WinActivate, %Title%
	Loop
	{
		Sleep, 100
		SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
		ClipBoard := ""
		PostMessage, 0x112, 0x170, 0,, %Title% ; dark magic copy context of the window to the clipboard
		ClipWait
		Loop, parse, Clipboard, `n, `r    ; gets the last line of text from the clipboard
		{
			if A_LoopField
				PuttyText := A_LoopField
		}
		PuttyText := SubStr(PuttyText, -(StrLen(WatchText)-1)) ; cut end of the line and check to match with WatchText
		if (PuttyText = WatchText) or GetKeyState("Enter")	; need because AHK executing too fast and picking up whole context of previous line
			Break											; also proper response to random lag (in theory)
		Else
			Continue
	}
	if (PuttyText = WatchText)
	{
		Send, %Command%
		Send, {Enter}
	}
	else
		Send, {Enter}
	ClipBoard := ""
}

PuttyCut(BeginText, EndText)
{
	WinActivate, %Title%
	global CaptureData := []
	Sleep, 10
	SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
	ClipBoard := ""
	PostMessage, 0x112, 0x170, 0,, %Title% ; dark magic copy context of the window to the clipboard
	ClipWait
	Cut := SubStr(Clipboard, -650) ; not taking the whole window, otherwise need to clear the window
	Loop, parse, Cut, `n, `r    ; gets the last line of text from the clipboard
	{
		if A_LoopField
		{
			PuttyText := A_LoopField
			BeginPos := InStr(PuttyText, BeginText)
			if EndText is Integer
				EndPos := EndText + (BeginPos+StrLen(BeginText))
			else
				EndPos := InStr(PuttyText, EndText)
			if (BeginPos != 0 and EndPos != 0)
			{
				MidText := SubStr(PuttyText, (BeginPos+StrLen(BeginText)), (EndPos-(BeginPos+StrLen(BeginText)))) ; extract text between BeginText and EndText
				CaptureData.Push(MidText)
			}
		}
	}
	ClipBoard := ""
}

PuttyRead(TextToFound, NumberOfLines:=0)
{
	WinActivate, %Title%
	global CaptureData := []
	LinesLength := []
	Sleep, 100
	SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
	ClipBoard := ""
	PostMessage, 0x112, 0x170, 0,, %Title% ; dark magic copy context of the window to the clipboard
	ClipWait
	Cut := SubStr(Clipboard, -650)
	Loop, parse, Cut, `n, `r ; parsing text line by line
	{
		if A_LoopField
		{
			LinesLength.Push(StrLen(A_LoopField)) ; index = number of line, value = length of line
		}
	}
	;MsgBox % LinesLength[LinesLength.MaxIndex()]
	CutLen := 650*(NumberOfLines=0)+0*(NumberOfLines>0) ; for retrofitting all PuttyRead calls
	Loop % NumberOfLines
	{
  		CutLen += LinesLength[A_Index + (LinesLength.MaxIndex() - NumberOfLines)] ; sum "lengths" of last NumberOfLines lines
	}
	Cut := SubStr(Clipboard, -(CutLen)) ; taking not whole window, otherwise need to clear window

	Loop, parse, Cut, `n, `r
	{
		if A_LoopField
		{
			PuttyText := A_LoopField
			if InStr(PuttyText, TextToFound)
  				return 1
		}
	}
	ClipBoard := ""
}

CaptureArf()
{
	global CaptureData
	for index, element in CaptureData ; Enumeration is the recommended approach in most cases.
	{
		CaptureData[index] := CaptureData[index] + 0
		Sum += CaptureData[index]
	}
	Arf := Sum/max(index)
	return Arf
}

SetTitleMatchMode, 2

F12::
	MsgBox, Script is killed
	ExitApp
return

PuttyLaunch:
;ScrollLock::
	BlockInput On

	WinClose, AUX
	Sleep, 500
	WinActivate, PuTTY Exit Confirmation
	Send, Enter
	WinClose, PuTTY
	Sleep, 500
	WinActivate, PuTTY Exit Confirmation
	Send, Enter
	PuttyLaunch("AUX", 0, 0, 300, 610)
	PuttyLaunch("PuTTY", 300, 0, 550, 610)

	BlockInput Off
return

Esc::
	MsgBox, Script is stopped
	exit
return

^1::
;Numpad0 & Numpad1::
	global Title := "PuTTY"
	WinActivate, PuTTY
	Sleep, 100
	Send, {Enter}
	#IfWinActive ahk_class PuTTY Fatal Error
	WinWait, PuTTY Fatal Error, ,3
		Send, {Enter}
	#IfWinActive

	Send, {Alt down}{Space}{Alt up}
	Send, r

	global Title := "AUX"
	WinActivate, AUX
	Sleep, 100
	Send, {Enter}
	#IfWinActive ahk_class PuTTY Fatal Error
	WinWait, PuTTY Fatal Error, ,3
		Send, {Enter}
	#IfWinActive

	Send, {Alt down}{Space}{Alt up}
	Send, r
return

^1_1:
	;===============================

	; SecurityAlert := 1
	; if SecurityAlert = 1
	; {
	; 	#IfWinActive ahk_class PuTTY Security Alert
	; 	Loop
	; 	{
	; 		WinWait, PuTTY Security Alert, ,3
	; 		if (ErrorLevel = 0) or (GetKeyState("Esc"))
	; 			break
	; 		else
	; 			continue
	; 	}
	; 	Send, {Left} {Enter} 
	; 	#IfWinActive
	; 	Sleep, 5000
	; 	#IfWinActive ahk_class PuTTY Security Alert
	; 	Loop
	; 	{
	; 		WinWait, PuTTY Security Alert, ,3
	; 		if (ErrorLevel = 0) or (GetKeyState("Esc"))
	; 			break
	; 		else
	; 			continue
	; 	}
	; 	Send, {Left} {Enter} 
	; 	#IfWinActive
	; }
return

^2::
;Numpad0 & Numpad2:: ; login
	global Title := "PuTTY"
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")

	global Title := "AUX"
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")	
return

^3::
;Numpad0 & Numpad3::
	global Title := "PuTTY"
	PuttySend("~#", "echo 80 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio80/direction")
	PuttySend("~#", "echo 120 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio120/direction")
	PuttySend("~#", "echo 121 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio121/direction")

return

^4::
;Numpad0 & Numpad4::
	global Title := "PuTTY"
	global CaptureData
	Label_GPIO:
	PuttySend("~#", "cat /sys/kernel/debug/gpio")
	; Message := "Проверка портов ввода/вывода"
	; Sleep, 70
	; PuttyCut("gpio-80  (sysfs               ) in",4) 
	; port80 := CaptureData[1]
	; PuttyCut("gpio-120 (sysfs               ) in",4) 
	; port120 := CaptureData[1]
	; PuttyCut("gpio-121 (sysfs               ) in",4) 
	; port121 := CaptureData[1]	
	; MsgBox, 0x000136,, %Message% `ngpio-80   = %port80%`ngpio-120 = %port120%`ngpio-121 = %port121%
	; 	IfMsgBox Cancel
 	; 	Exit
 	; else IfMsgBox TryAgain
 	; 	Goto, Label_GPIO
 	; else
 	; 	Send, {Enter}
return

^5::
;Numpad0 & Numpad5::
	global Title := "PuTTY"
	PuttySend("~#", "df -h")
	PuttySend("~#", "")
	Sleep, 100
	SDChoice:="1.9G"
;	if (PuttyRead("3.7G") != 1)
	if (PuttyRead(%SDChoice%) != 1)
	{
		MsgBox, 0x000040,,% "Warning! `nSD-card error"
		CheckRead := 1
	}
return

^6::
;Numpad0 & Numpad6::
	global Title := "AUX"
	PuttySend("~#", "cat /dev/ttyAPP2")

	global Title := "PuTTY"
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}

	global Title := "AUX"
	WinActivate, AUX
	Send, {Ctrl down}c{Ctrl up}
	
	PuttySend("~#", "cat /dev/ttyAPP3")

	global Title := "PuTTY"
	Sleep, 100
	PuttySend("~#", " ") 
	PuttySend("~#", " ") 
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP2 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP2 {Enter}
	PuttySend("~#", " ")
	Send, echo "AT" > /dev/ttyAPP2 {Enter}

	global Title := "AUX"
	WinActivate, AUX
	Send, {Ctrl down}c{Ctrl up}

return

^7::
;Numpad0 & Numpad7:: ; SIM check
	global Title := "PuTTY"
	Label_SIM:
	PuttySend("~#", "gcom -d /dev/ttyAPP0")
	PuttySend("~#", " ")

	CheckRead := 0
	if (PuttyRead("ERROR",7) = 1)
	{
		Message := "Warning! `nSim error"
		CheckRead := 1
	}

	if (PuttyRead("Can't open device /dev/ttyUSB",7) = 1)
	{
		Message := "Warning! `nGSM module error"
		CheckRead := 1
	}

	if (CheckRead = 1)
	{
		MsgBox, 0x000136,, % Message
			IfMsgBox Cancel
				Exit
			else IfMsgBox TryAgain
				Goto, Label_SIM
			else 
				Send, {Enter}
	}
return

^8::
;Numpad0 & Numpad8:: ; GSM check
	WinActivate, PuTTY
	PingDelay := 1
	BlockInput On
	MsgBox, 0x000040,,% PingDelay "sec delay. `nInput blocked. `nStand by...", % PingDelay
	IfMsgBox Timeout
	{
		BlockInput Off
	}

	Label_GSMping:
	PuttySend("~#", "ping 8.8.8.8 -c 10")
	PuttySend("~#", " ")

	PuttyCut("time="," ms")
	CheckCut := CaptureArf()
	WANPingRef := 1000
	WANPingRefMin := 45
	CheckRead := 0
	if (CheckCut > WANPingRef)
	{
		Message := "Warning! `nAverage ping is over " WANPingRef "ms."
		CheckRead := 1
	}
	if (CheckCut < WANPingRefMin) 
	{
		Message := "Warning! `nAverage ping is less then " WANPingRefMin "ms.`nCheck if WAN is disable"
		CheckRead := 1
	}

	if ( (PuttyRead("Network is unreachable") = 1) or (PuttyRead("Operation not permitted") = 1) )
	{
		Message := "Warning! `nNetwork error"
		CheckRead := 1
	}

	if (CheckRead = 1)
	{
		MsgBox, 0x000136,, % Message
			IfMsgBox Cancel
				Exit
			else IfMsgBox TryAgain
				Goto, Label_GSMPing
			else 
				Send, {Enter}
	}
return

^9::
;Numpad0 & Numpad9::
	global Title := "PuTTY"
	PuttySend("~#", "uci show mspd48.main")
	WinActivate, Form1
return

; ^0::
; 	Gosub ^2
; 	Gosub ^3
; 	Gosub ^4
; 	Gosub ^5
; 	Gosub ^6
; 	Gosub ^7
; 	Gosub ^8
; return
