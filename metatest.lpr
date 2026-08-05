program metatest;

{$mode objfpc}{$H+}

uses
  SysUtils, Logger, TorrentMeta, Rpc, Models;

var
  R: TuTorrentRpc;
  L: TTorrentList;
  Dirs: array of string;
  Comment, Hash: string;
begin
  LogInit(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'metatest.log');
  R := TuTorrentRpc.Create;
  try
    R.Configure('127.0.0.1', 8888, 'admin', 'Egzxrf11', False);
    if not R.Connect then
    begin
      WriteLn('CONNECT FAIL ', R.LastError);
      Halt(1);
    end;
    WriteLn('dirs: [', R.TorrentFilesDir, '] [', R.CompletedTorrentsDir, ']');
    if not R.GetList(L) then
    begin
      WriteLn('LIST FAIL ', R.LastError);
      Halt(2);
    end;
    try
      if L.Count = 0 then
      begin
        WriteLn('No torrents in list');
        Halt(0);
      end;
      Hash := L[0].Hash;
      WriteLn('hash=', Hash);
      WriteLn('name=', L[0].Name);
      SetLength(Dirs, 2);
      Dirs[0] := R.TorrentFilesDir;
      Dirs[1] := R.CompletedTorrentsDir;
      Comment := ReadCommentForHash(Dirs, Hash);
      WriteLn('comment=[', Comment, ']');
      if Comment = '' then
        Halt(3);
      WriteLn('OK');
    finally
      L.Free;
    end;
  finally
    R.Free;
  end;
end.
