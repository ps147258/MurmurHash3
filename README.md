[MurmurHash3](#MurmurHash3) | [HighAccuracyGauge](#HighAccuracyGauge)
***

# MurmurHash3
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
  Hash: TBytes;
begin
  // MurmurHash3 32bit
  TMurmurHash3_32bit_x86.Reset;
  TMurmurHash3_32bit_x86.Update(PAnsiChar(s)^, Length(s));
  Hash := TMurmurHash3_32bit_x86.HashAsBytes;

  // MurmurHash3 128bit x86
  MurmurHash128x86.Reset;
  MurmurHash128x86.Update(PAnsiChar(s)^, Length(s));
  Hash := MurmurHash128x86.HashAsBytes;

  // MurmurHash3 128bit x64
  TMurmurHash3_128bit_x64.Reset;
  TMurmurHash3_128bit_x64.Update(PAnsiChar(s)^, Length(s));
  Hash := TMurmurHash3_128bit_x64.HashAsBytes;
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
