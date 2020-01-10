#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force

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
			If A_LoopField
				PuttyText := A_LoopField
		}
		PuttyText := SubStr(PuttyText, -(StrLen(WatchText)-1)) ; cut end of the line and check to match with WatchText
		If (PuttyText != WatchText)	; need because AHK executing too fast and picking up whole context of previous line
			Continue				; also proper response to random lag (in theory)
		Else
			Break
	}
	If (PuttyText = WatchText)
	{
		Send, %Command%
		Send, {Enter}
	}
	ClipBoard := ""
}

PuttyRead(BeginText, EndText)
{
	Data := []
	Sleep, 100
	SetTitleMatchMode, 2 ; Mode 2 - "[title] contains" 
	ClipBoard := ""
	PostMessage, 0x112, 0x170, 0,, PuTTY ; dark magic copy context of the window to the clipboard ; [title] = PuTTY - not working with global var
	ClipWait
	Cut := SubStr(Clipboard, -650)
	MsgBox % Cut
	Loop, parse, Cut, `n, `r    ; gets the last line of text from the clipboard
	{
		If A_LoopField
		{
			PuttyText := A_LoopField
			BeginPos := InStr(PuttyText, BeginText)
			EndPos := InStr(PuttyText, EndText)
			if (BeginPos != 0 and EndPos != 0)
			{
				MidText := SubStr(PuttyText, (BeginPos+StrLen(BeginText)), (EndPos-(BeginPos+StrLen(BeginText))))
				Data.Push(MidText)
			}
		}
	}

	for index, element in Data ; Enumeration is the recommended approach in most cases.
	{
		MsgBox % "Element №" index " is " element
		Data[index] := Data[index] + 0
		Sum += Data[index]
		MsgBox % "Sum " Sum
	}
	MsgBox % "Arf " Arf := Sum/max(index)

	ClipBoard := ""
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

	PuttySend("~#", "ifdown wan2")
	PuttySend("~#", "ping 8.8.8.8 -c 3")
	
return

^0::
	PuttyRead("time="," ms")
return
