unit Lang;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TLanguageInfo = class
  public
    Code: string;       // file stem, e.g. "ru"
    Name: string;       // display name from LanguageName=
    FileName: string;
  end;

procedure LangInit;
procedure LangReload;
function LangDir: string;
function LanguageCount: Integer;
function GetLanguageInfo(Index: Integer): TLanguageInfo;
function FindLanguageIndex(const Code: string): Integer;
procedure SetAppLanguageCode(const Code: string);
function GetAppLanguageCode: string;
function _(const Id: string): string;

implementation

uses
  IniFiles, UtSettingLabels;

var
  GLangCode: string = 'en';
  GStrings: TStringList;
  GLanguages: TObjectList;
  GEnglish: TStringList;

procedure FillBuiltInEnglish(L: TStringList);
begin
  L.Clear;
  L.Values['LanguageName'] := 'English';
  L.Values['app.title'] := 'uTorrent Remote GUI';
  L.Values['menu.torrent'] := 'Torrent';
  L.Values['menu.view'] := 'View';
  L.Values['menu.tools'] := 'Tools';
  L.Values['menu.help'] := 'Help';
  L.Values['menu.language'] := 'Language';
  L.Values['act.connect'] := 'Connect...';
  L.Values['act.disconnect'] := 'Disconnect';
  L.Values['act.addfile'] := 'Add torrent...';
  L.Values['act.addurl'] := 'Add URL...';
  L.Values['act.start'] := 'Start';
  L.Values['act.forcestart'] := 'Force start';
  L.Values['act.pause'] := 'Pause';
  L.Values['act.stop'] := 'Stop';
  L.Values['act.recheck'] := 'Recheck';
  L.Values['act.remove'] := 'Remove';
  L.Values['act.removedata'] := 'Remove + data';
  L.Values['act.refresh'] := 'Refresh';
  L.Values['act.exit'] := 'Exit';
  L.Values['act.profiles'] := 'Connections...';
  L.Values['act.about'] := 'About...';
  L.Values['act.homepage'] := 'Home page';
  L.Values['act.open'] := 'Open';
  L.Values['act.openfolder'] := 'Open containing folder';
  L.Values['act.copymagnet'] := 'Copy magnet link';
  L.Values['act.queue'] := 'Queue';
  L.Values['act.queuetop'] := 'Move to top';
  L.Values['act.queueup'] := 'Move up';
  L.Values['act.queuedown'] := 'Move down';
  L.Values['act.queuebottom'] := 'Move to bottom';
  L.Values['act.columns'] := 'Configure columns...';
  L.Values['tb.connect'] := 'Connect';
  L.Values['tb.add'] := 'Add';
  L.Values['tb.url'] := 'URL';
  L.Values['tb.start'] := 'Start';
  L.Values['tb.pause'] := 'Pause';
  L.Values['tb.stop'] := 'Stop';
  L.Values['tb.remove'] := 'Remove';
  L.Values['flt.all'] := 'All torrents';
  L.Values['flt.down'] := 'Downloading';
  L.Values['flt.done'] := 'Completed';
  L.Values['flt.active'] := 'Active';
  L.Values['flt.inactive'] := 'Inactive';
  L.Values['flt.stopped'] := 'Stopped';
  L.Values['flt.error'] := 'Error';
  L.Values['flt.queued'] := 'Waiting';
  L.Values['col.name'] := 'Name';
  L.Values['col.size'] := 'Size';
  L.Values['col.downloaded'] := 'Downloaded';
  L.Values['col.done'] := 'Done';
  L.Values['col.status'] := 'Status';
  L.Values['col.seeds'] := 'Seeds';
  L.Values['col.peers'] := 'Peers';
  L.Values['col.down'] := 'Down';
  L.Values['col.up'] := 'Up';
  L.Values['col.uploaded'] := 'Uploaded';
  L.Values['col.remaining'] := 'Remaining';
  L.Values['col.ratio'] := 'Ratio';
  L.Values['col.eta'] := 'ETA';
  L.Values['col.label'] := 'Label';
  L.Values['col.file'] := 'Name';
  L.Values['col.priority'] := 'Priority';
  L.Values['col.tracker'] := 'Tracker';
  L.Values['tab.general'] := 'General';
  L.Values['tab.trackers'] := 'Trackers';
  L.Values['tab.files'] := 'Files';
  L.Values['grp.transfer'] := 'Transfer';
  L.Values['grp.torrent'] := 'Torrent';
  L.Values['lbl.status'] := 'Status:';
  L.Values['lbl.downloaded'] := 'Downloaded:';
  L.Values['lbl.uploaded'] := 'Uploaded:';
  L.Values['lbl.speed'] := 'Speed:';
  L.Values['lbl.remaining'] := 'Remaining:';
  L.Values['lbl.seeds'] := 'Seeds:';
  L.Values['lbl.peers'] := 'Peers:';
  L.Values['lbl.ratio'] := 'Ratio:';
  L.Values['lbl.error'] := 'Error:';
  L.Values['lbl.name'] := 'Name:';
  L.Values['lbl.size'] := 'Total size:';
  L.Values['lbl.hash'] := 'Hash:';
  L.Values['lbl.path'] := 'Path:';
  L.Values['lbl.added'] := 'Added:';
  L.Values['lbl.completed'] := 'Completed:';
  L.Values['lbl.comment'] := 'Comment:';
  L.Values['status.noconnect'] := 'Not connected';
  L.Values['status.connecting'] := 'Connecting...';
  L.Values['status.dl'] := 'DL';
  L.Values['status.ul'] := 'UL';
  L.Values['msg.connect.fail'] := 'Connection failed: %s';
  L.Values['msg.select.torrent'] := 'Select a torrent first.';
  L.Values['msg.error'] := 'Error: %s';
  L.Values['msg.remove'] := 'Remove torrent from list?';
  L.Values['msg.removedata'] := 'Remove torrent and delete data?';
  L.Values['msg.addurl'] := 'Add URL / magnet';
  L.Values['msg.host.required'] := 'Host is required.';
  L.Values['msg.name.required'] := 'Connection name is required.';
  L.Values['balloon.done.title'] := 'Download finished';
  L.Values['balloon.error.title'] := 'Torrent error';
  L.Values['tray.hint.server'] := ' (uTorrent %d @ %s:%d)';
  L.Values['tray.hint.counts'] := 'Downloading: %d, seeding: %d';
  L.Values['tray.hint.speeds'] := '%s: %s, %s: %s';
  L.Values['tray.show'] := 'Show window';
  L.Values['dlg.profiles'] := 'Connections';
  L.Values['dlg.profiles.list'] := 'List';
  L.Values['dlg.profiles.name'] := 'Name';
  L.Values['dlg.profiles.host'] := 'Host';
  L.Values['dlg.profiles.port'] := 'Port';
  L.Values['dlg.profiles.user'] := 'User';
  L.Values['dlg.profiles.password'] := 'Password';
  L.Values['dlg.profiles.https'] := 'HTTPS';
  L.Values['dlg.profiles.autoconnect'] := 'Connect on startup';
  L.Values['dlg.profiles.add'] := 'Add';
  L.Values['dlg.profiles.delete'] := 'Delete';
  L.Values['dlg.ok'] := 'OK';
  L.Values['dlg.cancel'] := 'Cancel';
  L.Values['of.torrent'] := 'Torrent files|*.torrent|All files|*.*';
  L.Values['about.title'] := 'About';
  L.Values['about.tab.about'] := 'About';
  L.Values['about.tab.license'] := 'License';
  L.Values['about.version'] := 'Version %s';
  L.Values['about.copyright'] := 'Copyright (c) 2026 gazizovemil';
  L.Values['about.homepage'] := 'Home page';
  L.Values['about.ok'] := 'OK';
  L.Values['tb.size.large'] := 'Large toolbar';
  L.Values['tb.size.small'] := 'Small toolbar';
  L.Values['st.error'] := 'Error';
  L.Values['st.error.msg'] := 'Error: %s';
  L.Values['st.checking'] := 'Checking';
  L.Values['st.paused'] := 'Paused';
  L.Values['st.seeding'] := 'Seeding';
  L.Values['st.downloading'] := 'Downloading';
  L.Values['st.queued'] := 'Queued';
  L.Values['st.queued.seed'] := 'Queued seed';
  L.Values['st.finished'] := 'Finished';
  L.Values['st.stopped'] := 'Stopped';
  L.Values['prio.skip'] := 'Skip';
  L.Values['prio.low'] := 'Low';
  L.Values['prio.normal'] := 'Normal';
  L.Values['prio.high'] := 'High';
  L.Values['unit.b'] := 'B';
  L.Values['unit.kb'] := 'KB';
  L.Values['unit.mb'] := 'MB';
  L.Values['unit.gb'] := 'GB';
  L.Values['unit.tb'] := 'TB';
  L.Values['unit.bps'] := 'B/s';
  L.Values['unit.per.sec'] := '/s';
  L.Values['fmt.of'] := '%d of %d';
