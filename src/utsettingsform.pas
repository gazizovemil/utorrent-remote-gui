unit UtSettingsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Spin, Rpc, Lang, UtSettingLabels, Utils, LCLType;

type
  { TUtSettingsDialog }

  TUtSettingsDialog = class(TForm)
  private
    FTree: TTreeView;
    FScroll: TScrollBox;
    FContentPanel: TPanel;
    FPanRight: TPanel;
    FPanBottom, FPanBtnRight: TPanel;
    FSplitter: TSplitter;
    FbtnReload, FbtnApply, FbtnClose: TButton;
    FRpc: TuTorrentRpc;
    FNames, FTypes, FValues, FOrig: TStringList;
    FCtrlMap: TStringList;
    FActiveCategory: string;
    procedure BuildUI;
    procedure Reload;
    procedure ApplyClick(Sender: TObject);
    procedure ReloadClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ShowCategory(const CatId: string);
    procedure ClearControls;
    procedure PersistCurrentValues;
    function GetSettingType(const AName: string): string;
    function ControlValue(Ctrl: TControl): string;
    function NormalizeValue(const Typ, V: string): string;
    function HasChanges: Boolean;
    function ApplyChanges(ShowMsg: Boolean): Integer;
    procedure TryClose;
    procedure LayoutContent;
    procedure LayoutBottomButtons;
  public
    class function Execute(ARpc: TuTorrentRpc): Boolean;
  end;

function SettingCategory(const Name: string): string;

implementation

const
  cRowH = 44;
  cLabelW = 420;
  cSpinW = 120;

function StartsWithText(const S, Prefix: string): Boolean;
begin
  Result := (Length(S) >= Length(Prefix)) and
    SameText(Copy(S, 1, Length(Prefix)), Prefix);
end;

function SettingCategory(const Name: string): string;
var
  L: string;
begin
  L := LowerCase(Name);
  if (L = 'locale') or (L = 'check_update') or (L = 'updater') or
     (L = 'confirm_when_deleting') or (L = 'confirm_remove_tracker') or
     (L = 'confirm_exit') or (L = 'confirm_exit_critical_seeding') or
     (L = 'prealloc_space') or (L = 'use_partial_files') or
     (L = 'prevent_standby') or StartsWithText(L, 'boss_') then
    Result := 'general'
  else if StartsWithText(L, 'dir_') or StartsWithText(L, 'move_') then
    Result := 'folders'
  else if StartsWithText(L, 'bind_') or StartsWithText(L, 'proxy_') or
     (L = 'port') or StartsWithText(L, 'port_') or StartsWithText(L, 'ip_') or
     (L = 'upnp') or (L = 'natpmp') or StartsWithText(L, 'net.') or
     (L = 'conns_per_torrent') or (L = 'conns_glob') then
    Result := 'connection'
  else if StartsWithText(L, 'max_') or StartsWithText(L, 'ul_') or
     StartsWithText(L, 'dl_') or (L = 'ulrate') or (L = 'dlrate') or
     (L = 'ulslots') then
    Result := 'bandwidth'
  else if StartsWithText(L, 'dht') or (L = 'pex') or (L = 'lsd') or
     StartsWithText(L, 'bt.') or (L = 'enable_scrape') or (L = 'bt_protocol') or
     (L = 'encryption') or StartsWithText(L, 'enc_') then
    Result := 'bittorrent'
  else if StartsWithText(L, 'queue_') then
    Result := 'queue'
  else if StartsWithText(L, 'sched_') or (L = 'scheduler') or (L = 'sched_enable') then
    Result := 'scheduler'
  else if StartsWithText(L, 'webui_') or StartsWithText(L, 'ulv_') or (L = 'remote') then
    Result := 'remote'
  else if StartsWithText(L, 'gui.') or StartsWithText(L, 'show_') or
     StartsWithText(L, 'detail_') then
    Result := 'ui'
  else
    Result := 'advanced';
end;

