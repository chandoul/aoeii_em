esc:: ExitApp()
#Include CNG.ahk
Class Base {
    name => 'Age of Empires II Easy Manager'
    namespace => 'aoe_em'
    ahknamespace => 'aoeii_em.ahk'
    description => (
        'An AutoHotkey application holds several useful tools that helps with the game'
    )
    version => '4.0'
    author => 'Smile'
    license => 'MIT'
    workDirectory => this.workDir()
    configuration => this.workDirectory '\configuration.ini'
    tools => Map(
        '00_game', Map(
            'title', 'My Game',
            'file', this.workDirectory '\tools\game\game.ahk',
            'workdir', this.workDirectory '\tools\game',
            'pid', 0
        ),
        '01_version', Map(
            'title', 'Versions',
            'file', this.workDirectory '\tools\version\version.ahk',
            'workdir', this.workDirectory '\tools\version',
            'pid', 0
        ),
        '02_fix', Map(
            'title', 'Patchs and Fixs',
            'file', this.workDirectory '\tools\fix\fix.ahk',
            'workdir', this.workDirectory '\tools\fix',
            'pid', 0
        ),
        '03_lng', Map(
            'title', 'Interface Language',
            'file', this.workDirectory '\tools\lng\language.ahk',
            'workdir', this.workDirectory '\tools\lng\',
            'pid', 0
        ),
        '04_vm', Map(
            'title', 'Visual Mods',
            'file', this.workDirectory '\tools\vm\visualmods.ahk',
            'workdir', this.workDirectory '\tools\vm\',
            'pid', 0
        ),
        '05_dm', Map(
            'title', 'Data Mods',
            'file', this.workDirectory '\tools\dm\datamods.ahk',
            'workdir', this.workDirectory '\tools\dm\',
            'pid', 0
        ),
        '06_rec', Map(
            'title', 'Recordings',
            'file', this.workDirectory '\tools\rec\recanalyst.ahk',
            'workdir', this.workDirectory '\tools\rec\',
            'pid', 0
        ),
        '07_ahk', Map(
            'title', 'AHK Hotkeys',
            'file', this.workDirectory '\tools\ahk\ahk.ahk',
            'workdir', this.workDirectory '\tools\ahk\',
            'pid', 0
        ),
    )
    ddrawLocation => this.workDirectory '\externals\cnc-ddraw.2'
    ddrawLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/externals/cnc-ddraw.2.7z'
    ddrawPackage => this.workDirectory '\externals\cnc-ddraw.2.7z'
    _7zrLink => 'https://www.7-zip.org/a/7zr.exe'
    _7zrCsle => this.workDirectory '\externals\7za.exe'
    _7zrVersion => '25.01'
    _7zrSHA256 => '27cbe3d5804ad09e90bbcaa916da0d5c3b0be9462d0e0fb6cb54be5ed9030875'
    gameLocation => this.readConfiguration('GameLocation')
    gameLocationHistory => this.readConfiguration('GameLocationHistory')
    gameRangerExecutable => A_AppData '\GameRanger\GameRanger\GameRanger.exe'
    gameRangerSetting => A_AppData '\GameRanger\GameRanger Prefs\Settings'
    gameRegLocation => 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Age of Empires II AIO'
    userRegLayer => "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    machineRegLayer => "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
    drsBuild => this.workDirectory '\externals\drsbuild.exe'
    mgxfix => this.workDirectory '\externals\mgxfix.exe'
    revealfix => this.workDirectory '\externals\revealfix.exe'
    lngLoader => this.workDirectory '\externals\language_x1_p1.dll'
    mmodsDLL => this.workDirectory '\externals\mmods'
    /**
     * Make sure the app base is correctly found
     */
    __Startup() {
        OnError(handleError)
        handleError(Thrown, Mode) {
            MsgBoxEx(
                'An error occured:`n`nMessage: ' Thrown.Message .
                '`n`nWhat: ' Thrown.What .
                '`n`nExtra: ' Thrown.Extra .
                '`n`nFile: ' Thrown.File .
                '`n`nLine: ' Thrown.Line .
                '`n`nStack: ' Thrown.Stack,
                'An error occured',
                0,
                0x10
            )
            ExitApp()
        }

        this.avoidVoobly()

        If !A_IsAdmin {
            MsgBoxEx('Script must be ran as an administrator!', this.name, , 0x30)
            ExitApp()
        }
        this._7zrGet()

        ;If this.HasMethod('ensurePackage') {
        ;this.ensurePackage()
        ;}

        SetRegView(A_Is64bitOS ? 64 : 32)
    }
    /**
     * Gets the default app working directory
     * @returns {string} 
     */
    workDir() {
        WorkDir := A_ScriptDir
        Loop 2
            SplitPath(WorkDir, , &WorkDir)
        Until FileExist(WorkDir '\workDirectory')
        Return FileExist(WorkDir '\workDirectory') ? WorkDir : A_ScriptDir
    }

    /**
     * Download and save 7zr.exe standealone if it doesn't exist
     */
    _7zrGet() {
        _7zrExist := False
        If FileExist(this._7zrCsle) {
            _7zrExist := this._7zrSHA256 == this.hashFile('SHA256', this._7zrCsle)
        }
        If (!_7zrExist) {
            Download(this._7zrLink, this._7zrCsle)
        }
        _7zrExist := this._7zrSHA256 == this.hashFile('SHA256', this._7zrCsle)
        If (!_7zrExist) {
            MsgboxEx(
                'Unable to get the correct 7zr.exe (x86) : 7-Zip console executable v' this._7zrVersion ' from "https://www.7-zip.org/download.html"`nTo fix this, download it manually and place it, into the "externals\" directory.'
                , '7-Zip console executable'
                , , 0x30
            )
            ExitApp()
        }
    }

    /**
     * Return the hashsum of a file
     * @param {string} Alg 
     * @param {string} file 
     * @returns {string} 
     */
    hashFile(Alg := 'MD5', file := '') {
        Return FileExist(file) ? Hash.File(Alg, file) : ''
    }

    /**
     * Avoid being banned at Voobly (Voobly bans AutoHotkey)
     */
    avoidVoobly() {
        If ProcessExist('voobly.exe')
            ExitApp()
        SetTimer(vooblyCheck, 1000)
        vooblyCheck() {
            If ProcessExist('voobly.exe')
                ExitApp()
        }
    }

    /**
     * Read user configuration
     * @param key 
     * @returns {string} 
     */
    readConfiguration(key) {
        Return IniRead(this.configuration, this.namespace, key, '')
    }

    /**
     * Write user configuration
     * @param key 
     * @param value 
     */
    writeConfiguration(key, value) {
        IniWrite(value, this.configuration, this.namespace, key)
    }

    /**
     * Check if there is internet connection
     * @returns {bool}
     */
    getConnectedState() {
        Return DllCall("Wininet.dll\InternetGetConnectedState", "Str", Flag := 0x40, "Int", 0)
    }

    /**
     * Download a file with some progress info
     * @param link 
     * @param file 
     * @param {number} fileSize 
     * @param {number} progressText 
     * @param {number} progressBar 
     */
    downloadPackage(link, file, fileSize := 0, progressText := 0, progressBar := 0, update := 0) {
        if !update && FileExist(file) {
            Return 1
        }

        If !this.getConnectedState() {
            MsgboxEx('Make sure you are connected to the internet!', "Can't download!", , 0x30).result
            Return
        }
        SplitPath(file, &OutFileName)
        SetTimer(fileWatch, 1000)
        Download(link, file)
        SetTimer(fileWatch, 0)
        If progressBar
            progressBar.value := 100
        If progressText
            progressText.Text := 'Download complete! "' OutFileName '" [ ' progressBar.value ' % ]...'
        fileWatch() {
            if FileExist(file) {
                currentSize := FileGetSize(file, 'M')
                If fileSize {
                    if !progressText.Visible {
                        progressText.Visible := 1
                        progressBar.Visible := 1
                    }
                    progress := Round(currentSize / fileSize * 100, 2)
                    if progressText {
                        progressText.Text := 'Downloading "' OutFileName '" [ ' progress ' % ]...'
                    }
                    if progressBar {
                        progressBar.Value := progress
                    }
                }
            }
        }
        Return 1
    }

    /**
     * Extract a 7zip package into a specified location
     * @param package
     * @param destination
     * @param {number} hide 
     * @param {number} progressText 
     * @param {string} overwrite 
     * @returns {number} 
     */
    extractPackage(package, destination, hide := 1, informMe := 1, overwrite := 'aoa') {
        Static infoGui := 0
        RC := 0
        If hide && informMe {
            If infoGui {
                infoGui.Destroy()
            }
            infoGui := GuiEx('-SysMenu', this.name)
            infoGui.initiate(0, , 0, 0)
            infoGui.addGif('xm+90', 'bored.gif')
            infoGui.AddText(
                'BackgroundTrans xm w400 Center cRed',
                'Please Wait...`nThe archive is being extracted!')
            infoGui.SetFont('s9')
            cap := infoGui.AddText(
                'BackgroundTrans xm w400 Center',
                '`nPackage: ' package .
                '`nDestination: ' destination
            )
            infoGui.OnEvent('Close', terminate)
            terminate(*) {
                If ProcessExist(PID) {
                    ProcessClose(PID)
                }
            }
            infoGui.showEx(, 1)
        }
        RC := RunWait('"' this._7zrCsle '" x "' package '" -o"' destination '" -' overwrite, , hide ? 'Hide' : '', &PID)
        If RC && 'Yes' = MsgBoxEx('An error occured while trying to extract the package`nError code: ' RC '`nDo you wish to exit now?', this.name, 0x4, 0x10).result {
            ExitApp()
        }
        infoGui.Hide()
        Return RC = 0
    }

    /**
     * Get a folder size in KB
     * @param location 
     * @returns {number} 
     */
    folderGetSize(location) {
        Size := 0
        Loop Files, location '\*.*', 'R' {
            Size += FileGetSize(A_LoopFileFullPath, 'K')
        }
        Return Size
    }

    /**
     * Verify is the game folder is correctly selected
     */
    isGameFolderSelected(wnd := 0) {
        If !Game().isValidGameDirectory(this.gameLocation) {
            If wnd {
                wnd.Opt('Disabled')
            }
            If 'Yes' = MsgBoxEx('Game is not yet located!, want to select now?', 'Game', 0x4, 0x40).result
                Run(this.tools['00_game']['file'])
            ExitApp()
        }
    }

    /**
     * Ensure the required package is correctly exist
     */
    ensureDDrawPackage() {
        If !FileExist(this.ddrawPackage) {
            this.downloadPackage(this.ddrawLink, this.ddrawPackage)
        }
        If !DirExist(this.ddrawLocation)
            this.extractPackage(this.ddrawPackage, this.ddrawLocation)
    }

    /**
     * Apply the direct draw configuration to the game
     */
    applyDDrawFix(
        locations := [
            this.gameLocation '\',
            this.gameLocation '\age2_x1\'
        ]
    ) {
        ;this.ensureDDrawPackage()
        For location in locations {
            If DirExist(location)
                DirCopy(this.ddrawLocation, location, 1)
            If FileExist(location '\wndmode.dll') {
                FileDelete(location '\wndmode.dll')
            }
            If FileExist(location '\windmode.dll') {
                FileDelete(location '\windmode.dll')
            }
        }
        this.compatibilityClear([this.userRegLayer, this.machineRegLayer], this.gameLocation '\empires2.exe')
        this.compatibilityClear([this.userRegLayer, this.machineRegLayer], this.gameLocation '\age2_x1\age2_x1.exe')
    }

    /**
     * Apply a userpatch patch fix (made by katsuie/rohan)
     * @param {array} locations 
     * @param {string} fix 
     * @returns {void} 
     */
    applyUserFix(
        fix := 'None',
        locations := [
            this.gameLocation '\'
        ]
    ) {
        If fix = 'None'
            Return
        For location in locations {
            If DirExist(location)
                DirCopy(fix, location, 1)
            If FileExist(location '\ddraw.dll') {
                FileDelete(location '\ddraw.dll')
            }
            If FileExist(location '\age2_x1\ddraw.dll') {
                FileDelete(location '\age2_x1\ddraw.dll')
            }
        }
        this.compatibilitySet([this.userRegLayer, this.machineRegLayer], this.gameLocation '\empires2.exe', 'RUNASADMIN WINXPSP3')
        this.compatibilitySet([this.userRegLayer, this.machineRegLayer], this.gameLocation '\age2_x1\age2_x1.exe', 'RUNASADMIN WINXPSP3')
    }

    /**
     * Enables a versions list
     * @param controls 
     */
    enableOptions(controls, enabled := 1) {
        For control in controls {
            control.Enabled := enabled
        }
    }

    /**
     * Clears out a compatibility to an executable
     * @param ValueName 
     */
    compatibilityClear(layers := [], valueName := '') {
        If !valueName {
            Return
        }
        For layer in layers {
            If RegRead(layer, valueName, '')
                RegDelete(layer, valueName)
        }
    }

    /**
     * Sets a compatibility to an executable
     * @param ValueName 
     * @param Value 
     */
    compatibilitySet(layers := [], valueName := '', value := '') {
        If !valueName {
            Return
        }
        For layer in layers {
            RegWrite(value, 'REG_SZ', layer, valueName)
        }
    }

    /**
     * Check if folder files exists in another folder
     * @param folder
     * @param anotherFolder 
     */
    folderMatch(folder, anotherFolder, ignoreFiles := Map()) {
        Loop Files, folder '\*.*', 'R' {
            If ignoreFiles.Has(A_LoopFileName)
                Continue
            PathFile := StrReplace(A_LoopFileFullPath, folder '\')
            If !FileExist(anotherFolder '\' PathFile) {
                Return 0
            }
            currentHash := this.hashFile(, A_LoopFileFullPath)
            foundHash := this.hashFile(, anotherFolder '\' PathFile)
            If (currentHash != foundHash) {
                Return 0
            }
        }
        Return 1
    }

    /**
     * Allow a single choice from group of checkboxs
     * @param {array} group 
     */
    groupCheckBoxs(group := []) {
        For cb in group {
            cb.group := group
        }
    }

    reloadApp() => Reload()

    appUpdateCheck() {

    }
}

#Include ImageButton.ahk
Class Button {
    workDirectory => Base().workDirectory
    default => [
        [this.workDirectory '\assets\000_50212.bmp', , 0xFFFFFF]
    ]
    checkedDisabled => [
        [this.workDirectory '\assets\000_50212.bmp', , 0xFFFFFF],
        [],
        [],
        [this.workDirectory '\assets\000_50212_check.bmp', , 0xFFFFFF]
    ]
}

#Include Gdip.ahk
#Include ScrollBars.ahk
#Include ImagePut.ahk

Class GuiEx extends Gui {
    workDirectory => Base().workDirectory
    backImage => this.workDirectory '\assets\000_50127.bmp'
    transColor => 0xFFFFFE
    checkedImage => this.workDirectory '\assets\cb\checked.png'
    uncheckedImage => this.workDirectory '\assets\cb\unchecked.png'
    click => this.workDirectory '\assets\wav\50300.wav'
    initiate(qA := 1, Scrollable := 0, footer := 1, header := 0) {
        this.BackColor := 0xFFFFFF
        If qA
            this.OnEvent('Close', (*) => ExitApp())
        this.MarginX := this.MarginY := 20
        this.SetFont('s10 Bold', 'Segoe UI')
        this.backGroundImage := this.AddPicture('xm-' this.MarginX ' ym-' this.MarginY)
        If Scrollable {
            this.scrollableGui()
        }
        If header {
            this.addButtonEx('xm w80', 'Reload', , appReload)
            this.MarginX := 5
            this.addButtonEx('xp+85 yp', 'Exit', , appQuit)
            this.MarginX := 20
        }
        this.footer := footer
        appReload(Ctrl, Info) => Reload()
        appQuit(Ctrl, Info) => ExitApp()
        ;OnMessage(0x200, OnMouseMove)

        OnMouseMove(wParam, lParam, msg, hwnd) {
            MouseGetPos(&x, &y, , &control)
            Static px := 0, py := 0,
                WM_SETCURSOR := 0x20,
                IDC_HAND := 32649,
                lastControl := '',
                hCursor := DllCall("LoadCursor", "Ptr", 0, "Int", IDC_HAND, "Ptr")
            If (control = lastControl) {
                DllCall("SetCursor", "Ptr", hCursor)
                Return
            }
            If x = px && y = py
                Return
            px := x
            py := y
            If InStr(control, 'Button') {
                DllCall("SetCursor", "Ptr", hCursor)
                lastControl := control
            }
        }
    }
    scrollableGui() {
        vmGuiSB := ScrollBar(this, 200, 400)
        HotIfWinActive("ahk_id " this.Hwnd)
        Hotkey("WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+WheelUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+WheelDown", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("Up", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("Down", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+Up", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+Down", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 1 : 0, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+PgUp", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("+PgDn", (*) => vmGuiSB.ScrollMsg((InStr(A_thisHotkey, "Down") || InStr(A_thisHotkey, "Dn")) ? 3 : 2, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("Home", (*) => vmGuiSB.ScrollMsg(6, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        Hotkey("End", (*) => vmGuiSB.ScrollMsg(7, 0, GetKeyState("Shift") ? 0x114 : 0x115, this.Hwnd))
        HotIfWinActive
    }
    showEx(options := '', backImage := 0) {
        If This.footer
            This.addAOEFooter()
        this.Show(options)

        ; Handling the background image (repeat x, y)
        If backImage {
            this.GetPos(&X, &Y, &bWidth, &bHeight)
            For Control in this {
                Control.GetPos(&X, &Y, &Width, &Height)
                Width += X
                Height += Y
                If Width > bWidth {
                    bWidth := Width
                }
                If Height > bHeight {
                    bHeight := Height
                }
            }

            this.backGroundImage.Move(0, 0, bWidth, bHeight)
            this.backGroundImage.Redraw()

            fBitmap := Gdip_CreateBitmapFromFile(this.backImage)
            Gdip_GetDimensions(fBitmap, &iWidth, &iHeight)

            bBitmap := Gdip_CreateBitmap(bWidth, bHeight)
            G := Gdip_GraphicsFromImage(bBitmap)

            vDrawTimes := bHeight > iHeight ? (bHeight // iHeight) + 1 : 1
            hDrawTimes := bWidth > iWidth ? (bWidth // iWidth) + 1 : 1

            Loop vDrawTimes {
                y := (A_Index - 1) * iHeight
                Loop hDrawTimes {
                    x := (A_Index - 1) * iWidth
                    Gdip_DrawImage(G, fBitmap, x, y, iWidth, iHeight)
                }
            }

            hBitmap := Gdip_CreateHBITMAPFromBitmap(bBitmap)
            this.backGroundImage.Value := 'HBITMAP:* ' hBitmap

            Gdip_DeleteGraphics(G)
            Gdip_DisposeImage(bBitmap)

            If This.footer {
                This.GetPos(, , &W, &H)
                This.split.Move(, , W - 60)
                This.ft.Move(, , W - 188)
            }
        }
    }
    addButtonEx(options := '', text := '', theme := Button().default, clickCallBack := 0) {
        b := this.AddButton(options, text)
        CreateImageButton(
            b,
            0,
            theme*
        )
        b.DefineProp('TextEx', { Set: textEx })
        textEx(b, value, text := '', theme := Button().default) {
            b.text := value
            update(b, theme)
        }

        b.DefineProp('update', { Call: update })
        update(b, theme := Button().default) {
            CreateImageButton(
                b,
                0,
                theme*
            )
            b.Redraw()
        }

        b.OnEvent('Click', (*) => SoundPlay(this.click))

        If clickCallBack {
            b.OnEvent('Click', clickCallBack)
        }

        Return b
    }
    addCheckBoxEx(options := '', text := '', clickCallBack := 0, defaultValue := 1) {
        T := this.AddText(options ' BackgroundTrans c4C4C4C', text)
        T.OnEvent('Click', toggleValue)
        T.GetPos(&X, &Y, &Width, &Height)

        StrReplace(text, '`n', , , &Count)
        nHeight := Height / (Count + 1)

        T.Move(X + nHeight + 5, Y, Width, Height)
        T.cbValue := 0

        P := this.AddPicture('BackgroundTrans x' X ' y' Y ' h' nHeight ' w' nHeight, this.uncheckedImage)
        P.cbValue := T.cbValue

        P.OnEvent('Click', toggleValue)
        toggleValue(*) {
            T.cbValue := !T.cbValue
            If T.cbValue {
                T.cbValue := defaultValue
                linkedCheck()
            }
            P.cbValue := T.cbValue
            If T.cbValue {
                T.Opt('cBlack')
                P.Value := this.checkedImage
            } Else {
                P.Value := this.uncheckedImage
                T.Opt('c4C4C4C')
            }
            T.Redraw()
        }

        If clickCallBack {
            T.OnEvent('Click', clickCallBack)
            P.OnEvent('Click', clickCallBack)
        }

        T.DefineProp('Checked', { Get: getValue, Set: setValue })
        P.DefineProp('Checked', { Get: getValue, Set: setValue })

        getValue(ctrl) {
            Return T.cbValue
        }
        setValue(ctrl, value) {
            T.cbValue := value ? 1 : 0
            If T.cbValue {
                T.cbValue := defaultValue
                linkedCheck()
            }
            P.cbValue := T.cbValue
            If T.cbValue {
                T.Opt('cBlack')
                P.Value := this.checkedImage
            } Else {
                P.Value := this.uncheckedImage
                T.Opt('c4C4C4C')
            }
            T.Redraw()
            If clickCallBack {
                clickCallBack.Call(T, '')
            }
        }

        linkedCheck() {
            If T.HasProp('group') {
                For cb in T.group {
                    If cb != T
                        cb.Checked := 0
                }
            }
        }
        this.AddText('x' X ' y' Y + Height - this.MarginY ' w1 h1 BackgroundTrans')
        Return T
    }

    addPictureEx(options := '', filename := 'blankmod.png', clickcallback := 0) {
        If !FileExist(filename) {
            filename := this.workDirectory '\assets\' filename
        }
        If !FileExist(filename) {
            filename := ''
        }
        P := this.AddPicture(options ' BackgroundTrans', filename)
        if clickcallback {
            P.OnEvent('click', clickcallback)
        }

        P.DefineProp('ValueEx', { Set: ValueEx })
        ValueEx(ctrl, value) {
            If !FileExist(value) {
                value := this.workDirectory '\assets\' value
            }
            If !FileExist(value) {
                value := ''
            }
            ctrl.Value := value
        }
        Return P
    }

    addGif(options := '', gif := '') {
        If !FileExist(gif) {
            gif := this.workDirectory '\assets\' gif
        }
        pic := this.addPictureEx(options, gif)
        gif := ImageShow(gif, , [0, 0], 0x40000000 | 0x10000000 | 0x8000000, , pic.Hwnd)
        Return pic
    }

    /**
     * Add a footer that displays some (important) info
     */
    addAOEFooter() {
        this.SetFont('s10')
        This.split := this.addText('xm w420 0x10')
        this.MarginY := 0
        this.addPictureEx('xm', 'aok_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\empires2.exe') ? Run(gameLocation '\empires2.exe', gameLocation) : '')
        this.addPictureEx('yp', 'aoc_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\age2_x1\age2_x1.exe') ? Run(gameLocation '\age2_x1\age2_x1.exe', gameLocation) : '')
        this.addPictureEx('yp', 'fe_c.png').OnEvent('Click', (*) => FileExist(gameLocation '\age2_x1\age2_x2.exe') ? Run(gameLocation '\age2_x1\age2_x2.exe', gameLocation) : '')
        gameLocation := Base().gameLocation
        If Game().isValidGameDirectory(gameLocation)
            This.ft := this.AddEdit('BackgroundBlack yp+10 x+20 cWhite w280 -E0x200 h20 Center ReadOnly', Base().gameLocation)
        Else This.ft := this.AddEdit('Backgroundff0000 yp+10 x+20 cWhite w280 -E0x200 h20 Center ReadOnly', Base().gameLocation)
        this.MarginY := 20
    }
}

Class MsgBoxEx {
    workDirectory => Base().workDirectory

    errorIcon => this.workDirectory '\assets\error.png'
    errorSound => this.workDirectory '\assets\mp3\error.mp3'

    questionIcon => this.workDirectory '\assets\question.png'
    questionSound => this.workDirectory '\assets\mp3\question.mp3'

    exclamationIcon => this.workDirectory '\assets\exclamation.png'
    exclamationSound => this.workDirectory '\assets\mp3\exclamation.mp3'

    infoIcon => this.workDirectory '\assets\info.png'
    infoSound => this.workDirectory '\assets\mp3\info.mp3'

    btnWidth => 100
    /**
     * App specific message box theme
     * @param Text 
     * @param Title 
     * @param {number} Function 
     * @param {number} Icon 
     * @param {number} TimeOut 
     */
    __New(Text := '', Title := A_ScriptName, Function := 0, Icon := 0, TimeOut := 0, minWidth := 400) {

        this.msgGui := GuiEx(, Title)
        this.msgGui.initiate(0, , 0)
        this.msgGui.AddText('x0 y0 h1 BackgroundTrans w' minWidth)
        this.hIcon := 0

        Switch Icon {
            Case 16:
                this.hIcon := this.msgGui.AddPicture('xm w48 h48 BackgroundTrans', this.errorIcon)
                SoundPlay(this.errorSound)
            Case 32:
                this.hIcon := this.msgGui.AddPicture('xm w48 h48 BackgroundTrans', this.questionIcon)
                SoundPlay(this.questionSound)
            Case 48:
                this.hIcon := this.msgGui.AddPicture('xm w48 h48 BackgroundTrans', this.exclamationIcon)
                SoundPlay(this.exclamationSound)
            Case 64:
                this.hIcon := this.msgGui.AddPicture('xm w48 h48 BackgroundTrans', this.infoIcon)
                SoundPlay(this.infoSound)
        }
        ;msgbox Text
        If Text = '' {
            Switch Function {
                Default: Text := 'Press OK to continue'
                Case 2: Text := 'Press Abort to stop'
                Case 3, 4: Text := 'Press Yes to agree'
                Case 5, 6: Text := 'Press Cancel to stop'
            }
        }

        this.hText := this.msgGui.AddEdit('xm Center ReadOnly BackgroundE1B15A -E0x200 -VScroll Border', '`n' Text '`n`n')

        Switch Function {
            Case 0:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'OK', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 1:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'OK', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Cancel', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 2:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'Abort', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Retry', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Ignore', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 3:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'Yes', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'No', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Cancel', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 4:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'Yes', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'No', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 5:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'Retry', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Cancel', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
            Case 6:
                this.msgGui.addButtonEx('xm w' this.btnWidth, 'Cancel', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Try Again', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Continue', , takeAction)
                this.msgGui.addButtonEx('yp w' this.btnWidth, 'Copy Message', , takeAction).Focus()
        }

        this.msgGui.showEx(, 1)
        centerControls()
        this.result := ''

        If TimeOut {
            this.hText.Value := '`n' text '`nQuitting in ' (TimeOut) ' second' ((TimeOut > 1) ? 's' : '')
            SetTimer(countdown, 1000)
            countdown() {
                this.hText.Value := '`n' text '`nQuitting in ' (--TimeOut) ' second' ((TimeOut > 1) ? 's' : '')
            }
            WinWaitClose(this.msgGui, , TimeOut)
        } Else WinWaitClose(this.msgGui)

        SetTimer(countdown, 0)
        If this.msgGui
            this.msgGui.Destroy()

        /**
         * Take action according to the result
         * @param Ctrl 
         * @param Info 
         * @returns {void} 
         */
        takeAction(Ctrl, Info) {
            this.result := Ctrl.Text
            If this.result = 'Copy Message' {
                A_Clipboard := this.hText.Value
                Return
            }
            SetTimer(countdown, 0)
            If this.msgGui
                this.msgGui.Destroy()
        }

        centerControls() {
            this.msgGui.GetClientPos(&X, &Y, &Width, &Height)
            If this.hIcon {
                this.hIcon.GetPos(&cX, &cY, &cWidth, &cHeight)
                this.hIcon.Move((Width - cWidth) // 2)
            }
            this.hText.GetPos(&cX, &cY, &cWidth, &cHeight)
            cWidth := cWidth > minWidth ? cWidth : minWidth
            this.hText.Move((Width - cWidth) // 2, , cWidth)

            buttons := []
            For Obj in this.msgGui {
                If !InStr(Type(Obj), 'Gui.Button')
                    Continue
                buttons.Push(Obj)
            }
            X := buttons.Length * this.btnWidth + (buttons.Length - 1) * this.msgGui.MarginX
            X := (Width - X) // 2
            For btn in buttons {
                btn.Move(X + (A_Index - 1) * (this.msgGui.MarginX + this.btnWidth))
                btn.Redraw()
            }
        }
    }
}

Class Game extends Base {
    name => 'My Game'
    gamePackage => this.workDirectory '\tools\Game\Age of Empires II.7z'
    addShortcuts => this.readConfiguration('AddShortcuts')
    /**
     * Check if a location is really an aoe ii game
     * @param Location 
     * @returns {string} 
     */
    isValidGameDirectory(Location) {
        Return (
            FileExist(Location '\empires2.exe') &&
            FileExist(Location '\language.dll') &&
            FileExist(Location '\Data\interfac.drs') &&
            FileExist(Location '\Data\graphics.drs') &&
            FileExist(Location '\Data\terrain.drs')
        )
    }
}

#Include LockCheck.ahk
Class Version extends Base {
    name => 'Game Versions'
    requiredVersion => Map(
        "aokCombine", Map(
            "2.0b", [
                "2.0a"
            ]
        ),
        "aocCombine", Map(
            "1.0e", [
                "1.0c"
            ],
            "1.1", [
                "1.0c"
            ],
            "1.5", [
                "1.0c"
            ],
            "1.6", [
                "1.0c",
                "1.5"
            ]
        )
    )
    versionLocation => this.workDirectory '\tools\Version'
    versionTool => this.versionLocation '\version.ahk'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/Version/Version.7z'
    packageName => 'Version.7z'
    packageLocation => this.workDirectory '\tools\Version'
    packagePath => this.packageLocation '\' this.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(this.packagePath) {
            this.downloadPackage(this.packageLink, this.packagePath)
            this.extractPackage(this.packagePath, this.packageLocation)
        }
        ;this.extractPackage(this.packagePath, this.packageLocation, 0, , 'aos')
    }

    /**
     * Check there is a commandline call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            For H in options.versionList['aok'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)

                }
            }
            For H in options.versionList['aoc'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)
                }
            }
            For H in options.versionList['fe'] {
                If H.Text = A_Args[1] {
                    options.callback.Call(H, '')
                    MsgBoxEx(H.Text ' version is applied successfully!', 'Version', , 0x40, 2)
                }
            }
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()
    }

    getGameVersions() {
        versions := Map(
            'aok', '',
            'aoc', '',
            'fe', ''
        )
        lookFor := 'interfac.drs'

        If FileExist(this.gameLocation '\empires2.exe') {
            empires2 := FileOpen(this.gameLocation '\empires2.exe', 'r')

            ; 2.0
            If this.readString(empires2, 2479120, 12) = lookFor {
                versions['aok'] := '2.0'
            }

            ; 2.0a
            If this.readString(empires2, 2475120, 12) = lookFor {
                versions['aok'] := '2.0a'
            }

            ; 2.0b
            If versions['aok'] = '2.0a'
                && FileExist(this.gameLocation '\on.ini')
                && FileRead(this.gameLocation '\on.ini') = 'on' {
                    versions['aok'] := '2.0b'
            }
            empires2.Close()
        }

        If FileExist(this.gameLocation '\age2_x1\age2_x1.exe') {
            age2_x1 := FileOpen(this.gameLocation '\age2_x1\age2_x1.exe', 'r')

            ; 1.0
            If this.readString(age2_x1, 2604688, 12) = lookFor {
                versions['aoc'] := '1.0'
            }

            ; 1.0c
            If this.readString(age2_x1, 2551448, 12) = lookFor {
                versions['aoc'] := '1.0c'
            }

            ; 1.0e
            If versions['aoc'] = '1.0c'
                && FileExist(this.gameLocation '\age2_x1\on.ini')
                && FileRead(this.gameLocation '\age2_x1\on.ini') = 'onon' {
                    versions['aoc'] := '1.0e'
            }

            ; 1.1
            If age2_x1.Length = 2969600 {
                versions['aoc'] := '1.1'
            }

            ; 1.5
            If age2_x1.Length = 3145728 {
                versions['aoc'] := '1.5'
            }
            age2_x1.Close()
        }

        If FileExist(this.gameLocation '\age2_x1\age2_x2.exe') {
            age2_x2 := FileOpen(this.gameLocation '\age2_x1\age2_x2.exe', 'r')
            age2_x2.Pos := 278
            ; 2.2
            If age2_x2.ReadChar() = 39 {
                versions['fe'] := '2.2'
            }
            age2_x2.Close()
        }
        Return versions
    }
    /**
     * Read string from buffer
     * @param {buffer} buff 
     * @param {number} pos
     * @param {number} len
     * @returns {string} 
     */
    readString(buff, pos := 0, len := 1) {
        str := ''
        buff.Pos := pos
        Loop len {
            Try str .= Chr(buff.ReadChar())
        }

        Return str
    }

    availableVersions() {
        aver := Map(
            'aok', [],
            'aoc', [],
            'fe', []
        )
        Loop Files, this.versionLocation '\aok\*', 'D' {
            aver['aok'].Push(A_LoopFileName)
        }
        Loop Files, this.versionLocation '\aoc\*', 'D' {
            aver['aoc'].Push(A_LoopFileName)
        }
        Loop Files, this.versionLocation '\fe\*', 'D' {
            aver['fe'].Push(A_LoopFileName)
        }
        Return aver
    }
}

Class FixPatch extends Base {
    name => 'Game Patchs/Fixs'
    fixLocation => this.workDirectory '\tools\fix'
    fixTool => this.fixLocation '\fix.ahk'
    fixs => this.getFixs()
    fixRegKey => 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Microsoft Games\Age of Empires'
    fixRegName => 'Aoe2Patch'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/fix/Fix.7z'
    packageLocation => this.workDirectory '\tools\fix'
    packageName => 'Fix.7z'
    packagePath => this.packageLocation '\' this.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(this.packagePath) {
            this.downloadPackage(this.packageLink, this.packagePath)
            this.extractPackage(this.packagePath, this.packageLocation)
        }
        ;this.extractPackage(this.packagePath, this.fixLocation, 1, , 'aos')
    }

    /**
     * Return a list of the available fixs
     * @returns {array} 
     */
    getFixs() {
        F := ['None']
        Loop Files, this.fixLocation '\*', 'D' {
            F.Push(A_LoopFileName)
        }
        Return F
    }

    fixExist(name) {
        Return DirExist(this.fixLocation '\' name)
    }

    /**
     * Check if it a command line call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            If options.callback.Call(A_Args[1], '')
                MsgBoxEx(A_Args[1] ' fix is applied successfully!', options.wnd.Title, , 0x40, 2)
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()
    }
}

Class VisualMod extends Base {
    name => 'Visual Mods'
    drsMap => Map(
        "gra", "graphics.drs",
        "int", "interfac.drs",
        "ter", "terrain.drs"
    )
    vmLocation => this.workDirectory '\tools\vm\VisualMods'
    packageLocation => this.workDirectory '\tools\vm'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/vm/VisualMods.7z'
    packageName => 'VisualMods.7z'
    packagePath => this.packageLocation '\' this.packageName

    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(this.packagePath) {
            this.downloadPackage(this.packageLink, this.packagePath)
        }
        If !DirExist(this.vmLocation)
            this.extractPackage(this.packagePath, this.packageLocation)
    }
}

Class DataMod extends Base {
    name => 'Data Mods'
    dmLocation => this.workDirectory '\tools\dm'
    packageLocation => this.workDirectory '\tools\dm'
    dmPackages => Map(
        'The Conquerors Updated', Map(
            'type', 'xml',
            'gameName', 'The Conquerors Updated',
            'gameLinker', 'age2_x1_up',
            'packageName', 'DEBalance-6.1.2.7z',
            'packagePath', this.packageLocation '\DEBalance-6.1.2.7z',
            'packageVersion', '6.1.2',
            'packageSizeMB', '81',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/DEBalance-6.1.2.7z',
            'description', "by _everaoc_`n'The Conquerors Updated' mod with shared allies' line of sight.",
            'thumbnail', this.workDirectory '\assets\DE Balance.png'
        ),
        'WololoKingdoms', Map(
            'type', 'xml',
            'gameName', 'WololoKingdoms',
            'gameLinker', 'age2_x1_wk',
            'packageName', 'WololoKingdoms-5.8.1.7z',
            'packagePath', this.packageLocation '\WololoKingdoms-5.8.1.7z',
            'packageVersion', '5.8.1',
            'packageSizeMB', '225',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/WololoKingdoms-5.8.1.7z',
            'description', "by Tails8521, Jineapple, TriRem, TWest\nPlay the HD Expansions on Voobly.",
            'thumbnail', this.workDirectory '\assets\WololoKingdoms.png'
        ),
        'Elemental TD', Map(
            'type', 'xml',
            'gameName', 'Elemental TD',
            'gameLinker', 'age2_x1_e_td',
            'packageName', 'ElementalTD-2.02.7z',
            'packagePath', this.packageLocation '\ElementalTD-2.02.7z',
            'packageVersion', '2.02',
            'packageSizeMB', '46',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/ElementalTD-2.02.7z',
            'description', "by BinaryPotka`nNew 2023 TD mod with Elemental Towers.",
            'thumbnail', this.workDirectory '\assets\Elemental TD.png'
        ),
        'Sheep vs Wolf 3', Map(
            'type', 'xml',
            'gameName', 'Sheep vs Wolf 3',
            'gameLinker', 'age2_x1_svw3',
            'packageName', 'SheepVSWolf-3.0.7.7z',
            'packagePath', this.packageLocation '\SheepVSWolf-3.0.7.7z',
            'packageVersion', '3.0.7',
            'packageSizeMB', '13.2',
            'packageLink', 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/dm/SheepVSWolf-3.0.7.7z',
            'description', "by Gallas`nSheep vs Wolf 3 is a random map based hunter / prey game with unique UP v1.5 RC mechanics. Hide in forest and build a fortress, or hunt for animals and search for Sheep as the Wolf!.",
            'thumbnail', this.workDirectory '\assets\svsw3mini.jpg'
        )
    )
}

Class Language extends Base {
    name => 'Game Interface Language'
    lngLocation => this.workDirectory '\tools\lng\Language'
    packageName => 'Language.7z'
    packagePath => this.packageLocation '\' this.packageName
    packageLocation => this.workDirectory '\tools\lng'
    packageLink => 'https://github.com/Chandoul/aoeii_em/raw/refs/heads/master/tools/lng/Language.7z'
    /**
     * Ensure the required package is correctly exist
     */
    ensurePackage() {
        If !FileExist(this.packagePath) {
            this.downloadPackage(this.packageLink, this.packagePath)
        }
        If !DirExist(this.lngLocation)
            this.extractPackage(this.packagePath, this.lngLocation)
    }

    /**
     * Check if it a command line call
     */
    isCommandLineCall(options) {
        If A_Args.Length {
            If options.callback.Call(A_Args[1], '')
                MsgBoxEx(A_Args[1] ' The language is applied successfully!', options.wnd.Title, , 0x40, 2)
            Quit()
        }
        /**
         * Exit the app from a commandline call
         * @returns {void} 
         */
        Quit() => ExitApp()
    }
}

Class AHK extends Base {
    name => 'Custom Shortcuts'
    ahkLocation => this.workDirectory '\tools\ahk'
    hotkeys => this.workDirectory '\tools\ahk\hotkeys.json'
}

Class Recanalyst extends Base {
    name => 'Age of Empires II: Record Analyzer'
    php => this.workDirectory '\tools\rec\php\php.exe'
    ra => this.workDirectory '\tools\rec\recanalyst'
    /**
     * Start the php server and return it PID
     * @returns {number} 
     */
    initiateServer(parent) {
        Run(Format('"{}" -S localhost:8000 -t "{}"', this.php, this.ra), , 'Hide', &phpPid)
        SplitPath(this.php, &phpexe)
        ProcessWait(phpexe)
        Run(Format('"{}\tools\rec\closephp.ahk" {} {}', this.workDirectory, ProcessExist(), phpPid))
    }
}