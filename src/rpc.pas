unit Rpc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SyncObjs, fpjson, jsonparser, fphttpclient,
  Models;

type
  TuTorrentRpc = class
  private
    FLock: TCriticalSection;
    FHttp: TFPHTTPClient;
    FBaseURL: string;
    FUser: string;
    FPassword: string;
    FToken: string;
    FGuid: string;
    FConnected: Boolean;
    FLastError: string;
    FLastStatusCode: Integer;
    FBuild: Integer;
    FTorrentFilesDir: string;
    FCompletedTorrentsDir: string;
    function EnsureToken: Boolean;
    function ExtractToken(const HTML: string): string;
    function ExtractGuidFromHeaders: string;
    procedure ApplyRequestHeaders;
    procedure CaptureCookiesFromResponse;
    function DoGet(const PathAndQuery: string; out Body: string): Boolean;
    function DoPostMultipart(const PathAndQuery, FieldName, FileName: string;
      const FileData: TBytes; out Body: string): Boolean;
    function GuiURL(const Query: string): string;
    function ParseJSONObject(const Body: string): TJSONObject;
    function TruncBody(const Body: string; MaxLen: Integer = 240): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Configure(const Host: string; Port: Integer;
      const UserName, Password: string; UseHTTPS: Boolean = False);
    function Connect: Boolean;
    procedure Disconnect;
    function GetList(out List: TTorrentList): Boolean;
    function GetProps(const Hash: string; out Props: TTorrentProps): Boolean;
    function GetFiles(const Hash: string; out Files: TTorrentFileList): Boolean;
    function TorrentAction(const Action, Hash: string): Boolean;
    function AddURL(const URL: string): Boolean;
    function AddFile(const FilePath: string): Boolean;
    function RefreshSettings: Boolean;
    function GetSettings(out Names, Types, Values: TStringList): Boolean;
    function SetSetting(const Name, Value: string): Boolean;
    procedure ApplyProxy(Enabled: Boolean; const Host: string; Port: Integer;
      const UserName, Password: string);
    property Connected: Boolean read FConnected;
    property LastError: string read FLastError;
    property LastStatusCode: Integer read FLastStatusCode;
    property Build: Integer read FBuild;
    property Token: string read FToken;
    property Guid: string read FGuid;
    property BaseURL: string read FBaseURL;
    property TorrentFilesDir: string read FTorrentFilesDir;
    property CompletedTorrentsDir: string read FCompletedTorrentsDir;
  end;

  TRefreshEvent = procedure(Sender: TObject; List: TTorrentList) of object;
  TRpcErrorEvent = procedure(Sender: TObject; const Msg: string) of object;

  TRpcRefreshThread = class(TThread)
  private
    FRpc: TuTorrentRpc;
    FIntervalMS: Integer;
    FOnRefresh: TRefreshEvent;
    FOnError: TRpcErrorEvent;
    FList: TTorrentList;
    FErrorMsg: string;
    FWake: TEvent;
    procedure DoRefresh;
    procedure DoError;
  protected
    procedure Execute; override;
  public
    constructor Create(ARpc: TuTorrentRpc);
    destructor Destroy; override;
    procedure TriggerNow;
    property IntervalMS: Integer read FIntervalMS write FIntervalMS;
    property OnRefresh: TRefreshEvent read FOnRefresh write FOnRefresh;
    property OnError: TRpcErrorEvent read FOnError write FOnError;
  end;

implementation

uses
  RegExpr, Logger;

function EncodeURLParam(const S: string): string;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    if C in ['A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.', '~'] then
      Result := Result + C
    else
      Result := Result + '%' + IntToHex(Ord(C), 2);
  end;
end;

{ TuTorrentRpc }

constructor TuTorrentRpc.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FHttp := TFPHTTPClient.Create(nil);
  FHttp.AllowRedirect := True;
  FHttp.KeepConnection := True;
  FConnected := False;
  FToken := '';
  FGuid := '';
  FBuild := 0;
  FLastError := '';
  FLastStatusCode := 0;
  FTorrentFilesDir := '';
  FCompletedTorrentsDir := '';
