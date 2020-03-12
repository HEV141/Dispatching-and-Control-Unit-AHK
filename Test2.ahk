#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;TODO
	;"Potentional Security Breach" error
	;Maybe upgrade Cut on PuttyRead and PuttyCut - set COUNT-var: for CNT ping and number of lines for copy
		;count for number of symbols in a row, send this to SubSrt, also count `n

		;or start from special symbol 

		;OR clear window and MAYBE logging
	;GSM-module type detection Quectel/Long Sung/Huawei
	;GUI

global CaptureData := []
global Title := "PuTTY"

PuttyLaunch(Title, X, Y, Width, Height)
{
	BlockInput On
	
	run putty.exe
	Sleep, 200
	Send, !g ; !=Alt
	Send, {Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}
	Send, {Tab} %Title%
	Send, !y  ; !=Alt
	Sleep, 100
	Send, {Enter}
	SetTitleMatchMode, 2
	Sleep, 100
	WinMove, %Title%, , %X%, %Y%, %Width%, %Height%

	BlockInput Off
}

PuttySend(WatchText, Command)
{
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
	global CaptureData := []
	Sleep, 100
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

PuttyRead(TextToFound)
{
	global CaptureData := []
	Sleep, 100
	SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
	ClipBoard := ""
	PostMessage, 0x112, 0x170, 0,, %Title% ; dark magic copy context of the window to the clipboard
	ClipWait
	Cut := SubStr(Clipboard, -650) ; taking not whole window, otherwise need to clear window
	Loop, parse, Cut, `n, `r    ; gets the last line of text from the clipboard
	{
		if A_LoopField
		{
			PuttyText := A_LoopField
			;MsgBox, % PuttyText
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

AltTab()
{	
	SetKeyDelay 30, 50
	Sleep, 100
	Send, {Alt down}{Tab}
	Sleep, 1
	Send, {Alt up}
}

SetTitleMatchMode, 2

F12::
	MsgBox, Script is killed
	ExitApp
return

;run putty through AHK command with AUX title
;resize and allign
;use WinActivate, AUX
	;WinWait, PuTTY, ,
	;WinMove, PuTTY, , 0, 0

ScrollLock::
	PuttyLaunch("AUX", 0, 0, 300, 675)
	PuttyLaunch("PuTTY", 300, 0, 550, 675)
return

Esc::
	MsgBox, Script is stopped
	exit
return

^1::
	WinActivate, PuTTY
	Sleep, 100
	Send, {Enter}
	#IfWinActive ahk_class PuTTY Fatal Error
	WinWait, PuTTY Fatal Error, ,3
		Send, {Enter}
	#IfWinActive

	Send, {Alt down}{Space}{Alt up}
	Send, r

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

^2:: ; login
	WinActivate, PuTTY
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")

	WinActivate, AUX
	global Title := "AUX"
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")	
return

^3::
	WinActivate, PuTTY
	PuttySend("~#", "echo 80 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio80/direction")
	PuttySend("~#", "echo 120 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio120/direction")
	PuttySend("~#", "echo 121 > /sys/class/gpio/export")
	PuttySend("~#", "echo in > /sys/class/gpio/gpio121/direction")

return

^4::
	PuttySend("~#", "cat /sys/kernel/debug/gpio")

return

^5::
	PuttySend("~#", "df -h")
	if (PuttyRead("1.9G") != 1)
	{
		Message := "Warning! `nSD-card error"
		CheckRead := 1
	}	

return

^6::

	AltTab()
	PuttySend("~#", "cat /dev/ttyAPP2")

	AltTab()
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP3 {Enter}

	AltTab()
	Send, {Ctrl down}c{Ctrl up}
	PuttySend("~#", "cat /dev/ttyAPP3")

	AltTab()
	PuttySend("~#", " ") 
	PuttySend("~#", " ") 
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP2 {Enter}
	PuttySend("~#", " ") 
	Send, echo "AT" > /dev/ttyAPP2 {Enter}
	PuttySend("~#", " ")
	Send, echo "AT" > /dev/ttyAPP2 {Enter}

	AltTab()
	Send, {Ctrl down}c{Ctrl up}

	AltTab()
return


^7:: ; SIM check
	WinActivate, PuTTY
	Label_SIM:
	PuttySend("~#", "gcom -d /dev/ttyAPP0")
	PuttySend("~#", " ")

	CheckRead := 0
	if (PuttyRead("ERROR") = 1)
	{
		Message := "Warning! `nSim error"
		CheckRead := 1
	}

	if (PuttyRead("Can't open device /dev/ttyUSB") = 1)
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

^8:: ; GSM check
	WinActivate, PuTTY
	PingDelay := 10
	BlockInput On
	MsgBox, 0x000040,,% PingDelay "sec delay. `nInput blocked. `nStand by...", % PingDelay
	IfMsgBox Timeout
	{
		BlockInput Off
	}

	Label_GSMping:
	PuttySend("~#", "ifdown wan")
	PuttySend("~#", "ping 8.8.8.8 -c 10")
	PuttySend("~#", " ")

	PuttyCut("time="," ms")
	CheckCut := CaptureArf()
	WANPingRef := 600
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

	if ((PuttyRead("Network is unreachable") = 1) or (PuttyRead("Operation not permitted") = 1))
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

; ^0::
; 	Gosub ^2
; 	Gosub ^3
; 	Gosub ^4
; 	Gosub ^5
; 	Gosub ^6
; 	Gosub ^7
; 	Gosub ^8
; return
