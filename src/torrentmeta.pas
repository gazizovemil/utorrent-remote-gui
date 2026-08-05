unit TorrentMeta;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function ExtractTorrentComment(const FileName: string): string;
function ExtractTorrentInfoHash(const FileName: string): string;
function FindTorrentFileByHash(const Dirs: array of string; const Hash: string;
  out FileName: string): Boolean;
function ReadCommentForHash(const Dirs: array of string; const Hash: string): string;

implementation

uses
  sha1, Logger;

type
  TByteArray = array of Byte;

function LoadFileBytes(const FileName: string; out Data: TByteArray): Boolean;
var
  FS: TFileStream;
begin
  Result := False;
  Data := nil;
  if not FileExists(FileName) then
    Exit;
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Data, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(Data[0], FS.Size);
    Result := True;
  finally
    FS.Free;
  end;
end;

function BytesToLatin1(const Data: TByteArray; StartIdx, Len: Integer): string;
var
  I: Integer;
begin
  SetLength(Result, Len);
  for I := 0 to Len - 1 do
    Result[I + 1] := Chr(Data[StartIdx + I]);
end;

function ParseInt(const Data: TByteArray; var Pos: Integer; out Value: Int64): Boolean;
var
  Sign: Int64;
  Digits: Integer;
begin
  Result := False;
  Value := 0;
  Sign := 1;
  Digits := 0;
  if (Pos < 0) or (Pos >= Length(Data)) then
    Exit;
  if Chr(Data[Pos]) = '-' then
  begin
    Sign := -1;
    Inc(Pos);
  end;
  while (Pos < Length(Data)) and (Chr(Data[Pos]) in ['0'..'9']) do
  begin
    Value := Value * 10 + (Data[Pos] - Ord('0'));
    Inc(Pos);
    Inc(Digits);
  end;
  Value := Value * Sign;
  Result := Digits > 0;
end;

function SkipValue(const Data: TByteArray; var Pos: Integer): Boolean; forward;

function SkipString(const Data: TByteArray; var Pos: Integer): Boolean;
var
  Len: Int64;
begin
  Result := False;
  if not ParseInt(Data, Pos, Len) then
    Exit;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> ':') then
    Exit;
  Inc(Pos); // skip ':'
  if (Len < 0) or (Pos + Len > Length(Data)) then
    Exit;
  Inc(Pos, Len);
  Result := True;
end;

function SkipList(const Data: TByteArray; var Pos: Integer): Boolean;
begin
  Result := False;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'l') then
    Exit;
  Inc(Pos);
  while (Pos < Length(Data)) and (Chr(Data[Pos]) <> 'e') do
    if not SkipValue(Data, Pos) then
      Exit;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'e') then
    Exit;
  Inc(Pos);
  Result := True;
end;

function SkipDict(const Data: TByteArray; var Pos: Integer): Boolean;
begin
  Result := False;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'd') then
    Exit;
  Inc(Pos);
  while (Pos < Length(Data)) and (Chr(Data[Pos]) <> 'e') do
  begin
    if not SkipString(Data, Pos) then
      Exit;
    if not SkipValue(Data, Pos) then
      Exit;
  end;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'e') then
    Exit;
  Inc(Pos);
  Result := True;
end;

function SkipInt(const Data: TByteArray; var Pos: Integer): Boolean;
var
  Dummy: Int64;
begin
  Result := False;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'i') then
    Exit;
  Inc(Pos);
  if not ParseInt(Data, Pos, Dummy) then
    Exit;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> 'e') then
    Exit;
  Inc(Pos);
  Result := True;
end;

function SkipValue(const Data: TByteArray; var Pos: Integer): Boolean;
begin
  if Pos >= Length(Data) then
    Exit(False);
  case Chr(Data[Pos]) of
    'd': Result := SkipDict(Data, Pos);
    'l': Result := SkipList(Data, Pos);
    'i': Result := SkipInt(Data, Pos);
    '0'..'9': Result := SkipString(Data, Pos);
  else
    Result := False;
  end;
end;

function ReadStringValue(const Data: TByteArray; var Pos: Integer; out S: string): Boolean;
var
  Len: Int64;
  Start: Integer;
begin
  Result := False;
  S := '';
  Start := Pos;
  if not ParseInt(Data, Pos, Len) then
  begin
    Pos := Start;
    Exit;
  end;
  if (Pos >= Length(Data)) or (Chr(Data[Pos]) <> ':') then
  begin
    Pos := Start;
    Exit;
  end;
  Inc(Pos);
  if (Len < 0) or (Pos + Len > Length(Data)) then
  begin
    Pos := Start;
    Exit;
  end;
  S := BytesToLatin1(Data, Pos, Len);
  Inc(Pos, Len);
  Result := True;
