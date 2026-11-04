; Inno Setup script for Claude Switch Panel (per-user, no admin).
; Built by packaging/build.py --installer, which passes:
;   /DAppVersion=  /DSourceDir=  /DOutputDir=  /DOutputName=

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{85A69A40-BFA1-4636-BE05-AC9AFD1472A7}
AppName=Claude Switch Panel
AppVersion={#AppVersion}
AppPublisher=xutianhao6
AppPublisherURL=https://github.com/xutianhao6/claude-switch-panel
AppSupportURL=https://github.com/xutianhao6/claude-switch-panel/issues
DefaultDirName={localappdata}\Programs\claude-switch-panel
DefaultGroupName=Claude Switch Panel
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename={#OutputName}
SetupIconFile={#SourcePath}\..\icon.ico
UninstallDisplayIcon={app}\claude-switch-panel.exe
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
WizardStyle=modern
CloseApplications=yes
ChangesEnvironment=yes

[Languages]
; ChineseSimplified.isl ships with newer Inno Setup releases only.
#if FileExists(AddBackslash(CompilerPath) + "Languages\ChineseSimplified.isl")
Name: "chs"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
#endif
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "addtopath"; Description: "将 cswap 命令加入 PATH（可在终端中使用命令行）"; GroupDescription: "命令行:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Claude Switch Panel"; Filename: "{app}\claude-switch-panel.exe"
Name: "{autodesktop}\Claude Switch Panel"; Filename: "{app}\claude-switch-panel.exe"; Tasks: desktopicon

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Tasks: addtopath; Check: NeedsAddPath(ExpandConstant('{app}'))

[Run]
Filename: "{app}\claude-switch-panel.exe"; Description: "{cm:LaunchProgram,Claude Switch Panel}"; Flags: nowait postinstall skipifsilent

[Code]
function NeedsAddPath(Dir: string): Boolean;
var
  Paths: string;
begin
  if not RegQueryStringValue(HKCU, 'Environment', 'Path', Paths) then
  begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Uppercase(Dir) + ';', ';' + Uppercase(Paths) + ';') = 0;
end;

procedure RemovePath(Dir: string);
var
  Paths: string;
  P: Integer;
begin
  if not RegQueryStringValue(HKCU, 'Environment', 'Path', Paths) then
    exit;
  P := Pos(';' + Uppercase(Dir) + ';', ';' + Uppercase(Paths) + ';');
  if P = 0 then
    exit;
  { P is 1-based in the ';'-wrapped string, i.e. the index of the separator before Dir. }
  if P = 1 then
    Delete(Paths, 1, Length(Dir) + 1)
  else
    Delete(Paths, P - 1, Length(Dir) + 1);
  RegWriteExpandStringValue(HKCU, 'Environment', 'Path', Paths);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
    RemovePath(ExpandConstant('{app}'));
end;
