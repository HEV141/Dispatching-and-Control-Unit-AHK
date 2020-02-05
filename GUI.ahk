#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force


;TODO
    ;blocking input - maybe good idea
    ;GSM signal quality

Gui, New,, Test GUI
Gui, Add, Text,, Проверка

Gui, Add, GroupBox, r3, Модем:
Gui, Add, Radio, vQuectel Group Checked xp+10 yp+20 r1, Quectel
Gui, Add, Radio, vLongSung r1, Long Sung
Gui, Add, Radio, vHuawei r1, Huawei

Gui, Add, Button, x50 y110 w60 g^0, Старт
Gui, Add, Button, x50 y140 w60 vStopAll, Стоп
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
Gui, Add, CheckBox, x190 y35 vCheck1 Checked, Перезапуск
Gui, Add, CheckBox, vCheck2 Checked, Логин
Gui, Add, CheckBox, vCheck3 Checked, Настройка
Gui, Add, CheckBox, vCheck4 Checked, Проверка WAN
Gui, Add, CheckBox, vCheck5 Checked, Проверка WAN, скачивание файла
Gui, Add, CheckBox, vCheck6 Checked, Проверка SIM
Gui, Add, CheckBox, vCheck7 Checked, Проверка GSM
Gui, Add, CheckBox, vCheck8 Checked, Финальная настройка и проверка ModBus

Gui, Show, x100 y4 w440 h500

Toggle := 0
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

#Include Test.ahk
