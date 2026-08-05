unit AppSettingsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Spin, Profiles, Lang, Utils, LCLType;

type
  { TAppSettingsDialog }

  TAppSettingsDialog = class(TForm)
  private
    FPages: TPageControl;
    FtsGeneral, FtsAdvanced, FtsProxy, FtsPaths: TTabSheet;
    FedRefresh, FedRefreshMin, FedFont: TSpinEdit;
    FchkDeleteTorrent: TCheckBox;
    FchkMinTray, FchkCloseTray, FchkAlwaysTray, FchkTrayNotify: TCheckBox;
    FchkProxy, FchkProxyAuth: TCheckBox;
    FedProxyHost, FedProxyUser, FedProxyPass: TEdit;
    FedProxyPort: TSpinEdit;
    FmemPaths: TMemo;
    FbtnOK, FbtnCancel: TButton;
    FSnap: TProfileList;
    procedure BuildUI;
    procedure LoadFrom(P: TProfileList);
    procedure SaveTo(P: TProfileList);
    procedure ProxyCheckClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TryClose;
    function HasChanges: Boolean;
    procedure LayoutScrollTab(Tab: TTabSheet);
    procedure LayoutGroupBox(G: TGroupBox);
    procedure LayoutBottomButtons;
    procedure AddSpinRow(AHost: TWinControl; var Y: Integer; const Cap: string; SE: TSpinEdit);
    procedure AddCheck(AHost: TWinControl; var Y: Integer; CB: TCheckBox);
    procedure AddEditRow(AHost: TWinControl; var Y: Integer; const Cap: string; E: TEdit;
      EditW: Integer = 280);
    function FinishGroup(G: TGroupBox; Y: Integer): Integer;
  public
    class function Execute(P: TProfileList): Boolean;
  end;

implementation

const
  cRowH = 48;
  cPad = 12;
  cLabelW = 400;
  cEditW = 96;
  cGrpCap = 24;

procedure TAppSettingsDialog.AddSpinRow(AHost: TWinControl; var Y: Integer;
  const Cap: string; SE: TSpinEdit);
var
  L: TLabel;
begin
  L := TLabel.Create(AHost);
  L.Parent := AHost;
  L.Caption := Cap;
  L.AutoSize := False;
  L.SetBounds(cPad, Y + 14, cLabelW, 22);
  L.Anchors := [akTop, akLeft];
  SE.Parent := AHost;
  SE.SetBounds(cPad + cLabelW + 8, Y + 10, cEditW, 26);
  SE.Anchors := [akTop, akLeft];
  Inc(Y, cRowH);
end;

procedure TAppSettingsDialog.AddEditRow(AHost: TWinControl; var Y: Integer;
  const Cap: string; E: TEdit; EditW: Integer);
var
  L: TLabel;
begin
  if EditW < 120 then EditW := 120;
  L := TLabel.Create(AHost);
  L.Parent := AHost;
  L.Caption := Cap;
  L.AutoSize := False;
  L.SetBounds(cPad, Y + 14, cLabelW, 22);
  L.Anchors := [akTop, akLeft];
  E.Parent := AHost;
  E.Tag := EditW;
  E.SetBounds(cPad + cLabelW + 8, Y + 10, EditW, 26);
  E.Anchors := [akTop, akLeft];
  Inc(Y, cRowH);
end;

procedure TAppSettingsDialog.AddCheck(AHost: TWinControl; var Y: Integer;
  CB: TCheckBox);
begin
  CB.Parent := AHost;
  CB.AutoSize := True;
  CB.SetBounds(cPad, Y + 12, AHost.ClientWidth - cPad * 2, 22);
  CB.Anchors := [akTop, akLeft, akRight];
  Inc(Y, cRowH);
end;

function TAppSettingsDialog.FinishGroup(G: TGroupBox; Y: Integer): Integer;
begin
  G.Height := Y + cPad + cGrpCap;
  Result := G.Top + G.Height + 8;
end;

