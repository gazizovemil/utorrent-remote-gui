unit Models;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, Lang;

const
  // uTorrent status bitmask
  ST_STARTED          = 1;
  ST_CHECKING         = 2;
  ST_START_AFTER_CHECK = 4;
  ST_CHECKED          = 8;
  ST_ERROR            = 16;
  ST_PAUSED           = 32;
  ST_QUEUED           = 64;
  ST_LOADED           = 128;

  // torrent[] field indices
  TI_HASH             = 0;
  TI_STATUS           = 1;
  TI_NAME             = 2;
  TI_SIZE             = 3;
  TI_PROGRESS         = 4;
  TI_DOWNLOADED       = 5;
  TI_UPLOADED         = 6;
  TI_RATIO            = 7;
  TI_UPSPEED          = 8;
  TI_DOWNSPEED        = 9;
  TI_ETA              = 10;
  TI_LABEL            = 11;
  TI_PEERS_CONNECTED  = 12;
  TI_PEERS_SWARM      = 13;
  TI_SEEDS_CONNECTED  = 14;
  TI_SEEDS_SWARM      = 15;
  TI_AVAILABILITY     = 16;
  TI_QUEUE_POSITION   = 17;
  TI_REMAINING        = 18;
  TI_DOWNLOAD_URL     = 19;
  TI_RSS_FEED_URL     = 20;
  TI_STATUS_MESSAGE   = 21;
  TI_STREAM_ID        = 22;
  TI_DATE_ADDED       = 23;
  TI_DATE_COMPLETED   = 24;
  TI_APP_UPDATE      = 25;
  TI_SAVE_PATH        = 26;

type
  TTorrent = class
  public
    Hash: string;
    Status: Integer;
    Name: string;
    Size: Int64;
    Progress: Int64;
    Downloaded: Int64;
    Uploaded: Int64;
    Ratio: Int64;
    UpSpeed: Int64;
    DownSpeed: Int64;
    ETA: Int64;
    LabelName: string;
    PeersConnected: Integer;
    PeersSwarm: Integer;
    SeedsConnected: Integer;
    SeedsSwarm: Integer;
    Availability: Int64;
    QueuePosition: Integer;
    Remaining: Int64;
    DownloadURL: string;
    RssFeedURL: string;
    StatusMessage: string;
    DateAdded: Int64;
    DateCompleted: Int64;
    SavePath: string;
    function StatusText: string;
    procedure AssignFromJSON(Arr: TJSONArray);
    procedure Assign(Source: TTorrent);
  end;

  TTorrentFile = class
  public
    Name: string;
    Size: Int64;
    Downloaded: Int64;
    Priority: Integer; // 0 skip, 1 low, 2 normal, 3 high
    function PriorityText: string;
    function ProgressText: string;
  end;

  TTorrentProps = class
  public
    Hash: string;
    Trackers: string;
    UlRate: Int64;
    DlRate: Int64;
    Comment: string;
    SuperSeed: Integer;
    SeedRatio: Int64;
    SeedTime: Int64;
    UlSlots: Integer;
    procedure AssignFromJSON(Obj: TJSONObject);
  end;

  TTorrentList = class
  private
    FItems: TFPList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TTorrent;
  public
    Build: Integer;
    CacheID: string;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function FindByHash(const AHash: string): TTorrent;
    procedure LoadFromListJSON(Root: TJSONObject);
    procedure Assign(Source: TTorrentList);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TTorrent read GetItem; default;
  end;

  TTorrentFileList = class
  private
    FItems: TFPList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TTorrentFile;
  public
    Hash: string;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromJSON(Root: TJSONObject);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TTorrentFile read GetItem; default;
  end;

function JsonGetStr(Arr: TJSONArray; Index: Integer; const Default: string = ''): string;
function JsonGetInt64(Arr: TJSONArray; Index: Integer; Default: Int64 = 0): Int64;
function JsonGetInt(Arr: TJSONArray; Index: Integer; Default: Integer = 0): Integer;

implementation

function JsonGetStr(Arr: TJSONArray; Index: Integer; const Default: string): string;
var
  D: TJSONData;
begin
  Result := Default;
  if (Arr = nil) or (Index < 0) or (Index >= Arr.Count) then
    Exit;
  D := Arr.Items[Index];
  if D = nil then
    Exit;
  case D.JSONType of
    jtString: Result := D.AsString;
    jtNumber: Result := D.AsString;
    jtNull: Result := Default;
  else
    Result := D.AsString;
  end;
end;

function JsonGetInt64(Arr: TJSONArray; Index: Integer; Default: Int64): Int64;
var
  D: TJSONData;
begin
  Result := Default;
  if (Arr = nil) or (Index < 0) or (Index >= Arr.Count) then
    Exit;
  D := Arr.Items[Index];
  if (D = nil) or (D.JSONType = jtNull) then
    Exit;
  try
    Result := D.AsInt64;
  except
    Result := Default;
  end;
end;