function CategoryCaption(const CatId: string): string;
begin
  if CatId = 'general' then Result := _('ut.cat.general')
  else if CatId = 'ui' then Result := _('ut.cat.ui')
  else if CatId = 'folders' then Result := _('ut.cat.folders')
  else if CatId = 'connection' then Result := _('ut.cat.connection')
  else if CatId = 'bandwidth' then Result := _('ut.cat.bandwidth')
  else if CatId = 'bittorrent' then Result := _('ut.cat.bittorrent')
  else if CatId = 'queue' then Result := _('ut.cat.queue')
  else if CatId = 'scheduler' then Result := _('ut.cat.scheduler')
  else if CatId = 'remote' then Result := _('ut.cat.remote')
  else Result := _('ut.cat.advanced');
end;

const
  CategoryOrder: array[0..9] of string = (
    'general', 'ui', 'folders', 'connection', 'bandwidth',
    'bittorrent', 'queue', 'scheduler', 'remote', 'advanced');

function TUtSettingsDialog.GetSettingType(const AName: string): string;
begin
  Result := FTypes.Values[AName];
  if Result = '' then
    Result := '2';
end;

function TUtSettingsDialog.NormalizeValue(const Typ, V: string): string;
var
  Code: Integer;
  N: LongInt;
begin
  if Typ = '1' then
  begin
    if (V = '1') or SameText(V, 'true') then
      Result := '1'
    else
      Result := '0';
  end
  else if Typ = '0' then
  begin
    Val(V, N, Code);
    Result := IntToStr(N);
  end
  else
    Result := V;
end;

procedure TUtSettingsDialog.BuildUI;
begin
  Caption := _('dlg.utsettings');
  Position := poOwnerFormCenter;
  Width := 1024;
  Height := 720;
  BorderStyle := bsSizeable;
  KeyPreview := True;
  Constraints.MinWidth := 800;
  Constraints.MinHeight := 580;
  OnResize := @FormResize;
  OnKeyDown := @FormKeyDown;

  FPanBottom := TPanel.Create(Self);
  FPanBottom.Parent := Self;
  FPanBottom.Align := alBottom;
  FPanBottom.Height := 52;
  FPanBottom.BevelOuter := bvNone;

  FPanBtnRight := TPanel.Create(FPanBottom);
  FPanBtnRight.Parent := FPanBottom;
  FPanBtnRight.Align := alRight;
  FPanBtnRight.Width := 260;
  FPanBtnRight.BevelOuter := bvNone;

  FbtnClose := TButton.Create(FPanBtnRight);
  FbtnClose.Parent := FPanBtnRight;
  FbtnClose.Caption := _('dlg.close');
  FbtnClose.Height := 28;
  FbtnClose.OnClick := @CloseClick;

  FbtnApply := TButton.Create(FPanBtnRight);
  FbtnApply.Parent := FPanBtnRight;
  FbtnApply.Caption := _('dlg.apply');
  FbtnApply.Height := 28;
  FbtnApply.OnClick := @ApplyClick;

  FbtnReload := TButton.Create(FPanBottom);
  FbtnReload.Parent := FPanBottom;
  FbtnReload.Caption := _('act.refresh');
  FbtnReload.Height := 28;
  FbtnReload.SetBounds(12, 12, 100, 28);
  FbtnReload.Anchors := [akLeft, akBottom];
  FbtnReload.OnClick := @ReloadClick;

  LayoutBottomButtons;

  FTree := TTreeView.Create(Self);
  FTree.Parent := Self;
  FTree.Align := alLeft;
  FTree.Width := 220;
  FTree.BorderStyle := bsSingle;
  FTree.HideSelection := False;
  FTree.ReadOnly := True;
  FTree.ShowLines := True;
  FTree.ShowRoot := False;
  FTree.ScrollBars := ssVertical;
  FTree.OnChange := @TreeChange;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alLeft;
  FSplitter.Width := 6;

  FPanRight := TPanel.Create(Self);
  FPanRight.Parent := Self;
  FPanRight.Align := alClient;
  FPanRight.BevelOuter := bvNone;
  FPanRight.Caption := '';

  FScroll := TScrollBox.Create(FPanRight);
  FScroll.Parent := FPanRight;
  FScroll.Align := alClient;
  FScroll.BorderStyle := bsNone;
  FScroll.HorzScrollBar.Visible := False;
  FScroll.AutoScroll := True;
end;

procedure TUtSettingsDialog.LayoutContent;
var
  I, W: Integer;
  Row: TControl;
