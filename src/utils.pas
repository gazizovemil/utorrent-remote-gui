unit Utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RegExpr, Graphics, StdCtrls, Controls, Forms, Lang;

procedure FitDialogButton(B: TButton; MinWidth: Integer = 100);
procedure LayoutRightButtons(Parent: TWinControl; const Btns: array of TButton;
  Top, RightMargin, Gap: Integer; MinWidth: Integer = 100);

function FormatByteSize(Bytes: Int64): string;
function FormatSpeed(BytesPerSec: Int64): string;
function FormatETA(Seconds: Int64): string;
function FormatPercent(ProgressPerMille: Int64): string;
function FormatRatio(RatioTimes1000: Int64): string;
procedure ExtractURLs(const Text: string; URLs: TStrings);
function OpenURLInBrowser(const URL: string): Boolean;
function OpenLocalPath(const APath: string): Boolean;
function EncodeURLComponent(const S: string): string;
function ConfigFilePath: string;
function GetLikeColor(Color: TColor; Delta: Integer): TColor;

implementation

{$IFDEF WINDOWS}
uses
  Windows, ShellAPI;
{$ELSE}
uses
  Process, LCLIntf;
{$ENDIF}

procedure FitDialogButton(B: TButton; MinWidth: Integer);
var
  W: Integer;
  F: TCustomForm;
begin
  W := MinWidth;
  F := GetParentForm(B);
  if F <> nil then
    W := F.Canvas.TextWidth(B.Caption) + 24;
  if W < MinWidth then
    W := MinWidth;
  B.Width := W;
end;

procedure LayoutRightButtons(Parent: TWinControl; const Btns: array of TButton;
  Top, RightMargin, Gap: Integer; MinWidth: Integer);
var
  I, X, TotalW: Integer;
begin
  TotalW := 0;
  for I := 0 to High(Btns) do
  begin
    FitDialogButton(Btns[I], MinWidth);
    if I > 0 then
      Inc(TotalW, Gap);
    Inc(TotalW, Btns[I].Width);
  end;
  X := Parent.ClientWidth - RightMargin - TotalW;
  for I := 0 to High(Btns) do
  begin
    Btns[I].SetBounds(X, Top, Btns[I].Width, Btns[I].Height);
    Inc(X, Btns[I].Width + Gap);
  end;
end;

function FormatByteSize(Bytes: Int64): string;
const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * 1024;
  TB = GB * 1024;
begin
  if Bytes < 0 then
    Bytes := 0;
  if Bytes >= TB then
    Result := Format('%.2f %s', [Bytes / TB, _('unit.tb')])
  else if Bytes >= GB then
    Result := Format('%.2f %s', [Bytes / GB, _('unit.gb')])
  else if Bytes >= MB then
    Result := Format('%.2f %s', [Bytes / MB, _('unit.mb')])
  else if Bytes >= KB then
    Result := Format('%.1f %s', [Bytes / KB, _('unit.kb')])
  else
    Result := Format('%d %s', [Bytes, _('unit.b')]);
end;

function FormatSpeed(BytesPerSec: Int64): string;
begin
  if BytesPerSec <= 0 then
    Result := Format('0 %s', [_('unit.bps')])
  else
    Result := FormatByteSize(BytesPerSec) + _('unit.per.sec');
end;

function FormatETA(Seconds: Int64): string;
var
  D, H, M, S: Int64;
begin
  if (Seconds < 0) or (Seconds >= 8640000) then
  begin
    Result := '';
    Exit;
  end;
  D := Seconds div 86400;
  H := (Seconds mod 86400) div 3600;
  M := (Seconds mod 3600) div 60;
  S := Seconds mod 60;
  if D > 0 then
    Result := Format('%dd %dh', [D, H])
  else if H > 0 then
    Result := Format('%dh %dm', [H, M])
  else if M > 0 then
    Result := Format('%dm %ds', [M, S])
  else
    Result := Format('%ds', [S]);
end;

function FormatPercent(ProgressPerMille: Int64): string;
begin
  // uTorrent progress is in 1/10 of a percent (1000 = 100.0%)
  Result := Format('%.1f%%', [ProgressPerMille / 10.0]);
end;

function FormatRatio(RatioTimes1000: Int64): string;
begin
  Result := Format('%.3f', [RatioTimes1000 / 1000.0]);
end;

procedure ExtractURLs(const Text: string; URLs: TStrings);
var
  Re: TRegExpr;
  U: string;
begin
  URLs.Clear;
  if Trim(Text) = '' then
    Exit;
  Re := TRegExpr.Create;
  try
    Re.Expression := 'https?://[^\s<>"''\]\)]+';
    Re.ModifierI := True;
    if Re.Exec(Text) then
    begin
      repeat
        U := Re.Match[0];
        while (Length(U) > 0) and (U[Length(U)] in ['.', ',', ';', ':', '!', '?']) do
          SetLength(U, Length(U) - 1);
        if (U <> '') and (URLs.IndexOf(U) < 0) then
          URLs.Add(U);
      until not Re.ExecNext;
    end;
  finally
    Re.Free;
  end;
end;

function OpenURLInBrowser(const URL: string): Boolean;
begin
  if Trim(URL) = '' then
    Exit(False);
{$IFDEF WINDOWS}
  Result := ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL) > 32;
{$ELSE}
  Result := OpenURL(URL);
{$ENDIF}
end;

function OpenLocalPath(const APath: string): Boolean;
var
  P: string;
begin
  P := Trim(APath);
  if P = '' then
    Exit(False);
{$IFDEF WINDOWS}
  if DirectoryExists(P) or FileExists(P) then
    Result := ShellExecute(0, 'open', PChar(P), nil, nil, SW_SHOWNORMAL) > 32
  else
    Result := False;
{$ELSE}
  Result := OpenURL(P);
{$ENDIF}
end;

function EncodeURLComponent(const S: string): string;
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

function ConfigFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'utorrentgui.ini';
end;

function AddToChannel(Clr: TColor; Value: Integer; Position: Byte): TColor;
var
  I: Integer;
begin
  I := (Clr shr (Position * 8)) and $FF;
  I := I + Value;
  if I < 0 then I := 0;
  if I > $FF then I := $FF;
  Result := Clr and (not (Cardinal($FF) shl (Position * 8))) or (Cardinal(I) shl (Position * 8));
end;

function AddToColor(Color: TColor; R, G, B: Integer): TColor;
begin
  Result := ColorToRGB(Color);
  Result := AddToChannel(Result, R, 0);
  Result := AddToChannel(Result, G, 1);
  Result := AddToChannel(Result, B, 2);
end;

function GetLikeColor(Color: TColor; Delta: Integer): TColor;
var
  I, J: Integer;
begin
  // Same algorithm as Transmission Remote GUI
  Result := ColorToRGB(Color);
  J := Result and $FF;
  I := (Result shr 8) and $FF;
  if I > J then
    J := I;
  I := ((Result shr 16) and $FF) shr 1;
  if I > J then
    J := I;
  if J < $80 then
    I := (($80 - J) div $20 + 1) * Delta
  else
    I := Delta;
  if (I + J > 255) or (I + J < 0) then
    I := -Delta;
  Result := AddToColor(Result, I, I, I);
end;

end.
