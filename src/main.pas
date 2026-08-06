unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, Menus, ActnList, DateUtils, LCLType, LCLIntf, Clipbrd, CheckLst,
  Models, Rpc, ConnForm, Utils, Logger, TorrentMeta, Profiles, Lang, AboutForm,
  AppSettingsForm, UtSettingsForm, AppVersion;

type
  TFilterKind = (fkAll, fkDownloading, fkCompleted, fkActive, fkInactive,
    fkStopped, fkError, fkQueued);

  { TMainForm }

  TMainForm = class(TForm)
    ActionList1: TActionList;
    actConnect: TAction;
    actDisconnect: TAction;
    actAddFile: TAction;
    actAddURL: TAction;
    actStart: TAction;
    actForceStart: TAction;
    actPause: TAction;
    actStop: TAction;
    actRecheck: TAction;
    actRemove: TAction;
    actRemoveData: TAction;
    actRefresh: TAction;
    actExit: TAction;
    actProfiles: TAction;
    actAppSettings: TAction;
    actUtSettings: TAction;
    actLangRU: TAction;
    actLangEN: TAction;
    actAbout: TAction;
    actHomePage: TAction;
    cmbProfile: TComboBox;
    btnProfile: TToolButton;
    pmProfiles: TPopupMenu;
    panTop: TPanel;
    ImageListToolbar: TImageList;
    ImageListToolbar32: TImageList;
    ImageListFilter: TImageList;
    ImageListMenu: TImageList;
    TrayIcon1: TTrayIcon;
    pmTray: TPopupMenu;
    miTrayShow: TMenuItem;
    miTrayExit: TMenuItem;
    btnAddFile: TToolButton;
    btnAddURL: TToolButton;
    btnConnect: TToolButton;
    btnPause: TToolButton;
    btnRemove: TToolButton;
    btnSep1: TToolButton;
    btnSep2: TToolButton;
    btnSep3: TToolButton;
    btnSep4: TToolButton;
    btnSep5: TToolButton;
    btnStart: TToolButton;
    btnStop: TToolButton;
    btnQueueUp: TToolButton;
    btnQueueDown: TToolButton;
    btnRefresh: TToolButton;
    btnRecheck: TToolButton;
    btnProfiles: TToolButton;
    lblCommentCaption: TLabel;
    lblCompleted: TLabel;
    lblCompletedVal: TLabel;
    lblDownloaded: TLabel;
    lblDownloadedVal: TLabel;
    lblError: TLabel;
    lblErrorVal: TLabel;
    lblHash: TLabel;
    lblHashVal: TLabel;
    lblAdded: TLabel;
    lblAddedVal: TLabel;
    lblName: TLabel;
    lblNameVal: TLabel;
    lblPathCap: TLabel;
    lblPathVal: TLabel;
    lblPeers: TLabel;
    lblPeersVal: TLabel;
    lblRatio: TLabel;
    lblRatioVal: TLabel;
    lblRemaining: TLabel;
    lblRemainingVal: TLabel;
    lblSeeds: TLabel;
    lblSeedsVal: TLabel;
    lblSize: TLabel;
    lblSizeVal: TLabel;
    lblSpeed: TLabel;
    lblSpeedVal: TLabel;
    lblStatus: TLabel;
    lblStatusVal: TLabel;
    lblTorrentGroup: TLabel;
    lblTransferGroup: TLabel;
    lblUploaded: TLabel;
    lblUploadedVal: TLabel;
    lvFiles: TListView;
    lvTorrents: TListView;
    lvTrackers: TListView;
    MainMenu1: TMainMenu;
    miConnect: TMenuItem;
    miDisconnect: TMenuItem;
    miExit: TMenuItem;
    miFile: TMenuItem;
    miAddFile: TMenuItem;
    miAddURL: TMenuItem;
    miForceStart: TMenuItem;
    miPause: TMenuItem;
    miRecheck: TMenuItem;
    miRefresh: TMenuItem;
    miRemove: TMenuItem;
    miRemoveData: TMenuItem;
    miSepFile1: TMenuItem;
    miSepFile2: TMenuItem;
    miSepTorrent1: TMenuItem;
    miStart: TMenuItem;
    miStop: TMenuItem;
    miTorrent: TMenuItem;
    miView: TMenuItem;
    miTools: TMenuItem;
    miLanguage: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    miHomePage: TMenuItem;
    miProfiles: TMenuItem;
    miViewSelectAll: TMenuItem;
    miViewColumns: TMenuItem;
    miViewFilterPanel: TMenuItem;
    miViewDetailsPanel: TMenuItem;
    miViewToolbar: TMenuItem;
    miViewStatusBar: TMenuItem;
    miSepView2: TMenuItem;
    miSepView3: TMenuItem;
    miAppSettings: TMenuItem;
    miUtSettings: TMenuItem;
    miSepTools1: TMenuItem;
    miSepTools2: TMenuItem;
    OpenDialog1: TOpenDialog;
    PageDetails: TPageControl;
    panDetails: TPanel;
    panGeneral: TPanel;
    panLeft: TPanel;
    panProgress: TPanel;
    panRight: TPanel;
    panTorrent: TPanel;
    panTransfer: TPanel;
    pbDone: TPaintBox;
    pmTorrents: TPopupMenu;
    pmToolbar: TPopupMenu;
    miToolbarLarge: TMenuItem;
    miToolbarSmall: TMenuItem;
    miViewToolbarLarge: TMenuItem;
    miViewToolbarSmall: TMenuItem;
    miSepView1: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    SplitterH: TSplitter;
    SplitterV: TSplitter;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    tsFiles: TTabSheet;
    tsGeneral: TTabSheet;
    tsTrackers: TTabSheet;
    tvFilter: TTreeView;
    txComment: TLabel;
    txDonePct: TLabel;
    procedure actAddFileExecute(Sender: TObject);
    procedure actAddURLExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actProfilesExecute(Sender: TObject);
    procedure actLangRUExecute(Sender: TObject);
    procedure actLangENExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actHomePageExecute(Sender: TObject);
    procedure actOpenFolderExecute(Sender: TObject);
    procedure actOpenContentExecute(Sender: TObject);
    procedure actCopyMagnetExecute(Sender: TObject);
    procedure actQueueTopExecute(Sender: TObject);
    procedure actQueueUpExecute(Sender: TObject);
    procedure actQueueDownExecute(Sender: TObject);
    procedure actQueueBottomExecute(Sender: TObject);
    procedure actColumnsExecute(Sender: TObject);
    procedure LanguageMenuClick(Sender: TObject);
    procedure actForceStartExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actRecheckExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRemoveDataExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure cmbProfileChange(Sender: TObject);
    procedure ProfileMenuClick(Sender: TObject);
    procedure ProfileNewClick(Sender: TObject);
    procedure btnProfileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure panGeneralResize(Sender: TObject);
    procedure lvTorrentsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure tvFilterChange(Sender: TObject; Node: TTreeNode);
    procedure txCommentClick(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure miTrayShowClick(Sender: TObject);
    procedure miToolbarLargeClick(Sender: TObject);
    procedure miToolbarSmallClick(Sender: TObject);
    procedure miViewSelectAllClick(Sender: TObject);
    procedure miViewFilterPanelClick(Sender: TObject);
    procedure miViewDetailsPanelClick(Sender: TObject);
    procedure miViewToolbarClick(Sender: TObject);
    procedure miViewStatusBarClick(Sender: TObject);
    procedure miAppSettingsClick(Sender: TObject);
    procedure miUtSettingsClick(Sender: TObject);
    procedure pbDonePaint(Sender: TObject);
  private
    FRpc: TuTorrentRpc;
    FThread: TRpcRefreshThread;
    FProfiles: TProfileList;
    FSelectedHash: string;
    FUpdatingList: Boolean;
    FUpdatingFilter: Boolean;
    FUpdatingCombo: Boolean;
    FLastList: TTorrentList;
    FFilter: TFilterKind;
    FCommentURL: string;
    FAllowClose: Boolean;
    FIncompleteHashes: TStringList;
    FErrorHashes: TStringList;
    FCompletionReady: Boolean;
    FErrorReady: Boolean;
    FProgressPermille: Integer;
    FNodeAll: TTreeNode;
    FNodeDown: TTreeNode;
    FNodeDone: TTreeNode;
    FNodeActive: TTreeNode;
    FNodeInactive: TTreeNode;
    FNodeStopped: TTreeNode;
    FNodeError: TTreeNode;
    FNodeQueued: TTreeNode;
    FFilterTitles: array[TFilterKind] of string;
    FActOpenFolder: TAction;
    FActOpenContent: TAction;
    FActCopyMagnet: TAction;
    FActQueueTop: TAction;
    FActQueueUp: TAction;
    FActQueueDown: TAction;
    FActQueueBottom: TAction;
    FActColumns: TAction;
    FToolbarLarge: Boolean;
    FToolbarIconsLoaded: Boolean;
    FLastNonMinimizedState: TWindowState;
    FRestoreWindowState: TWindowState;
    FNormalBounds: TRect;
    FWindowPlacementRestored: Boolean;
    procedure InitFilterTree;
    procedure LoadIcons;
    procedure EnsureToolbarIconsLoaded;
    procedure LoadToolbarIconsInto(IL: TImageList; Large: Boolean);
    procedure LoadMenuIcons;
    procedure AssignToolbarImageIndices;
    procedure AssignMenuImages;
    procedure ApplyToolbarSize;
    procedure SetupToolbarExtras;
    procedure ApplyGlassStyle;
    procedure LayoutDetails;
    procedure ApplyLanguage;
    procedure BuildLanguageMenu;
    procedure BuildTorrentPopup;
    procedure SetupActionShortcuts;
    procedure FillProfileCombo;
    procedure BuildProfileMenu;
    procedure UpdateProfileButton;
    function ConnectActiveProfile: Boolean;
    procedure ShowFromTray;
    procedure HideToTray;
    procedure UpdateNormalBounds;
    procedure SaveWindowPlacement;
    procedure RestoreWindowPlacement;
    procedure UpdateTrayHint(List: TTorrentList);
    procedure NotifyCompleted(const AName: string);
    procedure NotifyError(const AName, AMsg: string);
    procedure TrackCompletions(List: TTorrentList);
    procedure TrackErrors(List: TTorrentList);
    function ImagesDir: string;
    function FilterIconSize: Integer;
    procedure LoadFilterIcons;
    function AddPngToImageList(IL: TImageList; const FileName: string): Integer;
    function AddPngToImageListScaled(IL: TImageList; const FileName: string; Size: Integer): Integer;
    function ToolbarIconFile(const BaseName: string): string;
    function ToolbarIconFileForSize(const BaseName: string; Large: Boolean): string;
    procedure UpdateFilterCounts(List: TTorrentList);
    function MatchFilter(T: TTorrent): Boolean;
    procedure SetConnectedUI(Connected: Boolean);
    procedure ApplyList(List: TTorrentList);
    procedure OnRefresh(Sender: TObject; List: TTorrentList);
    procedure OnRpcError(Sender: TObject; const Msg: string);
    function SelectedHash: string;
    function FindTorrent(const Hash: string): TTorrent;
    procedure RunAction(const ActionName: string);
    procedure LoadDetails(const Hash: string);
    procedure ClearDetails;
    procedure UpdateStatusBar(List: TTorrentList);
    procedure StartRefreshThread;
    procedure StopRefreshThread;
    procedure UpdateRefreshInterval;
    procedure ApplyViewSettings;
    procedure SyncViewMenuChecks;
    procedure ApplyFontScale;
    procedure ApplyProxySettings;
    procedure SetCommentLink(const Comment: string);
    function FormatUnixTime(TS: Int64): string;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

const
  cTbBtnSize = 36;
  cTbSepWidth = 8;
  cTbPanHeight = 38;

function NodeCaption(const Title: string; Count: Integer): string;
begin
  Result := Format('%s (%d)', [Title, Count]);
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LogInit('');
  FRpc := TuTorrentRpc.Create;
  FProfiles := TProfileList.Create;
  FProfiles.Load;
  LangReload;
  if (FProfiles.Language <> '') and (FindLanguageIndex(FProfiles.Language) >= 0) then
    SetAppLanguageCode(FProfiles.Language)
  else if FindLanguageIndex('en') >= 0 then
    SetAppLanguageCode('en')
  else if LanguageCount > 0 then
    SetAppLanguageCode(GetLanguageInfo(0).Code)
  else
    SetAppLanguageCode('en');
  FThread := nil;
  FLastList := TTorrentList.Create;
  FIncompleteHashes := TStringList.Create;
  FIncompleteHashes.Sorted := True;
  FIncompleteHashes.Duplicates := dupIgnore;
  FErrorHashes := TStringList.Create;
  FErrorHashes.Sorted := True;
  FErrorHashes.Duplicates := dupIgnore;
  FSelectedHash := '';
  FUpdatingList := False;
  FUpdatingFilter := False;
  FUpdatingCombo := False;
  FFilter := fkAll;
  FCommentURL := '';
  FAllowClose := False;
  FCompletionReady := False;
  FErrorReady := False;
  FProgressPermille := 0;
  FToolbarIconsLoaded := False;
  FLastNonMinimizedState := wsNormal;
  FRestoreWindowState := wsNormal;
  FNormalBounds := BoundsRect;
  FWindowPlacementRestored := False;
  ApplyGlassStyle;
  FToolbarLarge := FProfiles.ToolbarLarge;
  LoadIcons;
  SetupActionShortcuts;
  BuildTorrentPopup;
  SetupToolbarExtras;
  FillProfileCombo;
  ApplyViewSettings;
  ApplyFontScale;
  ApplyProxySettings;
  ApplyLanguage;
  ApplyToolbarSize;
  ClearDetails;
  SetConnectedUI(False);
  if FProfiles.AlwaysShowTray or not Visible then
    TrayIcon1.Visible := True
  else
    TrayIcon1.Visible := False;
  ApplyRunAtStartup(FProfiles.RunAtStartup);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  StopRefreshThread;
  FreeAndNil(FLastList);
  FreeAndNil(FIncompleteHashes);
  FreeAndNil(FErrorHashes);
  FreeAndNil(FProfiles);
  FRpc.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if not FWindowPlacementRestored then
  begin
    RestoreWindowPlacement;
    FWindowPlacementRestored := True;
  end;
  ApplyToolbarSize;
  LayoutDetails;
  if FProfiles.AutoConnect and (FProfiles.Count > 0) and not FRpc.Connected then
    ConnectActiveProfile;
end;

procedure TMainForm.UpdateNormalBounds;
begin
  if WindowState = wsNormal then
    FNormalBounds := BoundsRect;
end;

procedure TMainForm.SaveWindowPlacement;
var
  R: TRect;
begin
  if FLastNonMinimizedState = wsMaximized then
    R := FNormalBounds
  else
    R := BoundsRect;
  if (R.Right <= R.Left) or (R.Bottom <= R.Top) then
    Exit;
  FProfiles.WindowMaximized := FLastNonMinimizedState = wsMaximized;
  FProfiles.WindowLeft := R.Left;
  FProfiles.WindowTop := R.Top;
  FProfiles.WindowWidth := R.Right - R.Left;
  FProfiles.WindowHeight := R.Bottom - R.Top;
  FProfiles.Save;
end;

procedure TMainForm.RestoreWindowPlacement;
var
  R: TRect;
  W, H: Integer;
begin
  W := FProfiles.WindowWidth;
  H := FProfiles.WindowHeight;
  if (W <= 0) or (H <= 0) then
    Exit;
  R := Rect(FProfiles.WindowLeft, FProfiles.WindowTop,
    FProfiles.WindowLeft + W, FProfiles.WindowTop + H);
  if R.Right > Screen.DesktopWidth then
    R.Left := Screen.DesktopWidth - W;
  if R.Bottom > Screen.DesktopHeight then
    R.Top := Screen.DesktopHeight - H;
  if R.Left < 0 then
    R.Left := 0;
  if R.Top < 0 then
    R.Top := 0;
  R.Right := R.Left + W;
  R.Bottom := R.Top + H;
  FNormalBounds := R;
  WindowState := wsNormal;
  BoundsRect := R;
  if FProfiles.WindowMaximized then
  begin
    WindowState := wsMaximized;
    FLastNonMinimizedState := wsMaximized;
    FRestoreWindowState := wsMaximized;
  end
  else
  begin
    FLastNonMinimizedState := wsNormal;
    FRestoreWindowState := wsNormal;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  UpdateNormalBounds;
  LayoutDetails;
end;

procedure TMainForm.panGeneralResize(Sender: TObject);
begin
  LayoutDetails;
end;

procedure TMainForm.ApplyGlassStyle;
var
  HeaderColor: TColor;
begin
  // Match TransGUI: system theme colors + flat icon toolbar.
  // Do NOT assign custom Color to ToolBar/PageControl — that kills Win32 visual styles.
  Color := clBtnFace;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  DoubleBuffered := True;

  if panTop <> nil then
  begin
    panTop.ParentColor := True;
    panTop.BevelOuter := bvNone;
  end;

  ToolBar1.ParentColor := True;
  ToolBar1.EdgeBorders := [];
  ToolBar1.Flat := True;
  ToolBar1.List := True;
  ToolBar1.ShowCaptions := False;
  ToolBar1.ShowHint := True;
  ToolBar1.AutoSize := True;

  panLeft.ParentColor := True;
  panLeft.BevelOuter := bvNone;
  panRight.ParentColor := True;
  panRight.BevelOuter := bvNone;
  panDetails.ParentColor := True;
  panDetails.BevelOuter := bvNone;
  panGeneral.ParentColor := True;
  panTransfer.ParentColor := True;
  panTorrent.ParentColor := True;
  panProgress.ParentColor := True;

  tvFilter.BorderStyle := bsSingle;
  tvFilter.ParentFont := True;
  lvTorrents.BorderStyle := bsSingle;
  lvTorrents.GridLines := False;
  lvFiles.BorderStyle := bsSingle;
  lvFiles.GridLines := False;
  lvTrackers.BorderStyle := bsSingle;
  lvTrackers.GridLines := False;
  StatusBar1.ParentColor := True;

  HeaderColor := GetLikeColor(clBtnFace, -15);
  lblTransferGroup.Color := HeaderColor;
  lblTransferGroup.Transparent := False;
  lblTransferGroup.AutoSize := False;
  lblTorrentGroup.Color := HeaderColor;
  lblTorrentGroup.Transparent := False;
  lblTorrentGroup.AutoSize := False;
end;

procedure TMainForm.LayoutDetails;
var
  W, Col2, Gap, MidGap, LeftCap, RightCap, LeftValX, RightValX, LeftValW, RightValW: Integer;
  RowH, Y0, LblH, NeedH: Integer;

  function MaxI(A, B: Integer): Integer;
  begin
    if A > B then Result := A else Result := B;
  end;

  function TextW(const S: string): Integer;
  begin
    Canvas.Font := Font;
    Result := Canvas.TextWidth(S);
  end;

  procedure PrepLabel(L: TLabel);
  begin
    if L = nil then Exit;
    L.AutoSize := False;
    L.ShowAccelChar := False;
    L.Transparent := True;
    L.Layout := tlCenter;
  end;

  procedure Place(L: TLabel; X, Y, AWidth: Integer);
  begin
    if L = nil then Exit;
    L.SetBounds(X, Y, AWidth, LblH);
  end;

begin
  if (panProgress = nil) or (panProgress.ClientWidth < 160) then Exit;
  if not HandleAllocated then Exit;

  Canvas.Font := Font;
  LblH := Canvas.TextHeight('AgЙy') + 4;
  if LblH < 18 then
    LblH := 18;
  RowH := LblH + 6;
  Y0 := 24;
  Gap := 10;
  MidGap := 32;

  PrepLabel(lblStatus); PrepLabel(lblDownloaded); PrepLabel(lblSpeed);
  PrepLabel(lblSeeds); PrepLabel(lblRatio); PrepLabel(lblUploaded);
  PrepLabel(lblRemaining); PrepLabel(lblPeers); PrepLabel(lblError);
  PrepLabel(lblStatusVal); PrepLabel(lblDownloadedVal); PrepLabel(lblSpeedVal);
  PrepLabel(lblSeedsVal); PrepLabel(lblRatioVal); PrepLabel(lblUploadedVal);
  PrepLabel(lblRemainingVal); PrepLabel(lblPeersVal); PrepLabel(lblErrorVal);
  PrepLabel(lblName); PrepLabel(lblSize); PrepLabel(lblPathCap);
  PrepLabel(lblAdded); PrepLabel(lblCommentCaption); PrepLabel(lblHash);
  PrepLabel(lblCompleted); PrepLabel(lblNameVal); PrepLabel(lblSizeVal);
  PrepLabel(lblPathVal); PrepLabel(lblAddedVal); PrepLabel(lblHashVal);
  PrepLabel(lblCompletedVal); PrepLabel(txComment);

  W := panProgress.ClientWidth;
  panProgress.Height := MaxI(28, LblH + 12);
  pbDone.SetBounds(8, (panProgress.Height - 14) div 2, MaxI(40, W - 96), 14);
  txDonePct.SetBounds(W - 80, (panProgress.Height - LblH) div 2, 72, LblH);
  pbDone.Invalidate;

  if panTransfer = nil then Exit;
  W := panTransfer.ClientWidth;
  lblTransferGroup.AutoSize := False;
  lblTransferGroup.Transparent := False;
  lblTransferGroup.SetBounds(0, 0, W, LblH + 2);

  LeftCap := MaxI(70, TextW(lblStatus.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblDownloaded.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblSpeed.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblSeeds.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblRatio.Caption));

  RightCap := MaxI(60, TextW(lblUploaded.Caption));
  RightCap := MaxI(RightCap, TextW(lblRemaining.Caption));
  RightCap := MaxI(RightCap, TextW(lblPeers.Caption));
  RightCap := MaxI(RightCap, TextW(lblError.Caption));

  Col2 := (W div 2) + 8;
  if Col2 < 16 + LeftCap + Gap + 100 + MidGap then
    Col2 := 16 + LeftCap + Gap + 100 + MidGap;
  if Col2 + RightCap + Gap + 90 > W - 8 then
    Col2 := MaxI(16 + LeftCap + Gap + 80 + MidGap, W - 8 - RightCap - Gap - 90);

  LeftValX := 16 + LeftCap + Gap;
  RightValX := Col2 + RightCap + Gap;
  LeftValW := MaxI(40, Col2 - MidGap - LeftValX);
  RightValW := MaxI(40, W - 8 - RightValX);

  Place(lblStatus, 16, Y0, LeftCap);
  Place(lblDownloaded, 16, Y0 + RowH, LeftCap);
  Place(lblSpeed, 16, Y0 + RowH * 2, LeftCap);
  Place(lblSeeds, 16, Y0 + RowH * 3, LeftCap);
  Place(lblRatio, 16, Y0 + RowH * 4, LeftCap);

  Place(lblStatusVal, LeftValX, Y0, LeftValW);
  Place(lblDownloadedVal, LeftValX, Y0 + RowH, LeftValW);
  Place(lblSpeedVal, LeftValX, Y0 + RowH * 2, LeftValW);
  Place(lblSeedsVal, LeftValX, Y0 + RowH * 3, LeftValW);
  Place(lblRatioVal, LeftValX, Y0 + RowH * 4, LeftValW);

  Place(lblUploaded, Col2, Y0 + RowH, RightCap);
  Place(lblRemaining, Col2, Y0 + RowH * 2, RightCap);
  Place(lblPeers, Col2, Y0 + RowH * 3, RightCap);
  Place(lblError, Col2, Y0 + RowH * 4, RightCap);

  Place(lblUploadedVal, RightValX, Y0 + RowH, RightValW);
  Place(lblRemainingVal, RightValX, Y0 + RowH * 2, RightValW);
  Place(lblPeersVal, RightValX, Y0 + RowH * 3, RightValW);
  Place(lblErrorVal, RightValX, Y0 + RowH * 4, RightValW);

  NeedH := Y0 + RowH * 5 + 8;
  if panTransfer.Height <> NeedH then
    panTransfer.Height := NeedH;

  if panTorrent = nil then Exit;
  W := panTorrent.ClientWidth;
  lblTorrentGroup.AutoSize := False;
  lblTorrentGroup.Transparent := False;
  lblTorrentGroup.SetBounds(0, 0, W, LblH + 2);

  LeftCap := MaxI(90, TextW(lblName.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblSize.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblPathCap.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblAdded.Caption));
  LeftCap := MaxI(LeftCap, TextW(lblCommentCaption.Caption));

  RightCap := MaxI(70, TextW(lblHash.Caption));
  RightCap := MaxI(RightCap, TextW(lblCompleted.Caption));

  Col2 := (W div 2) + 8;
  if Col2 < 16 + LeftCap + Gap + 120 + MidGap then
    Col2 := 16 + LeftCap + Gap + 120 + MidGap;
  if Col2 + RightCap + Gap + 120 > W - 8 then
    Col2 := MaxI(16 + LeftCap + Gap + 100 + MidGap, W - 8 - RightCap - Gap - 120);

  LeftValX := 16 + LeftCap + Gap;
  RightValX := Col2 + RightCap + Gap;
  LeftValW := MaxI(40, W - 8 - LeftValX);
  RightValW := MaxI(40, W - 8 - RightValX);

  Place(lblName, 16, Y0, LeftCap);
  Place(lblSize, 16, Y0 + RowH, LeftCap);
  Place(lblPathCap, 16, Y0 + RowH * 2, LeftCap);
  Place(lblAdded, 16, Y0 + RowH * 3, LeftCap);
  Place(lblCommentCaption, 16, Y0 + RowH * 4, LeftCap);

  Place(lblNameVal, LeftValX, Y0, LeftValW);
  Place(lblSizeVal, LeftValX, Y0 + RowH, MaxI(40, Col2 - MidGap - LeftValX));
  Place(lblPathVal, LeftValX, Y0 + RowH * 2, LeftValW);
  Place(lblAddedVal, LeftValX, Y0 + RowH * 3, MaxI(40, Col2 - MidGap - LeftValX));
  Place(txComment, LeftValX, Y0 + RowH * 4, LeftValW);

  Place(lblHash, Col2, Y0 + RowH, RightCap);
  Place(lblCompleted, Col2, Y0 + RowH * 3, RightCap);
  Place(lblHashVal, RightValX, Y0 + RowH, RightValW);
  Place(lblCompletedVal, RightValX, Y0 + RowH * 3, RightValW);
end;

procedure TMainForm.FillProfileCombo;
begin
  UpdateProfileButton;
  BuildProfileMenu;
end;

procedure TMainForm.UpdateProfileButton;
var
  Cap: string;
begin
  if btnProfile = nil then Exit;
  if (FProfiles.Count > 0) and (FProfiles.ActiveIndex >= 0) and
     (FProfiles.ActiveIndex < FProfiles.Count) then
    Cap := FProfiles[FProfiles.ActiveIndex].Name
  else
    Cap := _('conn.none');
  btnProfile.Caption := Cap;
  btnProfile.ShowCaption := True;
end;

procedure TMainForm.BuildProfileMenu;
var
  I: Integer;
  Mi: TMenuItem;
begin
  if pmProfiles = nil then Exit;
  while pmProfiles.Items.Count > 0 do
    pmProfiles.Items[0].Free;
  for I := 0 to FProfiles.Count - 1 do
  begin
    Mi := TMenuItem.Create(pmProfiles);
    Mi.Caption := FProfiles[I].Name;
    Mi.Tag := I;
    Mi.RadioItem := True;
    Mi.GroupIndex := 5;
    Mi.Checked := I = FProfiles.ActiveIndex;
    Mi.OnClick := @ProfileMenuClick;
    pmProfiles.Items.Add(Mi);
  end;
  if FProfiles.Count > 0 then
  begin
    Mi := TMenuItem.Create(pmProfiles);
    Mi.Caption := '-';
    pmProfiles.Items.Add(Mi);
  end;
  Mi := TMenuItem.Create(pmProfiles);
  Mi.Caption := _('conn.new');
  Mi.OnClick := @ProfileNewClick;
  pmProfiles.Items.Add(Mi);
  Mi := TMenuItem.Create(pmProfiles);
  Mi.Caption := _('act.profiles');
  Mi.OnClick := @actProfilesExecute;
  pmProfiles.Items.Add(Mi);
end;

procedure TMainForm.ProfileMenuClick(Sender: TObject);
var
  Mi: TMenuItem;
  Idx: Integer;
begin
  if not (Sender is TMenuItem) then Exit;
  Mi := TMenuItem(Sender);
  Idx := Mi.Tag;
  if (Idx < 0) or (Idx >= FProfiles.Count) then Exit;
  if Idx = FProfiles.ActiveIndex then
  begin
    ConnectActiveProfile;
    Exit;
  end;
  FProfiles.ActiveIndex := Idx;
  FProfiles.Save;
  UpdateProfileButton;
  BuildProfileMenu;
  ConnectActiveProfile;
end;

procedure TMainForm.ProfileNewClick(Sender: TObject);
begin
  actProfilesExecute(Sender);
end;

procedure TMainForm.btnProfileClick(Sender: TObject);
begin
  ConnectActiveProfile;
end;

procedure TMainForm.ApplyLanguage;
var
  I: Integer;
begin
  Caption := AppTitleWithVersionLocalized(_('app.title'));
  Application.Title := Caption;
  miTorrent.Caption := _('menu.torrent');
  miView.Caption := _('menu.view');
  if miTools <> nil then miTools.Caption := _('menu.tools');
  if miHelp <> nil then miHelp.Caption := _('menu.help');
  if miLanguage <> nil then
    miLanguage.Caption := _('menu.language');
  BuildLanguageMenu;
  actConnect.Caption := _('act.connect');
  actConnect.Hint := actConnect.Caption;
  if btnProfile <> nil then
    btnProfile.Hint := _('conn.profile.hint');
  actDisconnect.Caption := _('act.disconnect');
  actDisconnect.Hint := actDisconnect.Caption;
  actAddFile.Caption := _('act.addfile');
  actAddFile.Hint := actAddFile.Caption;
  actAddURL.Caption := _('act.addurl');
  actAddURL.Hint := actAddURL.Caption;
  actStart.Caption := _('act.start');
  actStart.Hint := actStart.Caption;
  actForceStart.Caption := _('act.forcestart');
  actForceStart.Hint := actForceStart.Caption;
  actPause.Caption := _('act.pause');
  actPause.Hint := actPause.Caption;
  actStop.Caption := _('act.stop');
  actStop.Hint := actStop.Caption;
  actRecheck.Caption := _('act.recheck');
  actRecheck.Hint := actRecheck.Caption;
  actRemove.Caption := _('act.remove');
  actRemove.Hint := actRemove.Caption;
  actRemoveData.Caption := _('act.removedata');
  actRemoveData.Hint := actRemoveData.Caption;
  actRefresh.Caption := _('act.refresh');
  actRefresh.Hint := actRefresh.Caption;
  actExit.Caption := _('act.exit');
  if actProfiles <> nil then
  begin
    actProfiles.Caption := _('act.profiles');
    actProfiles.Hint := actProfiles.Caption;
  end;
  if actAbout <> nil then
  begin
    actAbout.Caption := _('act.about');
    actAbout.Hint := actAbout.Caption;
  end;
  if actHomePage <> nil then
  begin
    actHomePage.Caption := _('act.homepage');
    actHomePage.Hint := actHomePage.Caption;
  end;
  if FActOpenFolder <> nil then
  begin
    FActOpenFolder.Caption := _('act.openfolder');
    FActOpenFolder.Hint := FActOpenFolder.Caption;
  end;
  if FActOpenContent <> nil then
  begin
    FActOpenContent.Caption := _('act.open');
    FActOpenContent.Hint := FActOpenContent.Caption;
  end;
  if FActCopyMagnet <> nil then
  begin
    FActCopyMagnet.Caption := _('act.copymagnet');
    FActCopyMagnet.Hint := FActCopyMagnet.Caption;
  end;
  if FActQueueTop <> nil then
  begin
    FActQueueTop.Caption := _('act.queuetop');
    FActQueueTop.Hint := FActQueueTop.Caption;
  end;
  if FActQueueUp <> nil then
  begin
    FActQueueUp.Caption := _('act.queueup');
    FActQueueUp.Hint := FActQueueUp.Caption;
  end;
  if FActQueueDown <> nil then
  begin
    FActQueueDown.Caption := _('act.queuedown');
    FActQueueDown.Hint := FActQueueDown.Caption;
  end;
  if FActQueueBottom <> nil then
  begin
    FActQueueBottom.Caption := _('act.queuebottom');
    FActQueueBottom.Hint := FActQueueBottom.Caption;
  end;
  if FActColumns <> nil then
  begin
    FActColumns.Caption := _('act.columns');
    FActColumns.Hint := FActColumns.Caption;
  end;
  for I := 0 to pmTorrents.Items.Count - 1 do
    if SameText(pmTorrents.Items[I].Name, 'miQueueRoot') then
    begin
      pmTorrents.Items[I].Caption := _('act.queue');
      Break;
    end;
  // Icon-only toolbar like TransGUI (captions live in Hint / menus)
  if miToolbarLarge <> nil then miToolbarLarge.Caption := _('tb.size.large');
  if miToolbarSmall <> nil then miToolbarSmall.Caption := _('tb.size.small');
  if miViewToolbarLarge <> nil then miViewToolbarLarge.Caption := _('tb.size.large');
  if miViewToolbarSmall <> nil then miViewToolbarSmall.Caption := _('tb.size.small');
  if miViewSelectAll <> nil then miViewSelectAll.Caption := _('view.selectall');
  if miViewColumns <> nil then miViewColumns.Caption := _('act.columns');
  if miViewFilterPanel <> nil then miViewFilterPanel.Caption := _('view.filter');
  if miViewDetailsPanel <> nil then miViewDetailsPanel.Caption := _('view.details');
  if miViewToolbar <> nil then miViewToolbar.Caption := _('view.toolbar');
  if miViewStatusBar <> nil then miViewStatusBar.Caption := _('view.statusbar');
  if miAppSettings <> nil then miAppSettings.Caption := _('menu.appsettings');
  if miUtSettings <> nil then miUtSettings.Caption := _('menu.utsettings');
  if actAppSettings <> nil then
  begin
    actAppSettings.Caption := _('menu.appsettings');
    actAppSettings.Hint := actAppSettings.Caption;
  end;
  if actUtSettings <> nil then
  begin
    actUtSettings.Caption := _('menu.utsettings');
    actUtSettings.Hint := actUtSettings.Caption;
  end;
  AssignMenuImages;
  SyncViewMenuChecks;
  btnConnect.ShowCaption := False;
  btnAddFile.ShowCaption := False;
  btnAddURL.ShowCaption := False;
  btnStart.ShowCaption := False;
  btnPause.ShowCaption := False;
  btnStop.ShowCaption := False;
  btnRemove.ShowCaption := False;
  btnConnect.Caption := '';
  btnAddFile.Caption := '';
  btnAddURL.Caption := '';
  btnStart.Caption := '';
  btnPause.Caption := '';
  btnStop.Caption := '';
  btnRemove.Caption := '';
  if btnQueueUp <> nil then begin btnQueueUp.ShowCaption := False; btnQueueUp.Caption := ''; end;
  if btnQueueDown <> nil then begin btnQueueDown.ShowCaption := False; btnQueueDown.Caption := ''; end;
  if btnRefresh <> nil then begin btnRefresh.ShowCaption := False; btnRefresh.Caption := ''; end;
  if btnRecheck <> nil then begin btnRecheck.ShowCaption := False; btnRecheck.Caption := ''; end;
  if btnProfiles <> nil then begin btnProfiles.ShowCaption := False; btnProfiles.Caption := ''; end;
  miTrayShow.Caption := _('tray.show');
  if miTrayExit <> nil then
    miTrayExit.Caption := _('act.exit');
  tsGeneral.Caption := _('tab.general');
  tsTrackers.Caption := _('tab.trackers');
  tsFiles.Caption := _('tab.files');
  lblTransferGroup.Caption := _('grp.transfer');
  lblTorrentGroup.Caption := _('grp.torrent');
  lblStatus.Caption := _('lbl.status');
  lblDownloaded.Caption := _('lbl.downloaded');
  lblUploaded.Caption := _('lbl.uploaded');
  lblSpeed.Caption := _('lbl.speed');
  lblRemaining.Caption := _('lbl.remaining');
  lblSeeds.Caption := _('lbl.seeds');
  lblPeers.Caption := _('lbl.peers');
  lblRatio.Caption := _('lbl.ratio');
  lblError.Caption := _('lbl.error');
  lblName.Caption := _('lbl.name');
  lblSize.Caption := _('lbl.size');
  lblHash.Caption := _('lbl.hash');
  lblPathCap.Caption := _('lbl.path');
  lblAdded.Caption := _('lbl.added');
  lblCompleted.Caption := _('lbl.completed');
  lblCommentCaption.Caption := _('lbl.comment');
  if lvTorrents.Columns.Count >= 14 then
  begin
    lvTorrents.Columns[0].Caption := _('col.name');
    lvTorrents.Columns[1].Caption := _('col.size');
    lvTorrents.Columns[2].Caption := _('col.downloaded');
    lvTorrents.Columns[3].Caption := _('col.done');
    lvTorrents.Columns[4].Caption := _('col.status');
    lvTorrents.Columns[5].Caption := _('col.seeds');
    lvTorrents.Columns[6].Caption := _('col.peers');
    lvTorrents.Columns[7].Caption := _('col.down');
    lvTorrents.Columns[8].Caption := _('col.up');
    lvTorrents.Columns[9].Caption := _('col.uploaded');
    lvTorrents.Columns[10].Caption := _('col.remaining');
    lvTorrents.Columns[11].Caption := _('col.ratio');
    lvTorrents.Columns[12].Caption := _('col.eta');
    lvTorrents.Columns[13].Caption := _('col.label');
  end;
  if lvFiles.Columns.Count >= 4 then
  begin
    lvFiles.Columns[0].Caption := _('col.file');
    lvFiles.Columns[1].Caption := _('col.size');
    lvFiles.Columns[2].Caption := _('col.done');
    lvFiles.Columns[3].Caption := _('col.priority');
  end;
  if lvTrackers.Columns.Count >= 1 then
    lvTrackers.Columns[0].Caption := _('col.tracker');
  FFilterTitles[fkAll] := _('flt.all');
  FFilterTitles[fkDownloading] := _('flt.down');
  FFilterTitles[fkCompleted] := _('flt.done');
  FFilterTitles[fkActive] := _('flt.active');
  FFilterTitles[fkInactive] := _('flt.inactive');
  FFilterTitles[fkStopped] := _('flt.stopped');
  FFilterTitles[fkError] := _('flt.error');
  FFilterTitles[fkQueued] := _('flt.queued');
  InitFilterTree;
  if not FRpc.Connected then
  begin
    StatusBar1.Panels[0].Text := _('status.noconnect');
    StatusBar1.Panels[1].Text := '';
    StatusBar1.Panels[2].Text := '';
  end;
  LayoutDetails;
  UpdateTrayHint(FLastList);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FProfiles.CloseToTray and not FAllowClose then
  begin
    CanClose := False;
    HideToTray;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveWindowPlacement;
  StopRefreshThread;
  FRpc.Disconnect;
  TrayIcon1.Visible := False;
  CloseAction := caFree;
end;

procedure TMainForm.FormWindowStateChange(Sender: TObject);
begin
  if WindowState <> wsMinimized then
  begin
    FLastNonMinimizedState := WindowState;
    if WindowState = wsNormal then
      FNormalBounds := BoundsRect;
  end;
  if (WindowState = wsMinimized) and FProfiles.MinimizeToTray then
  begin
    FRestoreWindowState := FLastNonMinimizedState;
    HideToTray;
  end;
end;

function TMainForm.ImagesDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'images';
end;

function TMainForm.ToolbarIconFile(const BaseName: string): string;
begin
  Result := ToolbarIconFileForSize(BaseName, FToolbarLarge);
end;

function TMainForm.ToolbarIconFileForSize(const BaseName: string; Large: Boolean): string;
var
  Dir: string;
begin
  Dir := IncludeTrailingPathDelimiter(ImagesDir);
  if Large then
    Result := Dir + BaseName + '_32.png'
  else
    Result := Dir + BaseName + '.png';
end;

function TMainForm.AddPngToImageList(IL: TImageList; const FileName: string): Integer;
begin
  Result := AddPngToImageListScaled(IL, FileName, IL.Width);
end;

function TMainForm.AddPngToImageListScaled(IL: TImageList; const FileName: string;
  Size: Integer): Integer;
var
  PNG: TPortableNetworkGraphic;
  Bmp: TBitmap;
begin
  Result := -1;
  if (Size < 8) or not FileExists(FileName) then
  begin
    if not FileExists(FileName) then
      Log('Icon missing: ' + FileName);
    Exit;
  end;
  PNG := TPortableNetworkGraphic.Create;
  Bmp := TBitmap.Create;
  try
    PNG.LoadFromFile(FileName);
    Bmp.SetSize(Size, Size);
    Bmp.Canvas.StretchDraw(Rect(0, 0, Size, Size), PNG);
    Result := IL.Add(Bmp, nil);
  finally
    Bmp.Free;
    PNG.Free;
  end;
end;

function TMainForm.FilterIconSize: Integer;
begin
  Result := MulDiv(16, FProfiles.FontSizePercent, 100);
  if Result < 14 then Result := 14;
  if Result > 28 then Result := 28;
end;

procedure TMainForm.LoadFilterIcons;
var
  Dir: string;
  Sz: Integer;
begin
  if ImageListFilter = nil then Exit;
  Dir := IncludeTrailingPathDelimiter(ImagesDir);
  Sz := FilterIconSize;
  ImageListFilter.Clear;
  ImageListFilter.Width := Sz;
  ImageListFilter.Height := Sz;
  ImageListFilter.Scaled := False;
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_all_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_down_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_done_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_active_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_inactive_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_stopped_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_error_16.png', Sz);
  AddPngToImageListScaled(ImageListFilter, Dir + 'flt_queue_16.png', Sz);
  if tvFilter <> nil then
  begin
    tvFilter.Images := ImageListFilter;
    tvFilter.Invalidate;
  end;
end;

procedure TMainForm.SetupToolbarExtras;
begin
  Application.ShowHint := True;
  if pmToolbar <> nil then
  begin
    ToolBar1.PopupMenu := pmToolbar;
    if panTop <> nil then
      panTop.PopupMenu := pmToolbar;
  end;
  if (btnQueueUp <> nil) and (FActQueueUp <> nil) then
  begin
    btnQueueUp.Action := FActQueueUp;
    btnQueueUp.ShowHint := True;
  end;
  if (btnQueueDown <> nil) and (FActQueueDown <> nil) then
  begin
    btnQueueDown.Action := FActQueueDown;
    btnQueueDown.ShowHint := True;
  end;
  ToolBar1.ShowHint := True;
end;

procedure TMainForm.ApplyToolbarSize;
var
  B: TToolButton;
  I: Integer;
  IL: TImageList;
  ComboH: Integer;
begin
  EnsureToolbarIconsLoaded;
  if FToolbarLarge then
    IL := ImageListToolbar32
  else
    IL := ImageListToolbar;

  if panTop <> nil then
    panTop.Height := cTbPanHeight;

  ComboH := cTbPanHeight - 10;
  if cmbProfile <> nil then
    cmbProfile.Visible := False;

  ToolBar1.Images := IL;
  ActionList1.Images := IL;
  AssignToolbarImageIndices;

  ToolBar1.Align := alClient;
  ToolBar1.List := False;
  ToolBar1.ShowCaptions := False;
  ToolBar1.AutoSize := False;
  ToolBar1.Flat := True;
  ToolBar1.EdgeBorders := [];
  ToolBar1.Wrapable := False;
  ToolBar1.Indent := 0;
  ToolBar1.ButtonHeight := cTbBtnSize;
  ToolBar1.ButtonWidth := cTbBtnSize;
  ToolBar1.ShowHint := True;
  ToolBar1.ParentShowHint := False;
  ToolBar1.Height := cTbPanHeight;
  ToolBar1.Top := 0;

  for I := 0 to ToolBar1.ButtonCount - 1 do
  begin
    B := ToolBar1.Buttons[I];
    if B.Style = tbsButton then
    begin
      B.AutoSize := False;
      B.ShowCaption := False;
      B.Caption := '';
      B.Width := cTbBtnSize;
      B.Height := cTbBtnSize;
      B.Top := 0;
      B.ShowHint := True;
      B.ParentShowHint := True;
    end
    else if B.Style = tbsSeparator then
    begin
      B.Width := cTbSepWidth;
      B.Top := 0;
    end;
  end;

  if btnProfile <> nil then
  begin
    btnProfile.Style := tbsDropDown;
    btnProfile.ShowCaption := True;
    btnProfile.DropDownMenu := pmProfiles;
    btnProfile.ImageIndex := 0;
    btnProfile.AutoSize := False;
    btnProfile.Width := 120;
    btnProfile.Height := cTbBtnSize;
    btnProfile.Top := 0;
    UpdateProfileButton;
  end;

  if btnSep1 <> nil then
    btnSep1.Visible := False;

  if miToolbarLarge <> nil then
    miToolbarLarge.Checked := FToolbarLarge;
  if miToolbarSmall <> nil then
    miToolbarSmall.Checked := not FToolbarLarge;
  if miViewToolbarLarge <> nil then
    miViewToolbarLarge.Checked := FToolbarLarge;
  if miViewToolbarSmall <> nil then
    miViewToolbarSmall.Checked := not FToolbarLarge;

  ToolBar1.Realign;
end;

procedure TMainForm.EnsureToolbarIconsLoaded;
begin
  if FToolbarIconsLoaded then
    Exit;
  ImageListToolbar.Clear;
  ImageListToolbar.Width := 24;
  ImageListToolbar.Height := 24;
  ImageListToolbar.Scaled := False;
  ImageListToolbar32.Clear;
  ImageListToolbar32.Width := 32;
  ImageListToolbar32.Height := 32;
  ImageListToolbar32.Scaled := False;
  LoadToolbarIconsInto(ImageListToolbar, False);
  LoadToolbarIconsInto(ImageListToolbar32, True);
  FToolbarIconsLoaded := True;
end;

procedure TMainForm.LoadToolbarIconsInto(IL: TImageList; Large: Boolean);
begin
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_connect', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_add', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_url', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_start', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_pause', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_stop', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_remove', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_refresh', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_queueup', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_queuedown', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_recheck', Large));
  AddPngToImageList(IL, ToolbarIconFileForSize('tb_profiles', Large));
end;

procedure TMainForm.AssignToolbarImageIndices;
begin
  actConnect.ImageIndex := 0;
  actAddFile.ImageIndex := 1;
  actAddURL.ImageIndex := 2;
  actStart.ImageIndex := 3;
  actForceStart.ImageIndex := 3;
  actPause.ImageIndex := 4;
  actStop.ImageIndex := 5;
  actRemove.ImageIndex := 6;
  actRemoveData.ImageIndex := 6;
  actRefresh.ImageIndex := 7;
  if FActQueueUp <> nil then FActQueueUp.ImageIndex := 8;
  if FActQueueDown <> nil then FActQueueDown.ImageIndex := 9;
  actRecheck.ImageIndex := 10;
  actDisconnect.ImageIndex := 5;
  actExit.ImageIndex := 5;
  actAbout.ImageIndex := 11;
  actHomePage.ImageIndex := 2;
  if actAppSettings <> nil then actAppSettings.ImageIndex := 11;
  if actUtSettings <> nil then actUtSettings.ImageIndex := 10;
  if FActOpenFolder <> nil then FActOpenFolder.ImageIndex := 1;
  if btnQueueUp <> nil then btnQueueUp.ImageIndex := 8;
  if btnQueueDown <> nil then btnQueueDown.ImageIndex := 9;
end;

procedure TMainForm.LoadMenuIcons;
var
  Dir: string;
begin
  if ImageListMenu = nil then Exit;
  ImageListMenu.Clear;
  ImageListMenu.Width := 16;
  ImageListMenu.Height := 16;
  ImageListMenu.Scaled := False;
  Dir := IncludeTrailingPathDelimiter(ImagesDir);
  AddPngToImageList(ImageListMenu, Dir + 'tb_connect.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_add.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_url.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_start.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_pause.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_stop.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_remove.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_refresh.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_queueup.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_queuedown.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_recheck.png');
  AddPngToImageList(ImageListMenu, Dir + 'tb_profiles.png');
end;

procedure TMainForm.AssignMenuImages;
begin
  if ImageListMenu = nil then Exit;
  MainMenu1.Images := ImageListMenu;
  pmTorrents.Images := ImageListMenu;
  pmTray.Images := ImageListMenu;
  pmProfiles.Images := ImageListMenu;
  if FActColumns <> nil then
  begin
    FActColumns.ImageIndex := 10;
    if miViewColumns <> nil then
      miViewColumns.ImageIndex := FActColumns.ImageIndex;
  end;
  if miViewSelectAll <> nil then miViewSelectAll.ImageIndex := 6;
  if miViewFilterPanel <> nil then miViewFilterPanel.ImageIndex := 0;
  if miViewDetailsPanel <> nil then miViewDetailsPanel.ImageIndex := 1;
  if miViewToolbar <> nil then miViewToolbar.ImageIndex := 11;
  if miViewStatusBar <> nil then miViewStatusBar.ImageIndex := 7;
  if miViewToolbarLarge <> nil then miViewToolbarLarge.ImageIndex := 11;
  if miViewToolbarSmall <> nil then miViewToolbarSmall.ImageIndex := 11;
  if miLanguage <> nil then miLanguage.ImageIndex := 2;
end;

procedure TMainForm.LoadIcons;
var
  Dir, Ico, Png: string;
  Pic: TPortableNetworkGraphic;
begin
  Dir := IncludeTrailingPathDelimiter(ImagesDir);

  LoadFilterIcons;

  LoadMenuIcons;
  AssignMenuImages;

  Ico := Dir + 'app.ico';
  Png := Dir + 'app_icon.png';
  try
    if FileExists(Ico) then
      Application.Icon.LoadFromFile(Ico)
    else if FileExists(Png) then
    begin
      Pic := TPortableNetworkGraphic.Create;
      try
        Pic.LoadFromFile(Png);
        Application.Icon.Assign(Pic);
      finally
        Pic.Free;
      end;
    end;
    if not Application.Icon.Empty then
    begin
      Icon.Assign(Application.Icon);
      if TrayIcon1 <> nil then
      begin
        TrayIcon1.Icon.Assign(Application.Icon);
        TrayIcon1.ShowIcon := True;
        TrayIcon1.Visible := True;
      end;
    end;
  except
    on E: Exception do
      Log('Icon load failed: ' + E.Message);
  end;
end;

procedure TMainForm.miToolbarLargeClick(Sender: TObject);
begin
  if FToolbarLarge then Exit;
  FToolbarLarge := True;
  FProfiles.ToolbarLarge := True;
  FProfiles.Save;
  ApplyToolbarSize;
end;

procedure TMainForm.miToolbarSmallClick(Sender: TObject);
begin
  if not FToolbarLarge then Exit;
  FToolbarLarge := False;
  FProfiles.ToolbarLarge := False;
  FProfiles.Save;
  ApplyToolbarSize;
end;

procedure TMainForm.HideToTray;
begin
  if WindowState <> wsMinimized then
    FRestoreWindowState := WindowState;
  SaveWindowPlacement;
  Hide;
  TrayIcon1.Visible := True;
  UpdateTrayHint(FLastList);
  UpdateRefreshInterval;
end;

procedure TMainForm.ShowFromTray;
var
  Restore: TWindowState;
begin
  Restore := FRestoreWindowState;
  if Restore = wsMinimized then
    Restore := wsNormal;
  Show;
  WindowState := Restore;
  BringToFront;
  Application.BringToFront;
  if not FProfiles.AlwaysShowTray then
    TrayIcon1.Visible := False;
  UpdateRefreshInterval;
end;

procedure TMainForm.TrayIcon1Click(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TMainForm.miTrayShowClick(Sender: TObject);
begin
  ShowFromTray;
end;

procedure TMainForm.NotifyCompleted(const AName: string);
begin
  if not FProfiles.TrayNotify then
    Exit;
  TrayIcon1.BalloonTitle := _('balloon.done.title');
  TrayIcon1.BalloonHint := AName;
  TrayIcon1.BalloonFlags := bfInfo;
  TrayIcon1.ShowBalloonHint;
  Log('Completed notification: ' + AName);
end;

procedure TMainForm.NotifyError(const AName, AMsg: string);
begin
  if not FProfiles.TrayNotify then
    Exit;
  TrayIcon1.BalloonTitle := _('balloon.error.title');
  if AMsg <> '' then
    TrayIcon1.BalloonHint := AName + ': ' + AMsg
  else
    TrayIcon1.BalloonHint := AName;
  TrayIcon1.BalloonFlags := bfError;
  TrayIcon1.ShowBalloonHint;
  Log('Error notification: ' + AName);
end;

procedure TMainForm.UpdateTrayHint(List: TTorrentList);
var
  I, CDown, CSeed: Integer;
  DL, UL: Int64;
  P: TConnectionProfile;
  T: TTorrent;
  Line1, Line2, Line3: string;
begin
  if TrayIcon1 = nil then Exit;
  Line1 := AppTitleWithVersionLocalized(_('app.title'));
  if FRpc.Connected and (FProfiles.Count > 0) then
  begin
    P := FProfiles[FProfiles.ActiveIndex];
    Line1 := Line1 + Format(_('tray.hint.server'), [FRpc.Build, P.Host, P.Port]);
  end
  else
    Line1 := Line1 + ' — ' + _('status.noconnect');
  CDown := 0;
  CSeed := 0;
  DL := 0;
  UL := 0;
  if List <> nil then
    for I := 0 to List.Count - 1 do
    begin
      T := List[I];
      Inc(DL, T.DownSpeed);
      Inc(UL, T.UpSpeed);
      if (T.Progress < 1000) and ((T.Status and ST_STARTED) <> 0) and
        ((T.Status and ST_PAUSED) = 0) and ((T.Status and ST_ERROR) = 0) then
        Inc(CDown);
      if (T.Progress >= 1000) and ((T.Status and ST_STARTED) <> 0) and
        ((T.Status and ST_PAUSED) = 0) then
        Inc(CSeed);
    end;
  Line2 := Format(_('tray.hint.counts'), [CDown, CSeed]);
  Line3 := Format(_('tray.hint.speeds'), [_('status.dl'), FormatSpeed(DL),
    _('status.ul'), FormatSpeed(UL)]);
  TrayIcon1.Hint := Line1 + #13#10 + Line2 + #13#10 + Line3;
end;

procedure TMainForm.TrackCompletions(List: TTorrentList);
var
  I, Idx: Integer;
  T: TTorrent;
begin
  if List = nil then Exit;
  if not FCompletionReady then
  begin
    FIncompleteHashes.Clear;
    for I := 0 to List.Count - 1 do
      if List[I].Progress < 1000 then
        FIncompleteHashes.Add(List[I].Hash);
    FCompletionReady := True;
    Exit;
  end;
  for I := 0 to List.Count - 1 do
  begin
    T := List[I];
    if T.Progress < 1000 then
      FIncompleteHashes.Add(T.Hash)
    else
    begin
      Idx := FIncompleteHashes.IndexOf(T.Hash);
      if Idx >= 0 then
      begin
        FIncompleteHashes.Delete(Idx);
        NotifyCompleted(T.Name);
      end;
    end;
  end;
end;

procedure TMainForm.TrackErrors(List: TTorrentList);
var
  I, Idx: Integer;
  T: TTorrent;
  HasErr: Boolean;
begin
  if List = nil then Exit;
  if not FErrorReady then
  begin
    FErrorHashes.Clear;
    for I := 0 to List.Count - 1 do
      if (List[I].Status and ST_ERROR) <> 0 then
        FErrorHashes.Add(List[I].Hash);
    FErrorReady := True;
    Exit;
  end;
  for I := 0 to List.Count - 1 do
  begin
    T := List[I];
    HasErr := (T.Status and ST_ERROR) <> 0;
    Idx := FErrorHashes.IndexOf(T.Hash);
    if HasErr then
    begin
      if Idx < 0 then
      begin
        FErrorHashes.Add(T.Hash);
        NotifyError(T.Name, T.StatusMessage);
      end;
    end
    else if Idx >= 0 then
      FErrorHashes.Delete(Idx);
  end;
end;

procedure TMainForm.InitFilterTree;
begin
  FUpdatingFilter := True;
  tvFilter.Items.Clear;
  FNodeAll := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkAll], 0));
  FNodeAll.ImageIndex := 0;
  FNodeAll.SelectedIndex := 0;
  FNodeDown := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkDownloading], 0));
  FNodeDown.ImageIndex := 1;
  FNodeDown.SelectedIndex := 1;
  FNodeDone := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkCompleted], 0));
  FNodeDone.ImageIndex := 2;
  FNodeDone.SelectedIndex := 2;
  FNodeActive := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkActive], 0));
  FNodeActive.ImageIndex := 3;
  FNodeActive.SelectedIndex := 3;
  FNodeInactive := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkInactive], 0));
  FNodeInactive.ImageIndex := 4;
  FNodeInactive.SelectedIndex := 4;
  FNodeStopped := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkStopped], 0));
  FNodeStopped.ImageIndex := 5;
  FNodeStopped.SelectedIndex := 5;
  FNodeError := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkError], 0));
  FNodeError.ImageIndex := 6;
  FNodeError.SelectedIndex := 6;
  FNodeQueued := tvFilter.Items.Add(nil, NodeCaption(FFilterTitles[fkQueued], 0));
  FNodeQueued.ImageIndex := 7;
  FNodeQueued.SelectedIndex := 7;
  tvFilter.Selected := FNodeAll;
  FUpdatingFilter := False;
