unit Profiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Utils;

type
  TConnectionProfile = record
    Name: string;
    Host: string;
    Port: Integer;
    UserName: string;
    Password: string;
    UseHTTPS: Boolean;
  end;

  { TProfileList — profiles + application options }

  TProfileList = class
  private
    FItems: array of TConnectionProfile;
    FActiveIndex: Integer;
    FAutoConnect: Boolean;
    FLanguage: string;
    FToolbarLarge: Boolean;
    FRefreshInterval: Integer;
    FRefreshMinimized: Integer;
    FMinimizeToTray: Boolean;
    FCloseToTray: Boolean;
    FAlwaysShowTray: Boolean;
    FTrayNotify: Boolean;
    FShowFilterPanel: Boolean;
    FShowDetailsPanel: Boolean;
    FShowToolbar: Boolean;
    FShowStatusBar: Boolean;
    FFontSizePercent: Integer;
    FPathMap: string;
    FProxyEnabled: Boolean;
    FProxyHost: string;
    FProxyPort: Integer;
    FProxyUser: string;
    FProxyPass: string;
    FProxySocks5: Boolean;
    FDeleteTorrentAfterAdd: Boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): TConnectionProfile;
    procedure SetItem(Index: Integer; const AValue: TConnectionProfile);
  public
    constructor Create;
    procedure Clear;
    procedure Load;
    procedure Save;
    function Add(const P: TConnectionProfile): Integer;
    procedure Delete(Index: Integer);
    procedure EnsureDefault;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TConnectionProfile read GetItem write SetItem; default;
    property ActiveIndex: Integer read FActiveIndex write FActiveIndex;
    property AutoConnect: Boolean read FAutoConnect write FAutoConnect;
    property Language: string read FLanguage write FLanguage;
    property ToolbarLarge: Boolean read FToolbarLarge write FToolbarLarge;
    property RefreshInterval: Integer read FRefreshInterval write FRefreshInterval;
    property RefreshMinimized: Integer read FRefreshMinimized write FRefreshMinimized;
    property MinimizeToTray: Boolean read FMinimizeToTray write FMinimizeToTray;
    property CloseToTray: Boolean read FCloseToTray write FCloseToTray;
    property AlwaysShowTray: Boolean read FAlwaysShowTray write FAlwaysShowTray;
    property TrayNotify: Boolean read FTrayNotify write FTrayNotify;
    property ShowFilterPanel: Boolean read FShowFilterPanel write FShowFilterPanel;
    property ShowDetailsPanel: Boolean read FShowDetailsPanel write FShowDetailsPanel;
    property ShowToolbar: Boolean read FShowToolbar write FShowToolbar;
    property ShowStatusBar: Boolean read FShowStatusBar write FShowStatusBar;
    property FontSizePercent: Integer read FFontSizePercent write FFontSizePercent;
    property PathMap: string read FPathMap write FPathMap;
    property ProxyEnabled: Boolean read FProxyEnabled write FProxyEnabled;
    property ProxyHost: string read FProxyHost write FProxyHost;
    property ProxyPort: Integer read FProxyPort write FProxyPort;
    property ProxyUser: string read FProxyUser write FProxyUser;
    property ProxyPass: string read FProxyPass write FProxyPass;
    property ProxySocks5: Boolean read FProxySocks5 write FProxySocks5;
    property DeleteTorrentAfterAdd: Boolean read FDeleteTorrentAfterAdd write FDeleteTorrentAfterAdd;
  end;

function DefaultProfile: TConnectionProfile;
function MapRemotePath(const PathMap, RemotePath: string): string;

implementation

function DefaultProfile: TConnectionProfile;
begin
  Result.Name := 'Local';
  Result.Host := '127.0.0.1';
  Result.Port := 8888;
  Result.UserName := 'admin';
  Result.Password := '';
  Result.UseHTTPS := False;
end;

function MapRemotePath(const PathMap, RemotePath: string): string;
var
  SL: TStringList;
  I, Eq: Integer;
  Line, L, R, P: string;
begin
  Result := RemotePath;
  P := Trim(RemotePath);
  if (P = '') or (Trim(PathMap) = '') then
    Exit;
  SL := TStringList.Create;
  try
    SL.Text := PathMap;
    for I := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[I]);
      if (Line = '') or (Line[1] = ';') or (Line[1] = '#') then
        Continue;
      Eq := Pos('=', Line);
      if Eq <= 1 then
        Continue;
      L := Copy(Line, 1, Eq - 1);
      R := Copy(Line, Eq + 1, MaxInt);
      if (Length(P) >= Length(L)) and SameText(Copy(P, 1, Length(L)), L) then
      begin
        Result := R + Copy(P, Length(L) + 1, MaxInt);
        Exit;
      end;
    end;
  finally
    SL.Free;
  end;
