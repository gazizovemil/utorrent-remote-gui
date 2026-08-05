unit AboutForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, LCLVersion, Lang, Utils, AppVersion;

type
  { TAboutDialog }

  TAboutDialog = class(TForm)
    PageControl1: TPageControl;
    tsAbout: TTabSheet;
    tsLicense: TTabSheet;
    imgIcon: TImage;
    lblTitle: TLabel;
    lblVersion: TLabel;
    lblBuild: TLabel;
    lblCopyright: TLabel;
    lblHome: TLabel;
    Bevel1: TBevel;
    memLicense: TMemo;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblHomeClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    procedure ApplyLanguage;
    procedure LoadAppIcon;
  public
    class procedure Execute;
  end;

implementation

{$R *.lfm}

const
  HomeURL = AppHomeURL;

procedure TAboutDialog.LoadAppIcon;
var
  Dir, Png, Ico: string;
begin
  Dir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'images' + PathDelim;
  Png := Dir + 'app_icon.png';
  Ico := Dir + 'app.ico';
  try
    if FileExists(Png) then
      imgIcon.Picture.LoadFromFile(Png)
    else if FileExists(Ico) then
      imgIcon.Picture.LoadFromFile(Ico);
  except
  end;
end;

procedure TAboutDialog.FormCreate(Sender: TObject);
begin
  LoadAppIcon;
  lblHome.Font.Color := clBlue;
  lblHome.Font.Style := [fsUnderline];
  lblHome.Cursor := crHandPoint;
  memLicense.Lines.Text :=
    'uTorrent Remote GUI' + LineEnding + LineEnding +
    'Permission is hereby granted, free of charge, to any person obtaining a copy ' +
    'of this software and associated documentation files (the "Software"), to deal ' +
    'in the Software without restriction, including without limitation the rights ' +
    'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell ' +
    'copies of the Software, and to permit persons to whom the Software is ' +
    'furnished to do so, subject to the following conditions:' + LineEnding + LineEnding +
    'The above copyright notice and this permission notice shall be included in ' +
    'all copies or substantial portions of the Software.' + LineEnding + LineEnding +
    'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.';
end;

procedure TAboutDialog.ApplyLanguage;
begin
  Caption := _('about.title');
  tsAbout.Caption := _('about.tab.about');
  tsLicense.Caption := _('about.tab.license');
  lblTitle.Caption := _('app.title');
  lblVersion.Caption := Format(_('about.version'), [AppVerStr]);
  lblBuild.Caption := Format('Build %d   Fpc : %s   Lazarus : %s',
    [AppBuildNumber, {$I %FPCVERSION%}, lcl_version]);
  lblCopyright.Caption := _('about.copyright');
  lblHome.Caption := _('about.homepage');
  btnOK.Caption := _('about.ok');
end;

procedure TAboutDialog.FormShow(Sender: TObject);
begin
  ApplyLanguage;
end;

procedure TAboutDialog.lblHomeClick(Sender: TObject);
begin
  OpenURLInBrowser(HomeURL);
end;

procedure TAboutDialog.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

class procedure TAboutDialog.Execute;
begin
  with TAboutDialog.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

end.
