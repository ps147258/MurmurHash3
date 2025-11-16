// 中文
//
// 類型：高精度時間測量
// 編寫：Wei-Lun Huang
// 參考：
//   https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
//   https://en.wikipedia.org/wiki/High_Precision_Event_Timer
// 說明：利用 WindowsAPI QPC 取得高精度時間，通常用來量測效能的極小差異
//
// 作用：
// 1. TPerformanceGauge
//    如果需要多組不同測量，或用於不同執行續。
// 2. PerformanceGauge
//    建立或取得共用的 TPerformanceGauge，但不可同時使用在不同執行序上。
//
// * 關於 TPerformanceGauge.ShotStart(Calibration = True)
//   在近期高性能 CPU上擷取開銷極小(目前我的機器平均為 1tick)，
//   因此在高性能 CPU上可以忽視(因此 Calibration 預設值是 False)。
//
// 歷程：
//   2025年05月01日 釋出 (註解修編於 2025年11月16日)
//
// 其他：<無>
//
// 最後變更日期：2025年11月16日
//

// English
//
// Type: High-Precision Time Measurement
// Author: Wei-Lun Huang
// Reference:
//   https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps
//   https://en.wikipedia.org/wiki/High_Precision_Event_Timer
// Description:
//   Utilizes the Windows API QPC (QueryPerformanceCounter) to obtain high-precision time,
//   typically used to measure extremely small differences in performance.
//
// Functionality / Purpose:
// 1. TPerformanceGauge
//    Used if multiple different measurements are needed, or for use across different threads.
// 2. PerformanceGauge
//    Creates or retrieves a shared TPerformanceGauge,
//    but must not be used concurrently on different threads.
//
// * Regarding TPerformanceGauge.ShotStart(Calibration = True)
//   The overhead for capture on modern high-performance CPUs is extremely small
//   (currently averaging 1 tick on my machine).
//   Therefore, it can be ignored on high-performance CPUs
//   (hence the default value for Calibration is False).
//
// History:
//   May 1 2025 Released ( Program comments revised on Nov 16 2025 )
//
// Others: <None>
//
// Last Modified Date: Nov 16 2025
//

unit HighAccuracyGauge;

interface

uses
  Winapi.Windows, System.SysUtils;

type
  TTimeUnit = (
    _PTU_Second,      // s.
    _PTU_Millisecond, // ms.
    _PTU_Microsecond, // us.
    _PTU_Nanoseconds, // ns.
    _PTU_Auto
  );

const
  LeastTimeUnit = _PTU_Nanoseconds;

  PerUnitTime: array[TTimeUnit] of Cardinal = (
    1,          //  s - One Second.
    1000,       // ms - Millisecond of one Second.
    1000000,    // us - Microsecond of one Second.
    1000000000, // ns - Nanoseconds of one Second.
    0
  );
  UnitNameLong: array[TTimeUnit] of string = (
    'Second', 'Millisecond', 'Microsecond', 'Nanoseconds', 'Auto');
  UnitNameShort: array[TTimeUnit] of array[0..2] of Char = (
    's', 'ms', 'us', 'ns', 't');