end;

procedure TMainForm.UpdateFilterCounts(List: TTorrentList);
var
  I, CAll, CDown, CDone, CActive, CInactive, CStopped, CError, CQueued: Integer;
  T: TTorrent;
  Prev: TFilterKind;
begin
  CAll := 0; CDown := 0; CDone := 0; CActive := 0;
  CInactive := 0; CStopped := 0; CError := 0; CQueued := 0;
  if List <> nil then
    for I := 0 to List.Count - 1 do
    begin
      T := List[I];
      Inc(CAll);
      if (T.Status and ST_ERROR) <> 0 then Inc(CError);
      if (T.Status and ST_QUEUED) <> 0 then Inc(CQueued);
      if T.Progress >= 1000 then
        Inc(CDone)
      else if ((T.Status and ST_STARTED) <> 0) and ((T.Status and ST_PAUSED) = 0) then
        Inc(CDown);
      if (T.DownSpeed > 0) or (T.UpSpeed > 0) then
        Inc(CActive)
      else
        Inc(CInactive);
      if ((T.Status and ST_STARTED) = 0) or ((T.Status and ST_PAUSED) <> 0) then
        if (T.Status and ST_ERROR) = 0 then
          Inc(CStopped);
    end;

  FUpdatingFilter := True;
  try
    Prev := FFilter;
    FNodeAll.Text := NodeCaption(FFilterTitles[fkAll], CAll);
    FNodeDown.Text := NodeCaption(FFilterTitles[fkDownloading], CDown);
    FNodeDone.Text := NodeCaption(FFilterTitles[fkCompleted], CDone);
    FNodeActive.Text := NodeCaption(FFilterTitles[fkActive], CActive);
    FNodeInactive.Text := NodeCaption(FFilterTitles[fkInactive], CInactive);
    FNodeStopped.Text := NodeCaption(FFilterTitles[fkStopped], CStopped);
    FNodeError.Text := NodeCaption(FFilterTitles[fkError], CError);
    FNodeQueued.Text := NodeCaption(FFilterTitles[fkQueued], CQueued);
    case Prev of
      fkAll: tvFilter.Selected := FNodeAll;
      fkDownloading: tvFilter.Selected := FNodeDown;
      fkCompleted: tvFilter.Selected := FNodeDone;
      fkActive: tvFilter.Selected := FNodeActive;
      fkInactive: tvFilter.Selected := FNodeInactive;
      fkStopped: tvFilter.Selected := FNodeStopped;
      fkError: tvFilter.Selected := FNodeError;
      fkQueued: tvFilter.Selected := FNodeQueued;
    end;
  finally
    FUpdatingFilter := False;
  end;