begin
  if FContentPanel = nil then Exit;
  W := FScroll.ClientWidth - 24;
  if W < 520 then W := 520;
  FContentPanel.Width := W;
  for I := 0 to FContentPanel.ControlCount - 1 do
  begin
    Row := FContentPanel.Controls[I];
    Row.Width := W;
  end;
end;

procedure TUtSettingsDialog.LayoutBottomButtons;
var
  Gap: Integer;
begin
  if (FPanBtnRight = nil) or (FbtnApply = nil) or (FbtnClose = nil) then Exit;
  Gap := 8;
  FitDialogButton(FbtnApply, 110);
  FitDialogButton(FbtnClose, 110);
  FPanBtnRight.Width := FbtnApply.Width + FbtnClose.Width + Gap + 24;
  LayoutRightButtons(FPanBtnRight, [FbtnApply, FbtnClose], 12, 12, Gap, 110);
  if FbtnReload <> nil then
    FitDialogButton(FbtnReload, 110);
end;

procedure TUtSettingsDialog.FormResize(Sender: TObject);
begin
  LayoutContent;
  LayoutBottomButtons;
end;

procedure TUtSettingsDialog.ClearControls;
begin
  if FContentPanel <> nil then
    FreeAndNil(FContentPanel);
  if FCtrlMap <> nil then
    FCtrlMap.Clear;
end;

procedure TUtSettingsDialog.PersistCurrentValues;
var
  I: Integer;
  N, V, T: string;
begin
  if (FCtrlMap = nil) or (FValues = nil) then Exit;
  for I := 0 to FCtrlMap.Count - 1 do
  begin
    N := FCtrlMap[I];
    T := GetSettingType(N);
    V := ControlValue(TControl(FCtrlMap.Objects[I]));
    FValues.Values[N] := NormalizeValue(T, V);
  end;
end;

function TUtSettingsDialog.ControlValue(Ctrl: TControl): string;
begin
  if Ctrl is TCheckBox then
  begin
    if TCheckBox(Ctrl).Checked then
      Result := '1'
    else
      Result := '0';
  end
  else if Ctrl is TSpinEdit then
    Result := IntToStr(TSpinEdit(Ctrl).Value)
  else if Ctrl is TEdit then
    Result := TEdit(Ctrl).Text
  else
    Result := '';
end;

function TUtSettingsDialog.HasChanges: Boolean;
var
  I: Integer;
  N, T, A, B: string;
begin
  PersistCurrentValues;
  Result := False;
  if (FNames = nil) or (FValues = nil) or (FOrig = nil) then Exit;
  for I := 0 to FNames.Count - 1 do
  begin
    N := FNames[I];
    T := GetSettingType(N);
    A := NormalizeValue(T, FValues.Values[N]);
    B := NormalizeValue(T, FOrig.Values[N]);
    if A <> B then
      Exit(True);
  end;
end;

function TUtSettingsDialog.ApplyChanges(ShowMsg: Boolean): Integer;
var
  I, NumChanged, Ok: Integer;
  N, T, V, Old: string;
begin
  PersistCurrentValues;
  Result := 0;
  if not FRpc.Connected then Exit;
  NumChanged := 0;
  Ok := 0;
  for I := 0 to FNames.Count - 1 do
  begin
    N := FNames[I];
    T := GetSettingType(N);
    V := NormalizeValue(T, FValues.Values[N]);
    Old := NormalizeValue(T, FOrig.Values[N]);
    if V <> Old then
    begin
      Inc(NumChanged);
      if FRpc.SetSetting(N, V) then
      begin
        Inc(Ok);
        FOrig.Values[N] := V;
        FValues.Values[N] := V;
      end;
    end;
  end;
  Result := Ok;
  if ShowMsg then
    MessageDlg(Format(_('dlg.utsettings.saved'), [Ok, NumChanged]), mtInformation, [mbOK], 0);
end;

procedure TUtSettingsDialog.TryClose;
var
  R: Integer;
begin
  if not HasChanges then
  begin
    ModalResult := mrCancel;
    Exit;
  end;
  R := MessageDlg(_('dlg.savechanges'), mtConfirmation, [mbYes, mbNo, mbCancel], 0);
  if R = mrCancel then Exit;
  if R = mrYes then
    ApplyChanges(True);
  ModalResult := mrCancel;