end;

destructor TuTorrentRpc.Destroy;
begin
  Disconnect;
  FHttp.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TuTorrentRpc.Configure(const Host: string; Port: Integer;
  const UserName, Password: string; UseHTTPS: Boolean);
var
  Scheme: string;
begin
  FLock.Enter;
  try
    if UseHTTPS then
      Scheme := 'https'
    else
      Scheme := 'http';
    FBaseURL := Format('%s://%s:%d/gui/', [Scheme, Host, Port]);
    FUser := UserName;
    FPassword := Password;
    FHttp.UserName := UserName;
    FHttp.Password := Password;
    FHttp.Cookies.Clear;
    FToken := '';
    FGuid := '';
    FConnected := False;
    LogFmt('Configure base=%s user=%s', [FBaseURL, FUser]);
  finally
    FLock.Leave;
  end;
end;

function TuTorrentRpc.ExtractToken(const HTML: string): string;
var
  Re: TRegExpr;
begin
  Result := '';
  Re := TRegExpr.Create;
  try
    Re.Expression := 'id\s*=\s*[''"]token[''"][^>]*>([^<]+)';
    Re.ModifierI := True;
    if Re.Exec(HTML) then
      Result := Trim(Re.Match[1]);
  finally
    Re.Free;
  end;
end;

function TuTorrentRpc.ExtractGuidFromHeaders: string;
var
  I, P: Integer;
  Line, LowLine, Value: string;
begin
  Result := '';
  for I := 0 to FHttp.ResponseHeaders.Count - 1 do
  begin
    Line := FHttp.ResponseHeaders[I];
    LowLine := LowerCase(Line);
    if Pos('set-cookie:', LowLine) = 1 then
    begin
      Value := Trim(Copy(Line, Length('Set-Cookie:') + 1, MaxInt));
      // GUID=xxxx; path=/
      if LowerCase(Copy(Value, 1, 5)) = 'guid=' then
      begin
        Value := Copy(Value, 6, MaxInt);
        P := Pos(';', Value);
        if P > 0 then
          Value := Copy(Value, 1, P - 1);
        Result := Trim(Value);
        Exit;
      end;
    end;
  end;
end;

procedure TuTorrentRpc.CaptureCookiesFromResponse;
var
  G: string;
  I: Integer;
begin
  G := ExtractGuidFromHeaders;
  if G <> '' then
  begin
    FGuid := G;
    LogFmt('Captured GUID cookie (%d chars)', [Length(FGuid)]);
  end;
  // Also dump cookies list from client if any
  if FHttp.Cookies.Count > 0 then
  begin
    for I := 0 to FHttp.Cookies.Count - 1 do
      LogFmt('Http.Cookies[%d]=%s', [I, FHttp.Cookies[I]]);
    // Try to pick GUID from Cookies name=value pairs
    for I := 0 to FHttp.Cookies.Count - 1 do
      if LowerCase(Copy(FHttp.Cookies[I], 1, 5)) = 'guid=' then
      begin
        FGuid := Copy(FHttp.Cookies[I], 6, MaxInt);
        Break;
      end;
  end;
end;

procedure TuTorrentRpc.ApplyRequestHeaders;
begin
  FHttp.RequestHeaders.Clear;
  FHttp.AddHeader('User-Agent', 'uTorrent-Remote-GUI/1.0');
  FHttp.AddHeader('Accept', 'application/json, text/javascript, */*; q=0.01');
  if FGuid <> '' then
    FHttp.AddHeader('Cookie', 'GUID=' + FGuid);
end;