end;

function TMainForm.MatchFilter(T: TTorrent): Boolean;
begin
  case FFilter of
    fkAll: Result := True;
    fkDownloading:
      Result := (T.Progress < 1000) and ((T.Status and ST_STARTED) <> 0) and
        ((T.Status and ST_PAUSED) = 0) and ((T.Status and ST_ERROR) = 0);
    fkCompleted: Result := T.Progress >= 1000;
    fkActive: Result := (T.DownSpeed > 0) or (T.UpSpeed > 0);
    fkInactive: Result := (T.DownSpeed = 0) and (T.UpSpeed = 0);
    fkStopped:
      Result := ((T.Status and ST_STARTED) = 0) or ((T.Status and ST_PAUSED) <> 0);
    fkError: Result := (T.Status and ST_ERROR) <> 0;
    fkQueued: Result := (T.Status and ST_QUEUED) <> 0;
  else
    Result := True;
  end;
end;

procedure TMainForm.tvFilterChange(Sender: TObject; Node: TTreeNode);
begin
  if FUpdatingFilter or (Node = nil) then Exit;
  if Node = FNodeAll then FFilter := fkAll
  else if Node = FNodeDown then FFilter := fkDownloading
  else if Node = FNodeDone then FFilter := fkCompleted
  else if Node = FNodeActive then FFilter := fkActive
  else if Node = FNodeInactive then FFilter := fkInactive
  else if Node = FNodeStopped then FFilter := fkStopped
  else if Node = FNodeError then FFilter := fkError
  else if Node = FNodeQueued then FFilter := fkQueued
  else Exit;
  ApplyList(FLastList);
