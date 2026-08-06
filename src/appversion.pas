unit AppVersion;

{$mode objfpc}{$H+}

interface

{ Pre-1.0 versioning: 0.N.0 where N is the iterative build count. }
const
  AppVerMajor    = 0;
  AppVerMinor    = 22;
  AppVerPatch    = 0;
  AppBuildNumber = 22;
  AppVerStr      = '0.23.0';
  AppName        = 'uTorrent Remote GUI';
  AppHomeURL     = 'https://github.com/gazizovemil/utorrent-remote-gui';

function AppTitleWithVersion: string;
function AppTitleWithVersionLocalized(const LocalizedName: string): string;

implementation

uses
  SysUtils;

function AppTitleWithVersion: string;
begin
  Result := Format('%s v%s', [AppName, AppVerStr]);
end;

function AppTitleWithVersionLocalized(const LocalizedName: string): string;
var
  N: string;
begin
  N := Trim(LocalizedName);
  if N = '' then
    N := AppName;
  Result := Format('%s v%s', [N, AppVerStr]);
end;

end.
