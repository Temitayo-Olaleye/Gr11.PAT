unit TransactionHistory_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, dmLibrary_U, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TfrmTransactionHistory = class(TForm)
    dbgTransactions: TDBGrid;
    btnFindTransaction: TButton;
    bitCloseTransacForm: TBitBtn;
    redTransactionOutput: TRichEdit;
    imgHistoryForm: TImage;
    lblHistory: TLabel;
    procedure ConnectDatabase(Sender: TObject);
    procedure btnFindTransactionClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTransactionHistory: TfrmTransactionHistory;

implementation

{$R *.dfm}

procedure TfrmTransactionHistory.btnFindTransactionClick(Sender: TObject);
var
  sTransacNo, sFileName, sLine, sTitle, sInfo: string;
  tTransaction: textfile;
  iPosSpace: integer;
begin
  redTransactionOutput.Clear;
  with dmLibrary do
  begin
    // Finding transaction's textfile, and displaying it in a richedit
    sTransacNo := inputbox('Find Transaction', 'Enter Transaction No:', '');
    if sTransacNo = '' then
      showmessage('Please enter value')

    else if tblTransactions.Locate('TransactionNo', strtoint(sTransacNo), []) = true
    then
    begin

      sFileName := 'Transac' + sTransacNo + '_' + tblTransactions
        ['CustomerID'] + '.txt'; //NAme of textfile
      assignfile(tTransaction, sFileName);
      try
        reset(tTransaction)
      except
        showmessage('file not found :/');
        exit;
      end;

      while not eof(tTransaction) do
      begin
        Readln(tTransaction, sLine);
        iPosSpace := pos('^', sLine); // '^' used as separator
        sTitle := copy(sLine, 1, iPosSpace - 1);
        delete(sLine, 1, iPosSpace);
        sInfo := sLine;
        redTransactionOutput.Lines.Add(sTitle + #9 + sInfo);
      end;
      closefile(tTransaction);
    end
    else
    begin
      showmessage('Transaction does not exist >W<');
    end;

  end;

end;

procedure TfrmTransactionHistory.ConnectDatabase(Sender: TObject);
begin
  dbgTransactions.DataSource := dmLibrary.dsrLibraryTransactions; // connecting
end;

procedure TfrmTransactionHistory.FormActivate(Sender: TObject);
begin
  redTransactionOutput.Clear; // lining up richedit
  redTransactionOutput.Paragraph.Tabcount := 2;
  redTransactionOutput.Paragraph.Tab[0] := 10;
  redTransactionOutput.Paragraph.Tab[1] := 150;
end;

end.