end;

procedure TMainForm.SetConnectedUI(Connected: Boolean);
begin
  actConnect.Enabled := not Connected;
  actDisconnect.Enabled := Connected;
  actStart.Enabled := Connected;
  actForceStart.Enabled := Connected;
  actPause.Enabled := Connected;
  actStop.Enabled := Connected;
  actRecheck.Enabled := Connected;
  actRemove.Enabled := Connected;
  actRemoveData.Enabled := Connected;
  actAddFile.Enabled := Connected;
  actAddURL.Enabled := Connected;
  actRefresh.Enabled := Connected;
  if FActOpenFolder <> nil then FActOpenFolder.Enabled := Connected;
  if FActOpenContent <> nil then FActOpenContent.Enabled := Connected;
  if FActCopyMagnet <> nil then FActCopyMagnet.Enabled := Connected;
  if FActQueueTop <> nil then FActQueueTop.Enabled := Connected;
  if FActQueueUp <> nil then FActQueueUp.Enabled := Connected;
  if FActQueueDown <> nil then FActQueueDown.Enabled := Connected;
  if FActQueueBottom <> nil then FActQueueBottom.Enabled := Connected;
  if FActColumns <> nil then FActColumns.Enabled := True;
end;

procedure TMainForm.StartRefreshThread;
begin
  StopRefreshThread;
  FThread := TRpcRefreshThread.Create(FRpc);
  FThread.OnRefresh := @OnRefresh;
  FThread.OnError := @OnRpcError;
  UpdateRefreshInterval;
  FThread.Start;
