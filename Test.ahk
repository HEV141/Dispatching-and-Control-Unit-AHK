#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force


;TODO
	;GSM-module type detection Quectel/LongSung/Huawei
	;auto show uci.show after scanning bar-codes
	;configurable X, Y, Width, Height of windows

global CaptureData := []
global Title := "PuTTY"

PuttyLaunch(Title, X, Y, Width, Height)
{
	BlockInput On
	
	Run putty.exe
	Sleep, 200
	Send, !g ; !=Alt
	Send, {Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}
	Send, {Tab} %Title%
	Send, !y ; !=Alt
	Sleep, 100
	Send, {Enter}
	SetTitleMatchMode, 2
	Sleep, 100
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
		if (PuttyText = WatchText) or (GetKeyState("Esc"))	; need because AHK executing too fast and picking up whole context of previous line
			break											; also proper response to random lag (in theory)
		else
			continue
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

PuttyCut(BeginText, EndText) ; EndText can accept numbers of symbols to cut right after BeginText
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

PuttyRead(TextToFound, NumberOfLines:=0) ; optional second parameter specify numbers of lines for parsing
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
;MsgBox, %Cut% 

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
	Critical On
	MsgBox, Script is killed
	ExitApp
return

Esc::
	Critical On
	Send, {Esc}
	MsgBox, Script is stopped
	Exit
return

ScrollLock::
	try  ; Attempts to execute code.
	{
		test := 2
		HelloWorld()
		MakeToast(test)
	}
	catch e  ; Handles the first error/exception raised by the block above.
	{
		MsgBox, An exception was thrown!`nSpecifically: %e%
		Exit
	}

	HelloWorld()  ; Always succeeds.
	{
		MsgBox, Hello, world!
	}

	MakeToast(test)  ; Always fails.
	{
		; Jump immediately to the try block's error handler:
		if (test = 2)
			throw A_ThisFunc " is not implemented, sorry"
	}
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
return

sec:
	#IfWinActive ahk_class PuTTY Security Alert
	Loop
	{
		WinWait, PuTTY Security Alert, ,3
		WinActivate, PuTTY Security Alert
		if (ErrorLevel = 0) or (GetKeyState("Esc"))
			break
		else
			continue
	}
	Send, {Left} {Enter} 
	#IfWinActive
return

^2:: ; login
	WinActivate, PuTTY
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")
return

^3:: ; setup
	WinActivate, PuTTY
	Send, {Enter}
	switch Modem
	{
		case "Quectel": PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB3'")
		case "LongSung": PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB2'")
		case "Huawei": PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB0'")
		Default: PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB3'")
	}
	PuttySend("~#", "uci delete network.lan.gateway")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/network reload")
return

^4:: ; WAN check
	WinActivate, PuTTY
	Label_WANPing: ; yes it's label for scary horrible GOTO
	PuttySend("~#", "                   ")
	PuttySend("~#", "                   ")
	PuttySend("~#", "ifdown wan2")
	PuttySend("~#", "ping 8.8.8.8 -c 3")
	PuttySend("~#", " ")

	CheckRead := 0 ; trigger for showing error message
	if ((PuttyRead("Network is unreachable",12) = 1) or (PuttyRead("Operation not permitted",12) = 1))
	{
		Message := "Warning! `nNetwork error"
		CheckRead := 1
	}

	PuttyCut("time="," ms")
	CheckCut := CaptureArf()
	WANPingRef := 25
	if (CheckCut > WANPingRef)
	{
		Message := "Warning! `nAverage ping is over " WANPingRef "ms."
		CheckRead := 1
	}

	if (CheckRead = 1)
	{
		MsgBox, 0x000136,, % Message
			IfMsgBox Cancel
				Exit
			else IfMsgBox TryAgain
				Goto, Label_WANPing ; yes it's scary horrible GOTO
			else 
				Send, {Enter}
	}
return

^5:: ; WAN check file download
	WinActivate, PuTTY
	PuttySend("~#", "wget --no-check-certificate -P /tmp http://4duker.ru/1.bmp")
return

^6:: ; SIM check
	WinActivate, PuTTY
	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "ifdown wan")
	Label_SIM:
	switch Modem
	{
		case "Quectel": PuttySend("~#", "gcom -d /dev/ttyUSB2")
		case "LongSung": PuttySend("~#", "gcom -d /dev/ttyUSB1")
		case "Huawei": PuttySend("~#", "gcom")
		Default: PuttySend("~#", "gcom -d /dev/ttyUSB2")
	}
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

^7:: ; GSM check
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

^8:: ; final setup, ModBus/MKADD/MTRDD check - val=1990
	WinActivate, PuTTY
	PuttySend("~#", "ifup wan")
	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "uci set mspd48.socket.port='9001'")
	PuttySend("~#", "uci set mspd48.socket.recvtimeout='1000'")
	PuttySend("~#", "uci set mspd48.socket.address='megafon.techmonitor.ru'")
	PuttySend("~#", "uci set mspd48.@module[0].enable='1'")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/mspd48 restart")
	ClipBoard := ""

	loop
	{
		if (PuttyRead("1990") = 1)
		{
			SoundBeep
			MsgBox, 0x000040,,% "Modbus active `nDevice is ready"
				IfMsgBox Ok
					{
						BlockInput On
						Sleep, 1000
						WinActivate, Form1
						BlockInput Off
					}
			break
		}
		if (GetKeyState("Esc"))
			break
	}
	ClipBoard := ""

return

^0::
	Gosub ^2
	Gosub ^3
	Gosub ^4
	Gosub ^5
	Gosub ^6
	Gosub ^7
	Gosub ^8
return

Form1Read:
	WinWait, Form1
	WinActivate, Form1
	WinGetText, Form1Text
	if GetKeyState("Enter")
		if InStr(Form1Text, "Сохранено успешно")
		{
			WinActivate, PuTTY
			Send, uci show mspd48.main{Enter}
		}
return