function JsonGetInt(Arr: TJSONArray; Index: Integer; Default: Integer): Integer;
begin
  Result := Integer(JsonGetInt64(Arr, Index, Default));
end;

{ TTorrent }

function TTorrent.StatusText: string;
begin
  if (Status and ST_ERROR) <> 0 then
  begin
    if StatusMessage <> '' then
      Result := Format(_('st.error.msg'), [StatusMessage])
    else
      Result := _('st.error');
  end
  else if (Status and ST_CHECKING) <> 0 then
    Result := _('st.checking')
  else if (Status and ST_PAUSED) <> 0 then
    Result := _('st.paused')
  else if (Status and ST_STARTED) <> 0 then
  begin
    if Progress >= 1000 then
      Result := _('st.seeding')
    else
      Result := _('st.downloading');
  end
  else if (Status and ST_QUEUED) <> 0 then
  begin
    if Progress >= 1000 then
      Result := _('st.queued.seed')
    else
      Result := _('st.queued');
  end
  else if Progress >= 1000 then
    Result := _('st.finished')
  else
    Result := _('st.stopped');
end;

procedure TTorrent.AssignFromJSON(Arr: TJSONArray);
begin
  Hash := UpperCase(JsonGetStr(Arr, TI_HASH));
  Status := JsonGetInt(Arr, TI_STATUS);
  Name := JsonGetStr(Arr, TI_NAME);
  Size := JsonGetInt64(Arr, TI_SIZE);
  Progress := JsonGetInt64(Arr, TI_PROGRESS);
  Downloaded := JsonGetInt64(Arr, TI_DOWNLOADED);
  Uploaded := JsonGetInt64(Arr, TI_UPLOADED);
  Ratio := JsonGetInt64(Arr, TI_RATIO);
  UpSpeed := JsonGetInt64(Arr, TI_UPSPEED);
  DownSpeed := JsonGetInt64(Arr, TI_DOWNSPEED);
  ETA := JsonGetInt64(Arr, TI_ETA);
  LabelName := JsonGetStr(Arr, TI_LABEL);
  PeersConnected := JsonGetInt(Arr, TI_PEERS_CONNECTED);
  PeersSwarm := JsonGetInt(Arr, TI_PEERS_SWARM);
  SeedsConnected := JsonGetInt(Arr, TI_SEEDS_CONNECTED);
  SeedsSwarm := JsonGetInt(Arr, TI_SEEDS_SWARM);
  Availability := JsonGetInt64(Arr, TI_AVAILABILITY);
  QueuePosition := JsonGetInt(Arr, TI_QUEUE_POSITION);
  Remaining := JsonGetInt64(Arr, TI_REMAINING);
  DownloadURL := JsonGetStr(Arr, TI_DOWNLOAD_URL);
  RssFeedURL := JsonGetStr(Arr, TI_RSS_FEED_URL);
  StatusMessage := JsonGetStr(Arr, TI_STATUS_MESSAGE);
  DateAdded := JsonGetInt64(Arr, TI_DATE_ADDED);
  DateCompleted := JsonGetInt64(Arr, TI_DATE_COMPLETED);
  SavePath := JsonGetStr(Arr, TI_SAVE_PATH);
end;

procedure TTorrent.Assign(Source: TTorrent);
begin
  if Source = nil then
    Exit;
  Hash := Source.Hash;
  Status := Source.Status;
  Name := Source.Name;
  Size := Source.Size;
  Progress := Source.Progress;
  Downloaded := Source.Downloaded;
  Uploaded := Source.Uploaded;
  Ratio := Source.Ratio;
  UpSpeed := Source.UpSpeed;
  DownSpeed := Source.DownSpeed;
  ETA := Source.ETA;
  LabelName := Source.LabelName;
  PeersConnected := Source.PeersConnected;
  PeersSwarm := Source.PeersSwarm;
  SeedsConnected := Source.SeedsConnected;
  SeedsSwarm := Source.SeedsSwarm;
  Availability := Source.Availability;
  QueuePosition := Source.QueuePosition;
  Remaining := Source.Remaining;
  DownloadURL := Source.DownloadURL;
  RssFeedURL := Source.RssFeedURL;
  StatusMessage := Source.StatusMessage;
  DateAdded := Source.DateAdded;
  DateCompleted := Source.DateCompleted;
  SavePath := Source.SavePath;
end;

{ TTorrentFile }

function TTorrentFile.PriorityText: string;
begin
  case Priority of
    0: Result := _('prio.skip');
    1: Result := _('prio.low');
    2: Result := _('prio.normal');
    3: Result := _('prio.high');
  else
    Result := IntToStr(Priority);
  end;
end;

function TTorrentFile.ProgressText: string;
begin
  if Size <= 0 then
    Result := '0%'
  else
    Result := Format('%.1f%%', [Downloaded * 100.0 / Size]);
end;

{ TTorrentProps }

