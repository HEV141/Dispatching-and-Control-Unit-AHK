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

Gui, Add, Button, x50 y110 w60 vStart, Старт
Gui, Add, Button, x50 y140 w60 vStop, Стоп
Gui, Add, Text, x10 y175, Статус
Gui, Add, Edit, w380 r5


Gui, Add, Button, x160 y6 gToggleAll w40, All/None
Gui, Add, Button, v11 w25 h13, >>
Gui, Add, Button, v12 w25 h13, >>
Gui, Add, Button, v13 w25 h13, >>
Gui, Add, Button, v14 w25 h13, >>
Gui, Add, Button, v15 w25 h13, >>
Gui, Add, Button, v16 w25 h13, >>
Gui, Add, Button, v17 w25 h13, >>
Gui, Add, Button, v18 w25 h13, >>
Gui, Add, CheckBox,x190 y35 v1 Checked, Перезапуск
Gui, Add, CheckBox, v2 Checked, Логин
Gui, Add, CheckBox, v3 Checked, Настройка
Gui, Add, CheckBox, v4 Checked, Проверка WAN
Gui, Add, CheckBox, v5 Checked, Проверка WAN, скачивание файла
Gui, Add, CheckBox, v6 Checked, Проверка SIM
Gui, Add, CheckBox, v7 Checked, Проверка GSM
Gui, Add, CheckBox, v8 Checked, Финальная настройка и проверка ModBus

Gui, Show, x100 y4 w440 h500

Toggle := 0
ToggleAll:
Toggle ^= 1
GuiControl,, 1, % Toggle
GuiControl,, 2, % Toggle
GuiControl,, 3, % Toggle
GuiControl,, 4, % Toggle
GuiControl,, 5, % Toggle
GuiControl,, 6, % Toggle
GuiControl,, 7, % Toggle
GuiControl,, 8, % Toggle