end;

constructor TProfileList.Create;
begin
  inherited Create;
  FActiveIndex := 0;
  FAutoConnect := False;
  FLanguage := 'en';
  FToolbarLarge := False;
  FRefreshInterval := 2;
  FRefreshMinimized := 20;
  FMinimizeToTray := True;
  FCloseToTray := True;
  FAlwaysShowTray := True;
  FTrayNotify := True;
  FShowFilterPanel := True;
  FShowDetailsPanel := True;
  FShowToolbar := True;
  FShowStatusBar := True;
  FFontSizePercent := 100;
  FPathMap := '';
  FProxyEnabled := False;
  FProxyHost := '';
  FProxyPort := 8080;
  FProxyUser := '';
  FProxyPass := '';
  FProxySocks5 := False;
  FDeleteTorrentAfterAdd := False;
  SetLength(FItems, 0);
end;

procedure TProfileList.Clear;
begin
  SetLength(FItems, 0);
  FActiveIndex := 0;
end;

function TProfileList.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TProfileList.GetItem(Index: Integer): TConnectionProfile;
begin
  Result := FItems[Index];
end;

procedure TProfileList.SetItem(Index: Integer; const AValue: TConnectionProfile);
begin
  FItems[Index] := AValue;
end;

function TProfileList.Add(const P: TConnectionProfile): Integer;
begin
  Result := Length(FItems);
  SetLength(FItems, Result + 1);
  FItems[Result] := P;
end;

procedure TProfileList.Delete(Index: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index >= Length(FItems)) then
    Exit;
  for I := Index to High(FItems) - 1 do
    FItems[I] := FItems[I + 1];
  SetLength(FItems, Length(FItems) - 1);
  if FActiveIndex >= Length(FItems) then
    FActiveIndex := Length(FItems) - 1;
  if FActiveIndex < 0 then
    FActiveIndex := 0;
end;

procedure TProfileList.EnsureDefault;
begin
  if Length(FItems) = 0 then
    Add(DefaultProfile);
end;

procedure TProfileList.Load;
var
  Ini: TIniFile;
  N, I: Integer;
  Sec: string;
  P: TConnectionProfile;
  OldHost: string;
begin
  Clear;
  Ini := TIniFile.Create(ConfigFilePath);
  try
    FLanguage := Ini.ReadString('General', 'Language', 'ru');
    FAutoConnect := Ini.ReadBool('General', 'AutoConnect', False);
    FToolbarLarge := Ini.ReadBool('General', 'ToolbarLarge', False);
    FActiveIndex := Ini.ReadInteger('General', 'ActiveProfile', 0);
    FRefreshInterval := Ini.ReadInteger('General', 'RefreshInterval', 2);
    FRefreshMinimized := Ini.ReadInteger('General', 'RefreshMinimized', 20);
    FMinimizeToTray := Ini.ReadBool('General', 'MinimizeToTray', True);
    FCloseToTray := Ini.ReadBool('General', 'CloseToTray', True);
    FAlwaysShowTray := Ini.ReadBool('General', 'AlwaysShowTray', True);
    FTrayNotify := Ini.ReadBool('General', 'TrayNotify', True);
    FShowFilterPanel := Ini.ReadBool('General', 'ShowFilterPanel', True);
    FShowDetailsPanel := Ini.ReadBool('General', 'ShowDetailsPanel', True);
    FShowToolbar := Ini.ReadBool('General', 'ShowToolbar', True);
    FShowStatusBar := Ini.ReadBool('General', 'ShowStatusBar', True);
    FFontSizePercent := Ini.ReadInteger('General', 'FontSizePercent', 100);
    FPathMap := StringReplace(Ini.ReadString('General', 'PathMap', ''), '\n', LineEnding, [rfReplaceAll]);
    FProxyEnabled := Ini.ReadBool('Proxy', 'Enabled', False);
    FProxyHost := Ini.ReadString('Proxy', 'Host', '');
    FProxyPort := Ini.ReadInteger('Proxy', 'Port', 8080);
    FProxyUser := Ini.ReadString('Proxy', 'User', '');
    FProxyPass := Ini.ReadString('Proxy', 'Password', '');
    FProxySocks5 := Ini.ReadBool('Proxy', 'Socks5', False);
    FDeleteTorrentAfterAdd := Ini.ReadBool('General', 'DeleteTorrentAfterAdd', False);
    if FRefreshInterval < 1 then FRefreshInterval := 2;
    if FRefreshMinimized < 1 then FRefreshMinimized := 20;
    if FFontSizePercent < 50 then FFontSizePercent := 50;
    if FFontSizePercent > 200 then FFontSizePercent := 200;
    N := Ini.ReadInteger('General', 'ProfileCount', -1);
    if N < 0 then
    begin
      OldHost := Ini.ReadString('Connection', 'Host', '');
      if OldHost <> '' then
      begin
        P := DefaultProfile;
        P.Name := 'Default';
        P.Host := OldHost;
        P.Port := Ini.ReadInteger('Connection', 'Port', 8888);
        P.UserName := Ini.ReadString('Connection', 'User', 'admin');
        P.Password := Ini.ReadString('Connection', 'Password', '');
        P.UseHTTPS := Ini.ReadBool('Connection', 'HTTPS', False);
        Add(P);
      end;
    end
    else
    begin
      for I := 0 to N - 1 do
      begin
        Sec := Format('Profile%d', [I]);
        P.Name := Ini.ReadString(Sec, 'Name', Format('Profile %d', [I + 1]));
        P.Host := Ini.ReadString(Sec, 'Host', '127.0.0.1');
        P.Port := Ini.ReadInteger(Sec, 'Port', 8888);
        P.UserName := Ini.ReadString(Sec, 'User', 'admin');
        P.Password := Ini.ReadString(Sec, 'Password', '');
        P.UseHTTPS := Ini.ReadBool(Sec, 'HTTPS', False);
        Add(P);
      end;
    end;
  finally
    Ini.Free;
  end;
  EnsureDefault;
  if FActiveIndex >= Count then
    FActiveIndex := 0;