procedure TAppSettingsDialog.LayoutGroupBox(G: TGroupBox);
var
  I, W, EditW: Integer;
  C: TControl;
begin
  W := G.ClientWidth;
  if W < 300 then Exit;
  for I := 0 to G.ControlCount - 1 do
  begin
    C := G.Controls[I];
    if C is TLabel then
      TLabel(C).SetBounds(cPad, C.Top, cLabelW, 22)
    else if C is TSpinEdit then
      TSpinEdit(C).SetBounds(cPad + cLabelW + 8, C.Top, cEditW, 26)
    else if C is TEdit then
    begin
      EditW := TEdit(C).Tag;
      if EditW < 120 then EditW := 280;
      if EditW > W - cLabelW - cPad * 2 then
        EditW := W - cLabelW - cPad * 2;
      TEdit(C).SetBounds(cPad + cLabelW + 8, C.Top, EditW, 26);
    end
    else if C is TCheckBox then
      TCheckBox(C).Width := W - cPad * 2;
  end;
end;

procedure TAppSettingsDialog.LayoutScrollTab(Tab: TTabSheet);
var
  I, J: Integer;
  SB: TScrollBox;
  G: TGroupBox;
begin
  if Tab = nil then Exit;
  for I := 0 to Tab.ControlCount - 1 do
  begin
    if not (Tab.Controls[I] is TScrollBox) then Continue;
    SB := TScrollBox(Tab.Controls[I]);
    for J := 0 to SB.ControlCount - 1 do
    begin
      if SB.Controls[J] is TGroupBox then
      begin
        G := TGroupBox(SB.Controls[J]);
        G.Width := SB.ClientWidth - 16;
        LayoutGroupBox(G);
      end;
    end;
  end;
end;

procedure TAppSettingsDialog.LayoutBottomButtons;
begin
  if (FbtnOK = nil) or (FbtnCancel = nil) then Exit;
  LayoutRightButtons(FbtnOK.Parent, [FbtnOK, FbtnCancel], 12, 12, 8, 100);
end;

procedure TAppSettingsDialog.FormResize(Sender: TObject);
begin
  if FPages = nil then Exit;
  LayoutScrollTab(FtsGeneral);
  LayoutScrollTab(FtsAdvanced);
  LayoutScrollTab(FtsProxy);
  LayoutBottomButtons;
end;

function TAppSettingsDialog.HasChanges: Boolean;
var
  Tmp: TProfileList;
begin
  Result := False;
  if FSnap = nil then Exit;
  Tmp := TProfileList.Create;
  try
    SaveTo(Tmp);
    Result :=
      (Tmp.RefreshInterval <> FSnap.RefreshInterval) or
      (Tmp.RefreshMinimized <> FSnap.RefreshMinimized) or
      (Tmp.FontSizePercent <> FSnap.FontSizePercent) or
      (Tmp.DeleteTorrentAfterAdd <> FSnap.DeleteTorrentAfterAdd) or
      (Tmp.MinimizeToTray <> FSnap.MinimizeToTray) or
      (Tmp.CloseToTray <> FSnap.CloseToTray) or
      (Tmp.AlwaysShowTray <> FSnap.AlwaysShowTray) or
      (Tmp.TrayNotify <> FSnap.TrayNotify) or
      (Tmp.ProxyEnabled <> FSnap.ProxyEnabled) or
      (Tmp.ProxyHost <> FSnap.ProxyHost) or
      (Tmp.ProxyPort <> FSnap.ProxyPort) or
      (Tmp.ProxyUser <> FSnap.ProxyUser) or
      (Tmp.ProxyPass <> FSnap.ProxyPass) or
      (Tmp.PathMap <> FSnap.PathMap);
  finally
    Tmp.Free;
  end;
end;

procedure TAppSettingsDialog.TryClose;
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
    ModalResult := mrOK
  else
    ModalResult := mrCancel;
end;

procedure TAppSettingsDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    TryClose;
  end;
end;

