#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

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
		if (PuttyText != WatchText)	; need because AHK executing too fast and picking up whole context of previous line
			Continue				; also proper response to random lag (in theory)
		Else
			Break
	}
	if (PuttyText = WatchText)
	{
		Send, %Command%
		Send, {Enter}
	}
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

^1:: ; todo
	WinWait, PuTTY Fatal Error, ,3
		Send, {Enter}
 
	Send, !{Space}
	Send, r
	
	WinWait, PuTTY Security Alert, ,3
		Send, {Left} {Enter} 
return

^2::
	PuttySend("as:", "root")
	PuttySend("password:", "tmsoft")
return

^3::
	Send, {Enter}
	PuttySend("~#", "uci set network.wan2.device='/dev/ttyUSB3'")
	PuttySend("~#", "uci delete network.lan.gateway")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/network reload")

	WANPing:
	PuttySend("~#", "ifdown wan2")
	PuttySend("~#", "ping 8.8.8.8 -c 3")
	PuttySend("~#", " ")
	
	CheckRead := 0
	if (PuttyRead("Network is unreachable") = 1)
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
		MsgBox, 0x000236,, % Message
			IfMsgBox Cancel
				return
			else IfMsgBox TryAgain
				Goto, WANPing
			else 
				Send, {Enter}
	}

	PuttySend("~#", "wget --no-check-certificate -P /tmp http://4duker.ru/1.bmp")

	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "ifdown wan")
	SIM:
	PuttySend("~#", "gcom -d /dev/ttyUSB2")
	PuttySend("~#", " ")

	CheckRead := 0
	if (PuttyRead("ERROR") = 1)
	{
		Message := "Sim error"
		CheckRead := 1
	}

	if (PuttyRead("Can't open device /dev/ttyUSB2") = 1)
	{
		Message := "GSM module error"
		CheckRead := 1
	}
	
	if (CheckRead = 1)
	{
		MsgBox, 0x000236,, % Message
			IfMsgBox Cancel
				return
			else IfMsgBox TryAgain
				Goto, SIM
			else 
				Send, {Enter}
	}

	PingDelay := 10
	BlockInput On
	MsgBox, 0x000040,,% PingDelay "sec delay. `nInput blocked. `nStand by...", % PingDelay
	IfMsgBox Timeout
	{
		PuttySend("~#", "ping 8.8.8.8 -c 10")
		BlockInput Off
	}

	PuttySend("~#", "ifup wan")
	PuttySend("~#", "ifup wan2")
	PuttySend("~#", "uci set mspd48.socket.port='9001'")
	PuttySend("~#", "uci set mspd48.socket.recvtimeout='1000'")
	PuttySend("~#", "uci set mspd48.socket.address='megafon.techmonitor.ru'")
	PuttySend("~#", "uci set mspd48.@module[0].enable='1'")
	PuttySend("~#", "uci commit")
	PuttySend("~#", "/etc/init.d/mspd48 restart")
	
	CheckRead := 0
	CheckRead := PuttyRead("1990")

	if (CheckRead = 1)
	{
		MsgBox, 0x000040,, % "DEVICE IS GOOD"
	}

return

^0::

return