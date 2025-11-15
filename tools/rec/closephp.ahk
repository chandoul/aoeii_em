#Requires AutoHotkey v2
#SingleInstance Force

ahk := A_Args[1]
php := A_Args[2]

ProcessWaitClose(ahk)
ProcessClose(php)

ExitApp()