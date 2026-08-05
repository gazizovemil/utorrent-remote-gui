unit Logger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs;

procedure LogInit(const FileName: string = '');
procedure Log(const Msg: string);
procedure LogFmt(const Fmt: string; const Args: array of const);
function LogFilePath: string;

implementation

var
  GLock: TCriticalSection = nil;
  GFileName: string = '';
  GEnabled: Boolean = True;

function DefaultLogPath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'utorrentgui.log';
end;

function LogFilePath: string;
begin
  if GFileName = '' then
    Result := DefaultLogPath
  else
    Result := GFileName;
end;

procedure LogInit(const FileName: string);
begin
  if GLock = nil then
    GLock := TCriticalSection.Create;
  if FileName <> '' then
    GFileName := FileName
  else
    GFileName := DefaultLogPath;
  Log('---- log start ----');
end;

procedure Log(const Msg: string);
var
  Line: string;
  F: TextFile;
begin
  if not GEnabled then
    Exit;
  if GLock = nil then
    LogInit('');
  Line := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' + Msg;
  GLock.Enter;
  try
    AssignFile(F, LogFilePath);
    if FileExists(LogFilePath) then
      Append(F)
    else
      Rewrite(F);
    try
      WriteLn(F, Line);
    finally
      CloseFile(F);
    end;
  except
    // ignore logging failures
  end;
  GLock.Leave;
end;

procedure LogFmt(const Fmt: string; const Args: array of const);
begin
  Log(Format(Fmt, Args));
end;

finalization
  FreeAndNil(GLock);

end.
