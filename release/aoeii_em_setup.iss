#define APP_NAME "Age of Empires II Easy Manager"
#define APP_VERSION "4.0"
#define INSTALL_DIR "{commonpf}\Age of Empires II Easy Manager v2"
#define AHK "AutoHotkey"
#define AHK_FAILED "AutoHotkey is missing, it has to be installed first!."
#define SETUP_ICON "resources\aoeii_em-icon-2.png"
#define SHORTCUT_ICON "resources\aoeii_em-icon-2.ico"
#define SETUP_IMG "resources\aoeii_em-side.png"
#define SETUP_AHK "resources\AutoHotkey_2.0.19_setup.exe"
#define INTERPRETER_AHK "resources\AutoHotkey32_2.0.19.exe"
#define SETUP_NAME "aoeii_em"

[Setup]
AppId=6C8A2B8E-EE1C-4FA8-8BB9-149BA20347BA
AppName={#APP_NAME}
AppVersion={#APP_VERSION}
AppVerName={#APP_NAME} v{#APP_VERSION}
AppPublisher=Smile
AppPublisherURL=chandoul.github.io
AppSupportURL=chandoul.github.io
AppUpdatesURL=chandoul.github.io
VersionInfoVersion={#APP_VERSION}
AppCopyright=MIT License, 2025
DefaultDirName={#INSTALL_DIR}
WizardSmallImageFile={#SETUP_ICON}
DisableWelcomePage=no
OutputDir=..\release
WizardImageFile={#SETUP_IMG}
OutputBaseFilename={#SETUP_NAME}_setup_latest
UninstallDisplayIcon={app}\resources\aoeii_em-icon-2.ico

[Dirs]
Name: "{app}\packages"

[Files]
Source: {#INTERPRETER_AHK}; DestDir: "{app}\resources"; Flags: ignoreversion
Source: {#SHORTCUT_ICON}; DestDir: "{app}\resources"; Flags: ignoreversion
Source: "..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs
Source: "..\externals\*"; DestDir: "{app}\externals"; Flags: ignoreversion recursesubdirs
Source: "..\libs\*"; DestDir: "{app}\libs"; Flags: ignoreversion recursesubdirs
Source: "..\screenshots\*"; DestDir: "{app}\screenshots"; Flags: ignoreversion recursesubdirs
// autohotkey
Source: "..\tools\ahk\ahk.ahk"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
Source: "..\tools\ahk\default.json"; DestDir: "{app}\tools\ahk"; Flags: ignoreversion
// data mods
Source: "..\tools\dm\datamods.ahk"; DestDir: "{app}\tools\dm"; Flags: ignoreversion
// Fixs
Source: "..\tools\fix\fix.ahk"; DestDir: "{app}\tools\fix"; Flags: ignoreversion 
// game
Source: "..\tools\game\game.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
Source: "..\tools\game\uninstallgame.ahk"; DestDir: "{app}\tools\game"; Flags: ignoreversion
// language
Source: "..\tools\lng\language.ahk"; DestDir: "{app}\tools\lng"; Flags: ignoreversion 
// recording
Source: "..\tools\rec\closephp.ahk"; DestDir: "{app}\tools\rec"; Flags: ignoreversion 
Source: "..\tools\rec\recanalyst.ahk"; DestDir: "{app}\tools\rec"; Flags: ignoreversion 
// version
Source: "..\tools\version\version.ahk"; DestDir: "{app}\tools\version"; Flags: ignoreversion
// visual mods
Source: "..\tools\vm\visualmods.ahk"; DestDir: "{app}\tools\vm"; Flags: ignoreversion
// main
Source: "..\tools\aoeii_em.ahk"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "..\workDirectory"; DestDir: "{app}"; Flags: ignoreversion
// other files
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commondesktop}\Age of Empires II Easy Manager"; Filename: "{app}\{#INTERPRETER_AHK}"; \
Parameters: """{app}\tools\aoeii_em.ahk"""; \
WorkingDir: "{app}\tools"; \
IconFilename: "{app}\resources\aoeii_em-icon-2.ico";

Name: "{group}\Age of Empires II Easy Manager"; Filename: "{app}\tools\aoeii_em.ahk"; WorkingDir: "{app}"
Name: "{group}\Uninstall Age of Empires II Easy Manager"; Filename: "{uninstallexe}"

[Run]
Filename: "{commondesktop}\Age of Empires II Easy Manager"; \
Description: "Run Age of Empires II Easy Manager v{#APP_VERSION}"; \
Flags: postinstall shellexec

[Languages]
Name: "English"; MessagesFile: "compiler:Default.isl"
Name: "Arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "Armenian"; MessagesFile: "compiler:Languages\Armenian.isl"
Name: "French"; MessagesFile: "compiler:Languages\French.isl"
Name: "Turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "BrazilianPortuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "Bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "Catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "Corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "Czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "Danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "Dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "Finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "German"; MessagesFile: "compiler:Languages\German.isl"
Name: "Hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "Hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "Italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "Japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "Korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "Norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "Polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "Portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "Russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "Slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "Spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "Swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "Tamil"; MessagesFile: "compiler:Languages\Tamil.isl"
Name: "Ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[code]
// Some color update
procedure InitializeWizard();
begin
  WizardForm.MainPanel.Color := $71A6CB;
  WizardForm.Color := $97DAF4;
end;

[Registry]
Root: HKCU32; \
    Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#INTERPRETER_AHK}"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue; Check: not IsWin64
Root: HKLM32; \
    Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#INTERPRETER_AHK}"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue; Check: not IsWin64
Root: HKCU64; \
    Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#INTERPRETER_AHK}"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue; Check: IsWin64
Root: HKLM64; \
    Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#INTERPRETER_AHK}"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue; Check: IsWin64