procedure TAppSettingsDialog.BuildUI;
var
  PanBottom: TPanel;
  Scroll: TScrollBox;
  G: TGroupBox;
  Y, TopY: Integer;
begin
  Caption := _('dlg.appsettings');
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  KeyPreview := True;
  ClientWidth := 760;
  ClientHeight := 620;
  Constraints.MinWidth := 680;
  Constraints.MinHeight := 500;
  OnResize := @FormResize;
  OnKeyDown := @FormKeyDown;

  PanBottom := TPanel.Create(Self);
  PanBottom.Parent := Self;
  PanBottom.Align := alBottom;
  PanBottom.Height := 52;
  PanBottom.BevelOuter := bvNone;

  FbtnCancel := TButton.Create(PanBottom);
  FbtnCancel.Parent := PanBottom;
  FbtnCancel.Caption := _('dlg.cancel');
  FbtnCancel.ModalResult := mrCancel;
  FbtnCancel.Height := 28;
  FbtnCancel.Anchors := [akTop, akRight];

  FbtnOK := TButton.Create(PanBottom);
  FbtnOK.Parent := PanBottom;
  FbtnOK.Caption := _('dlg.ok');
  FbtnOK.ModalResult := mrOK;
  FbtnOK.Height := 28;
  FbtnOK.Anchors := [akTop, akRight];

  FPages := TPageControl.Create(Self);
  FPages.Parent := Self;
  FPages.Align := alClient;

  { --- General --- }
  FtsGeneral := TTabSheet.Create(FPages);
  FtsGeneral.PageControl := FPages;
  FtsGeneral.Caption := _('tab.general');

  Scroll := TScrollBox.Create(FtsGeneral);
  Scroll.Parent := FtsGeneral;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.HorzScrollBar.Visible := False;
  Scroll.AutoScroll := True;

  TopY := 8;
  G := TGroupBox.Create(Scroll);
  G.Parent := Scroll;
  G.Caption := _('dlg.app.display');
  G.SetBounds(8, TopY, Scroll.ClientWidth - 16, 100);
  G.Anchors := [akTop, akLeft, akRight];
  Y := 16;
  FedRefresh := TSpinEdit.Create(G);
  FedRefresh.MinValue := 1;
  FedRefresh.MaxValue := 3600;
  AddSpinRow(G, Y, _('dlg.app.refresh'), FedRefresh);
  FedRefreshMin := TSpinEdit.Create(G);
  FedRefreshMin.MinValue := 1;
  FedRefreshMin.MaxValue := 3600;
  AddSpinRow(G, Y, _('dlg.app.refreshmin'), FedRefreshMin);
  FedFont := TSpinEdit.Create(G);
  FedFont.MinValue := 50;
  FedFont.MaxValue := 200;
  AddSpinRow(G, Y, _('dlg.app.fontsize'), FedFont);
  TopY := FinishGroup(G, Y);

  G := TGroupBox.Create(Scroll);
  G.Parent := Scroll;
  G.Caption := _('dlg.app.addtorrent');
  G.SetBounds(8, TopY, Scroll.ClientWidth - 16, 80);
  G.Anchors := [akTop, akLeft, akRight];
  FchkDeleteTorrent := TCheckBox.Create(G);
  FchkDeleteTorrent.Caption := _('dlg.app.deletetorrent');
  Y := 16;
  AddCheck(G, Y, FchkDeleteTorrent);
  FinishGroup(G, Y);

  { --- Advanced --- }
  FtsAdvanced := TTabSheet.Create(FPages);
  FtsAdvanced.PageControl := FPages;
  FtsAdvanced.Caption := _('dlg.app.advanced');

  Scroll := TScrollBox.Create(FtsAdvanced);
  Scroll.Parent := FtsAdvanced;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.HorzScrollBar.Visible := False;
  Scroll.AutoScroll := True;

  G := TGroupBox.Create(Scroll);
  G.Parent := Scroll;
  G.Caption := _('dlg.app.tray');
  G.SetBounds(8, 8, Scroll.ClientWidth - 16, 100);
  G.Anchors := [akTop, akLeft, akRight];
  Y := 16;
  FchkMinTray := TCheckBox.Create(G);
  FchkMinTray.Caption := _('dlg.app.mintray');
  AddCheck(G, Y, FchkMinTray);
  FchkCloseTray := TCheckBox.Create(G);
  FchkCloseTray.Caption := _('dlg.app.closetray');
  AddCheck(G, Y, FchkCloseTray);
  FchkAlwaysTray := TCheckBox.Create(G);
  FchkAlwaysTray.Caption := _('dlg.app.alwaystray');
  AddCheck(G, Y, FchkAlwaysTray);
  FchkTrayNotify := TCheckBox.Create(G);
  FchkTrayNotify.Caption := _('dlg.app.traynotify');
  AddCheck(G, Y, FchkTrayNotify);
  FinishGroup(G, Y);

  { --- Proxy --- }
  FtsProxy := TTabSheet.Create(FPages);
  FtsProxy.PageControl := FPages;
  FtsProxy.Caption := _('dlg.app.proxy');

  Scroll := TScrollBox.Create(FtsProxy);
  Scroll.Parent := FtsProxy;
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  Scroll.HorzScrollBar.Visible := False;
  Scroll.AutoScroll := True;

  G := TGroupBox.Create(Scroll);
  G.Parent := Scroll;
  G.Caption := _('dlg.app.proxy');
  G.SetBounds(8, 8, Scroll.ClientWidth - 16, 100);
  G.Anchors := [akTop, akLeft, akRight];
  Y := 16;
  FchkProxy := TCheckBox.Create(G);
  FchkProxy.Caption := _('dlg.app.proxyenable');
  FchkProxy.OnClick := @ProxyCheckClick;
  AddCheck(G, Y, FchkProxy);
  FedProxyHost := TEdit.Create(G);
  AddEditRow(G, Y, _('dlg.app.proxyhost'), FedProxyHost, 280);
  FedProxyPort := TSpinEdit.Create(G);
  FedProxyPort.MinValue := 1;
  FedProxyPort.MaxValue := 65535;
  AddSpinRow(G, Y, _('dlg.app.proxyport'), FedProxyPort);
  FchkProxyAuth := TCheckBox.Create(G);
  FchkProxyAuth.Caption := _('dlg.app.proxyauth');
  FchkProxyAuth.OnClick := @ProxyCheckClick;
  AddCheck(G, Y, FchkProxyAuth);
  FedProxyUser := TEdit.Create(G);
  AddEditRow(G, Y, _('dlg.profiles.user'), FedProxyUser, 280);
  FedProxyPass := TEdit.Create(G);
  FedProxyPass.EchoMode := emPassword;
  AddEditRow(G, Y, _('dlg.profiles.password'), FedProxyPass, 280);
  FinishGroup(G, Y);

  { --- Paths --- }
  FtsPaths := TTabSheet.Create(FPages);
  FtsPaths.PageControl := FPages;
  FtsPaths.Caption := _('dlg.app.paths');
  G := TGroupBox.Create(FtsPaths);
  G.Parent := FtsPaths;
  G.Caption := _('dlg.app.pathmap.help');
  G.Align := alClient;
  G.BorderSpacing.Around := 8;
  FmemPaths := TMemo.Create(G);
  FmemPaths.Parent := G;
  FmemPaths.Align := alClient;
  FmemPaths.BorderSpacing.Around := 8;
  FmemPaths.ScrollBars := ssAutoBoth;
  FmemPaths.Font.Name := 'Consolas';
  LayoutBottomButtons;
