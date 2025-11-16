unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  JvComponentBase, JvThread, JvExMask, JvToolEdit,

  Unit2,             // A text editor form.
  HighAccuracyGauge, // High-precision performance timer.
  MurmurHash3;       // This is to test the unit.

type
  TForm1 = class(TForm)
    JvThread1: TJvThread;
    FileOpenDialog1: TFileOpenDialog;
    Panel1: TPanel;
      Label1: TLabel;
      Edit1: TEdit;
      UpDown1: TUpDown;
      btnCalculation: TButton;
      btnReset: TButton;
    PageControl1: TPageControl;
      TabSheet1: TTabSheet;
        cbStringType: TComboBox;
        cbLineBreak: TComboBox;
        btnOpenEdit: TButton;
        btnLoadText: TButton;
      TabSheet2: TTabSheet;
        JvFilenameEdit1: TJvFilenameEdit;
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOpenEditClick(Sender: TObject);
    procedure btnLoadTextClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnCalculationClick(Sender: TObject);
    procedure JvThread1Begin(Sender: TObject);
    procedure JvThread1Execute(Sender: TObject; Params: Pointer);
    procedure JvThread1FinishAll(Sender: TObject);
  private type
    TTickTimes = record
      a, b: Cardinal;
    end;
    TMurmurHashType = (_MurmurHash32, _MurmurHash128x86, _MurmurHash128x64);
    PTickTimes = ^TTickTimes;
  private const
    MinUpdateTime = 30; // [ms] for UI update.
  private
    TimeTicks: array[TMurmurHashType] of TTickTimes;
    RunTimes: Cardinal;
    MurmurHash32: TMurmurHash3_32bit_x86;
    MurmurHash128x86: TMurmurHash3_128bit_x86;
    MurmurHash128x64: TMurmurHash3_128bit_x64;
    s: array[0..5] of string;
    t: array[0..5] of string;
    BufferStream: TMemoryStream;
    GenerateCount: Integer;
    Thread: TJvBaseThread;
  public
    procedure UpdateLowerTimeA(t: Cardinal; HashType: TMurmurHashType);
    procedure UpdateLowerTimeB(t: Cardinal; HashType: TMurmurHashType);
    function GetTickTimeStr(HashType: TMurmurHashType): string;
    procedure ResetTimeTicks;
    procedure DisplayResult(Forced: Boolean); overload;
    procedure DisplayResult; overload;
    procedure EnableDataSettingUI(b: Boolean);
    function StartGenerate: Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IFDEF CPUX86}
     Caption := Caption + ' - X86';
  {$ELSE}
  {$IFDEF CPUX64}
     Caption := Caption + ' - X64';
  {$ELSE}
     Caption := Caption + ' - <unknown>';
  {$IFEND}
  {$IFEND}
  ResetTimeTicks;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if JvThread1.Count > 0 then
  begin
    JvThread1.Terminate;
    JvThread1.WaitFor;
  end;
  if Assigned(BufferStream) then
    BufferStream.Free;
end;

