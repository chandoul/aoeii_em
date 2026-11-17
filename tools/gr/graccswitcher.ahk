#Requires AutoHotkey v2
#SingleInstance Force

#Include ..\..\libs\Base.ahk

app := Base()

DirCreate(app.gameRangerAccounts)

fetchSetting(setting := app.gameRangerSetting) {
    static needle := { id: '53 65 73 73 55 49 44 5F', username: '53 65 73 73 4E 69 63 6B' }
    if !FileExist(setting)
        return

    obj := FileOpen(setting, 'r')
    pattern := ''

    result := { id: '', username: '' }

    while !obj.AtEOF {
        char := obj.ReadUChar()
        hex := Format('{:02X}', char)

        pattern .= (pattern != '' ? ' ' : '') hex

        if StrLen(pattern) < 23 {
            continue
        }

        if StrLen(pattern) > 23 {
            pattern := SubStr(pattern, 4)
        }

        if pattern = needle.id && !result.id {
            obj.pos += 7
            len := obj.ReadUChar()
            loop len {
                result.id .= Format('{:02X}', obj.ReadUChar())
            }
            result.id := Number('0x' result.id)
        }

        if pattern = needle.username && !result.username {
            obj.pos += 8
            len := obj.ReadUChar()
            loop len {
                result.username .= Chr(obj.ReadUChar())
            }
        }
    }
    return result
}

if !FileExist(app.gameRangerExecutable) {
    MsgBoxEx('You must install gameranger first!', 'Info', , 0x30)
    ExitApp()
}

accPath := []

grsGui := GuiEx(, app.name)
grsGui.initiate(, , 0)

loggedUser := grsGui.AddEdit('xm ym+30 ReadOnly w460 Background000000 cFFFFFF -E0x200 Center')

grsGui.AddText('BackgroundTrans', 'Accounts list:')
accList := grsGui.AddListView('w304 r10 y+5 -E0x200 -Multi Grid -Hdr', ['ID', 'USERNAME', 'LOGGED'])
accList.ModifyCol(1, 100)
accList.ModifyCol(2, 200)

grsGui.SetFont('s10')
grsGui.MarginY := 10
grsGui.addButtonEx('x+10 w150', '→ Log in', , login)
grsGui.addButtonEx('wp', '← Log out', , (*) => ProcessClose('GameRanger.exe'))
grsGui.addButtonEx('wp', 'Switch zone', , switchTZ)
grsGui.addButtonEx('wp', 'Switch account', , switchAcc)
grsGui.addButtonEx('wp', 'Delete account', , deleteAcc)

grsGui.MarginY := 20
grsGui.showEx(, 1)

loadSavedLogins()

loggingInfo()
SetTimer(loggingInfo, 1000)

loggingInfo() {
    static lastHash := 0
    hash := app.hashFile(, app.gameRangerSetting)
    if hash = lastHash
        return

    data := fetchSetting()

    if !data.username {
        loggedUser.Value := 'You must log in into your GameRanger account!'
    } else loggedUser.Value := 'Session name: ' data.username

    lastHash := hash
}

switchAcc(*) {
    ProcessClose('GameRanger.exe')
    if ProcessWaitClose('GameRanger.exe', 10) {
        MsgBoxEx('Unable to close GameRanger!', 'Info', , 0x30)
        return
    }
    FileMove(app.gameRangerSetting, app.gameRangerAccounts '\' A_Now '.gracc')
    Run(app.gameRangerExecutable)
    loadSavedLogins()
}

login(*) {
    if !selected := accList.GetNext() {
        Run(app.gameRangerExecutable)
        return
    }
    ProcessClose('GameRanger.exe')
    if ProcessWaitClose('GameRanger.exe', 10) {
        MsgBoxEx('Unable to close GameRanger!', 'Info', , 0x30)
        return
    }
    FileCopy(app.gameRangerAccounts '\' accPath[selected], app.gameRangerSetting, 1)
    Run(app.gameRangerExecutable)

    if WinWait('Friends ahk_exe GameRanger.exe',, 10) {
        FileCopy(app.gameRangerSetting, app.gameRangerAccounts '\' accPath[selected], 1)
        loadSavedLogins()
    }
}

loadSavedLogins(*) {
    accList.Delete()
    Loop Files, app.gameRangerAccounts '\*.gracc' {
        accPath.Push(A_LoopFileName)
        data := fetchSetting(A_LoopFileFullPath)
        accList.Add(, data.id ? data.id : 'N/A', data.username ? data.username : 'N/A')
    }
}

switchTZ(*) {
    static nameRef := '53 65 73 73 54 6D 5A 6E',
        remHex := 'FF FF FF FF 52 6D 76 64'
    ProcessClose('GameRanger.exe')
    if ProcessWaitClose('GameRanger.exe', 20) {
        MsgBoxEx('Unable to close GameRanger!', 'Info', , 0x30)
        return
    }
    obj := FileOpen(app.gameRangerSetting, 'rw')
    pattern := ''
    while !obj.AtEOF {
        char := obj.ReadUChar()
        hex := Format('{:02X}', char)

        pattern .= (pattern != '' ? ' ' : '') hex
        if StrLen(pattern) > 23 {
            pattern := SubStr(pattern, 4)
        }

        if pattern = nameRef {
            obj.pos -= 8
            for hex in StrSplit(remHex, ' ')
                obj.WriteUChar('0x' hex)
            break
        }
    }
    obj.Close()
    Run(app.gameRangerExecutable)
}

deleteAcc(*) {
    if !selected := accList.GetNext()
        return
    if 'Yes' != MsgBoxEx('Take action with precaution!`nYou sure want to delete "' accList.GetText(selected, 2) '" ?',
        'Info', 0x4, 0x30).result {
        return
    }
    if 'Yes' != MsgBoxEx('[ Double Check! ]`nTake action with precaution!`nYou sure want to delete "' accList.GetText(selected, 2) '" ?',
        'Info', 0x4, 0x30).result {
        return
    }
    try {
        FileDelete(app.gameRangerAccounts '\' accPath[selected])
        accPath.RemoveAt(selected)
    }
    loadSavedLogins()
}