end;

function ExtractCommentFromBytes(const Data: TByteArray): string;
var
  Pos: Integer;
  Key: string;
begin
  Result := '';
  if Length(Data) = 0 then
    Exit;
  Pos := 0;
  if Chr(Data[Pos]) <> 'd' then
    Exit;
  Inc(Pos);
  while (Pos < Length(Data)) and (Chr(Data[Pos]) <> 'e') do
  begin
    if not ReadStringValue(Data, Pos, Key) then
      Exit;
    if Key = 'comment' then
    begin
      if not ReadStringValue(Data, Pos, Result) then
        Result := '';
      Exit;
    end;
    if not SkipValue(Data, Pos) then
      Exit;
  end;
end;

function ExtractInfoHashFromBytes(const Data: TByteArray): string;
var
  Pos, InfoStart, InfoEnd: Integer;
  Key: string;
  Digest: TSHA1Digest;
  I: Integer;
begin
  Result := '';
  if Length(Data) = 0 then
    Exit;
  Pos := 0;
  if Chr(Data[Pos]) <> 'd' then
    Exit;
  Inc(Pos);
  while (Pos < Length(Data)) and (Chr(Data[Pos]) <> 'e') do
  begin
    if not ReadStringValue(Data, Pos, Key) then
      Exit;
    if Key = 'info' then
    begin
      InfoStart := Pos;
      if not SkipValue(Data, Pos) then
        Exit;
      InfoEnd := Pos;
      Digest := SHA1Buffer(Data[InfoStart], InfoEnd - InfoStart);
      Result := '';
      for I := 0 to 19 do
        Result := Result + LowerCase(IntToHex(Digest[I], 2));
      Exit;
    end;
    if not SkipValue(Data, Pos) then
      Exit;
  end;
end;

function ExtractTorrentComment(const FileName: string): string;
var
  Data: TByteArray;
begin
  Result := '';
  if not LoadFileBytes(FileName, Data) then
    Exit;
  Result := ExtractCommentFromBytes(Data);
end;

function ExtractTorrentInfoHash(const FileName: string): string;
var
  Data: TByteArray;
begin
  Result := '';
  if not LoadFileBytes(FileName, Data) then
    Exit;
  Result := UpperCase(ExtractInfoHashFromBytes(Data));
end;

function FindTorrentFileByHash(const Dirs: array of string; const Hash: string;
  out FileName: string): Boolean;
var
  D, H, Candidate, FoundHash: string;
  SR: TSearchRec;
begin
  Result := False;
  FileName := '';
  H := UpperCase(Hash);
  if H = '' then
    Exit;

  for D in Dirs do
  begin
    if (D = '') or not DirectoryExists(D) then
      Continue;

    Candidate := IncludeTrailingPathDelimiter(D) + H + '.torrent';
    if FileExists(Candidate) then
    begin
      FileName := Candidate;
      Exit(True);
    end;
    Candidate := IncludeTrailingPathDelimiter(D) + LowerCase(H) + '.torrent';
    if FileExists(Candidate) then
    begin
      FileName := Candidate;
      Exit(True);
    end;

    if FindFirst(IncludeTrailingPathDelimiter(D) + '*.torrent', faAnyFile, SR) = 0 then
    try
      repeat
        if (SR.Attr and faDirectory) <> 0 then
          Continue;
        Candidate := IncludeTrailingPathDelimiter(D) + SR.Name;
        FoundHash := ExtractTorrentInfoHash(Candidate);
        if FoundHash = H then
        begin
          FileName := Candidate;
          Exit(True);
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function ReadCommentForHash(const Dirs: array of string; const Hash: string): string;
var
  FN: string;
begin
  Result := '';
  if not FindTorrentFileByHash(Dirs, Hash, FN) then
  begin
    LogFmt('TorrentMeta: .torrent not found for hash %s', [Copy(Hash, 1, 8)]);
    Exit;
  end;
  LogFmt('TorrentMeta: reading comment from %s', [FN]);
  Result := ExtractTorrentComment(FN);
  if Result = '' then
    Log('TorrentMeta: comment empty in .torrent')
  else
    LogFmt('TorrentMeta: comment length=%d', [Length(Result)]);
end;

end.
