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
		PostMessage, 0x112, 0x170, 0,, PuTTY ; dark magic ; [title] = PuTTY - not working with global var
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