procedure TForm1.btnOpenEditClick(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.btnLoadTextClick(Sender: TObject);
begin
  if FileOpenDialog1.Execute then
  begin
    try
      Form2.Memo1.Lines.LoadFromFile(FileOpenDialog1.FileName);
      Form2.Show;
    except on E: Exception do
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TForm1.btnResetClick(Sender: TObject);
begin
  ResetTimeTicks;
end;

procedure TForm1.btnCalculationClick(Sender: TObject);
begin
  if JvThread1.Count > 0 then
  begin
    JvThread1.Terminate;
    JvThread1.WaitFor;
  end
  else
  begin
    EnableDataSettingUI(False);
    if StartGenerate then
      btnCalculation.Caption := 'Stop'
    else
      EnableDataSettingUI(True);
  end;
end;

procedure TForm1.UpdateLowerTimeA(t: Cardinal; HashType: TMurmurHashType);
begin
  if t < TimeTicks[HashType].a then
    TimeTicks[HashType].a := t;
end;

procedure TForm1.UpdateLowerTimeB(t: Cardinal; HashType: TMurmurHashType);
begin
  if t < TimeTicks[HashType].b then
    TimeTicks[HashType].b := t;
end;

function TForm1.GetTickTimeStr(HashType: TMurmurHashType): string;
begin
  Result := Format('min ticktime B %dt / A %dt = %0.2f%%', [
    TimeTicks[HashType].b,
    TimeTicks[HashType].a,
    TimeTicks[HashType].b / TimeTicks[HashType].a * 100]);
end;

procedure TForm1.ResetTimeTicks;
var
  I: TMurmurHashType;
  pTicks: PTickTimes;
begin
  RunTimes := 0;
  for I := Low(TimeTicks) to High(TimeTicks) do
  begin
    pTicks := @TimeTicks[I];
    pTicks.a := Cardinal.MaxValue;
    pTicks.b := Cardinal.MaxValue;
  end;
end;

var
  WaitSysTick: NativeUInt = 0;

procedure TForm1.DisplayResult(Forced: Boolean);
var
  NowSysTick: NativeUInt;
begin
  if not Forced then
  begin
    NowSysTick := GetTickCount;
    if WaitSysTick > NowSysTick then
      Exit;

    WaitSysTick := NowSysTick + MinUpdateTime;
  end;

  Memo1.Lines.BeginUpdate;
  try
    Memo1.Clear;
    Memo1.Lines.Add('Run[' + RunTimes.ToString + ']:');

    Memo1.Lines.Add('MurmurHash3 32bit x86');
    Memo1.Lines.Add(s[0] + #9 + t[0]);
    Memo1.Lines.Add(s[1] + #9 + t[1]);
    Memo1.Lines.Add(GetTickTimeStr(_MurmurHash32));
    Memo1.Lines.Add('MurmurHash3 128bit x86');
    Memo1.Lines.Add(s[2] + #9 + t[2]);
    Memo1.Lines.Add(s[3] + #9 + t[3]);
    Memo1.Lines.Add(GetTickTimeStr(_MurmurHash128x86));
    Memo1.Lines.Add('MurmurHash3 128bit x64');
    Memo1.Lines.Add(s[4] + #9 + t[4]);
    Memo1.Lines.Add(s[5] + #9 + t[5]);
    Memo1.Lines.Add(GetTickTimeStr(_MurmurHash128x64));
  finally
    Memo1.Lines.EndUpdate;
  end;
end;

procedure TForm1.DisplayResult;
begin
  DisplayResult(False);
end;

procedure TForm1.EnableDataSettingUI(b: Boolean);
begin
  PageControl1.Enabled := b;
  Edit1.Enabled := b;
  UpDown1.Enabled := b;
end;

function TForm1.StartGenerate: Boolean;
const
  LineBreak: array[0..2] of string = (#10, #13#10, #13);
  SizeLimit = 10 * 1024 * 1024; // 10MB
var
  Data: TBytes;
  SL: TStringList;
  s: string;
  iMB: Integer;
  F: TFileStream;
begin
  Result := False;
  Memo1.Clear;

  if Assigned(BufferStream) then
    BufferStream.Clear
  else
    BufferStream := TMemoryStream.Create;

  case PageControl1.ActivePageIndex of
    0: // Text
    begin
      SL := TStringList.Create;
      try
        SL.Assign(Form2.Memo1.Lines);
        SL.LineBreak := LineBreak[cbLineBreak.ItemIndex];
        SL.TrailingLineBreak := False;
        s := SL.Text;
      finally
        SL.Free;
      end;
      case cbStringType.ItemIndex of
        0: // AnsiString
        begin
          Data := TEncoding.ANSI.GetBytes(s);
          BufferStream.Write(Data, Length(Data));
          Result := True;
        end;
        1: // WideString
        begin
          BufferStream.Write(PChar(s)^, Length(s) * SizeOf(Char));
          Result := True;
        end;
        2:
        begin
          Data := TEncoding.UTF8.GetBytes(s);
          BufferStream.Write(Data, Length(Data));
          Result := True;
        end
        else Exit;
      end;
//      if Result then // For debug. Encoding data check...
//        BufferStream.SaveToFile('temp.bin');
    end;
    1: // File
    begin
      try
        F := TFileStream.Create(JvFilenameEdit1.FileName, fmOpenRead or fmShareDenyWrite);
        try
          if F.Size > SizeLimit then
          begin
            s := 'The file size exceeds ' + SizeLimit.ToString + 'bytes.' + sLineBreak +
                 'It will likely take a long time to process.' + sLineBreak +
                 'This is just a test program, are you sure you want to play it this way?';
            iMB := MessageBox(Self.Handle, PChar(s), 'Big file!', MB_OKCANCEL or MB_DEFBUTTON2);
            if iMB <> IDOK then
              Exit;
          end;
          BufferStream.LoadFromStream(F);
          Result := True;
        finally
          F.Free;
        end;
      except on E: Exception do
        ShowMessage(E.Message);
      end;
    end;
    else Exit;
  end;
  if Result then
    Thread := JvThread1.Execute(nil);
end;

procedure TForm1.JvThread1Begin(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := 'Bytes: ' + FormatCurr('#,###', BufferStream.Size);
  GenerateCount := UpDown1.Position;
  BufferStream.Position := 0;
end;

procedure TForm1.JvThread1Execute(Sender: TObject; Params: Pointer);
var
  I: Integer;
  Hash1: Cardinal;
  Hash2: UInt128;
  n: Int64;
begin
  I := 0;
  repeat
    Performance.ShotStart();
    Hash1 := MurmurHash3_32bit_x86(BufferStream.Memory^, BufferStream.Size, 0);
    s[0] := Hash1.ToHexString(8)+ #32#9#40 + Hash1.ToString  + #41;
    Performance.ShotEnd;
    n := Performance.LastTicks;
    UpdateLowerTimeA(n, _MurmurHash32);
    t[0] := n.ToString;

    Performance.ShotStart();
    MurmurHash32.Reset;
    MurmurHash32.Update(BufferStream.Memory^, BufferStream.Size);
    s[1] := MurmurHash32.HashAsCardinal.ToHexString(8) + #32#9#40 +  MurmurHash32.HashAsString + #41;
    Performance.ShotEnd;
    n := Performance.LastTicks;
    UpdateLowerTimeB(n, _MurmurHash32);
    t[1] := n.ToString;

    Performance.ShotStart();
    Hash2 := MurmurHash3_128bit_x86(BufferStream.Memory^, BufferStream.Size, 0);
    s[2] := Int128ToHex_x86(Hash2);
    Performance.ShotEnd;
    n := Performance.LastTicks;
    UpdateLowerTimeA(n, _MurmurHash128x86);
    t[2] := n.ToString;

    Performance.ShotStart();
    MurmurHash128x86.Reset;
    MurmurHash128x86.Update(BufferStream.Memory^, BufferStream.Size);
    s[3] := MurmurHash128x86.HashAsString;
    UpdateLowerTimeB(n, _MurmurHash128x86);
    Performance.ShotEnd;
    n := Performance.LastTicks;
    t[3] := n.ToString;

    Performance.ShotStart();
    Hash2 := MurmurHash3_128bit_x64(BufferStream.Memory^, BufferStream.Size, 0);
    s[4] := Int128ToHex_x64(Hash2);
    Performance.ShotEnd;
    n := Performance.LastTicks;
    UpdateLowerTimeA(n, _MurmurHash128x64);
    t[4] := n.ToString;

    Performance.ShotStart();
    MurmurHash128x64.Reset;
    MurmurHash128x64.Update(BufferStream.Memory^, BufferStream.Size);
    s[5] := MurmurHash128x64.HashAsString;
    Performance.ShotEnd;
    n := Performance.LastTicks;
    UpdateLowerTimeB(n, _MurmurHash128x64);
    t[5] := n.ToString;

    Inc(RunTimes);
    Thread.Synchronize(DisplayResult);

    if Thread.Terminated then
      Break;

    if GenerateCount > 0 then
    begin
      Inc(I);
      if I >= GenerateCount then
        Break;
    end;
  until False;
end;

procedure TForm1.JvThread1FinishAll(Sender: TObject);
begin
  if Assigned(BufferStream) then
    FreeAndNil(BufferStream);
  Thread := nil;
  DisplayResult(True);
  btnCalculation.Caption := 'Calculation';
  EnableDataSettingUI(True);
end;

end.
