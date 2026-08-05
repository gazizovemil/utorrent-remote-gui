unit ConnForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, Buttons, Profiles, Lang;

type
  { TConnDialog }

  TConnDialog = class(TForm)
    btnAdd: TButton;
    btnCancel: TButton;
    btnDelete: TButton;
    btnOK: TButton;
    chkAutoConnect: TCheckBox;
    chkHTTPS: TCheckBox;
    edtHost: TEdit;
    edtName: TEdit;
    edtPassword: TEdit;
    edtUser: TEdit;
    lblHost: TLabel;
    lblList: TLabel;
    lblName: TLabel;
    lblPassword: TLabel;
    lblPort: TLabel;
    lblUser: TLabel;
    lstProfiles: TListBox;
    PanelBottom: TPanel;
    PanelEdit: TPanel;
    PanelList: TPanel;
    sePort: TSpinEdit;
    Splitter1: TSplitter;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstProfilesClick(Sender: TObject);
  private
    FProfiles: TProfileList;
    FLoading: Boolean;
    procedure ApplyLanguage;
    procedure LoadList;
    procedure SaveCurrentToList;
    procedure ShowProfile(Index: Integer);
  public
    function Execute(Profiles: TProfileList): Boolean;
  end;

implementation

{$R *.lfm}

{ TConnDialog }

procedure TConnDialog.FormCreate(Sender: TObject);
begin
  Position := poScreenCenter;
  BorderStyle := bsSizeable;
  Constraints.MinWidth := 520;
  Constraints.MinHeight := 320;
  FLoading := False;
end;

procedure TConnDialog.ApplyLanguage;
begin
  Caption := _('dlg.profiles');
  lblList.Caption := _('dlg.profiles.list');
  lblName.Caption := _('dlg.profiles.name');
  lblHost.Caption := _('dlg.profiles.host');
  lblPort.Caption := _('dlg.profiles.port');
  lblUser.Caption := _('dlg.profiles.user');
  lblPassword.Caption := _('dlg.profiles.password');
  chkHTTPS.Caption := _('dlg.profiles.https');
  chkAutoConnect.Caption := _('dlg.profiles.autoconnect');
  btnAdd.Caption := _('dlg.profiles.add');
  btnDelete.Caption := _('dlg.profiles.delete');
  btnOK.Caption := _('dlg.ok');
  btnCancel.Caption := _('dlg.cancel');
end;

procedure TConnDialog.LoadList;
var
  I, Sel: Integer;
begin
  Sel := FProfiles.ActiveIndex;
  lstProfiles.Items.BeginUpdate;
  try
    lstProfiles.Clear;
    for I := 0 to FProfiles.Count - 1 do
      lstProfiles.Items.Add(FProfiles[I].Name);
  finally
    lstProfiles.Items.EndUpdate;
  end;
  if (Sel >= 0) and (Sel < lstProfiles.Items.Count) then
    lstProfiles.ItemIndex := Sel
  else if lstProfiles.Items.Count > 0 then
    lstProfiles.ItemIndex := 0;
  ShowProfile(lstProfiles.ItemIndex);
  chkAutoConnect.Checked := FProfiles.AutoConnect;
end;

procedure TConnDialog.SaveCurrentToList;
var
  I: Integer;
  P: TConnectionProfile;
begin
  I := lstProfiles.ItemIndex;
  if (I < 0) or (I >= FProfiles.Count) then
    Exit;
  P := FProfiles[I];
  P.Name := Trim(edtName.Text);
  if P.Name = '' then
    P.Name := Format('Profile %d', [I + 1]);
  P.Host := Trim(edtHost.Text);
  P.Port := sePort.Value;
  P.UserName := edtUser.Text;
  P.Password := edtPassword.Text;
  P.UseHTTPS := chkHTTPS.Checked;
  FProfiles[I] := P;
  lstProfiles.Items[I] := P.Name;
end;

procedure TConnDialog.ShowProfile(Index: Integer);
var
  P: TConnectionProfile;
begin
  FLoading := True;
  try
    if (Index < 0) or (Index >= FProfiles.Count) then
    begin
      edtName.Text := '';
      edtHost.Text := '';
      sePort.Value := 8888;
      edtUser.Text := '';
      edtPassword.Text := '';
      chkHTTPS.Checked := False;
      Exit;
    end;
    P := FProfiles[Index];
    edtName.Text := P.Name;
    edtHost.Text := P.Host;
    sePort.Value := P.Port;
    edtUser.Text := P.UserName;
    edtPassword.Text := P.Password;
    chkHTTPS.Checked := P.UseHTTPS;
  finally
    FLoading := False;
  end;
end;

procedure TConnDialog.lstProfilesClick(Sender: TObject);
begin
  if FLoading then
    Exit;
  SaveCurrentToList;
  ShowProfile(lstProfiles.ItemIndex);
end;

procedure TConnDialog.btnAddClick(Sender: TObject);
var
  P: TConnectionProfile;
  Idx: Integer;
begin
  SaveCurrentToList;
  P := DefaultProfile;
  P.Name := Format('%s %d', [_('dlg.profiles.name'), FProfiles.Count + 1]);
  Idx := FProfiles.Add(P);
  lstProfiles.Items.Add(P.Name);
  lstProfiles.ItemIndex := Idx;
  ShowProfile(Idx);
  edtName.SetFocus;
end;

procedure TConnDialog.btnDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  I := lstProfiles.ItemIndex;
  if I < 0 then
    Exit;
  if FProfiles.Count <= 1 then
    Exit;
  FProfiles.Delete(I);
  LoadList;
end;

procedure TConnDialog.btnOKClick(Sender: TObject);
var
  I: Integer;
begin
  SaveCurrentToList;
  if FProfiles.Count = 0 then
  begin
    MessageDlg(_('msg.name.required'), mtError, [mbOK], 0);
    Exit;
  end;
  if lstProfiles.ItemIndex >= 0 then
    I := lstProfiles.ItemIndex
  else
    I := 0;
  if Trim(FProfiles[I].Host) = '' then
  begin
    MessageDlg(_('msg.host.required'), mtError, [mbOK], 0);
    Exit;
  end;
  FProfiles.ActiveIndex := I;
  FProfiles.AutoConnect := chkAutoConnect.Checked;
  ModalResult := mrOK;
end;

function TConnDialog.Execute(Profiles: TProfileList): Boolean;
begin
  FProfiles := Profiles;
  ApplyLanguage;
  LoadList;
  Result := ShowModal = mrOK;
end;

end.
