#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
#SingleInstance Force

;Ctrl+K+C
;Ctrl+K+U

;TODO
    ;blocking input - maybe good idea
    ;GSM signal quality
    ;calling subroutine that calling other subroutine seems doesn't work 

Gui, New,, Dispatching and Control Unit | Quality Control
Gui, Add, Text,, Проверка

Gui, Add, GroupBox, r3, Модем:
Gui, Add, Radio, gRadioCheck vRadioGr Group Checked xp+10 yp+20 r1, Quectel
Gui, Add, Radio, gRadioCheck r1, Long Sung
Gui, Add, Radio, gRadioCheck r1, Huawei

Gui, Add, Button, x80 y110 w60 gStart, Start
Gui, Add, Button, x20 y110 w50 h53 gReboot, Reboot
Gui, Add, Button, x80 y140 w60 gStop, Stop
Gui, Add, Text, x10 y175, Статус
Gui, Add, Edit, w380 r5


Gui, Add, Button, x160 y6 gToggleAll w40, All/None
Gui, Add, Button, g^1 w25 h13, >>
Gui, Add, Button, g^2 w25 h13, >>
Gui, Add, Button, g^3 w25 h13, >>
Gui, Add, Button, g^4 w25 h13, >>
Gui, Add, Button, g^5 w25 h13, >>
Gui, Add, Button, g^6 w25 h13, >>
Gui, Add, Button, g^7 w25 h13, >>
Gui, Add, Button, g^8 w25 h13, >>
Gui, Add, Button, x290 y6 gPingForm1Launch w70, Ping/Form
Gui, Add, Button, x370 y6 gPuttyLaunch w60, PuTTY
Gui, Add, CheckBox, x190 y35 vCheck1 Checked, Перезапуск
Gui, Add, CheckBox, vCheck2 Checked, Логин
Gui, Add, CheckBox, vCheck3 Checked, Первоначальная настройка
Gui, Add, CheckBox, vCheck4 Checked, Проверка WAN
Gui, Add, CheckBox, vCheck5 Checked, Проверка WAN, скачивание файла
Gui, Add, CheckBox, vCheck6 Checked, Проверка SIM
Gui, Add, CheckBox, vCheck7 Checked, Проверка GSM
Gui, Add, CheckBox, vCheck8 Checked, Финальная настройка и проверка ModBus

Gui, Show, x800 y4 w440 h500

Toggle := 1
#Include Test.ahk
SetTitleMatchMode, 2
return

PuttyLaunch:
    PuttyLaunch("PuTTY", 0, 0, 640, 675)
return

PingForm1Launch:
    WinClose, cmd.exe
    Run C:\Windows\System32\cmd.exe /k ping -t 192.168.1.122
    Sleep, 200
    WinMove, ping, , 0, 675, 400, 300

    WinClose, Form1
    Run "C:\Users\TM_SycHEVanov\Desktop\ПРОВЕРКА АСДУ\ФИНАЛЬНАЯ ПРОВЕРКА АСДУ\SerialScanerNew\Emuliator.SerialScaner.exe"
    Sleep, 200
    WinMove, Form1, , 405, 675
return

RadioCheck:
    Gui, Submit, NoHide
    if (RadioGr = 1)
        Modem := "Quectel"
    if (RadioGr = 2)
        Modem := "LongSung"
    if (RadioGr = 3)
        Modem := "Huawei"
return

Start:
    Gui, Submit, NoHide
    if (Check1)
        Gosub ^1
    if (Check2)
        Gosub ^2
    if (Check3)
        Gosub ^3
    if (Check4)
        Gosub ^4
    if (Check5)
        Gosub ^5
    if (Check6)
        Gosub ^6
    if (Check7)
        Gosub ^7
    if (Check8)
        Gosub ^8
return

Stop:
    Critical, On
    Send, {Esc}
    #Include Test.ahk
return

Reboot:
    Critical, On
    Reload
return

ToggleAll:
    Toggle ^= 1
    GuiControl,, Check1, % Toggle
    GuiControl,, Check2, % Toggle
    GuiControl,, Check3, % Toggle
    GuiControl,, Check4, % Toggle
    GuiControl,, Check5, % Toggle
    GuiControl,, Check6, % Toggle
    GuiControl,, Check7, % Toggle
    GuiControl,, Check8, % Toggle
return

GuiClose:
ExitApp