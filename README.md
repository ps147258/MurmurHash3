[MurmurHash3](#MurmurHash3) | [HighAccuracyGauge](#HighAccuracyGauge)
***

# MurmurHash3
> [!CAUTION]
> English:
> The problem has been identified but not yet resolved.
> * The next step is to correct the handling of non-continuous data and unaligned block length calculations in the following structure's Update function
>   TMurmurHash3_32bit_x86、TMurmurHash3_128bit_x86、TMurmurHash3_128bit_x64
> 
> 中文：
> 已知問題，待處理
> * 下一步修正下列結構中 Update 對於非連續資料與非對齊區塊長度計算時的處理問題
>   TMurmurHash3_32bit_x86、TMurmurHash3_128bit_x86、TMurmurHash3_128bit_x64
  
## function
MurmurHash3_32bit_x86、MurmurHash3_128bit_x86、MurmurHash3_128bit_x64
```delphi
procedure TForm1.Buttin1Click(Sender: TObject);
const
  s: AnsiString = 'test';
var
  I: Integer;
  Hash32: Cardinal;
  Hash128: UInt128;
begin
  Hash32 := MurmurHash3_32bit_x86(PAnsiChar(s)^, Length(s), 0);
  Hash128 := MurmurHash3_128bit_x86(PAnsiChar(s)^, Length(s), 0);
  Hash128 := MurmurHash3_128bit_x64(PAnsiChar(s)^, Length(s), 0);
end;
```

## record
TMurmurHash3_32bit_x86、TMurmurHash3_128bit_x86、TMurmurHash3_128bit_x64
```delphi
procedure TForm1.Buttin1Click(Sender: TObject);
const
  s: AnsiString = 'test';
var
  MurmurHash3_32bit: TMurmurHash3_32bit_x86;
  MurmurHash3_128bit_x86: TMurmurHash3_128bit_x86;
  MurmurHash3_128bit_x64: TMurmurHash3_128bit_x64;
  Hash: TBytes;
begin
  // MurmurHash3 32bit
  MurmurHash3_32bit.Reset;
  MurmurHash3_32bit.Update(PAnsiChar(s)^, Length(s));
  Hash := MurmurHash3_32bit.HashAsBytes;

  // MurmurHash3 128bit x86
  MurmurHash3_128bit_x86.Reset;
  MurmurHash3_128bit_x86.Update(PAnsiChar(s)^, Length(s));
  Hash := MurmurHash3_128bit_x86.HashAsBytes;

  // MurmurHash3 128bit x64
  MurmurHash3_128bit_x64.Reset;
  MurmurHash3_128bit_x64.Update(PAnsiChar(s)^, Length(s));
  Hash := MurmurHash3_128bit_x64.HashAsBytes;
end;
```

***
# HighAccuracyGauge
```delphi
var
  n: Int64;
  c: Currency;
  s: string;
begin
  Performance.ShotStart();
  // ...
  Performance.ShotEnd;
  n := Performance.LastTicks;    // Get ticks

  // The performance time conversion, [ns] is the smallest unit, [s] is the highest unit.
  // if ticktime = 123456789ns ...

  // Get string
  s := Performance.LastTimeStr;  // '123ms'
  s := Performance.LastTimeStrF; // '123.45ms'

  // Get numerical value.
  n := Performance.LastTime[_PTU_Microsecond];  // 123456
  c := Performance.LastTimeF[_PTU_Microsecond]; // 123456.789
end
```
