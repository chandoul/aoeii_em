#define APP_NAME "Age of Empires II Easy Manager"
#define APP_VERSION "4.0"
#define INSTALL_DIR "{commonpf}\Age of Empires II Easy Manager v2"
#define AHK "AutoHotkey"
#define AHK_FAILED "AutoHotkey is missing, it has to be installed first!."
#define SETUP_ICON "release\resources\aoeii_em-icon-2.png"
#define SHORTCUT_ICON "release\resources\aoeii_em-icon-2.ico"
#define SETUP_IMG "release\resources\aoeii_em-side.png"
#define SETUP_AHK "release\resources\AutoHotkey_2.0.19_setup.exe"
[Setup]
AppId=6C8A2B8E-EE1C-4FA8-8BB9-149BA20347BA
AppName={#APP_NAME}
AppVersion={#APP_VERSION}
AppVerName={#APP_NAME} v{#APP_VERSION}
DefaultDirName={#INSTALL_DIR}
WizardSmallImageFile={#SETUP_ICON}
DisableWelcomePage=no
WizardImageFile={#SETUP_IMG}
OutputDir=release
OutputBaseFilename=Age of Empires II Easy Manager Setup v{#APP_VERSION}
WindowVisible=yes
UninstallDisplayIcon={app}\resources\aoeii_em-icon-2.ico
[Files]
Source: {#SETUP_AHK}; DestDir: "{app}\resources"; Flags: ignoreversion dontcopy
Source: {#SHORTCUT_ICON}; DestDir: "{app}\resources"; Flags: ignoreversion
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs
Source: "externals\*"; DestDir: "{app}\externals"; Flags: ignoreversion recursesubdirs
Source: "libs\*"; DestDir: "{app}\libs"; Flags: ignoreversion recursesubdirs
// autohotkey
Source: "tools\ahk\ahk.ahk"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
Source: "tools\ahk\hotkeys.json"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
// data mods
Source: "tools\dm\datamods.ahk"; DestDir: "{app}\tools\dm"; Flags: ignoreversion
// Fixs
//Source: "tools\fix\*"; DestDir: "{app}\tools\fix"; Flags: ignoreversion recursesubdirs
// game
Source: "tools\game\game.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
Source: "tools\game\uninstallgame.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
// language
//Source: "tools\lng\*"; DestDir: "{app}\tools\lng"; Flags: ignoreversion recursesubdirs
// recording
//Source: "tools\rec\*"; DestDir: "{app}\tools\rec"; Flags: ignoreversion recursesubdirs
// version
//Source: "tools\version\*"; DestDir: "{app}\tools\version"; Flags: ignoreversion recursesubdirs
// visual mods
//Source: "tools\vm\*"; DestDir: "{app}\tools\vm"; Flags: ignoreversion recursesubdirs
// main
Source: "tools\aoeii_em.ahk"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "workDirectory"; DestDir: "{app}"; Flags: ignoreversion
// other files
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENSE"; DestDir: "{app}"; Flags: ignoreversion
[Icons]
Name: "{commondesktop}\Age of Empires II Easy Manager"; Filename: "{app}\tools\aoeii_em.ahk"; WorkingDir: "{app}\tools"; IconFilename: "{app}\resources\aoeii_em-icon-2.ico"
Name: "{group}\Age of Empires II Easy Manager"; Filename: "{app}\tools\aoeii_em.ahk"; WorkingDir: "{app}"
Name: "{group}\Uninstall Age of Empires II Easy Manager"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\tools\aoeii_em.ahk"; Description: "Run Age of Empires II Easy Manager v{#APP_VERSION}"; Flags: postinstall shellexec

[Languages]
Name: "Arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "French"; MessagesFile: "compiler:Languages\French.isl"
Name: "Turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[code]
// Registery view 32/64
function GetHKLM: Integer;
begin
  if IsWin64 then Result := HKLM64
  else Result := HKCU32;
end;
function GetHKCU: Integer;
begin
  if IsWin64 then Result := HKCU64
  else Result := HKCU32;
end;

// AHK registery key
function AHKInstalled: boolean;
begin
  Result := True;
  if not (RegKeyExists(GetHKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey') 
       or RegKeyExists(GetHKCU, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AutoHotkey')) then
    Result := False
end;

// Some color update
procedure InitializeWizard();
begin
  WizardForm.MainPanel.Color := $71A6CB;
  WizardForm.Color := $97DAF4;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var ErrorCode:Integer;
begin
  Result := '';
  if not AHKInstalled then
    begin
        ExtractTemporaryFile('AutoHotkey_2.0.19_setup.exe');
        if ShellExec('', ExpandConstant('{tmp}\AutoHotkey_2.0.19_setup.exe'), '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ErrorCode) then 
            if ErrorCode <> 0 then Result := '{#AHK_FAILED}'
        else Result := '{#AHK_FAILED}';
        if not AHKInstalled then Result := '{#AHK_FAILED}';
    end;
    if not AHKInstalled then Result := '{#AHK_FAILED}';
end;