type
  TPerformanceStamps = record
    Frequency: Int64; // Ticks per second.
    Starting: Int64;  // Ticks.
    Ending: Int64;    // Ticks.
  end;

  TPerformanceGaugeOption = (_PGO_Calibration, _PGO_FirstShot);
  TPerformanceGaugeOptions = set of TPerformanceGaugeOption;

  TPerformanceGauge = class(TObject)
  private const
    DefaultTests = 100;
  private
    FTests: Byte;                // Number of tests.
    FDeviation: Cardinal;        // [Ticks] Time overhead during measurement
    FStamps: TPerformanceStamps; // Data by QPC
    FTotal: UInt64;              // [Ticks] EndTick - StartTick = TotalTick

    function GetFrequency: Int64; inline;
    function GetStarting: Int64; inline;
    function GetEnding: Int64; inline;

    procedure QueryCounter(var lpPerformanceCount: TLargeInteger); inline;
    procedure QueryFrequency(var lpPerformanceCount: TLargeInteger); overload; inline;
    procedure QueryFrequency; overload; inline;
    procedure QueryStarting; inline;
    procedure QueryEnding; inline;

    function GetLastTicks: Int64; inline;
    function GetLastTime(U: TTimeUnit): Int64; overload; inline;
    function GetLastTimeF(U: TTimeUnit): Currency; overload; inline;
    function GetLastTime(out Value: Int64; out TimeUnit: TTimeUnit): Boolean; overload; //inline;
    function GetLastTimeF(out Value: Currency; out TimeUnit: TTimeUnit): Boolean; overload; //inline;
    function GetLastTimeStr(TimeUnit: TTimeUnit): string; overload; //inline;
    function GetLastTimeStr: string; overload; //inline;
    function GetLastTimeStrF(TimeUnit: TTimeUnit): string; overload; //inline;
    function GetLastTimeStrF: string; overload; //inline;

    procedure IncreaseToTotal; inline;

    function GetTimeByUnit(out Value: Int64; TimeUnit: TTimeUnit): Boolean; overload; inline;
    function GetTimeByUnit(out Value: Currency; TimeUnit: TTimeUnit): Boolean; overload; inline;
  public
    constructor Create;
    destructor Destroy; override;

    function Test(Count: Byte): Integer;

    procedure ZeroTotal ; inline;
    procedure Initialize(Options: TPerformanceGaugeOptions = []); inline;

    function Shot: Boolean; inline;
    procedure ShotStart(Calibration: Boolean = False); inline;
    procedure ShotEnd; inline;

    procedure CalcTimeByUnit(out ValueOut: Int64; TicksIn: Int64; TimeUnit: TTimeUnit); overload; //inline;
    procedure CalcTimeByUnit(out ValueOut: Currency; TicksIn: Int64; TimeUnit: TTimeUnit); overload; //inline;
    function CalcTimeSimilar(out ValueOut: Int64; TicksIn: Int64): TTimeUnit; overload;
    function CalcTimeSimilar(out ValueOut: Currency; TicksIn: Int64): TTimeUnit; overload;

    function GetTimeStr(Ticks: Int64; TimeUnit: TTimeUnit = _PTU_Auto): string;
    function GetTimeStrF(Ticks: Int64; TimeUnit: TTimeUnit = _PTU_Auto): string;

    function GetTicks(out Value: Int64): Boolean; inline;
    function GetTime(out Value: Int64; out TimeUnit: TTimeUnit): Boolean; overload; inline;
    function GetTime: string; overload; inline;

    function GetSecond(out Value: Int64): Boolean; overload; inline;
    function GetSecond(out Value: Currency): Boolean; overload; inline;
    function GetMillisecond(out Value: Int64): Boolean; overload; inline;
    function GetMillisecond(out Value: Currency): Boolean; overload; inline;
    function GetMicrosecond(out Value: Int64): Boolean; overload; inline;
    function GetMicrosecond(out Value: Currency): Boolean; overload; inline;
    function GetNanoseconds(out Value: Int64): Boolean; overload; inline;
    function GetNanoseconds(out Value: Currency): Boolean; overload; inline;

    property Tests: Byte read FTests write FTests;

    // Ticks
    property Stamps: TPerformanceStamps read FStamps;
    property Frequency: Int64 read GetFrequency;
    property Starting: Int64 read GetStarting;
    property Ending: Int64 read GetEnding;
    property Total: UInt64 read FTotal; // Time
    property Deviation: Cardinal read FDeviation write FDeviation;
    property LastTicks: Int64 read GetLastTicks;

    // Time
    property LastTime[U: TTimeUnit]: Int64 read GetLastTime;
    property LastTimeF[U: TTimeUnit]: Currency read GetLastTimeF;
    property LastTimeBy[U: TTimeUnit]: string read GetLastTimeStr;
    property LastTimeByF[U: TTimeUnit]: string read GetLastTimeStrF;
    property LastTimeStr: string read GetLastTimeStr;
    property LastTimeStrF: string read GetLastTimeStrF;
  end;