end;

function LangDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'lang';
end;

function LanguageCount: Integer;
begin
  if GLanguages = nil then
    Result := 0
  else
    Result := GLanguages.Count;
end;

function GetLanguageInfo(Index: Integer): TLanguageInfo;
begin
  Result := TLanguageInfo(GLanguages[Index]);
end;

function FindLanguageIndex(const Code: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if GLanguages = nil then Exit;
  for I := 0 to GLanguages.Count - 1 do
    if SameText(TLanguageInfo(GLanguages[I]).Code, Code) then
      Exit(I);
end;

procedure LoadStringsFromFile(const FileName: string; Dest: TStringList);
var
  Ini: TMemIniFile;
  SL, Raw: TStringList;
  I: Integer;
  Sec, Key, Val: string;
begin
  Dest.Clear;
  Raw := TStringList.Create;
  try
    Raw.LoadFromFile(FileName, TEncoding.UTF8);
    Ini := TMemIniFile.Create('');
    try
      Ini.SetStrings(Raw);
      SL := TStringList.Create;
      try
        Ini.ReadSectionValues('Strings', Dest);
        if Dest.Count = 0 then
        begin
          Ini.ReadSections(SL);
          for I := 0 to SL.Count - 1 do
          begin
            Sec := SL[I];
            if SameText(Sec, 'Meta') then Continue;
            Ini.ReadSectionValues(Sec, Dest);
          end;
        end;
        Val := Ini.ReadString('Meta', 'LanguageName', '');
        if Val = '' then
          Val := Ini.ReadString('Strings', 'LanguageName', '');
        if Val = '' then
          Val := ChangeFileExt(ExtractFileName(FileName), '');
        Dest.Values['LanguageName'] := Val;
      finally
        SL.Free;
      end;
    finally
      Ini.Free;
    end;
  finally
    Raw.Free;
  end;
  // normalize keys to lowercase
  SL := TStringList.Create;
  try
    SL.Assign(Dest);
    Dest.Clear;
    for I := 0 to SL.Count - 1 do
    begin
      Key := Trim(SL.Names[I]);
      Val := SL.ValueFromIndex[I];
      if Key <> '' then
        Dest.Values[LowerCase(Key)] := Val;
    end;
  finally
    SL.Free;
  end;
end;

procedure ScanLanguages;
var
  Dir, Fn, Code: string;
  Rec: TSearchRec;
  Info: TLanguageInfo;
  Tmp: TStringList;
begin
  GLanguages.Clear;
  Dir := LangDir;
  if not DirectoryExists(Dir) then Exit;
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*.lng', faAnyFile, Rec) = 0 then
  try
    repeat
      if (Rec.Attr and faDirectory) <> 0 then Continue;
      Fn := IncludeTrailingPathDelimiter(Dir) + Rec.Name;
      Code := LowerCase(ChangeFileExt(Rec.Name, ''));
      if Code = '' then Continue;
      Info := TLanguageInfo.Create;
      Info.Code := Code;
      Info.FileName := Fn;
      Tmp := TStringList.Create;
      try
        LoadStringsFromFile(Fn, Tmp);
        Info.Name := Tmp.Values['languagename'];
        if Info.Name = '' then
          Info.Name := Code;
      finally
        Tmp.Free;
      end;
      GLanguages.Add(Info);
    until FindNext(Rec) <> 0;
  finally
    FindClose(Rec);
  end;
end;

procedure ApplyLanguageStrings;
var
  Idx, I: Integer;
  Info: TLanguageInfo;
  Tmp: TStringList;
  Key: string;
begin
  GStrings.Clear;
  GStrings.Assign(GEnglish);
  Idx := FindLanguageIndex(GLangCode);
  if Idx < 0 then
  begin
    GLangCode := 'en';
  end
  else
  begin
    Info := GetLanguageInfo(Idx);
    Tmp := TStringList.Create;
    try
      LoadStringsFromFile(Info.FileName, Tmp);
      for I := 0 to Tmp.Count - 1 do
      begin
        Key := Tmp.Names[I];
        if Key <> '' then
          GStrings.Values[Key] := Tmp.ValueFromIndex[I];
      end;
    finally
      Tmp.Free;
    end;
  end;
  UtSettingLabelsReload;
end;

procedure LangReload;
begin
  ScanLanguages;
  ApplyLanguageStrings;
end;

procedure LangInit;
begin
  if GEnglish = nil then
  begin
    GEnglish := TStringList.Create;
    GEnglish.NameValueSeparator := '=';
    FillBuiltInEnglish(GEnglish);
  end;
  if GStrings = nil then
  begin
    GStrings := TStringList.Create;
    GStrings.NameValueSeparator := '=';
  end;
  if GLanguages = nil then
    GLanguages := TObjectList.Create(True);
  LangReload;
end;

procedure SetAppLanguageCode(const Code: string);
begin
  if Trim(Code) = '' then
    GLangCode := 'en'
  else
    GLangCode := LowerCase(Trim(Code));
  ApplyLanguageStrings;
end;

function GetAppLanguageCode: string;
begin
  Result := GLangCode;
end;

function _(const Id: string): string;
var
  K: string;
begin
  K := LowerCase(Id);
  if GStrings <> nil then
    Result := GStrings.Values[K]
  else
    Result := '';
  if Result = '' then
  begin
    if GEnglish <> nil then
      Result := GEnglish.Values[K];
  end;
  if Result = '' then
    Result := Id;
end;

initialization
  LangInit;

finalization
  FreeAndNil(GLanguages);
  FreeAndNil(GStrings);
  FreeAndNil(GEnglish);

end.
