unit UMultiDemo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ExtCtrls, FMX.StdCtrls, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit,
  FMX.EditBox, FMX.SpinBox;

type
  TForm1 = class(TForm)
    Button1: TButton;
    SD: TSaveDialog;
    Label2: TLabel;
    RateCombo: TComboBox;
    Label1: TLabel;
    SpinBox1: TSpinBox;
    Label3: TLabel;
    CodecCombo: TComboBox;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure MakeMovie(const filename: string);
    procedure ShowProgress(Videotime: int64);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses UFormatsM, UBitmaps2VideoM, FFMPEG, math;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SD.Execute then
    MakeMovie(SD.filename);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  Index: integer;
begin
  ListSupportedCodecs('.mp4', CodecCombo.Items, Index);
  CodecCombo.ItemIndex := Index;
end;

procedure TForm1.MakeMovie(const filename: string);
var
  bme: TBitmapEncoderM;
  t: double; // time in seconds
  TheColor: TBGR;
  PeriodRed, PeriodGreen, PeriodBlue: double;
  Width, Height: integer;
  FrameTime: double;
  CodecID: TAVCodecID;
  FrameRate: integer;
begin
  Width := 1080;
  Height := 720;
  CodecID := AV_CODEC_ID_MJPEG;
  if CodecCombo.ItemIndex >= 0 then
    CodecID := TAVCodecID(CodecCombo.Items.Objects[CodecCombo.ItemIndex]);
  FrameRate := StrToInt(RateCombo.Items.Strings[RateCombo.ItemIndex]);
  FrameTime:=1/FrameRate;
  bme := TBitmapEncoderM.Create(filename, Width, Height, FrameRate,
    trunc(SpinBox1.Value), CodecID, vsBicubic);
  try
    bme.OnProgress:=ShowProgress;
    PeriodRed := 1/8;
    PeriodGreen := 1/10.4; //actually 1/period
    PeriodBlue := 1/12.7;
    t := 0;
    // 30seconds of movie
    While t < 30 do
    begin
      TheColor.Red:=Trunc(127*(sin(2*Pi*PeriodRed*t)+1.01));
      TheColor.Green:=Trunc(127*(sin(2*Pi*PeriodGreen*t)+1.01));
      TheColor.Blue:=Trunc(127*(sin(2*Pi*PeriodBlue*t)+1.01));
      bme.AddColorFrame(TheColor);
      t:=t+FrameTime;
    end;
    bme.CloseFile;
  finally
    bme.free;
  end;

end;

procedure TForm1.ShowProgress(Videotime: int64);
begin
  Progressbar1.Value:=VideoTime;
  Progressbar1.Repaint;
end;

end.