function TuTorrentRpc.TruncBody(const Body: string; MaxLen: Integer): string;
begin
  if Length(Body) <= MaxLen then
    Result := Body
  else
    Result := Copy(Body, 1, MaxLen) + '...';
  Result := StringReplace(Result, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

function TuTorrentRpc.EnsureToken: Boolean;
var
  Body: string;
begin
  Result := False;
  if (FToken <> '') and (FGuid <> '') then
    Exit(True);
  // Always refresh token+guid together — GUID is required or API returns 400
  FToken := '';
  if not DoGet('token.html', Body) then
    Exit(False);
  FToken := ExtractToken(Body);
  if FToken = '' then
  begin
    FLastError := 'Could not parse CSRF token from token.html';
    Log('ERROR: ' + FLastError + ' body=' + TruncBody(Body));
    Exit(False);
  end;
  if FGuid = '' then
  begin
    FLastError := 'No GUID cookie from token.html (required by WebUI)';
    Log('ERROR: ' + FLastError);
    Exit(False);
  end;
  LogFmt('Token OK (%d chars), GUID OK (%d chars)', [Length(FToken), Length(FGuid)]);
  Result := True;
end;

function TuTorrentRpc.GuiURL(const Query: string): string;
begin
  if Query = '' then
    Result := FBaseURL
  else if Query[1] = '?' then
    Result := FBaseURL + Query
  else
    Result := FBaseURL + '?' + Query;
end;

function TuTorrentRpc.DoGet(const PathAndQuery: string; out Body: string): Boolean;
var
  URL, Path, SafeURL: string;
  SS: TStringStream;
begin
  Result := False;
  Body := '';
  FLock.Enter;
  try
    try
      if Pos('token.html', PathAndQuery) > 0 then
        URL := FBaseURL + 'token.html'
      else
      begin
        Path := PathAndQuery;
        if (Path <> '') and (Path[1] = '?') then
          Delete(Path, 1, 1);
        URL := GuiURL(Path);
      end;
      // redact token in logs
      SafeURL := URL;
      if FToken <> '' then
        SafeURL := StringReplace(SafeURL, FToken, '<token>', [rfReplaceAll]);

      ApplyRequestHeaders;
      LogFmt('GET %s (cookie GUID set=%s)', [SafeURL, BoolToStr(FGuid <> '', True)]);

      SS := TStringStream.Create('');
      try
        FHttp.HTTPMethod('GET', URL, SS, []);
        Body := SS.DataString;
        FLastStatusCode := FHttp.ResponseStatusCode;
        CaptureCookiesFromResponse;
        LogFmt('RESP %d %s body=%s',
          [FLastStatusCode, FHttp.ResponseStatusText, TruncBody(Body)]);

        if FLastStatusCode = 401 then
        begin
          FLastError := 'Unauthorized (check login/password)';
          Exit(False);
        end;
        if (FLastStatusCode < 200) or (FLastStatusCode >= 300) then
        begin
          FLastError := Format('HTTP %d: %s', [FLastStatusCode, FHttp.ResponseStatusText]);
          Exit(False);
        end;
        Result := True;
      finally
        SS.Free;
      end;
    except
      on E: Exception do
      begin
        FLastError := E.Message;
        Log('EXCEPTION: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TuTorrentRpc.DoPostMultipart(const PathAndQuery, FieldName, FileName: string;
  const FileData: TBytes; out Body: string): Boolean;
var
  Boundary, URL, Path, Head, Tail: string;
  Payload: TMemoryStream;
  SS: TStringStream;
begin
  Result := False;
  Body := '';
  Boundary := '----uTorrentGUI' + IntToStr(Random(MaxInt));
  FLock.Enter;
  try
    try
      Path := PathAndQuery;
      if (Path <> '') and (Path[1] = '?') then
        Delete(Path, 1, 1);
      URL := GuiURL(Path);

      Head := '--' + Boundary + #13#10 +
        'Content-Disposition: form-data; name="' + FieldName + '"; filename="' +
        ExtractFileName(FileName) + '"' + #13#10 +
        'Content-Type: application/x-bittorrent' + #13#10#13#10;
      Tail := #13#10 + '--' + Boundary + '--' + #13#10;

      Payload := TMemoryStream.Create;
      try
        if Length(Head) > 0 then
          Payload.WriteBuffer(Head[1], Length(Head));
        if Length(FileData) > 0 then
          Payload.WriteBuffer(FileData[0], Length(FileData));
        if Length(Tail) > 0 then
          Payload.WriteBuffer(Tail[1], Length(Tail));
        Payload.Position := 0;

        ApplyRequestHeaders;
        FHttp.AddHeader('Content-Type', 'multipart/form-data; boundary=' + Boundary);
        LogFmt('POST add-file %s bytes=%d', [ExtractFileName(FileName), Length(FileData)]);
        SS := TStringStream.Create('');
        try
          FHttp.RequestBody := Payload;
          FHttp.HTTPMethod('POST', URL, SS, []);
          Body := SS.DataString;
          FLastStatusCode := FHttp.ResponseStatusCode;
          CaptureCookiesFromResponse;
          LogFmt('RESP %d body=%s', [FLastStatusCode, TruncBody(Body)]);
          if (FLastStatusCode < 200) or (FLastStatusCode >= 300) then
          begin
            FLastError := Format('HTTP %d: %s', [FLastStatusCode, FHttp.ResponseStatusText]);
            Exit(False);
          end;
          Result := True;
        finally
          SS.Free;
          FHttp.RequestBody := nil;
        end;
      finally
        Payload.Free;
      end;
    except
      on E: Exception do
      begin
        FLastError := E.Message;
        Log('EXCEPTION: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TuTorrentRpc.ParseJSONObject(const Body: string): TJSONObject;
var
  Data: TJSONData;
begin
  Result := nil;
  if Trim(Body) = '' then
  begin
    FLastError := 'Empty response';
    Exit;
  end;
  try
    Data := GetJSON(Body);
  except
    on E: Exception do
    begin
      FLastError := 'JSON parse error: ' + E.Message;
      Log('ERROR: ' + FLastError);
      Exit;
    end;
  end;
  if not (Data is TJSONObject) then
  begin
    Data.Free;
    FLastError := 'Expected JSON object';
    Exit;
  end;
  Result := TJSONObject(Data);
end;

function TuTorrentRpc.Connect: Boolean;
var
  Body: string;
  Obj: TJSONObject;
begin
  Result := False;
  FConnected := False;
  FToken := '';
  FGuid := '';
  FLastError := '';
  Log('Connect start');
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&list=1', [EncodeURLParam(FToken)]), Body) then
  begin
    Log('list=1 failed, refreshing token+guid and retrying');
    FToken := '';
    FGuid := '';
    if not EnsureToken then
      Exit(False);
    if not DoGet(Format('token=%s&list=1', [EncodeURLParam(FToken)]), Body) then
      Exit(False);
  end;
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  try
    FBuild := Obj.Get('build', 0);
  finally
    Obj.Free;
  end;
  FConnected := True;
  LogFmt('Connected OK build=%d', [FBuild]);
  RefreshSettings;
  Result := True;
end;

function TuTorrentRpc.RefreshSettings: Boolean;
var
  Body: string;
  Obj: TJSONObject;
  Arr: TJSONData;
  Row: TJSONData;
  Name: string;
  I: Integer;
begin
  Result := False;
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&action=getsettings', [EncodeURLParam(FToken)]), Body) then
    Exit(False);
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  try
    Arr := Obj.Find('settings');
    if (Arr <> nil) and (Arr is TJSONArray) then
    begin
      for I := 0 to TJSONArray(Arr).Count - 1 do
      begin
        Row := TJSONArray(Arr).Items[I];
        if not (Row is TJSONArray) then
          Continue;
        if TJSONArray(Row).Count < 3 then
          Continue;
        Name := TJSONArray(Row).Items[0].AsString;
        if Name = 'dir_torrent_files' then
          FTorrentFilesDir := TJSONArray(Row).Items[2].AsString
        else if Name = 'dir_completed_torrents' then
          FCompletedTorrentsDir := TJSONArray(Row).Items[2].AsString;
      end;
    end;
    LogFmt('Settings dirs: torrents="%s" done="%s"',
      [FTorrentFilesDir, FCompletedTorrentsDir]);
    Result := True;
  finally
    Obj.Free;
  end;
end;

function TuTorrentRpc.GetSettings(out Names, Types, Values: TStringList): Boolean;
var
  Body: string;
  Obj: TJSONObject;
  Arr: TJSONData;
  Row: TJSONData;
  I: Integer;
begin
  Result := False;
  Names := nil;
  Types := nil;
  Values := nil;
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&action=getsettings', [EncodeURLParam(FToken)]), Body) then
    Exit(False);
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  Names := TStringList.Create;
  Types := TStringList.Create;
  Values := TStringList.Create;
  try
    Arr := Obj.Find('settings');
    if (Arr <> nil) and (Arr is TJSONArray) then
      for I := 0 to TJSONArray(Arr).Count - 1 do
      begin
        Row := TJSONArray(Arr).Items[I];
        if not (Row is TJSONArray) then
          Continue;
        if TJSONArray(Row).Count < 3 then
          Continue;
        Names.Add(TJSONArray(Row).Items[0].AsString);
        Types.Add(TJSONArray(Row).Items[1].AsString);
        Values.Add(TJSONArray(Row).Items[2].AsString);
      end;
    Result := Names.Count > 0;
  finally
    Obj.Free;
    if not Result then
    begin
      FreeAndNil(Names);
      FreeAndNil(Types);
      FreeAndNil(Values);
    end;
  end;
end;

function TuTorrentRpc.SetSetting(const Name, Value: string): Boolean;
var
  Body: string;
begin
  Result := False;
  if not EnsureToken then
    Exit(False);
  Result := DoGet(Format('token=%s&action=setsetting&s=%s&v=%s',
    [EncodeURLParam(FToken), EncodeURLParam(Name), EncodeURLParam(Value)]), Body);
end;

procedure TuTorrentRpc.ApplyProxy(Enabled: Boolean; const Host: string; Port: Integer;
  const UserName, Password: string);
begin
  FLock.Enter;
  try
    if Enabled and (Trim(Host) <> '') then
    begin
      FHttp.Proxy.Host := Host;
      FHttp.Proxy.Port := Port;
      FHttp.Proxy.UserName := UserName;
      FHttp.Proxy.Password := Password;
    end
    else
    begin
      FHttp.Proxy.Host := '';
      FHttp.Proxy.Port := 0;
      FHttp.Proxy.UserName := '';
      FHttp.Proxy.Password := '';
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TuTorrentRpc.Disconnect;
begin
  FLock.Enter;
  try
    FConnected := False;
    FToken := '';
    FGuid := '';
    FHttp.Cookies.Clear;
    Log('Disconnected');
  finally
    FLock.Leave;
  end;
end;

function TuTorrentRpc.GetList(out List: TTorrentList): Boolean;
var
  Body: string;
  Obj: TJSONObject;
begin
  Result := False;
  List := nil;
  if not FConnected and not Connect then
    Exit(False);
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&list=1', [EncodeURLParam(FToken)]), Body) then
  begin
    // 400 almost always = missing/stale GUID or token
    LogFmt('GetList failed (%s), full re-auth', [FLastError]);
    FToken := '';
    FGuid := '';
    if not EnsureToken then
      Exit(False);
    if not DoGet(Format('token=%s&list=1', [EncodeURLParam(FToken)]), Body) then
      Exit(False);
  end;
  if (Pos('invalid token', LowerCase(Body)) > 0) then
  begin
    FToken := '';
    FGuid := '';
    if not EnsureToken then
      Exit(False);
    if not DoGet(Format('token=%s&list=1', [EncodeURLParam(FToken)]), Body) then
      Exit(False);
  end;
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  try
    List := TTorrentList.Create;
    List.LoadFromListJSON(Obj);
    FBuild := List.Build;
    Result := True;
  finally
    Obj.Free;
  end;
end;

function TuTorrentRpc.GetProps(const Hash: string; out Props: TTorrentProps): Boolean;
var
  Body: string;
  Obj: TJSONObject;
  Arr: TJSONData;
  Item: TJSONData;
begin
  Result := False;
  Props := nil;
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&action=getprops&hash=%s',
    [EncodeURLParam(FToken), EncodeURLParam(Hash)]), Body) then
    Exit(False);
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  try
    Props := TTorrentProps.Create;
    Arr := Obj.Find('props');
    if (Arr <> nil) and (Arr is TJSONArray) and (TJSONArray(Arr).Count > 0) then
    begin
      Item := TJSONArray(Arr).Items[0];
      if Item is TJSONObject then
        Props.AssignFromJSON(TJSONObject(Item));
    end;
    Result := True;
  finally
    Obj.Free;
  end;
