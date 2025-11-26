#SingleInstance Force
#Requires AutoHotkey v2

#Include ..\..\libs\Base.ahk

haiapp := Base()

haiPath := (A_Is64bitOS ? EnvGet('ProgramFiles(x86)') : EnvGet('ProgramFiles')) '\Hide All IP\HideALLIP.exe'

haiGui := GuiEx(, 'Hide All IP Trial Reset')
haiGui.initiate(, , 0)
haiGui.addButtonEx('xm w400', 'Reset Trial Period', , resetTrial)
haiGui.showEx(, 1)

resetTrial(*) {
    For setting in ['~ WIN7RTM RUNASADMIN', '~ WIN8RTM RUNASADMIN'] {
        If !FileExist(haiPath) {
            MsgBoxEx("Hide All IP not found!`nYou must install Hide All IP first.", 'Hide All IP Trial Reset', , 0x30)
            Return
        }
        If ProcessExist('HideALLIP.exe')
            ProcessClose('HideALLIP.exe')
        ; Clear registery
        Loop Parse, "HKCU|HKLM", '|' {
            hk := A_LoopField
            Loop Parse, "Software\HideAllIP|Software\Wow6432Node\HideAllIP", '|' {
                Loop Reg, hk "\" A_LoopField {
                    RegDeleteKey(A_LoopRegkey)
                }
            }
        }
        haiapp.compatibilityClear(, haiPath)

        Run(haiPath)
        If !WinWait('ahk_class THintTimeForm ahk_exe HideALLIP.exe', , 20) {
            MsgBoxEx("Activation attempt failed!`nThe Hint Time Form wasn't found.", 'Hide All IP Trial Reset', , 0x30)
            Return
        }
        ProcessClose('HideALLIP.exe')

        haiapp.compatibilitySet(, haiPath, setting)

        Run(haiPath)
        If !WinWait('ahk_class THintTimeForm ahk_exe HideALLIP.exe', , 20) {
            MsgBoxEx("Activation attempt failed!`nThe Hint Time Form wasn't found.", 'Hide All IP Trial Reset', , 0x30)
            Return
        }

        ProcessClose('HideALLIP.exe')

        haiapp.compatibilityClear(, haiPath)

        Run(haiPath)

        if A_Index = 1 && "Yes" != MsgBoxEx('Still not working?, give this another try?', 'Hide All IP Trial Reset', 0x4, 0x20).result {
            Break
        }
    }
}