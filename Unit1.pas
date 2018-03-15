unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  uTotalCpuUsagePct, Average, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    Timer2: TTimer;
    TrackBar1: TTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    Average: TAverage;
    bars: array[0..59] of TPanel;
    max: double;
    procedure SetBar(index: integer; value: double);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
  Average := TAverage.Create;
  Panel1.Visible := false;
  for i := 0 to 59 do
  begin
    bars[i] := TPanel.Create(Groupbox1);
    bars[i].Parent := Groupbox1;
    bars[i].ParentColor := false;
    bars[i].ParentBackground := false;
    bars[i].Color := Panel1.Color;
    bars[i].Width := Panel1.Width;
    bars[i].Top := Panel1.Top;
    bars[i].Height := Panel1.Height;
    bars[i].Width := Panel1.Width;
    bars[i].Left := ((Panel1.Width + 2) * i) + Panel1.Left;
  end;
  GroupBox1.Width := ((Panel1.Width + 2) * (i + 0)) + (Panel1.Left * 2);
  ClientWidth := GroupBox1.Width + (2 * GroupBox1.Left);
  Timer2Timer(self);
  // start cpu load thread
  TThread.CreateAnonymousThread(
    procedure
    begin
      while True do
      begin
        sleep(1000);
      end;
    end).Start;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  TotalCPUusagePercentage: Double;
begin
  TotalCPUusagePercentage := GetTotalCpuUsagePct();
  Average.AddUsage(TotalCPUusagePercentage);
  Label1.Caption := 'Total cpu: ' + IntToStr(Round(TotalCPUusagePercentage)) + '%';
  Label2.Caption := 'Average cpu: ' + IntToStr(Round(Average.AveragePerHour)) + '%'
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var i: integer;
begin
  max := 0;
  if Trackbar1.Position = 1 then
  begin
    for i := 0 to 59 do
      if max < Average.MinuteValue(i) then max := Average.MinuteValue(i);
    for i := 0 to 59 do
      SetBar(i, Average.MinuteValue(i));

  end
  else
  begin
    for i := 0 to 59 do
      if max < Average.HourValue(i) then max := Average.HourValue(i);
    for i := 0 to 59 do
      SetBar(i, Average.HourValue(i));
  end;
  GroupBox1.Caption := inttostr(round(max)) + '% Maximum';
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Timer2Timer(self);
end;

procedure TForm1.SetBar(index: integer; value: Double);
begin
  if max = 0 then
    bars[index].Height := 1
  else
    bars[index].Height := round(value / max * Panel1.Height) + 1;
  bars[index].Top := Panel1.Top + Panel1.Height - bars[index].Height;
end;

end.