end;

function TuTorrentRpc.GetFiles(const Hash: string; out Files: TTorrentFileList): Boolean;
var
  Body: string;
  Obj: TJSONObject;
begin
  Result := False;
  Files := nil;
  if not EnsureToken then
    Exit(False);
  if not DoGet(Format('token=%s&action=getfiles&hash=%s',
    [EncodeURLParam(FToken), EncodeURLParam(Hash)]), Body) then
    Exit(False);
  Obj := ParseJSONObject(Body);
  if Obj = nil then
    Exit(False);
  try
    Files := TTorrentFileList.Create;
    Files.LoadFromJSON(Obj);
    Result := True;
  finally
    Obj.Free;
  end;
end;

function TuTorrentRpc.TorrentAction(const Action, Hash: string): Boolean;
var
  Body: string;
begin
  Result := False;
  if not EnsureToken then
    Exit(False);
  Result := DoGet(Format('token=%s&action=%s&hash=%s',
    [EncodeURLParam(FToken), EncodeURLParam(Action), EncodeURLParam(Hash)]), Body);
end;

function TuTorrentRpc.AddURL(const URL: string): Boolean;
var
  Body: string;
begin
  Result := False;
  if not EnsureToken then
    Exit(False);
  Result := DoGet(Format('token=%s&action=add-url&s=%s',
    [EncodeURLParam(FToken), EncodeURLParam(URL)]), Body);