end;

procedure TMainForm.UpdateRefreshInterval;
var
  MS: Integer;
begin
  if FThread = nil then
    Exit;
  if not Visible then
    MS := FProfiles.RefreshMinimized * 1000
  else
    MS := FProfiles.RefreshInterval * 1000;
  if MS < 500 then
    MS := 500;
  FThread.IntervalMS := MS;
end;

procedure TMainForm.ApplyViewSettings;
begin
  if panLeft <> nil then
    panLeft.Visible := FProfiles.ShowFilterPanel;
  if SplitterV <> nil then
    SplitterV.Visible := FProfiles.ShowFilterPanel;
  if panDetails <> nil then
    panDetails.Visible := FProfiles.ShowDetailsPanel;
  if SplitterH <> nil then
    SplitterH.Visible := FProfiles.ShowDetailsPanel;
  if ToolBar1 <> nil then
    ToolBar1.Visible := FProfiles.ShowToolbar;
  if StatusBar1 <> nil then
    StatusBar1.Visible := FProfiles.ShowStatusBar;
  SyncViewMenuChecks;
end;

procedure TMainForm.SyncViewMenuChecks;
begin
  if miViewFilterPanel <> nil then
    miViewFilterPanel.Checked := FProfiles.ShowFilterPanel;
  if miViewDetailsPanel <> nil then
    miViewDetailsPanel.Checked := FProfiles.ShowDetailsPanel;
  if miViewToolbar <> nil then
    miViewToolbar.Checked := FProfiles.ShowToolbar;
  if miViewStatusBar <> nil then
    miViewStatusBar.Checked := FProfiles.ShowStatusBar;
  if miViewToolbarLarge <> nil then
    miViewToolbarLarge.Checked := FToolbarLarge;
  if miViewToolbarSmall <> nil then
    miViewToolbarSmall.Checked := not FToolbarLarge;