end;

procedure TAppSettingsDialog.ProxyCheckClick(Sender: TObject);
var
  En: Boolean;
begin
  En := FchkProxy.Checked;
  FedProxyHost.Enabled := En;
  FedProxyPort.Enabled := En;
  FchkProxyAuth.Enabled := En;
  FedProxyUser.Enabled := En and FchkProxyAuth.Checked;
  FedProxyPass.Enabled := En and FchkProxyAuth.Checked;
end;

procedure TAppSettingsDialog.LoadFrom(P: TProfileList);
begin
  FedRefresh.Value := P.RefreshInterval;
  FedRefreshMin.Value := P.RefreshMinimized;
  FedFont.Value := P.FontSizePercent;
  FchkDeleteTorrent.Checked := P.DeleteTorrentAfterAdd;
  FchkMinTray.Checked := P.MinimizeToTray;
  FchkCloseTray.Checked := P.CloseToTray;
  FchkAlwaysTray.Checked := P.AlwaysShowTray;
  FchkTrayNotify.Checked := P.TrayNotify;
  FchkProxy.Checked := P.ProxyEnabled;
  FedProxyHost.Text := P.ProxyHost;
  FedProxyPort.Value := P.ProxyPort;
  FchkProxyAuth.Checked := (P.ProxyUser <> '') or (P.ProxyPass <> '');
  FedProxyUser.Text := P.ProxyUser;
  FedProxyPass.Text := P.ProxyPass;
  if Trim(P.PathMap) <> '' then
    FmemPaths.Text := P.PathMap
  else
    FmemPaths.Text := '';
  ProxyCheckClick(nil);
