program apitest;

{$mode objfpc}{$H+}

uses
  SysUtils, Rpc, Models, Logger;

var
  R: TuTorrentRpc;
  L: TTorrentList;
begin
  LogInit(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'apitest.log');
  WriteLn('Log: ', LogFilePath);
  R := TuTorrentRpc.Create;
  try
    R.Configure('127.0.0.1', 8888, 'admin', 'Egzxrf11', False);
    if not R.Connect then
    begin
      WriteLn('CONNECT FAIL: ', R.LastError, ' status=', R.LastStatusCode);
      Halt(1);
    end;
    WriteLn('CONNECT OK build=', R.Build, ' guid_len=', Length(R.Guid));
    if not R.GetList(L) then
    begin
      WriteLn('LIST FAIL: ', R.LastError);
      Halt(2);
    end;
    try
      WriteLn('LIST OK count=', L.Count, ' torrentc=', L.CacheID);
    finally
      L.Free;
    end;
    WriteLn('OK');
  finally
    R.Free;
  end;
end.