end;

procedure TProfileList.Save;
var
  Ini: TIniFile;
  I: Integer;
  Sec: string;
  P: TConnectionProfile;
begin
  Ini := TIniFile.Create(ConfigFilePath);
  try
    Ini.WriteString('General', 'Language', FLanguage);
    Ini.WriteBool('General', 'AutoConnect', FAutoConnect);
    Ini.WriteBool('General', 'ToolbarLarge', FToolbarLarge);
    Ini.WriteInteger('General', 'ActiveProfile', FActiveIndex);
    Ini.WriteInteger('General', 'ProfileCount', Count);
    Ini.WriteInteger('General', 'RefreshInterval', FRefreshInterval);
    Ini.WriteInteger('General', 'RefreshMinimized', FRefreshMinimized);
    Ini.WriteBool('General', 'MinimizeToTray', FMinimizeToTray);
    Ini.WriteBool('General', 'CloseToTray', FCloseToTray);
    Ini.WriteBool('General', 'AlwaysShowTray', FAlwaysShowTray);
    Ini.WriteBool('General', 'TrayNotify', FTrayNotify);
    Ini.WriteBool('General', 'ShowFilterPanel', FShowFilterPanel);
    Ini.WriteBool('General', 'ShowDetailsPanel', FShowDetailsPanel);
    Ini.WriteBool('General', 'ShowToolbar', FShowToolbar);
    Ini.WriteBool('General', 'ShowStatusBar', FShowStatusBar);
    Ini.WriteInteger('General', 'FontSizePercent', FFontSizePercent);
    Ini.WriteString('General', 'PathMap', StringReplace(FPathMap, LineEnding, '\n', [rfReplaceAll]));
    Ini.WriteBool('General', 'DeleteTorrentAfterAdd', FDeleteTorrentAfterAdd);
    Ini.WriteBool('Proxy', 'Enabled', FProxyEnabled);
    Ini.WriteString('Proxy', 'Host', FProxyHost);
    Ini.WriteInteger('Proxy', 'Port', FProxyPort);
    Ini.WriteString('Proxy', 'User', FProxyUser);
    Ini.WriteString('Proxy', 'Password', FProxyPass);
    Ini.WriteBool('Proxy', 'Socks5', FProxySocks5);
    for I := 0 to Count - 1 do
    begin
      P := FItems[I];
      Sec := Format('Profile%d', [I]);
      Ini.WriteString(Sec, 'Name', P.Name);
      Ini.WriteString(Sec, 'Host', P.Host);
      Ini.WriteInteger(Sec, 'Port', P.Port);
      Ini.WriteString(Sec, 'User', P.UserName);
      Ini.WriteString(Sec, 'Password', P.Password);
      Ini.WriteBool(Sec, 'HTTPS', P.UseHTTPS);
    end;
  finally
    Ini.Free;
  end;
end;

end.