end;

function TuTorrentRpc.AddFile(const FilePath: string): Boolean;
var
  Body: string;
  FS: TFileStream;
  Data: TBytes;
begin
  Result := False;
  Data := nil;
  if not EnsureToken then
    Exit(False);
  if not FileExists(FilePath) then
  begin
    FLastError := 'File not found: ' + FilePath;
    Exit(False);
  end;
  FS := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Data, FS.Size);
    if FS.Size > 0 then
      FS.ReadBuffer(Data[0], FS.Size);
  finally
    FS.Free;
  end;
  Result := DoPostMultipart(Format('token=%s&action=add-file', [EncodeURLParam(FToken)]),
    'torrent_file', FilePath, Data, Body);
end;

{ TRpcRefreshThread }

constructor TRpcRefreshThread.Create(ARpc: TuTorrentRpc);
begin
  inherited Create(True);
  FRpc := ARpc;
  FIntervalMS := 2000;
  FreeOnTerminate := False;
  FWake := TEvent.Create(nil, False, False, '');
  FList := nil;
end;

destructor TRpcRefreshThread.Destroy;
begin
  FWake.Free;
  if FList <> nil then
    FList.Free;
  inherited Destroy;
end;

procedure TRpcRefreshThread.TriggerNow;
begin
  FWake.SetEvent;
end;

procedure TRpcRefreshThread.DoRefresh;
begin
  if Assigned(FOnRefresh) and (FList <> nil) then
    FOnRefresh(Self, FList);
end;

procedure TRpcRefreshThread.DoError;
begin
  if Assigned(FOnError) then
    FOnError(Self, FErrorMsg);
end;

procedure TRpcRefreshThread.Execute;
var
  List: TTorrentList;
  WaitRes: TWaitResult;
begin
  while not Terminated do
  begin
    List := nil;
    if FRpc.GetList(List) then
    begin
      if FList <> nil then
        FList.Free;
      FList := List;
      Synchronize(@DoRefresh);
    end
    else
    begin
      FErrorMsg := FRpc.LastError;
      Synchronize(@DoError);
    end;
    WaitRes := FWake.WaitFor(FIntervalMS);
    if Terminated then
      Break;
    if WaitRes = wrSignaled then
      Continue;
  end;
end;

end.
