unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, JvPrvwDoc, ComCtrls, StdCtrls, ExtCtrls, Menus, jpeg,
  JvRichEdit, JvPrvwRender;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    udCols: TUpDown;
    Edit2: TEdit;
    udRows: TUpDown;
    Edit3: TEdit;
    udShadowWidth: TUpDown;
    Label4: TLabel;
    Edit4: TEdit;
    udZoom: TUpDown;
    PrinterSetupDialog1: TPrinterSetupDialog;
    cbPreview: TComboBox;
    Label5: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Printer1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    View1: TMenuItem;
    First1: TMenuItem;
    Previous1: TMenuItem;
    Next1: TMenuItem;
    Last1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Options1: TMenuItem;
    mnuMargins: TMenuItem;
    PageControl1: TPageControl;
    tabPreview: TTabSheet;
    tabOriginal: TTabSheet;
    OpenDialog1: TOpenDialog;
    reOriginal: TJvRichEdit;
    PrintDialog1: TPrintDialog;
    Print1: TMenuItem;
    Label6: TLabel;
    cbScaleMode: TComboBox;
    StatusBar1: TStatusBar;
    N3: TMenuItem;
    PreviewForm1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure udColsClick(Sender: TObject; Button: TUDBtnType);
    procedure udRowsClick(Sender: TObject; Button: TUDBtnType);
    procedure udShadowWidthClick(Sender: TObject; Button: TUDBtnType);
    procedure udZoomClick(Sender: TObject; Button: TUDBtnType);
    procedure cbPreviewChange(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Printer1Click(Sender: TObject);
    procedure mnuMarginsClick(Sender: TObject);
    procedure First1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Last1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure cbScaleModeChange(Sender: TObject);
    procedure PreviewForm1Click(Sender: TObject);
  private
    { Private declarations }
    procedure OpenRTFFile(const Filename: string);
    procedure DoChange(Sender: TObject);
    procedure DoVertScroll(Sender: TObject);
    procedure BuildRTFPreview;
    procedure BuildTXTPreview;
    procedure BuildImagePreview;
    procedure OpenImages(Files: TStrings);
    procedure OpenTxtFile(const Filename: string);
    procedure OpenImage(const Filename: string);
  public
    { Public declarations }
    pd: TJvPreviewDoc;
    JvRTF: TJvPreviewRichEditRender;
    JvTxt: TJvPreviewStringsRender;
    JvImg: TJvPreviewGraphicRender;
  end;


var
  frmMain: TfrmMain;

implementation
uses
  Printers;

{$R *.dfm}


procedure TfrmMain.Print1Click(Sender: TObject);
var jp: TJvPrinter;
begin
  PrintDialog1.PrintRange := prAllPages;
  if pd.PageCount < 1 then
    PrintDialog1.Options := PrintDialog1.Options - [poPageNums]
  else
  begin
    PrintDialog1.Options := PrintDialog1.Options + [poPageNums];
    PrintDialog1.FromPage := 1;
    PrintDialog1.ToPage := pd.PageCount;
  end;
  if PrintDialog1.Execute then
  begin
    jp := TJvPrinter.Create(nil);
    try
      jp.Printer := Printer;
      if PrintDialog1.PrintRange = prPageNums then
        pd.PrintRange(jp, PrintDialog1.FromPage - 1, PrintDialog1.ToPage - 1, PrintDialog1.Copies, PrintDialog1.Collate)
      else
        pd.PrintRange(jp, 0, -1, PrintDialog1.Copies, PrintDialog1.Collate)
    finally
      jp.Free;
    end;
  end;
end;

function Max(Val1, Val2: integer): integer;
begin
  Result := Val1;
  if Val2 > Val1 then
    Result := Val2;
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  OpenDialog1.Filter := OpenDialog1.Filter + '|' + GraphicFilter(TGraphic);

  pd := TJvPreviewDoc.Create(self);
  pd.Parent := tabPreview;
  pd.Align := alClient;
  pd.TabStop := true;
  pd.BeginUpdate;
  pd.OnChange := DoChange;
  try
    pd.Options.DrawMargins := mnuMargins.Checked;
    pd.Options.Rows := udRows.Position;
    pd.Options.Cols := udCols.Position;
    pd.Options.Shadow.Offset := udShadowWidth.Position;
    pd.Options.Scale := udZoom.Position;
    pd.OnVertScroll := DoVertScroll;

    cbPreview.ItemIndex := 1; // printer
    cbPreviewChange(nil);
    cbScaleMode.ItemIndex := 0; // full page
//    cbScaleModeChange(nil);

  finally
    pd.EndUpdate;
  end;
end;

procedure TfrmMain.DoChange(Sender: TObject);
begin
  udCols.Position := pd.Options.Cols;
  udRows.Position := pd.Options.Rows;
  udShadowWidth.Position := pd.Options.Shadow.Offset;
  udZoom.Position := pd.Options.Scale;
  mnuMargins.Checked := pd.Options.DrawMargins;
  cbScaleMode.ItemIndex := Ord(pd.Options.ScaleMode);
  Statusbar1.Panels[0].Text := ExtractFilename(OpenDialog1.Filename);
  Statusbar1.Panels[1].Text := Format('%d pages', [pd.PageCount]);
  Statusbar1.Panels[2].Text := Format('Cols: %d, Rows: %d, Page %d', [pd.TotalCols, pd.VisibleRows, pd.TopPage]);
end;

procedure TfrmMain.udColsClick(Sender: TObject; Button: TUDBtnType);
begin
  pd.Options.Cols := udCols.Position;
  udCols.Position := pd.Options.Cols;
end;

procedure TfrmMain.udRowsClick(Sender: TObject; Button: TUDBtnType);
begin
  pd.Options.Rows := udRows.Position;
  udRows.Position := pd.Options.Rows;
end;

procedure TfrmMain.udShadowWidthClick(Sender: TObject; Button: TUDBtnType);
begin
  pd.Options.Shadow.Offset := udShadowWidth.Position;
  udShadowWidth.Position := pd.Options.Shadow.Offset;
end;

procedure TfrmMain.udZoomClick(Sender: TObject; Button: TUDBtnType);
begin
  pd.Options.Scale := udZoom.Position;
  udZoom.Position := pd.Options.Scale;
end;

procedure TfrmMain.cbPreviewChange(Sender: TObject);
var Ext: string;
begin
  case cbPreview.ItemIndex of
    0:
      pd.DeviceInfo.ReferenceHandle := 0; // reset to default (screen)
    1:
      pd.DeviceInfo.ReferenceHandle := Printer.Handle;
  end;
  // set 0.5 inch margin
  pd.DeviceInfo.OffsetLeft := Max(pd.DeviceInfo.InchToXPx(0.5), pd.DeviceInfo.OffsetLeft);
  pd.DeviceInfo.OffsetRight := Max(pd.DeviceInfo.InchToXPx(0.5), pd.DeviceInfo.OffsetRight);
  pd.DeviceInfo.OffsetTop := Max(pd.DeviceInfo.InchToYPx(0.5), pd.DeviceInfo.OffsetTop);
  pd.DeviceInfo.OffsetBottom := Max(pd.DeviceInfo.InchToYPx(0.5), pd.DeviceInfo.OffsetBottom);
  Ext := AnsiLowerCase(ExtractFileExt(OpenDialog1.Filename));
  case OpenDialog1.FilterIndex of
    1: BuildRTFPreview;
    2: BuildTxtPreview;
  else if Pos(Ext, AnsiLowerCase(GraphicFilter(TGraphic))) > 0 then
    BuildImagePreview
  else
    BuildRTFPreview;
  end;
end;

procedure TfrmMain.OpenRTFFile(const Filename: string);
begin
  Screen.Cursor := crHourGlass;
  try
    reOriginal.Lines.LoadFromFile(OpenDialog1.Filename);
    BuildRTFPreview;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.OpenTxtFile(const Filename: string);
begin
  Screen.Cursor := crHourGlass;
  try
    reOriginal.Lines.LoadFromFile(OpenDialog1.Filename);
    BuildTxtPreview;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.OpenImage(const Filename: string);
begin
  if JvImg = nil then
    JvImg := TJvPreviewGraphicRender.Create(self);
  with JvImg.Images.Add do
    Picture.LoadFromFile(Filename);
end;

procedure TfrmMain.OpenImages(Files: TStrings);
var i: integer;
begin
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to Files.Count - 1 do
      OpenImage(Files[i]);
    BuildImagePreview;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.Open1Click(Sender: TObject);
var Ext: string;
begin
  if OpenDialog1.Execute then
  begin
    Ext := AnsiLowerCase(ExtractFileExt(OpenDialog1.Filename));
    case OpenDialog1.FilterIndex of
      1: OpenRTFFile(OpenDialog1.Filename);
      2: OpenTxtFile(OpenDialog1.Filename);
    else if Pos(Ext, AnsiLowerCase(GraphicFilter(TGraphic))) > 0 then
      OpenImages(OpenDialog1.Files)
    else
      OpenRTFFile(OpenDialog1.Filename);
    end; // case
  end; // if
end;


procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.Printer1Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
  cbPreviewChange(Sender);
end;

procedure TfrmMain.mnuMarginsClick(Sender: TObject);
begin
  mnuMargins.Checked := not mnuMargins.Checked;
  pd.Options.DrawMargins := mnuMargins.Checked;
end;

procedure TfrmMain.First1Click(Sender: TObject);
begin
  pd.First;
end;

procedure TfrmMain.Previous1Click(Sender: TObject);
begin
  pd.Prior;
end;

procedure TfrmMain.Next1Click(Sender: TObject);
begin
  pd.Next;
end;

procedure TfrmMain.Last1Click(Sender: TObject);
begin
  pd.Last;
end;

procedure TfrmMain.About1Click(Sender: TObject);
begin
  ShowMessage('JvPreviewDocument Demo');
end;

procedure TfrmMain.cbScaleModeChange(Sender: TObject);
begin
  pd.Options.ScaleMode := TJvPreviewScaleMode(cbScaleMode.ItemIndex);
  cbScaleMode.ItemIndex := Ord(pd.Options.ScaleMode);
end;

procedure TfrmMain.DoVertScroll(Sender: TObject);
begin
  Statusbar1.Panels[2].Text := Format('Cols: %d, Rows: %d, Page %d', [pd.TotalCols, pd.VisibleRows, pd.TopPage]);
end;

procedure TfrmMain.BuildRTFPreview;
begin
  if JvRTF = nil then
    JvRTF := TJvPreviewRichEditRender.Create(self);
  with JvRTF do
  begin
    RichEdit := reOriginal;
    PrintPreview := pd;
    CreatePreview(false);
  end;
end;

procedure TfrmMain.BuildImagePreview;
begin
  if JvImg = nil then
    JvImg := TJvPreviewGraphicRender.Create(self);
  with JvImg do
  begin
    PrintPreview := pd;
    CreatePreview(false);
  end;
end;

procedure TfrmMain.BuildTXTPreview;
begin
  if JvTxt = nil then
    JvTxt := TJvPreviewStringsRender.Create(self);
  with JvTxt do
  begin
    PrintPreview := pd;
    Strings := reOriginal.Lines;
    CreatePreview(false);
  end;
end;

procedure TfrmMain.PreviewForm1Click(Sender: TObject);
begin
  with TJvPreviewControlRender.Create(nil) do
  try
    pd.TopPage := 0;
    PrintPreview := pd;
    Control := self;
    CreatePreview(false);
  finally
    Free;
  end;
end;

end.