end;

procedure TMainForm.ApplyFontScale;
var
  H: Integer;
begin
  H := MulDiv(12, FProfiles.FontSizePercent, 100);
  if H < 8 then H := 8;
  if H > 24 then H := 24;
  Font.Height := -H;
  LoadFilterIcons;
end;

procedure TMainForm.ApplyProxySettings;
begin
  FRpc.ApplyProxy(FProfiles.ProxyEnabled, FProfiles.ProxyHost, FProfiles.ProxyPort,
    FProfiles.ProxyUser, FProfiles.ProxyPass);
end;

procedure TMainForm.StopRefreshThread;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    FThread.TriggerNow;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

procedure TMainForm.actConnectExecute(Sender: TObject);
begin
  ConnectActiveProfile;
end;

function TMainForm.ConnectActiveProfile: Boolean;
var
  P: TConnectionProfile;
begin
  Result := False;
  if FProfiles.Count = 0 then
    Exit;
  if (FProfiles.ActiveIndex < 0) or (FProfiles.ActiveIndex >= FProfiles.Count) then
    FProfiles.ActiveIndex := 0;
  P := FProfiles[FProfiles.ActiveIndex];
  StatusBar1.Panels[0].Text := _('status.connecting');
  Application.ProcessMessages;
  if FRpc.Connected then
  begin
    StopRefreshThread;
    FRpc.Disconnect;
  end;
  FIncompleteHashes.Clear;
  FErrorHashes.Clear;
  FCompletionReady := False;
  FErrorReady := False;
  FRpc.Configure(P.Host, P.Port, P.UserName, P.Password, P.UseHTTPS);
  ApplyProxySettings;
  if not FRpc.Connect then
  begin
    MessageDlg(Format(_('msg.connect.fail'), [FRpc.LastError]), mtError, [mbOK], 0);
    StatusBar1.Panels[0].Text := _('status.noconnect');
    SetConnectedUI(False);
    Exit;
  end;
  FProfiles.Save;
  SetConnectedUI(True);
  StatusBar1.Panels[0].Text := Format('uTorrent build %d @ %s:%d',
    [FRpc.Build, P.Host, P.Port]);
  StartRefreshThread;
  Result := True;
end;

procedure TMainForm.actProfilesExecute(Sender: TObject);
var
  Dlg: TConnDialog;
begin
  Dlg := TConnDialog.Create(Self);
  try
    if not Dlg.Execute(FProfiles) then
      Exit;
  finally
    Dlg.Free;
  end;
  FProfiles.Save;
  FillProfileCombo;
  if FRpc.Connected then
    ConnectActiveProfile;
end;

procedure TMainForm.BuildLanguageMenu;
var
  I: Integer;
  Mi: TMenuItem;
  Info: TLanguageInfo;
begin
  if miLanguage = nil then Exit;
  while miLanguage.Count > 0 do
    miLanguage.Items[0].Free;
  miLanguage.Enabled := LanguageCount > 0;
  for I := 0 to LanguageCount - 1 do
  begin
    Info := GetLanguageInfo(I);
    Mi := TMenuItem.Create(Self);
    Mi.Caption := Info.Name;
    Mi.Tag := I;
    Mi.RadioItem := True;
    Mi.GroupIndex := 21;
    Mi.Checked := SameText(Info.Code, GetAppLanguageCode);
    Mi.OnClick := @LanguageMenuClick;
    miLanguage.Add(Mi);
  end;
end;

procedure TMainForm.LanguageMenuClick(Sender: TObject);
var
  Mi: TMenuItem;
  Info: TLanguageInfo;
begin
  if not (Sender is TMenuItem) then Exit;
  Mi := TMenuItem(Sender);
  if (Mi.Tag < 0) or (Mi.Tag >= LanguageCount) then Exit;
  Info := GetLanguageInfo(Mi.Tag);
  SetAppLanguageCode(Info.Code);
  FProfiles.Language := Info.Code;
  FProfiles.Save;
  ApplyLanguage;
end;

procedure TMainForm.SetupActionShortcuts;
begin
  actStart.ShortCut := ShortCut(VK_F3, []);
  actForceStart.ShortCut := ShortCut(VK_F3, [ssShift]);
  actStop.ShortCut := ShortCut(VK_F4, []);
  actPause.ShortCut := ShortCut(VK_F4, [ssCtrl]);
  actRemove.ShortCut := ShortCut(VK_DELETE, []);
  actRemoveData.ShortCut := ShortCut(VK_DELETE, [ssShift]);
  actRecheck.ShortCut := ShortCut(Ord('R'), [ssCtrl]);
end;

function NewAct(Owner: TComponent; List: TActionList; Handler: TNotifyEvent): TAction;
begin
  Result := TAction.Create(Owner);
  Result.ActionList := List;
  Result.OnExecute := Handler;
end;

procedure TMainForm.BuildTorrentPopup;
var
  Mi, Queue: TMenuItem;