procedure TTorrentProps.AssignFromJSON(Obj: TJSONObject);

  function ReadInt64(const Key: string; Default: Int64): Int64;
  var
    D: TJSONData;
  begin
    Result := Default;
    D := Obj.Find(Key);
    if (D <> nil) and (D.JSONType <> jtNull) then
    try
      Result := D.AsInt64;
    except
      Result := Default;
    end;
  end;

  function ReadInt(const Key: string; Default: Integer): Integer;
  begin
    Result := Integer(ReadInt64(Key, Default));
  end;

begin
  if Obj = nil then
    Exit;
  Hash := UpperCase(Obj.Get('hash', ''));
  Trackers := Obj.Get('trackers', '');
  UlRate := ReadInt64('ulrate', 0);
  DlRate := ReadInt64('dlrate', 0);
  Comment := Obj.Get('comment', '');
  if Comment = '' then
    Comment := Obj.Get('Comment', '');
  SuperSeed := ReadInt('superseed', 0);
  SeedRatio := ReadInt64('seed_ratio', 0);
  SeedTime := ReadInt64('seed_time', 0);
  UlSlots := ReadInt('ulslots', 0);
end;

{ TTorrentList }

constructor TTorrentList.Create;
begin
  inherited Create;
  FItems := TFPList.Create;
  Build := 0;
  CacheID := '';
end;

destructor TTorrentList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TTorrentList.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    TTorrent(FItems[I]).Free;
  FItems.Clear;
end;

function TTorrentList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TTorrentList.GetItem(Index: Integer): TTorrent;
begin
  Result := TTorrent(FItems[Index]);
end;

function TTorrentList.FindByHash(const AHash: string): TTorrent;
var
  I: Integer;
  H: string;
begin
  H := UpperCase(AHash);
  for I := 0 to FItems.Count - 1 do
  begin
    Result := TTorrent(FItems[I]);
    if Result.Hash = H then
      Exit;
  end;
  Result := nil;
end;

procedure TTorrentList.LoadFromListJSON(Root: TJSONObject);
var
  Torrents: TJSONArray;
  Item: TJSONData;
  ItemData: TJSONData;
  Arr: TJSONArray;
  T: TTorrent;
  I: Integer;
begin
  Clear;
  if Root = nil then
    Exit;
  Build := Root.Get('build', 0);
  CacheID := Root.Get('torrentc', '');
  ItemData := Root.Find('torrents');
  if (ItemData = nil) or not (ItemData is TJSONArray) then
    Exit;
  Torrents := TJSONArray(ItemData);
  for I := 0 to Torrents.Count - 1 do
  begin
    Item := Torrents.Items[I];
    if not (Item is TJSONArray) then
      Continue;
    Arr := TJSONArray(Item);
    T := TTorrent.Create;
    T.AssignFromJSON(Arr);
    FItems.Add(T);
  end;
end;

procedure TTorrentList.Assign(Source: TTorrentList);
var
  I: Integer;
  T: TTorrent;
begin
  Clear;
  if Source = nil then
    Exit;
  Build := Source.Build;
  CacheID := Source.CacheID;
  for I := 0 to Source.Count - 1 do
  begin
    T := TTorrent.Create;
    T.Assign(Source[I]);
    FItems.Add(T);
  end;
end;

{ TTorrentFileList }

constructor TTorrentFileList.Create;
begin
  inherited Create;
  FItems := TFPList.Create;
  Hash := '';
end;

destructor TTorrentFileList.Destroy;
begin
  Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TTorrentFileList.Clear;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    TTorrentFile(FItems[I]).Free;
  FItems.Clear;
end;

function TTorrentFileList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TTorrentFileList.GetItem(Index: Integer): TTorrentFile;
begin
  Result := TTorrentFile(FItems[Index]);
end;

procedure TTorrentFileList.LoadFromJSON(Root: TJSONObject);
var
  FilesRoot: TJSONArray;
  FilesRootData: TJSONData;
  Pair: TJSONArray;
  FileArr: TJSONArray;
  Item: TJSONData;
  F: TTorrentFile;
  I: Integer;
begin
  Clear;
  Hash := '';
  if Root = nil then
    Exit;
  // files: [ hash, [ [name,size,downloaded,priority,...], ... ] ]
  FilesRootData := Root.Find('files');
  if (FilesRootData = nil) or not (FilesRootData is TJSONArray) then
    Exit;
  FilesRoot := TJSONArray(FilesRootData);
  if FilesRoot.Count < 2 then
    Exit;
  Hash := UpperCase(FilesRoot.Items[0].AsString);
  if not (FilesRoot.Items[1] is TJSONArray) then
    Exit;
  Pair := TJSONArray(FilesRoot.Items[1]);
  for I := 0 to Pair.Count - 1 do
  begin
    Item := Pair.Items[I];
    if not (Item is TJSONArray) then
      Continue;
    FileArr := TJSONArray(Item);
    F := TTorrentFile.Create;
    F.Name := JsonGetStr(FileArr, 0);
    F.Size := JsonGetInt64(FileArr, 1);
    F.Downloaded := JsonGetInt64(FileArr, 2);
    F.Priority := JsonGetInt(FileArr, 3);
    FItems.Add(F);
  end;
end;

end.
