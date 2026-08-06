program utorrentgui;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  Main, ConnForm,   AppVersion;

{$R lib\x86_64-win64\winver.o}

{$R win32manifest.res}

begin
  RequireDerivedFormResource := True;
  Application.Title := AppTitleWithVersion;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
