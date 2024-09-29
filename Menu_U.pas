unit Menu_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, BookInventory_U,
  Customers_U, Checkout_U, TransactionHistory_U, Vcl.ExtCtrls, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage, dmLibrary_U, Vcl.Buttons;

type
  TfrmMenu = class(TForm)
    btnAddBookMenu: TButton;
    btnAddCustomerMenu: TButton;
    btnCheckOutMenu: TButton;
    btnTransacHistoryMenu: TButton;
    lblMenu: TLabel;
    imgMenu: TImage;
    imgbookMenu: TImage;
    imgCheckoutmenu: TImage;
    imgHistorymenu: TImage;
    imgcustomermenu: TImage;
    imgcheckouthelp: TImage;
    bitCloseMenu: TBitBtn;
    procedure btnAddCustomerMenuClick(Sender: TObject);
    procedure btnAddBookMenuClick(Sender: TObject);
    procedure btnCheckOutMenuClick(Sender: TObject);
    procedure btnTransacHistoryMenuClick(Sender: TObject);
  private
    procedure CheckIfBookOverdue;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

{$R *.dfm}

procedure TfrmMenu.btnAddBookMenuClick(Sender: TObject);
begin
  frmBookInventory.ShowModal;

end;

procedure TfrmMenu.btnAddCustomerMenuClick(Sender: TObject);
begin
  frmCustomers.ShowModal;

end;

procedure TfrmMenu.btnCheckOutMenuClick(Sender: TObject);
begin
  frmCheckout.ShowModal;
end;

procedure TfrmMenu.btnTransacHistoryMenuClick(Sender: TObject);
begin
  frmTransactionHistory.ShowModal;
  frmTransactionHistory.dbgTransactions.Refresh;

  { 'CheckIfBookOverdue' Updates the value in the 'FineAmount' field in tblTransactions,
    because everyday the table must update to see if a book is overdue }
  CheckIfBookOverdue;
  with dmLibrary do
  begin
    { 'CreateTransactionTextFile' updates textfile because of the potential change,
      because the book could be overdue }
    Checkout_U.frmCheckout.CreateTransactionTextFile
      (tblTransactions['TransactionNo'], tblTransactions['BookID'],
      tblTransactions['CustomerID'], tblTransactions['BorrowDate'],
      tblTransactions['DueDate'], tblTransactions['IsBookOverdue'],
      tblTransactions['TransactionCompleted'], tblTransactions['FineAmount']);
  end;

end;

procedure TfrmMenu.CheckIfBookOverdue;
const
  FineRate = 0.50; // customer charged 50c per day a book is overdue
var
  dtTodayCheck, dtDateDifference: tdatetime;
  iDaysOverdue: integer;
  rFineAmount: real;
begin
  with dmLibrary do
  begin
    tblTransactions.First;
    dtTodayCheck := now;
    iDaysOverdue := 0;
    rFineAmount := 0;
    while not(tblTransactions.Eof) do
    begin
      // if a book is out, and the current date is past the due date, the book is overdue
      if (tblTransactions['TransactionCompleted'] = false) AND
        (dtTodayCheck > tblTransactions['DueDate']) then
      begin
           //dtDateDifference shows the no. of days overdue
        dtDateDifference := dtTodayCheck - tblTransactions['DueDate'];

        iDaysOverdue := trunc(dtDateDifference);
        rFineAmount := iDaysOverdue * FineRate; //fine
        tblTransactions.Edit; //   updating/editing table
        tblTransactions['IsBookOverdue'] := true;
        tblTransactions['FineAmount'] := rFineAmount;
        tblTransactions.Post;

        tblCustomers.First;  //   updating/editing table
        tblCustomers.Locate('CustomerID', tblTransactions['CustomerID'], []);
        tblCustomers.Edit;
        tblCustomers['CustomerFine'] := rFineAmount;
        tblCustomers.Post;

      end;
      tblTransactions.Next;
    end;
  end;
end;

end.