resourcestring
  ErrCalcTime = 'function %s, %s parameter does not support value %s.';
  ErrFrequency = 'Frequency value error.';
  ErrGetTickFrequency  = 'API QueryPerformanceFrequency failed.';
  ErrGetTickCounter = 'API QueryPerformanceCounter failed.';

function Performance: TPerformanceGauge;

implementation

const
  cOneThousand = 1000;

var
  PerformanceGauge: TPerformanceGauge = nil;

function Performance: TPerformanceGauge;
begin
  if not Assigned(PerformanceGauge) then
    PerformanceGauge := TPerformanceGauge.Create;
  Result := PerformanceGauge;
end;


{ TQueryPerformanceTimer }

constructor TPerformanceGauge.Create;
begin
  FTests := DefaultTests;
  FDeviation := 0;
  FStamps.Frequency := -1;
  FStamps.Starting  := -1;
  FStamps.Ending    := -1;
  ZeroTotal;
  QueryFrequency;
end;

destructor TPerformanceGauge.Destroy;
begin

  inherited;
end;

function TPerformanceGauge.GetFrequency: Int64;
begin
  Result := FStamps.Frequency;
end;

function TPerformanceGauge.GetStarting: Int64;
begin
  Result := FStamps.Starting;
end;

function TPerformanceGauge.GetEnding: Int64;
begin
  Result := FStamps.Ending;
end;

procedure TPerformanceGauge.QueryCounter(var lpPerformanceCount: TLargeInteger);
begin
// https://learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter

// 中文
// QueryPerformanceCounter 在 Windows XP 或之後 Result 不應為 False，因為總是回應True。

// English
// In Windows XP and later, the QueryPerformanceCounter result should not be False,
// as it always responds to True.

  if not QueryPerformanceCounter(lpPerformanceCount) then
    raise Exception.Create(ErrGetTickCounter);
end;

procedure TPerformanceGauge.QueryFrequency(var lpPerformanceCount: TLargeInteger);
begin
// https://learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancefrequency

// 中文
// QueryPerformanceFrequency 在 Windows XP 或之後 Result 不應為 False，因為總是回應True。

// English
// In Windows XP and later, the QueryPerformanceFrequency result should not be False,
// as it always responds to True.

  if not QueryPerformanceFrequency(FStamps.Frequency) then
    raise Exception.Create(ErrGetTickFrequency)
  else
    if FStamps.Frequency <= 0 then
      raise Exception.Create(ErrFrequency)
end;

procedure TPerformanceGauge.QueryFrequency;
begin
  QueryFrequency(FStamps.Frequency);
end;

procedure TPerformanceGauge.QueryStarting;
begin
  QueryCounter(FStamps.Starting);
end;

procedure TPerformanceGauge.QueryEnding;
begin
  QueryCounter(FStamps.Ending);
end;

function TPerformanceGauge.Test(Count: Byte): Integer;
const
  Affect = 3;
var
  I, J: Integer;
  Value, Min, Max: Cardinal;
  AverageA, AverageB: Cardinal;
  iA, iB: Int64;
  N: array of Cardinal;
