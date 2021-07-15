#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
#SingleInstance Force

;Ctrl+K+C
;Ctrl+K+U

CoordIniWrite(SectionName, X, Y, Width, Height)
{
    IniWrite, %X%, %A_ScriptDir%\config.ini, %SectionName%, X
    IniWrite, %Y%, %A_ScriptDir%\config.ini, %SectionName%, Y
    IniWrite, %Width%, %A_ScriptDir%\config.ini, %SectionName%, Width
    IniWrite, %Height%, %A_ScriptDir%\config.ini, %SectionName%, Height
}

CoordIniRead(SectionName)
{
    IniRead, X, %A_ScriptDir%\config.ini, %SectionName%, X
    IniRead, Y, %A_ScriptDir%\config.ini, %SectionName%, Y
    IniRead, Width, %A_ScriptDir%\config.ini, %SectionName%, Width
    IniRead, Height, %A_ScriptDir%\config.ini, %SectionName%, Height
    return {X: X, Y: Y, W: Width, H: Height}
}


Gui, New,, Dispatching and Control Unit | Quality Control
Gui, Add, Text,, Проверка

Gui, Add, CheckBox, x10 y25 gAutoModem, Автодетекция модема ;; gAutoModem Checked

Gui, Add, GroupBox, r3, Модем:
Gui, Add, Radio, gRadioCheck vRadioGr Group Checked xp+10 yp+20 r1, Quectel
Gui, Add, Radio, gRadioCheck r1, Long Sung
Gui, Add, Radio, gRadioCheck r1, Huawei

Gui, Add, Button, x80 y130 w60 gStart, Start
Gui, Add, Button, x20 y130 w50 h53 gReboot, Reboot
Gui, Add, Button, x80 y160 w60 gStop, Stop

Gui, Add, Text, x10 y205, Статус
Gui, Add, Edit, w380 r1 vStatusMsgBar

Gui, Add, Text, x10 y255, Заметки
Gui, Add, Edit, w380 r9, `nls -l /dev/ttyUSB*`n`nlogread -e Modbus`n`n`nuci show mspd48.main`n`n


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
Gui, Add, Button, x290 y6 gPingForm1Launch w70, Ping/Form
Gui, Add, Button, x370 y6 gPuttyLaunch w60, PuTTY

Gui, Add, CheckBox, x190 y35 vCheck1 Checked, Перезапуск
    Gui, Add, CheckBox, x220 y54 vCheck1_1 Checked, Security Alert отработка
Gui, Add, CheckBox, x190 y73 vCheck2 Checked, Логин
Gui, Add, CheckBox, vCheck3 Checked, Первоначальная настройка
Gui, Add, CheckBox, vCheck4 Checked, Проверка WAN
Gui, Add, CheckBox, vCheck5 Checked, Проверка WAN, скачивание файла
Gui, Add, CheckBox, vCheck6 Checked, Проверка SIM
Gui, Add, CheckBox, vCheck7 Checked, Проверка GSM
Gui, Add, CheckBox, vCheck8 Checked, Финальная настройка и проверка ModBus

    Menu, FileMenu, Add, &Открыть`tCtrl+O, MenuFileOpen
    Menu, FileMenu, Add, &Сохранить`tCtrl+S, MenuFileOpen
    Menu, FileMenu, Add, &Выход, GuiClose
Menu, MenuBar, Add, &Файл, :FileMenu  ; Attach the two sub-menus that were created above.

    Menu, WinParam, Add, &Запомнить положение, CoodrSave
    Menu, WinParam, Add, &Окно скрипта, MenuHandler
    Menu, WinParam, Add, &Ping, MenuHandler 
    Menu, WinParam, Add, &Form1, MenuHandler
    Menu, WinParam, Add, &PuTTY, MenuHandler
    Menu, WinParam, Add, &Сброс, CoodrReset
Menu, MenuBar, Add, &Вид, :WinParam

Gui, Menu, MenuBar

CR := CoordIniRead("Script_Coordinates")
x := CR.X ; because %CR.X% -> ERROR
y := CR.Y
w := CR.W
h := CR.H
Gui, Show, x%x% y%y% w%w% h%h%


;; to change autodetection make Disable Disable Disable | AutoModem := 0 | Gui, Add, CheckBox, x10 y25 gAutoModem Checked, Автодетекция модема

GuiControl, Enable, Quectel
GuiControl, Enable, Long Sung
GuiControl, Enable, Huawei
Toggle := 1
AutoModem := 0
#Include Test.ahk
SetTitleMatchMode, 2
return

MenuFileOpen:
return
MenuHandler:
return

CoodrSave:
    WinGetPos, X, Y, Width, Height, ping
    CoordIniWrite("Ping_Coordinates", X, Y, Width, Height)
    WinGetPos, X, Y, Width, Height, Form1
    CoordIniWrite("Form1_Coordinates", X, Y, Width, Height)
    WinGetPos, X, Y, Width, Height, PuTTY
    CoordIniWrite("PuTTY_Coordinates", X, Y, Width, Height)
    WinGetPos, X, Y, Width, Height, Dispatching and Control Unit | Quality Control
    CoordIniWrite("Script_Coordinates", X, Y, Width, Height)
return

CoodrReset:
    CoordIniWrite("Ping_Coordinates", 0, 675, 400, 300)
    CoordIniWrite("Form1_Coordinates", 405, 675, "", "")
    CoordIniWrite("PuTTY_Coordinates", 0, 0, 640, 675)
    CoordIniWrite("Script_Coordinates", 800, 4, 440, 500)
return

PuttyLaunch:
    CR := CoordIniRead("PuTTY_Coordinates")
    PuttyLaunch("PuTTY", CR.X, CR.Y, CR.W, CR.H)
return

PingForm1Launch:
    WinClose, cmd.exe
    Run C:\Windows\System32\cmd.exe /k ping -t 192.168.1.122
    CR := CoordIniRead("Ping_Coordinates")
    Sleep, 200
    WinMove, ping, , CR.X, CR.Y, CR.W, CR.H

    WinClose, Form1
    Run "C:\Users\TM_SycHEVanov\Desktop\ПРОВЕРКА АСДУ\ФИНАЛЬНАЯ ПРОВЕРКА АСДУ\SerialScanerNew\Emuliator.SerialScaner.exe"
    CR := CoordIniRead("Form1_Coordinates")
    Sleep, 200
    WinMove, Form1, , CR.X, CR.Y, CR.W, CR.H
return

AutoModem:
    AutoModem ^= 1
    if AutoModem
    {
        GuiControl, Disable, Quectel
        GuiControl, Disable, Long Sung
        GuiControl, Disable, Huawei
    }
    else
    {
        GuiControl, Enable, Quectel
        GuiControl, Enable, Long Sung
        GuiControl, Enable, Huawei
    }
    Gui, Submit, NoHide
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
    GuiControl,, Check1_1, % Toggle
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