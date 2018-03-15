unit Average;

interface

type
  THistory = array[0..59] of double;

  TAverage = class
  private
    FMin: double;
    FMinCount: integer;
    FHour: THistory;
    FHourCount: integer;
    F24HourIndex: integer;
    FHourIndex: integer;
    FDay: THistory;             //24 Minutes intervall
    FDayCount: integer;
    FDayIndex: integer;
  public
    procedure AddUsage(usage: double);
    function AverageCurrentMinute: double;
    function AveragePerHour: double;
    constructor Create;
    function MinuteValue(index: integer; raw: boolean = false): double;
    function HourValue(index: integer; raw: boolean = false): double;
  end;

implementation

{ TAverage }

procedure TAverage.AddUsage;

  procedure incIndex(var i: integer);
  begin
    i := (i + 1) mod 60;
  end;

  function average24 : double;
  var i: integer;
  begin
    for i := 37 to 60 do
      result := result + FHour[(FHourIndex + i) mod 60];
    result := result / 24;
  end;

begin
  FMin := FMin + usage;
  if FMinCount < 59 then
    inc(FMinCount)
  else
  begin
    FMinCount := 0;
    FHour[FHourIndex] := Fmin / 60;
    FMin := 0;
    if FHourCount < 60 then inc(FHourCount);
    incIndex(FHourIndex);
    F24HourIndex := (F24HourIndex +1) mod 24;
    if F24HourIndex = 0 then
    begin
      FDay[FDayIndex] := average24;
      if FDayCount < 60 then inc(FDayCount);
      incIndex(FDayIndex);
    end;
  end;
end;

function TAverage.AverageCurrentMinute: double;
begin
  result := FMin / (FMinCount + 1);
end;

function TAverage.AveragePerHour;
var d: double;
    i: integer;
begin
  for i := 0 to FHourCount -1 do
    d := d + FHour[i];
  if FHourCount = 0 then
    result := AverageCurrentMinute
  else
    result := d / FHourCount;
end;

constructor TAverage.Create;
begin
  FMin := 0;
  FMinCount := 0;
  FHourIndex := 0;
  FHourCount := 0;
end;

function TAverage.MinuteValue;
begin
  if index in [0..59] then
    if raw = true then
      result := FHour[index]
    else
    begin
      result := FHour[(index + FHourIndex) mod 60]
    end
  else
    result := 0;
end;

function TAverage.HourValue;
begin
  if index in [0..59] then
    if raw = true then
      result := FDay[index]
    else
    begin
      result := FDay[(index + FDayIndex) mod 60]
    end
  else
    result := 0;
end;

end.