end;

procedure TAppSettingsDialog.SaveTo(P: TProfileList);
begin
  P.RefreshInterval := FedRefresh.Value;
  P.RefreshMinimized := FedRefreshMin.Value;
  P.FontSizePercent := FedFont.Value;
  P.DeleteTorrentAfterAdd := FchkDeleteTorrent.Checked;
  P.MinimizeToTray := FchkMinTray.Checked;
  P.CloseToTray := FchkCloseTray.Checked;
  P.AlwaysShowTray := FchkAlwaysTray.Checked;
  P.TrayNotify := FchkTrayNotify.Checked;
  P.ProxyEnabled := FchkProxy.Checked;
  P.ProxyHost := Trim(FedProxyHost.Text);
  P.ProxyPort := FedProxyPort.Value;
  if FchkProxyAuth.Checked then
  begin
    P.ProxyUser := FedProxyUser.Text;
    P.ProxyPass := FedProxyPass.Text;
  end
  else
  begin
    P.ProxyUser := '';
    P.ProxyPass := '';
  end;
  P.PathMap := Trim(FmemPaths.Text);
end;

class function TAppSettingsDialog.Execute(P: TProfileList): Boolean;
var
  D: TAppSettingsDialog;
begin
  D := TAppSettingsDialog.CreateNew(Application);
  try
    D.FSnap := TProfileList.Create;
    D.FSnap.RefreshInterval := P.RefreshInterval;
    D.FSnap.RefreshMinimized := P.RefreshMinimized;
    D.FSnap.FontSizePercent := P.FontSizePercent;
    D.FSnap.DeleteTorrentAfterAdd := P.DeleteTorrentAfterAdd;
    D.FSnap.MinimizeToTray := P.MinimizeToTray;
    D.FSnap.CloseToTray := P.CloseToTray;
    D.FSnap.AlwaysShowTray := P.AlwaysShowTray;
    D.FSnap.TrayNotify := P.TrayNotify;
    D.FSnap.ProxyEnabled := P.ProxyEnabled;
    D.FSnap.ProxyHost := P.ProxyHost;
    D.FSnap.ProxyPort := P.ProxyPort;
    D.FSnap.ProxyUser := P.ProxyUser;
    D.FSnap.ProxyPass := P.ProxyPass;
    D.FSnap.PathMap := P.PathMap;
    D.BuildUI;
    D.LoadFrom(P);
    D.FormResize(nil);
    Result := D.ShowModal = mrOK;
    if Result then
      D.SaveTo(P);
  finally
    D.FSnap.Free;
    D.Free;
  end;
end;

end.