begin
  if FActOpenContent = nil then
    FActOpenContent := NewAct(Self, ActionList1, @actOpenContentExecute);
  if FActOpenFolder = nil then
    FActOpenFolder := NewAct(Self, ActionList1, @actOpenFolderExecute);
  if FActCopyMagnet = nil then
    FActCopyMagnet := NewAct(Self, ActionList1, @actCopyMagnetExecute);
  if FActQueueTop = nil then
    FActQueueTop := NewAct(Self, ActionList1, @actQueueTopExecute);
  if FActQueueUp = nil then
    FActQueueUp := NewAct(Self, ActionList1, @actQueueUpExecute);
  if FActQueueDown = nil then
    FActQueueDown := NewAct(Self, ActionList1, @actQueueDownExecute);
  if FActQueueBottom = nil then
    FActQueueBottom := NewAct(Self, ActionList1, @actQueueBottomExecute);
  if FActColumns = nil then
    FActColumns := NewAct(Self, ActionList1, @actColumnsExecute);

  FActOpenFolder.ShortCut := ShortCut(VK_RETURN, [ssCtrl]);

  pmTorrents.Items.Clear;

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := FActOpenContent;
  Mi.Default := True;
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := FActOpenFolder;
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Caption := '-';
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actStart;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actForceStart;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actPause;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actStop;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actRemove;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actRemoveData;
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Caption := '-';
  pmTorrents.Items.Add(Mi);

  Queue := TMenuItem.Create(pmTorrents);
  Queue.Caption := _('act.queue');
  Queue.Name := 'miQueueRoot';
  pmTorrents.Items.Add(Queue);
  Mi := TMenuItem.Create(Queue);
  Mi.Action := FActQueueTop;
  Queue.Add(Mi);
  Mi := TMenuItem.Create(Queue);
  Mi.Action := FActQueueUp;
  Queue.Add(Mi);
  Mi := TMenuItem.Create(Queue);
  Mi.Action := FActQueueDown;
  Queue.Add(Mi);
  Mi := TMenuItem.Create(Queue);
  Mi.Action := FActQueueBottom;
  Queue.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := actRecheck;
  pmTorrents.Items.Add(Mi);
  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := FActCopyMagnet;
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Caption := '-';
  pmTorrents.Items.Add(Mi);

  Mi := TMenuItem.Create(pmTorrents);
  Mi.Action := FActColumns;
  pmTorrents.Items.Add(Mi);
end;

procedure TMainForm.actOpenFolderExecute(Sender: TObject);
var
  T: TTorrent;
  P: string;
begin
  T := FindTorrent(SelectedHash);
  if T = nil then
  begin
    MessageDlg(_('msg.select.torrent'), mtInformation, [mbOK], 0);
    Exit;
  end;
  P := Trim(T.SavePath);
  if P = '' then Exit;
  P := MapRemotePath(FProfiles.PathMap, P);
  if FileExists(P) then
    P := ExtractFilePath(P);
  if not OpenLocalPath(P) then
    MessageDlg(Format(_('msg.error'), [P]), mtError, [mbOK], 0);
end;

procedure TMainForm.actOpenContentExecute(Sender: TObject);
var
  T: TTorrent;
begin
  T := FindTorrent(SelectedHash);
  if T = nil then
  begin
    MessageDlg(_('msg.select.torrent'), mtInformation, [mbOK], 0);
    Exit;
  end;
  if Trim(T.SavePath) = '' then Exit;
  if not OpenLocalPath(MapRemotePath(FProfiles.PathMap, T.SavePath)) then
    MessageDlg(Format(_('msg.error'), [T.SavePath]), mtError, [mbOK], 0);
end;

procedure TMainForm.miViewSelectAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvTorrents.Items.Count - 1 do
    lvTorrents.Items[I].Selected := True;
end;

procedure TMainForm.miViewFilterPanelClick(Sender: TObject);
begin
  FProfiles.ShowFilterPanel := not FProfiles.ShowFilterPanel;
  FProfiles.Save;
  ApplyViewSettings;
end;

procedure TMainForm.miViewDetailsPanelClick(Sender: TObject);
begin
  FProfiles.ShowDetailsPanel := not FProfiles.ShowDetailsPanel;
  FProfiles.Save;
  ApplyViewSettings;
end;

procedure TMainForm.miViewToolbarClick(Sender: TObject);
begin
  FProfiles.ShowToolbar := not FProfiles.ShowToolbar;
  FProfiles.Save;
  ApplyViewSettings;
end;

procedure TMainForm.miViewStatusBarClick(Sender: TObject);
begin
  FProfiles.ShowStatusBar := not FProfiles.ShowStatusBar;
  FProfiles.Save;
  ApplyViewSettings;
end;

procedure TMainForm.miAppSettingsClick(Sender: TObject);
begin
  if not TAppSettingsDialog.Execute(FProfiles) then
    Exit;
  FProfiles.Save;
  ApplyViewSettings;
  ApplyFontScale;
  ApplyProxySettings;
  ApplyRunAtStartup(FProfiles.RunAtStartup);
  UpdateRefreshInterval;
end;

procedure TMainForm.miUtSettingsClick(Sender: TObject);
begin
  TUtSettingsDialog.Execute(FRpc);
end;

procedure TMainForm.actCopyMagnetExecute(Sender: TObject);
var
  T: TTorrent;
  Mag: string;
begin
  T := FindTorrent(SelectedHash);
  if T = nil then
  begin
    MessageDlg(_('msg.select.torrent'), mtInformation, [mbOK], 0);
    Exit;
  end;
  Mag := 'magnet:?xt=urn:btih:' + LowerCase(T.Hash);
  if Trim(T.Name) <> '' then
    Mag := Mag + '&dn=' + EncodeURLComponent(T.Name);
  Clipboard.AsText := Mag;
end;

procedure TMainForm.actQueueTopExecute(Sender: TObject);
begin
  RunAction('queuetop');
end;

procedure TMainForm.actQueueUpExecute(Sender: TObject);
begin
  RunAction('queueup');
end;

procedure TMainForm.actQueueDownExecute(Sender: TObject);
begin
  RunAction('queuedown');
end;

procedure TMainForm.actQueueBottomExecute(Sender: TObject);
begin
  RunAction('queuebottom');
end;

procedure TMainForm.actColumnsExecute(Sender: TObject);
var
  Dlg: TForm;
  CL: TCheckListBox;
  OKBtn, CancelBtn: TButton;
  I: Integer;
begin
  Dlg := TForm.CreateNew(Self);
  try
    Dlg.Caption := _('act.columns');
    Dlg.Position := poOwnerFormCenter;
    Dlg.BorderStyle := bsDialog;
    Dlg.Width := 320;
    Dlg.Height := 420;
    CL := TCheckListBox.Create(Dlg);
    CL.Parent := Dlg;
    CL.SetBounds(12, 12, 280, 320);
    for I := 0 to lvTorrents.Columns.Count - 1 do
    begin
      CL.Items.Add(lvTorrents.Columns[I].Caption);
      CL.Checked[I] := lvTorrents.Columns[I].Visible;
    end;
    OKBtn := TButton.Create(Dlg);
    OKBtn.Parent := Dlg;
    OKBtn.Caption := _('dlg.ok');
    OKBtn.ModalResult := mrOK;
    OKBtn.SetBounds(120, 350, 80, 28);
    CancelBtn := TButton.Create(Dlg);
    CancelBtn.Parent := Dlg;
    CancelBtn.Caption := _('dlg.cancel');
    CancelBtn.ModalResult := mrCancel;
    CancelBtn.SetBounds(212, 350, 80, 28);
    if Dlg.ShowModal = mrOK then
      for I := 0 to CL.Items.Count - 1 do
        lvTorrents.Columns[I].Visible := CL.Checked[I];
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.actHomePageExecute(Sender: TObject);
begin
  OpenURLInBrowser('https://github.com/gazizovemil/utorrent-remote-gui');
end;

procedure TMainForm.actLangRUExecute(Sender: TObject);
begin
  // kept for LFM compatibility; languages come from lang\*.lng
end;

procedure TMainForm.actLangENExecute(Sender: TObject);
begin
end;

procedure TMainForm.actAboutExecute(Sender: TObject);
begin
  TAboutDialog.Execute;
end;

procedure TMainForm.cmbProfileChange(Sender: TObject);
begin
  if FUpdatingCombo then Exit;
  if cmbProfile = nil then Exit;
  if cmbProfile.ItemIndex < 0 then Exit;
  FProfiles.ActiveIndex := cmbProfile.ItemIndex;
  FProfiles.Save;
  UpdateProfileButton;
  BuildProfileMenu;
  if FRpc.Connected then
    ConnectActiveProfile;
end;

procedure TMainForm.actDisconnectExecute(Sender: TObject);
begin
  StopRefreshThread;
  FRpc.Disconnect;
  FLastList.Clear;
  FIncompleteHashes.Clear;
  FErrorHashes.Clear;
  FCompletionReady := False;
  FErrorReady := False;
  lvTorrents.Items.Clear;
  ClearDetails;
  InitFilterTree;
  FSelectedHash := '';
  SetConnectedUI(False);
  StatusBar1.Panels[0].Text := _('status.noconnect');
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
  UpdateTrayHint(nil);
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  FAllowClose := True;
  TrayIcon1.Visible := False;
  Close;
end;

procedure TMainForm.actRefreshExecute(Sender: TObject);
begin
  if FThread <> nil then
    FThread.TriggerNow;
end;

procedure TMainForm.OnRefresh(Sender: TObject; List: TTorrentList);
begin
  FLastList.Assign(List);
  TrackCompletions(FLastList);
  TrackErrors(FLastList);
  UpdateFilterCounts(FLastList);
  ApplyList(FLastList);
end;

procedure TMainForm.OnRpcError(Sender: TObject; const Msg: string);
begin
  if Msg <> '' then
    StatusBar1.Panels[0].Text := Format(_('msg.error'), [Msg]);
end;

procedure TMainForm.UpdateStatusBar(List: TTorrentList);
var
  I: Integer;
  DL, UL: Int64;
  P: TConnectionProfile;
begin
  DL := 0;
  UL := 0;
  if List <> nil then
    for I := 0 to List.Count - 1 do
    begin
      Inc(DL, List[I].DownSpeed);
      Inc(UL, List[I].UpSpeed);
    end;
  StatusBar1.Panels[1].Text := Format('%s: %s', [_('status.dl'), FormatSpeed(DL)]);
    StatusBar1.Panels[2].Text := Format('%s: %s', [_('status.ul'), FormatSpeed(UL)]);
  if FRpc.Connected and (FProfiles.Count > 0) then
  begin
    P := FProfiles[FProfiles.ActiveIndex];
    StatusBar1.Panels[0].Text := Format('uTorrent build %d @ %s:%d',
      [FRpc.Build, P.Host, P.Port]);
  end;
  UpdateTrayHint(List);
end;

procedure TMainForm.ApplyList(List: TTorrentList);
var
  I: Integer;
  T: TTorrent;
  Item: TListItem;
  PrevHash: string;
  SelIndex: Integer;