begin
  SetLength(N, Count);
  Min := Integer.MaxValue;
  Max := 0;

  I := 0;
  while I < Count do
  begin
    QueryCounter(iA);
    QueryStarting;
    QueryEnding;
    QueryCounter(iB);

    Value := iB - iA;
    if Value < Min then Min := Value;
    if Value > Max then Max := Value;
    N[I] := Value;

    Inc(I);
  end;

  if Min <= 0 then
    Min := 1;
  AverageA := Round((Max + Min) / 2);
  if (AverageA > (Min * Affect)) or (Min < (Max div Affect)) then
    AverageA := Min * Affect;

  AverageB := 0;
  J := 0;
  for I := 0 to Count - 1 do
  begin
    Value := N[I];
    if Value > AverageA then
    begin
      N[I] := Cardinal.MaxValue;
    end
    else
    begin
      Inc(AverageB, Value);
      Inc(J);
    end;
  end;

  AverageA := Round(AverageB / J);

  if J = Count then
    Exit(AverageA);

  Min := Integer.MaxValue;
  Max := 0;
  AverageB := 0;
  I := 0;
  while I < Count do
  begin
    Value := N[I];
    if Value = Cardinal.MaxValue then
    begin
      QueryCounter(iA);
      QueryStarting;
      QueryEnding;
      QueryCounter(iB);

      Value := iB - iA;
      N[I] := Value;
    end;
    if Value < Min then Min := Value;
    if Value > Max then Max := Value;

    if Value <= ((AverageA + Max) shr 1) then
    begin
      Inc(AverageB, Value);
    end;
    Inc(I);
  end;

  AverageB := Round(AverageB / Count);
  Result := AverageB;
end;

procedure TPerformanceGauge.ZeroTotal;
begin
  FTotal := 0;
end;

procedure TPerformanceGauge.Initialize(Options: TPerformanceGaugeOptions);
begin
  ZeroTotal;
  if _PGO_Calibration in Options then
    FDeviation := Test(FTests)
  else
    FDeviation := 0;
  FStamps.Ending := -1;
  if _PGO_FirstShot in Options then
    QueryStarting
  else
    FStamps.Starting := -1;
end;

function TPerformanceGauge.Shot: Boolean;
var
  Counter: Int64;
begin
  QueryCounter(Counter);

  if FStamps.Starting < 0 then
  begin
    Result := False;
    // 重新查詢計數器，使得每個 QueryCounter 處理過程中減少其他處理以減少誤差值。
    // Re-query the counter to reduce the difference caused by other processes
    // during each QueryCounter process.
    QueryStarting;
  end
  else
  begin
    FStamps.Ending := Counter;
    IncreaseToTotal;
    Result := True;
  end;
end;

procedure TPerformanceGauge.ShotStart(Calibration: Boolean);
begin
  if Calibration then
    Initialize([_PGO_Calibration, _PGO_FirstShot])
  else
    Initialize([_PGO_FirstShot]);
end;

procedure TPerformanceGauge.ShotEnd;
begin
  QueryEnding;
  if (FStamps.Frequency >= 0) and (FStamps.Starting >= 0) then
    IncreaseToTotal;
end;

function TPerformanceGauge.GetTicks(out Value: Int64): Boolean;
var
  N: Int64;
begin
  Result := Shot;
  if Result then
  begin
    N := GetLastTicks;
    Value := N;
    Result := N >= 0;
    QueryStarting;
  end
  else
  begin
    Value := -1;
  end;
end;

function TPerformanceGauge.GetTime(out Value: Int64; out TimeUnit: TTimeUnit): Boolean;
var
  N: Int64;
begin
  Result := GetTicks(N);
  if Result then
    GetLastTime(Value, TimeUnit);
end;

function TPerformanceGauge.GetTime: string;
var
  Value: Int64;
  TimeUnit: TTimeUnit;
begin
  if GetTime(Value, TimeUnit) then
    Result := IntToStr(Value) + UnitNameShort[TimeUnit]
  else
    Result := '';
end;

function TPerformanceGauge.GetSecond(out Value: Int64): Boolean;
var
  N: Int64;
begin
  Result := GetTicks(N);
  if Result then
    Value := N div FStamps.Frequency;
end;

function TPerformanceGauge.GetSecond(out Value: Currency): Boolean;
var
  N: Int64;
begin
  Result := GetTicks(N);
  if Result then
    Value := N / FStamps.Frequency;
end;

procedure TPerformanceGauge.CalcTimeByUnit(out ValueOut: Int64; TicksIn: Int64; TimeUnit: TTimeUnit);
var
  U: Cardinal;
