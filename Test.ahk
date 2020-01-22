#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

;TODO
	;"Potentional Security Breach" error
	;Maybe upgrade Cut on PuttyRead and PuttyCut - set COUNT-var: for CNT ping and number of lines for copy
	;GSM-module type detection Quectel/Long Sung/Huawei
	;1990 detection
	;GUI

CaptureData := []

PuttySend(WatchText, Command)
{
	Loop
	{
		Sleep, 100
		SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
		ClipBoard := ""
		PostMessage, 0x112, 0x170, 0,, PuTTY ; dark magic copy context of the window to the clipboard ; [title] = PuTTY - not working with global var
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
	PostMessage, 0x112, 0x170, 0,, PuTTY ; dark magic copy context of the window to the clipboard ; [title] = PuTTY - not working with global var
	ClipWait
	Cut := SubStr(Clipboard, -650) ; taking not the whole window, otherwise need to clear the window
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
	PostMessage, 0x112, 0x170, 0,, PuTTY ; dark magic copy context of the window to the clipboard ; [title] = PuTTY - not working with global var
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

^1::
	Send, {Enter}
	#IfWinActive ahk_class PuTTY Fatal Error
	WinWait, PuTTY Fatal Error, ,3
		Send, {Enter}
	#IfWinActive

	Send, {Alt down}{Space}{Alt up}
	Send, r
;return
;^q::
	#IfWinActive ahk_class PuTTY Security Alert
	Loop
	{
		WinWait, PuTTY Security Alert, ,3
		if ErrorLevel = 0
			Break
		else
			Continue
	}
	Send, {Left} {Enter} 
	#IfWinActive
return

^2:: ; login
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")
return

^3:: ; setup
	Send, {Enter}
	PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB3'")
	PuttySend("~#", "uci delete network.lan.gateway")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/network reload")
return

^4:: ; WAN check
	Label_WANPing: ; yes it's label for scary horrible GOTO
	PuttySend("~#", " ")
	PuttySend("~#", " ")
	PuttySend("~#", " ")
	PuttySend("~#", " ")
	PuttySend("~#", "ifdown wan2")
	PuttySend("~#", "ping 8.8.8.8 -c 3")
	PuttySend("~#", " ")
	
	CheckRead := 0 ; trigger for showing error message
	if ((PuttyRead("Network is unreachable") = 1) or (PuttyRead("Operation not permitted") = 1))
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

^5:: ; WAN check
	PuttySend("~#", "wget --no-check-certificate -P /tmp http://4duker.ru/1.bmp")
return

^6:: ; SIM check
	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "ifdown wan")
	Label_SIM:
	PuttySend("~#", "gcom -d /dev/ttyUSB2")
	PuttySend("~#", " ")

	CheckRead := 0
	if (PuttyRead("ERROR") = 1)
	{
		Message := "Warning! `nSim error"
		CheckRead := 1
	}

	if (PuttyRead("Can't open device /dev/ttyUSB2") = 1)
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
	WANPingRefMin := 30
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
	PuttySend("~#", "ifup wan")
	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "uci set mspd48.socket.port='9001'")
	PuttySend("~#", "uci set mspd48.socket.recvtimeout='1000'")
	PuttySend("~#", "uci set mspd48.socket.address='megafon.techmonitor.ru'")
	PuttySend("~#", "uci set mspd48.@module[0].enable='1'")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/mspd48 restart")

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

Esc::ExitApp