begin
  if List = nil then Exit;
  FUpdatingList := True;
  PrevHash := FSelectedHash;
  SelIndex := -1;
  lvTorrents.Items.BeginUpdate;
  try
    lvTorrents.Items.Clear;
    for I := 0 to List.Count - 1 do
    begin
      T := List[I];
      if not MatchFilter(T) then Continue;
      Item := lvTorrents.Items.Add;
      Item.Caption := T.Name;
      Item.SubItems.Add(FormatByteSize(T.Size));
      Item.SubItems.Add(FormatByteSize(T.Downloaded));
      Item.SubItems.Add(FormatPercent(T.Progress));
      Item.SubItems.Add(T.StatusText);
      Item.SubItems.Add(Format('%d (%d)', [T.SeedsConnected, T.SeedsSwarm]));
      Item.SubItems.Add(Format('%d (%d)', [T.PeersConnected, T.PeersSwarm]));
      Item.SubItems.Add(FormatSpeed(T.DownSpeed));
      Item.SubItems.Add(FormatSpeed(T.UpSpeed));
      Item.SubItems.Add(FormatByteSize(T.Uploaded));
      Item.SubItems.Add(FormatByteSize(T.Remaining));
      Item.SubItems.Add(FormatRatio(T.Ratio));
      Item.SubItems.Add(FormatETA(T.ETA));
      Item.SubItems.Add(T.LabelName);
      Item.SubItems.Add(T.Hash); // last visible-hidden column / last subitem
      if (PrevHash <> '') and (T.Hash = PrevHash) then
        SelIndex := lvTorrents.Items.Count - 1;
    end;
  finally
    lvTorrents.Items.EndUpdate;
    FUpdatingList := False;
  end;
  UpdateStatusBar(List);
  if SelIndex >= 0 then
  begin
    lvTorrents.Items[SelIndex].Selected := True;
    lvTorrents.Items[SelIndex].MakeVisible(False);
    // SelectItem may skip reload when hash unchanged; force details fill
    FSelectedHash := SelectedHash;
    if FSelectedHash <> '' then
      LoadDetails(FSelectedHash);
  end
  else if (PrevHash <> '') and (List.FindByHash(PrevHash) = nil) then
  begin
    FSelectedHash := '';
    ClearDetails;
  end
  else if (lvTorrents.Items.Count > 0) and (lvTorrents.Selected = nil) then
  begin
    // first fill: auto-select first row so details appear
    lvTorrents.Items[0].Selected := True;
    FSelectedHash := SelectedHash;
    if FSelectedHash <> '' then
      LoadDetails(FSelectedHash);
  end;
end;

function TMainForm.SelectedHash: string;
var
  Item: TListItem;
begin
  Result := '';
  Item := lvTorrents.Selected;
  if (Item = nil) or (Item.SubItems.Count = 0) then
    Exit;
  // Hash is always the last subitem
  Result := Item.SubItems[Item.SubItems.Count - 1];
end;

function TMainForm.FindTorrent(const Hash: string): TTorrent;
begin
  if FLastList = nil then
    Result := nil
  else
    Result := FLastList.FindByHash(Hash);
end;

procedure TMainForm.lvTorrentsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  H: string;
begin
  if FUpdatingList or not Selected then Exit;
  H := SelectedHash;
  if H = '' then Exit;
  if H = FSelectedHash then
  begin
    // still refresh if details were never filled
    if Trim(lblNameVal.Caption) = '' then
      LoadDetails(H);
    Exit;
  end;
  FSelectedHash := H;
  LoadDetails(H);
end;

procedure TMainForm.ClearDetails;
begin
  FProgressPermille := 0;
  pbDone.Invalidate;
  txDonePct.Caption := '0.0%';
  lblStatusVal.Caption := '';
  lblDownloadedVal.Caption := '';
  lblUploadedVal.Caption := '';
  lblSpeedVal.Caption := '';
  lblRemainingVal.Caption := '';
  lblRatioVal.Caption := '';
  lblSeedsVal.Caption := '';
  lblPeersVal.Caption := '';
  lblErrorVal.Caption := '';
  lblNameVal.Caption := '';
  lblSizeVal.Caption := '';
  lblHashVal.Caption := '';
  lblPathVal.Caption := '';
  lblAddedVal.Caption := '';
  lblCompletedVal.Caption := '';
  SetCommentLink('');
  lvTrackers.Items.Clear;
  lvFiles.Items.Clear;
end;

function TMainForm.FormatUnixTime(TS: Int64): string;
begin
  if TS <= 0 then
    Result := ''
  else
    Result := FormatDateTime('dd.mm.yyyy hh:nn:ss', UnixToDateTime(TS));
end;

procedure TMainForm.SetCommentLink(const Comment: string);
var
  URLs: TStringList;
begin
  FCommentURL := '';
  txComment.Caption := Comment;
  txComment.Font.Color := clWindowText;
  txComment.Font.Style := [];
  txComment.Cursor := crDefault;
  txComment.ShowHint := False;
  if Trim(Comment) = '' then Exit;
  URLs := TStringList.Create;
  try
    ExtractURLs(Comment, URLs);
    if URLs.Count > 0 then
    begin
      FCommentURL := URLs[0];
      txComment.Font.Color := clBlue;
      txComment.Font.Style := [fsUnderline];
      txComment.Cursor := crHandPoint;
      txComment.Hint := FCommentURL;
      txComment.ShowHint := True;
    end;
  finally
    URLs.Free;
  end;
end;

procedure TMainForm.txCommentClick(Sender: TObject);
begin
  if FCommentURL <> '' then
    OpenURLInBrowser(FCommentURL);
end;

procedure TMainForm.pbDonePaint(Sender: TObject);
var
  R: TRect;
  MidY, FillRight: Integer;
  C: TCanvas;
  Light: TColor;
begin
  C := pbDone.Canvas;
  R := pbDone.ClientRect;
  // TransGUI-style gradient progress
  C.Pen.Color := clBtnFace;
  C.Brush.Color := clBtnFace;
  C.Rectangle(R);
  InflateRect(R, -1, -1);
  C.Brush.Color := clWindow;
  C.FillRect(R);
  if FProgressPermille <= 0 then Exit;

  FillRight := R.Left + MulDiv(R.Right - R.Left, FProgressPermille, 1000);
  if FillRight <= R.Left then Exit;
  MidY := (R.Top + R.Bottom) div 2;
  Light := GetLikeColor(clHighlight, 70);
  C.GradientFill(Rect(R.Left, R.Top, FillRight, MidY), Light, clHighlight, gdVertical);
  C.GradientFill(Rect(R.Left, MidY, FillRight, R.Bottom), clHighlight, Light, gdVertical);
end;

procedure TMainForm.LoadDetails(const Hash: string);
var
  T: TTorrent;
  Props: TTorrentProps;
  Files: TTorrentFileList;
  Comment: string;
  Dirs: array of string;
  I: Integer;
  Item: TListItem;
  Lines: TStringList;
begin
  ClearDetails;
  T := FindTorrent(Hash);
  if T <> nil then
  begin
    if T.Progress < 0 then
      FProgressPermille := 0
    else if T.Progress > 1000 then
      FProgressPermille := 1000
    else
      FProgressPermille := Integer(T.Progress);
    pbDone.Invalidate;
    txDonePct.Caption := FormatPercent(T.Progress);
    lblStatusVal.Caption := T.StatusText;
    lblDownloadedVal.Caption := FormatByteSize(T.Downloaded);
    lblUploadedVal.Caption := FormatByteSize(T.Uploaded);
    lblSpeedVal.Caption := Format('↓ %s  ↑ %s',
      [FormatSpeed(T.DownSpeed), FormatSpeed(T.UpSpeed)]);
    lblRemainingVal.Caption := FormatByteSize(T.Remaining);
    lblRatioVal.Caption := FormatRatio(T.Ratio);
    lblSeedsVal.Caption := Format(_('fmt.of'), [T.SeedsConnected, T.SeedsSwarm]);
    lblPeersVal.Caption := Format(_('fmt.of'), [T.PeersConnected, T.PeersSwarm]);
    lblErrorVal.Caption := T.StatusMessage;
    if (T.Status and ST_ERROR) = 0 then
      lblErrorVal.Caption := '';
    lblNameVal.Caption := T.Name;
    lblSizeVal.Caption := FormatByteSize(T.Size);
    lblHashVal.Caption := T.Hash;
    lblPathVal.Caption := T.SavePath;
    lblAddedVal.Caption := FormatUnixTime(T.DateAdded);
    lblCompletedVal.Caption := FormatUnixTime(T.DateCompleted);
  end;

  Comment := '';
  if FRpc.GetProps(Hash, Props) then
  try
    Comment := Props.Comment;
    Lines := TStringList.Create;
    try
      Lines.Text := StringReplace(Props.Trackers, #10, LineEnding, [rfReplaceAll]);
      lvTrackers.Items.BeginUpdate;
      try
        lvTrackers.Items.Clear;
        for I := 0 to Lines.Count - 1 do
          if Trim(Lines[I]) <> '' then
          begin
            Item := lvTrackers.Items.Add;
            Item.Caption := Trim(Lines[I]);
          end;
      finally
        lvTrackers.Items.EndUpdate;
      end;
    finally
      Lines.Free;
    end;
  finally
    Props.Free;
  end;

  if Trim(Comment) = '' then
  begin
    SetLength(Dirs, 2);
    Dirs[0] := FRpc.TorrentFilesDir;
    Dirs[1] := FRpc.CompletedTorrentsDir;
    Comment := ReadCommentForHash(Dirs, Hash);
  end;
  SetCommentLink(Comment);

  if FRpc.GetFiles(Hash, Files) then
  try
    lvFiles.Items.BeginUpdate;
    try
      for I := 0 to Files.Count - 1 do
      begin
        Item := lvFiles.Items.Add;
        Item.Caption := Files[I].Name;
        Item.SubItems.Add(FormatByteSize(Files[I].Size));
        Item.SubItems.Add(Files[I].ProgressText);
        Item.SubItems.Add(Files[I].PriorityText);
      end;
    finally
      lvFiles.Items.EndUpdate;
    end;
  finally
    Files.Free;
  end;
end;

procedure TMainForm.RunAction(const ActionName: string);
var
  H: string;
begin
  H := SelectedHash;
  if H = '' then
  begin
    MessageDlg(_('msg.select.torrent'), mtInformation, [mbOK], 0);
    Exit;
  end;
  if not FRpc.TorrentAction(ActionName, H) then
    MessageDlg(Format(_('msg.error'), [FRpc.LastError]), mtError, [mbOK], 0);
  if FThread <> nil then
    FThread.TriggerNow;
end;

procedure TMainForm.actStartExecute(Sender: TObject);
begin
  RunAction('start');
end;

procedure TMainForm.actForceStartExecute(Sender: TObject);
begin
  RunAction('forcestart');
end;

procedure TMainForm.actPauseExecute(Sender: TObject);
begin
  RunAction('pause');
end;

procedure TMainForm.actStopExecute(Sender: TObject);
begin
  RunAction('stop');
end;

procedure TMainForm.actRecheckExecute(Sender: TObject);
begin
  RunAction('recheck');
end;

procedure TMainForm.actRemoveExecute(Sender: TObject);
begin
  if MessageDlg(_('msg.remove'), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  RunAction('remove');
  FSelectedHash := '';
  ClearDetails;
end;

procedure TMainForm.actRemoveDataExecute(Sender: TObject);
begin
  if MessageDlg(_('msg.removedata'), mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  RunAction('removedata');
  FSelectedHash := '';
  ClearDetails;
end;

procedure TMainForm.actAddFileExecute(Sender: TObject);
var
  Fn: string;
begin
  OpenDialog1.Filter := _('of.torrent');
  if not OpenDialog1.Execute then Exit;
  Fn := OpenDialog1.FileName;
  if not FRpc.AddFile(Fn) then
    MessageDlg(Format(_('msg.error'), [FRpc.LastError]), mtError, [mbOK], 0)
  else
  begin
    if FProfiles.DeleteTorrentAfterAdd then
      SysUtils.DeleteFile(Fn);
    if FThread <> nil then
      FThread.TriggerNow;
  end;
end;

procedure TMainForm.actAddURLExecute(Sender: TObject);
var
  URL: string;
begin
  URL := '';
  if not InputQuery(_('msg.addurl'), 'URL:', URL) then Exit;
  URL := Trim(URL);
  if URL = '' then Exit;
  if not FRpc.AddURL(URL) then
    MessageDlg(Format(_('msg.error'), [FRpc.LastError]), mtError, [mbOK], 0)
  else if FThread <> nil then
    FThread.TriggerNow;
end;

end.

