unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls,

  Vcl.Memo.LineNumbers;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Memo1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateStatusBar;
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin
  TLineNumbers.Create(Self, Memo1, Panel1, True);
  Memo1.SelLength := 0;
  Memo1.SelStart := 0;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  UpdateStatusBar
end;

procedure TForm2.Memo1Change(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TForm2.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  UpdateStatusBar;
end;

procedure TForm2.Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateStatusBar;
end;

procedure TForm2.Memo1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  UpdateStatusBar;
end;

procedure TForm2.UpdateStatusBar;
var
  StartPos, EndPos: Integer;
  StartLine, EndLine: Integer;
  s: string;
  function FC(Vallue: Integer): string;
  begin
    Result := FormatCurr('#,###', Vallue);
  end;
begin
  StatusBar1.Panels.Items[0].Text := Format('Lines %s', [FC(Memo1.Lines.Count)]);
  StatusBar1.Panels.Items[1].Text := Format('Chars %s', [FC(Memo1.GetTextLen)]);

  StartPos := 0;
  EndPos := 0;
  StartLine := 0;
  EndLine := 0;
  SendMessage(Memo1.Handle, EM_GETSEL, WPARAM(@StartPos), LPARAM(@EndPos));
  StartLine := SendMessage(Memo1.Handle, EM_LINEFROMCHAR, StartPos, 0) + 1;

  if StartPos = EndPos then
  begin
    s :=  Format('Cursor %s, line %s', [FC(StartPos), FC(StartLine)]);
  end
  else
  begin
    EndLine := SendMessage(Memo1.Handle, EM_LINEFROMCHAR, EndPos, 0) + 1;
    s :=  Format('Cursor %s to %s', [FC(StartPos), FC(EndPos)]);

    if StartLine = EndLine then
      s := s + Format(', line %s', [FC(StartLine)])
    else
      s := s + Format(', line %s to %s', [FC(StartLine), FC(EndLine)]);
  end;
  StatusBar1.Panels.Items[2].Text := s;

end;

end.