begin
  case TimeUnit of
    _PTU_Auto:
      raise Exception.CreateFmt(ErrCalcTime, [
        'CalcTimeByUnit', 'TimeUnit', '_PTU_' + UnitNameLong[TimeUnit]]);
    _PTU_Second:
      ValueOut := TicksIn div FStamps.Frequency;
    else
    begin
      U := PerUnitTime[TimeUnit];
      if FStamps.Frequency >= U then
        ValueOut := TicksIn div (FStamps.Frequency div U)
      else
        ValueOut := TicksIn * U div FStamps.Frequency;
    end;
  end;
end;

procedure TPerformanceGauge.CalcTimeByUnit(out ValueOut: Currency; TicksIn: Int64; TimeUnit: TTimeUnit);
var
  U: Cardinal;
begin
  case TimeUnit of
    _PTU_Auto:
      raise Exception.CreateFmt(ErrCalcTime, [
        'CalcTimeByUnit', 'TimeUnit', '_PTU_' + UnitNameLong[TimeUnit]]);
    _PTU_Second:
      ValueOut := TicksIn / FStamps.Frequency;
    else
    begin
      U := PerUnitTime[TimeUnit];
      if FStamps.Frequency >= U then
        ValueOut := TicksIn / (FStamps.Frequency / U)
      else
        ValueOut := TicksIn * U / FStamps.Frequency;
    end;
  end;
end;

function TPerformanceGauge.CalcTimeSimilar(out ValueOut: Int64; TicksIn: Int64): TTimeUnit;
var
  U: TTimeUnit;
  F: Int64;
  N: Int64;
begin
  F := FStamps.Frequency;
  N := TicksIn;
  U := _PTU_Second;
  while (U < LeastTimeUnit) and (F >= 1000) do
  begin
    F := F div 1000;
    Inc(U);
  end;

  if F > 1 then
  begin
    if (U < LeastTimeUnit) and (N < 1000) then
    begin
      N := N * 1000 div F;
      Inc(U);
    end
    else
    begin
      N := N div F;
    end;
  end;

  while (U > _PTU_Second) and (N >= 1000) do
  begin
    N := N div 1000;
    Dec(U);
  end;

  Result := U;
  ValueOut := N;
end;

function TPerformanceGauge.CalcTimeSimilar(out ValueOut: Currency; TicksIn: Int64): TTimeUnit;
var
  U: TTimeUnit;
  F: Int64;
  N: Currency;
begin
  F := FStamps.Frequency;
  N := TicksIn;
  U := _PTU_Second;
  while (U < LeastTimeUnit) and (F >= 1000) do
  begin
    F := F div 1000;
    Inc(U);
  end;

  if F > 1 then
  begin
    if (U < LeastTimeUnit) and (N < 1000) then
    begin
      N := N * 1000 / F;
      Inc(U);
    end
    else
    begin
      N := N / F;
    end;
  end;

  while (U > _PTU_Second) and (N >= 1000) do
  begin
    N := N / 1000;
    Dec(U);
  end;

  Result := U;
  ValueOut := N;
end;

function TPerformanceGauge.GetTimeStr(Ticks: Int64; TimeUnit: TTimeUnit): string;
var
  Value: Int64;
begin
  if TimeUnit < _PTU_Auto then
    CalcTimeByUnit(Value, Ticks, TimeUnit)
  else
    TimeUnit := CalcTimeSimilar(Value, Ticks);

  Result := IntToStr(Value) + UnitNameShort[TimeUnit];
end;

function TPerformanceGauge.GetTimeStrF(Ticks: Int64; TimeUnit: TTimeUnit): string;
var
  Value: Currency;
begin
  if TimeUnit < _PTU_Auto then
    CalcTimeByUnit(Value, Ticks, TimeUnit)
  else
    TimeUnit := CalcTimeSimilar(Value, Ticks);

  Result := CurrToStrF(Value, ffNumber, 2) + UnitNameShort[TimeUnit]
