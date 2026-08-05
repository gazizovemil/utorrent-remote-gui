unit UtSettingLabels;

{$mode objfpc}{$H+}

interface

procedure UtSettingLabelsReload;
function UtSettingCaption(const Name: string): string;

implementation

uses
  Classes, SysUtils, IniFiles, Lang;

var
  GLabels: TStringList;

procedure LoadLabelFile(const FileName: string; Dest: TStringList);
var
  Ini: TMemIniFile;
  SL, Secs, Items: TStringList;
  I, J: Integer;
  Sec, Key, Val: string;
begin
  if not FileExists(FileName) then Exit;
  Ini := TMemIniFile.Create(FileName);
  try
    Items := TStringList.Create;
    Secs := TStringList.Create;
    try
      Ini.ReadSectionValues('Strings', Items);
      if Items.Count = 0 then
      begin
        Ini.ReadSections(Secs);
        for I := 0 to Secs.Count - 1 do
        begin
          Sec := Secs[I];
          if SameText(Sec, 'Meta') then Continue;
          SL := TStringList.Create;
          try
            Ini.ReadSectionValues(Sec, SL);
            Items.AddStrings(SL);
          finally
            SL.Free;
          end;
        end;
      end;
      for J := 0 to Items.Count - 1 do
      begin
        Key := LowerCase(Trim(Items.Names[J]));
        Val := Items.ValueFromIndex[J];
        if (Key <> '') and (Val <> '') then
          Dest.Values[Key] := Val;
      end;
    finally
      Items.Free;
      Secs.Free;
    end;
  finally
    Ini.Free;
  end;
end;

function HumanizeSettingName(const Name: string): string;
var
  S, Word: string;
  I, Start: Integer;
  InWord: Boolean;

  function UpFirst(const W: string): string;
  begin
    if W = '' then
      Exit('');
    Result := UpperCase(Copy(W, 1, 1)) + LowerCase(Copy(W, 2, MaxInt));
  end;

begin
  S := Name;
  Result := '';
  InWord := False;
  Start := 1;
  for I := 1 to Length(S) do
  begin
    if (S[I] = '_') or (S[I] = '.') then
    begin
      if InWord then
      begin
        Word := Copy(S, Start, I - Start);
        if Result <> '' then Result := Result + ' ';
        Result := Result + UpFirst(Word);
        InWord := False;
      end;
    end
    else if not InWord then
    begin
      Start := I;
      InWord := True;
    end;
  end;
  if InWord then
  begin
    Word := Copy(S, Start, MaxInt);
    if Result <> '' then Result := Result + ' ';
    Result := Result + UpFirst(Word);
  end;
  if Result = '' then
    Result := Name;
end;

procedure UtSettingLabelsReload;
var
  Fn: string;
begin
  if GLabels = nil then
  begin
    GLabels := TStringList.Create;
    GLabels.NameValueSeparator := '=';
  end;
  GLabels.Clear;
  Fn := IncludeTrailingPathDelimiter(LangDir) + 'utsettings_' + GetAppLanguageCode + '.lng';
  LoadLabelFile(Fn, GLabels);
  if GLabels.Count = 0 then
  begin
    Fn := IncludeTrailingPathDelimiter(LangDir) + 'utsettings_en.lng';
    LoadLabelFile(Fn, GLabels);
  end;
end;

function UtSettingCaption(const Name: string): string;
var
  K: string;
begin
  if GLabels = nil then
    UtSettingLabelsReload;
  K := LowerCase(Name);
  Result := GLabels.Values[K];
  if Result = '' then
    Result := HumanizeSettingName(Name);
end;

finalization
  FreeAndNil(GLabels);

end.