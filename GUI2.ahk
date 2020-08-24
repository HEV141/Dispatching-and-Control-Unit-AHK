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

Gui, New,, mini Dispatching and Control Unit | Quality Control
Gui, Add, Text,, Проверка
Gui, Add, Button, x80 y47 w60 h53 gUPDATE, UPDATE
Gui, Add, Progress, x80 y37 w60 h10 +Border Background%val% vUPDsign

Gui, Add, Button, x80 y110 w60 gStart, Start
Gui, Add, Button, x20 y110 w50 h53 gReboot, Reboot
Gui, Add, Button, x80 y140 w60 gStop, Stop
Gui, Add, Text, x10 y205, Статус
Gui, Add, Edit, w380 r5

Gui, Add, Button, x160 y6 gToggleAll w40, All/None
Gui, Add, Button, g^1 w25 h13, >>
    Gui, Add, Button, x190 y54 gsec w25 h13, >>
Gui, Add, Button, x160 y73 g^2 w25 h13, >>
Gui, Add, Button, g^3 w25 h13, >>
Gui, Add, Button, g^4 w25 h13, >>
Gui, Add, Button, g^5 w25 h13, >>
Gui, Add, Button, g^6 w25 h13, >>
Gui, Add, Button, g^7 w25 h13, >>
Gui, Add, Button, g^8 w25 h13, >>
Gui, Add, Button, g9mod w25 h13, >>
Gui, Add, Button, x290 y6 gPingForm1Launch w70, Ping/Form
Gui, Add, Button, x370 y6 gPuttyLaunch w60, PuTTY

Gui, Add, CheckBox, x190 y35 vCheck1 Checked, Перезапуск
    Gui, Add, CheckBox, x220 y54 vCheck1_1 Checked, Security Alert отработка
Gui, Add, CheckBox, x190 y73 vCheck2 Checked, Логин
Gui, Add, CheckBox, vCheck3 Checked, Настройка портов
Gui, Add, CheckBox, vCheck4 Checked, Проверка портов
Gui, Add, CheckBox, vCheck5 Checked, Проверка SD-карты
Gui, Add, CheckBox, vCheck6 Checked, Echo "AT" посылка
Gui, Add, CheckBox, vCheck7 Checked, Проверка SIM
Gui, Add, CheckBox, vCheck8 Checked, Ping
Gui, Add, CheckBox, vCheck9 Checked, Показать инфо об устройстве

Gui, Add, ComboBox, x320 y126 vSDChoice, 1.9G||3.7G ; a|b|c - no default ; a||b|c - "a" is default

Gui, Show, x800 y4 w440 h500

Toggle := 1
#Include Test2.ahk
SetTitleMatchMode, 2
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

UPDATE:
;no    Run "C:\Users\TM_SycHEVanov\Desktop\UpdateMiniAsdu\update.bat", "C:\Users\TM_SycHEVanov\Desktop\UpdateMiniAsdu"
    Run "C:\Users\TM_SycHEVanov\Desktop\update.bat - Ярлык"
    val := "00FF00"
    GuiControl, +Background%val%, UPDsign
    GuiControl,, Check1_1, 0
return

9mod:
    val := "000000"
    GuiControl, +Background%val%, UPDsign
    Gosub ^9
return

Start:
    Gui, Submit, NoHide
    if (Check1)
        Gosub ^1
    if (Check1_1)
        Gosub sec
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
    if (Check9)
        Gosub 9mod
return

Stop:
    Critical, On
    Send, {Esc}
    #Include Test2.ahk
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
    GuiControl,, Check9, % Toggle
return

GuiClose:
ExitApp