end;

function TPerformanceGauge.GetLastTicks: Int64;
begin
  if (FStamps.Frequency <= 0) or (FStamps.Starting < 0) or (FStamps.Ending < 0) then
    Exit(-1);
  Result := FStamps.Ending - FStamps.Starting;
  if (Result > FDeviation) and (FDeviation > 0) then
    Dec(Result, FDeviation);
end;

function TPerformanceGauge.GetLastTime(out Value: Int64; out TimeUnit: TTimeUnit): Boolean;
var
  N: Int64;
begin
  N := GetLastTicks;
  if N < 0 then
    Exit(False);

  TimeUnit := CalcTimeSimilar(Value, N);
  Result := True;
end;

function TPerformanceGauge.GetLastTimeF(out Value: Currency; out TimeUnit: TTimeUnit): Boolean;
var
  N: Int64;
begin
  N := GetLastTicks;
  if N < 0 then
    Exit(False);

  TimeUnit := CalcTimeSimilar(Value, N);
  Result := True;
end;

function TPerformanceGauge.GetLastTime(U: TTimeUnit): Int64;
begin
  CalcTimeByUnit(Result, GetLastTicks, U);
end;

function TPerformanceGauge.GetLastTimeF(U: TTimeUnit): Currency;
begin
  CalcTimeByUnit(Result, GetLastTicks, U);
end;

function TPerformanceGauge.GetLastTimeStr(TimeUnit: TTimeUnit): string;
var
  Value: Int64;
begin
  if TimeUnit < _PTU_Auto then
    Value := GetLastTime(TimeUnit)
  else
    if not GetLastTime(Value, TimeUnit) then
      Exit('');

  Result := IntToStr(Value) + UnitNameShort[TimeUnit];
end;

function TPerformanceGauge.GetLastTimeStr: string;
begin
  Result := GetLastTimeStr(_PTU_Auto);
end;

function TPerformanceGauge.GetLastTimeStrF(TimeUnit: TTimeUnit): string;
var
  Value: Currency;
begin
  if TimeUnit < _PTU_Auto then
    Value := GetLastTimeF(TimeUnit)
  else
    if not GetLastTimeF(Value, TimeUnit) then
      Exit('');

  Result := CurrToStrF(Value, ffNumber, 2) + UnitNameShort[TimeUnit]
end;

function TPerformanceGauge.GetLastTimeStrF: string;
begin
  Result := GetLastTimeStrF(_PTU_Auto);
end;

procedure TPerformanceGauge.IncreaseToTotal;
begin
  Inc(FTotal, GetLastTicks);
end;

function TPerformanceGauge.GetTimeByUnit(out Value: Int64; TimeUnit: TTimeUnit): Boolean;
var
  N: Int64;
begin
  Result := GetTicks(N);
  if Result then
    CalcTimeByUnit(Value, N, TimeUnit);
end;

function TPerformanceGauge.GetTimeByUnit(out Value: Currency; TimeUnit: TTimeUnit): Boolean;
var
  N: Int64;
begin
  Result := GetTicks(N);
  if Result then
    CalcTimeByUnit(Value, N, TimeUnit);
end;

function TPerformanceGauge.GetMillisecond(out Value: Int64): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Millisecond);
end;

function TPerformanceGauge.GetMillisecond(out Value: Currency): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Millisecond);
end;

function TPerformanceGauge.GetMicrosecond(out Value: Int64): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Microsecond);
end;

function TPerformanceGauge.GetMicrosecond(out Value: Currency): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Microsecond);
end;

function TPerformanceGauge.GetNanoseconds(out Value: Int64): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Nanoseconds);
end;

function TPerformanceGauge.GetNanoseconds(out Value: Currency): Boolean;
begin
  Result := GetTimeByUnit(Value, _PTU_Nanoseconds);
end;

initialization

finalization
  if Assigned(PerformanceGauge) then
    FreeAndNil(PerformanceGauge);

end.