end;

procedure TUtSettingsDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    TryClose;
  end;
end;

procedure TUtSettingsDialog.CloseClick(Sender: TObject);
begin
  TryClose;
end;

procedure TUtSettingsDialog.ShowCategory(const CatId: string);
var
  I, Y, Code: Integer;
  N, T, V: string;
  Row: TPanel;
  Lbl: TLabel;
  Ctrl: TControl;
  NVal: LongInt;
  W, CtrlW: Integer;
begin
  PersistCurrentValues;
  FActiveCategory := CatId;
  ClearControls;
  if (FNames = nil) or (FCtrlMap = nil) then Exit;

  W := FScroll.ClientWidth - 24;
  if W < 520 then W := 520;

  FContentPanel := TPanel.Create(FScroll);
  FContentPanel.Parent := FScroll;
  FContentPanel.Left := 0;
  FContentPanel.Top := 0;
  FContentPanel.Width := W;
  FContentPanel.BevelOuter := bvNone;
  FContentPanel.Caption := '';
  FContentPanel.ParentColor := True;

  Y := 0;
  for I := 0 to FNames.Count - 1 do
  begin
    N := FNames[I];
    if SettingCategory(N) <> CatId then
      Continue;
    T := GetSettingType(N);
    V := FValues.Values[N];

    Row := TPanel.Create(FContentPanel);
    Row.Parent := FContentPanel;
    Row.SetBounds(0, Y, W, cRowH);
    Row.BevelOuter := bvNone;
    Row.Caption := '';
    Row.ParentColor := True;

    if T = '1' then
    begin
      Ctrl := TCheckBox.Create(Row);
      Ctrl.Parent := Row;
      TCheckBox(Ctrl).Caption := UtSettingCaption(N);
      TCheckBox(Ctrl).AutoSize := True;
      TCheckBox(Ctrl).SetBounds(8, 10, W - 16, 22);
      TCheckBox(Ctrl).Anchors := [akTop, akLeft, akRight];
      TCheckBox(Ctrl).Checked := (V = '1') or SameText(V, 'true');
      FCtrlMap.AddObject(N, Ctrl);
    end
    else
    begin
      Lbl := TLabel.Create(Row);
      Lbl.Parent := Row;
      Lbl.Caption := UtSettingCaption(N);
      Lbl.SetBounds(8, 0, cLabelW, cRowH);
      Lbl.Layout := tlCenter;
      Lbl.AutoSize := False;
      Lbl.WordWrap := True;

      if T = '0' then
      begin
        Ctrl := TSpinEdit.Create(Row);
        Ctrl.Parent := Row;
        TSpinEdit(Ctrl).SetBounds(cLabelW + 12, 8, cSpinW, 26);
        TSpinEdit(Ctrl).Anchors := [akTop, akLeft];
        TSpinEdit(Ctrl).MinValue := -2147483647;
        TSpinEdit(Ctrl).MaxValue := 2147483647;
        Val(V, NVal, Code);
        TSpinEdit(Ctrl).Value := NVal;
      end
      else
      begin
        CtrlW := W - cLabelW - 28;
        if CtrlW < 160 then CtrlW := 160;
        Ctrl := TEdit.Create(Row);
        Ctrl.Parent := Row;
        TEdit(Ctrl).SetBounds(cLabelW + 12, 8, CtrlW, 26);
        TEdit(Ctrl).Anchors := [akTop, akLeft, akRight];
        TEdit(Ctrl).Text := V;
      end;
      FCtrlMap.AddObject(N, Ctrl);
    end;

    Inc(Y, cRowH);
  end;

  FContentPanel.Height := Y + 8;
  FScroll.VertScrollBar.Range := FContentPanel.Height + 16;
end;

procedure TUtSettingsDialog.TreeChange(Sender: TObject; Node: TTreeNode);
var
  Idx: Integer;
begin
  if Node = nil then Exit;
  Idx := PtrInt(Node.Data);
  if (Idx < 0) or (Idx > High(CategoryOrder)) then Exit;
  ShowCategory(CategoryOrder[Idx]);
end;

