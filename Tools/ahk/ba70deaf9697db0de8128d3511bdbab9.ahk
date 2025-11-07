#Requires AutoHotkey v2
#SingleInstance Force
GroupAdd('AOKAOC', 'ahk_exe empires2.exe')
GroupAdd('AOKAOC', 'ahk_exe age2_x1.exe')
GroupAdd('AOKAOC', 'ahk_exe age2_x2.exe')
#HotIf WinActive('ahk_group AOKAOC')
!RButton:: {
WinGetPos(,, &W, &H, 'ahk_group AOKAOC')
If W != A_ScreenWidth || H != A_ScreenHeight
Return
MouseClick('Right', , , , 0)
MouseGetPos(&X, &Y)
SendInput('{LCtrl Down}')
MouseClick('Left', 315, A_ScreenHeight - 130, , 0)
SendInput('{Ctrl Up}')
MouseMove(X, Y, 0)
}
#q:: {
If GameIsRunning()
Msgbox('Game termination failuree!', 'Game Terminate', 0x30)
}
GameIsRunning() {
Processes := ['empires2.exe', 'age2_x1.exe', 'age2_x2.exe']
For Each, Process in Processes {
If ProcessExist(Process) {
ProcessClose(Process)
}
ProcessWaitClose(Process, 5)
If ProcessExist(Process) {
Return True
}
}
Return False
}#HotIf
ProcessWaitClose(A_Args[1])
ExitApp()