procedure TUtSettingsDialog.Reload;
var
  I, J: Integer;
  Cat: string;
  Counts: array[0..9] of Integer;
  Node: TTreeNode;
  SelCat: string;
  TmpNames, TmpTypes, TmpValues: TStringList;
begin
  PersistCurrentValues;
  ClearControls;
  FTree.Items.Clear;
  if FNames <> nil then FreeAndNil(FNames);
  if FTypes <> nil then FreeAndNil(FTypes);
  if FValues <> nil then FreeAndNil(FValues);
  if FOrig <> nil then FreeAndNil(FOrig);
  FNames := TStringList.Create;
  FTypes := TStringList.Create;
  FValues := TStringList.Create;
  FOrig := TStringList.Create;
  if FCtrlMap = nil then
    FCtrlMap := TStringList.Create
  else
    FCtrlMap.Clear;

  if not FRpc.Connected then
  begin
    MessageDlg(_('status.noconnect'), mtInformation, [mbOK], 0);
    Exit;
  end;
  TmpNames := nil;
  TmpTypes := nil;
  TmpValues := nil;
  if not FRpc.GetSettings(TmpNames, TmpTypes, TmpValues) then
  begin
    MessageDlg(Format(_('msg.error'), [FRpc.LastError]), mtError, [mbOK], 0);
    Exit;
  end;
  try
    FNames.Assign(TmpNames);
    for I := 0 to FNames.Count - 1 do
    begin
      FTypes.Add(FNames[I]);
      FValues.Add(FNames[I]);
      FTypes.Values[FNames[I]] := TmpTypes[I];
      FValues.Values[FNames[I]] := TmpValues[I];
      FOrig.Values[FNames[I]] := TmpValues[I];
    end;
  finally
    TmpNames.Free;
    TmpTypes.Free;
    TmpValues.Free;
  end;

  for I := 0 to High(Counts) do
    Counts[I] := 0;
  for I := 0 to FNames.Count - 1 do
  begin
    Cat := SettingCategory(FNames[I]);
    for J := 0 to High(CategoryOrder) do
      if CategoryOrder[J] = Cat then
      begin
        Inc(Counts[J]);
        Break;
      end;
  end;

  SelCat := FActiveCategory;
  FTree.Items.BeginUpdate;
  try
    for J := 0 to High(CategoryOrder) do
    begin
      if Counts[J] = 0 then Continue;
      Node := FTree.Items.Add(nil, CategoryCaption(CategoryOrder[J]));
      Node.Data := Pointer(PtrInt(J));
      if SelCat = CategoryOrder[J] then
        FTree.Selected := Node;
    end;
    if (FTree.Selected = nil) and (FTree.Items.Count > 0) then
      FTree.Selected := FTree.Items[0];
  finally
    FTree.Items.EndUpdate;
  end;

  if FTree.Selected <> nil then
    TreeChange(nil, FTree.Selected);
end;

procedure TUtSettingsDialog.ReloadClick(Sender: TObject);
begin
  if HasChanges then
  begin
    if MessageDlg(_('dlg.reload.discard'), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;
  end;
  Reload;
end;

procedure TUtSettingsDialog.ApplyClick(Sender: TObject);
begin
  ApplyChanges(True);
end;

class function TUtSettingsDialog.Execute(ARpc: TuTorrentRpc): Boolean;
var
  D: TUtSettingsDialog;
begin
  Result := False;
  if (ARpc = nil) or not ARpc.Connected then
  begin
    MessageDlg(_('status.noconnect'), mtInformation, [mbOK], 0);
    Exit;
  end;
  D := TUtSettingsDialog.CreateNew(Application);
  try
    D.FRpc := ARpc;
    D.FNames := nil;
    D.FTypes := nil;
    D.FValues := nil;
    D.FOrig := nil;
    D.FCtrlMap := nil;
    D.FContentPanel := nil;
    D.FActiveCategory := '';
    D.BuildUI;
    D.Reload;
    D.ShowModal;
    Result := True;
  finally
    D.ClearControls;
    FreeAndNil(D.FCtrlMap);
    FreeAndNil(D.FNames);
    FreeAndNil(D.FTypes);
    FreeAndNil(D.FValues);
    FreeAndNil(D.FOrig);
    D.Free;
  end;
end;

end.
