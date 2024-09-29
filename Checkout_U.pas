unit Checkout_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.WinXPickers, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Buttons, dmLibrary_U,
  BookInventory_U, DateUtils;

type
  TfrmCheckout = class(TForm)
    btnEnterTransaction: TButton;
    btnreturnbook: TButton;
    imgCheckoutfrmcheckout: TImage;
    pnlReturns: TPanel;
    edtCustPassReturn: TEdit;
    lblCustomerPasswordReturns: TLabel;
    dtpReturnBook: TDateTimePicker;
    edtCustomerIDReturn: TEdit;
    edtBookIDReturn: TEdit;
    lblreturnDate: TLabel;
    lblCustomerIDreturn: TLabel;
    lblBookIDReturn: TLabel;
    lblReturn: TLabel;
    pnlCheckOUT: TPanel;
    edtCustomerPassOut: TEdit;
    edtBookIDOut: TEdit;
    edtCustomerIDOut: TEdit;
    lblCheckout: TLabel;
    lblBookID: TLabel;
    lblCustomerIDCheckout: TLabel;
    lblCustomerPassword: TLabel;
    bitCloseCheckOutForm: TBitBtn;
    btnEnterTransactionconfirm: TButton;
    btnReturnBookConfirm: TButton;
    btnCancelCheckOut: TButton;
    btnReturnCancel: TButton;
    imgReturnsPassword: TImage;
    imgCheckOUTeye: TImage;
    imgGuySitCheckOut: TImage;
    procedure btnEnterTransactionClick(Sender: TObject);
    procedure btnreturnbookClick(Sender: TObject);
    procedure btnEnterTransactionconfirmClick(Sender: TObject);
    procedure btnReturnBookConfirmClick(Sender: TObject);
    procedure btnCancelCheckOutClick(Sender: TObject);
    procedure btnReturnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure imgCheckOUTeyeClick(Sender: TObject);
    procedure imgReturnsPasswordClick(Sender: TObject);

  private

    procedure ClearEdits(edtCustomerID, edtBookID, edtPassword: TEdit);
    // clears edits
    procedure CheckIfCustomerValid(sCustomerID: string; var sMessage: string;
      var bValid: boolean); // explained when defining
    procedure CheckEditsAnswered(edit1, edit2, edit3: TEdit;
      var sMessage: string; var bValid: boolean); // ensures edits not blank
    procedure CheckPasswordCorrect(sCustomer, sPassword: string;
      var sMessage: string; var bValid: boolean);
    procedure IsBookAvailable(sBookID: string; var sMessage: string;
      var bValid: boolean);
    procedure IsBookAndCustomerOut(var sMessage: string; var bValid: boolean);
    procedure DoesBookExist(sBookID: string; var sMessage: string;
      var bValid: boolean);
    procedure DoesCustomerExist(sCustomerID: string; var sMessage: string;
      var bValid: boolean);

    { Private declarations }
  public
    procedure CreateTransactionTextFile(sTransacNo, sBookID,
      sCustomerID: string; dtBorrowDAte, dtDueDate: tDateTime;
      IsBookOD, bTransComplete: boolean; rFine: real);
    procedure SeePassword(edtPassword: TEdit; imgEye: TImage);
    { Public declarations }
  end;

var
  frmCheckout: TfrmCheckout;

implementation

{$R *.dfm}

procedure TfrmCheckout.btnCancelCheckOutClick(Sender: TObject);
begin
  ClearEdits(edtBookIDOut, edtCustomerIDOut, edtCustomerPassOut);
  pnlCheckOUT.Visible := false;

end;

procedure TfrmCheckout.btnEnterTransactionClick(Sender: TObject);
begin
  pnlCheckOUT.Visible := true;
  pnlReturns.Visible := false;
  edtCustomerPassOut.PasswordChar := '*';
end;

procedure TfrmCheckout.btnEnterTransactionconfirmClick(Sender: TObject);
var
  iPrimaryTransacKey: integer;

  dtToday, dtDueDate: tDateTime;
  sErrorMessage, sBookErrorMessage: string;
  bValid: boolean; // boolean to ensure inputs are valid
begin
  with dmLibrary do
  begin
    bValid := true;
    sErrorMessage := '';
    sBookErrorMessage := '';

    CheckEditsAnswered(edtBookIDOut, edtCustomerPassOut, edtCustomerIDOut,
      sErrorMessage, bValid);
    if bValid then
      CheckIfCustomerValid(Uppercase(edtCustomerIDOut.Text),
        sErrorMessage, bValid);

    if bValid then
      CheckPasswordCorrect(Uppercase(edtCustomerIDOut.Text),
        edtCustomerPassOut.Text, sErrorMessage, bValid);
    if bValid then
      IsBookAvailable(Uppercase(edtBookIDOut.Text), sBookErrorMessage, bValid);

    if sErrorMessage <> '' then
    begin
      ShowMessage('ERROR: ' + #13 + sErrorMessage);
    end;

    if sBookErrorMessage <> '' then
    begin
      ShowMessage('BOOK UNAVAILABLE: ' + #13 + sBookErrorMessage);
    end;

    if bValid then // all inputs are valid
    begin
      dtToday := Now;
      dtDueDate := IncDay(dtToday, 14);
      // due date is two weekds from day taken out

      iPrimaryTransacKey := BookInventory_U.frmBookInventory.GetPrimaryKey
        (tblTransactions, 'TransactionNo');
      tblTransactions.Insert;
      tblTransactions['TransactionNo'] := iPrimaryTransacKey;
      tblTransactions['BookID'] := edtBookIDOut.Text;
      tblTransactions['CustomerID'] := Uppercase(edtCustomerIDOut.Text);
      tblTransactions['BorrowDate'] := dtToday;
      tblTransactions['DueDate'] := dtDueDate;
      tblTransactions['IsBookOverdue'] := false;
      tblTransactions['FineAmount'] := 0;
      tblTransactions['TransactionCompleted'] := false;
      tblTransactions.post;

      CreateTransactionTextFile(tblTransactions['TransactionNo'],
        tblTransactions['BookID'], tblTransactions['CustomerID'],
        tblTransactions['BorrowDate'], tblTransactions['DueDate'],
        tblTransactions['IsBookOverdue'],
        tblTransactions['TransactionCompleted'], tblTransactions['FineAmount']);
      tblBooks.First;

      tblBooks.locate('BookID', edtBookIDOut.Text, []);
      tblBooks.edit;
      tblBooks['AvailabilityStatus'] := false;
      tblBooks['BorrowedCount'] := tblBooks['BorrowedCount'] + 1;
      tblBooks.post;

      tblCustomers.locate('CustomerID', edtCustomerIDOut.Text, []);
      tblCustomers.edit;
      tblCustomers['IsBookOut'] := true;
      tblCustomers.post;
      ShowMessage('Transaction entered');
      ClearEdits(edtBookIDOut, edtCustomerIDOut, edtCustomerPassOut);
      pnlCheckOUT.Visible := false;
    end;

  end;
end;

procedure TfrmCheckout.btnreturnbookClick(Sender: TObject);
begin
  pnlReturns.Visible := true;
  pnlCheckOUT.Visible := false;
  edtCustPassReturn.PasswordChar := '*';
end;

procedure TfrmCheckout.btnReturnBookConfirmClick(Sender: TObject);
const
  FineRatePerDay = 0.50;
var
  iDaysOverDue: integer;
  rFineAmount: real;
  dtDateReturned, dtDateDifference: tDateTime;
  sBookID, sCustomerID, sMessage: string;
  bIsbookOverdue, bValid: boolean;

begin
  with dmLibrary do
  begin
    bValid := true;
    sMessage := '';
    CheckEditsAnswered(edtCustPassReturn, edtCustomerIDReturn, edtBookIDReturn,
      sMessage, bValid);
    if bValid then
    begin
      DoesBookExist(edtBookIDReturn.Text, sMessage, bValid);
      DoesCustomerExist(Uppercase(edtCustomerIDReturn.Text), sMessage, bValid);
    end;
    if bValid then
      CheckPasswordCorrect(Uppercase(edtCustomerIDReturn.Text),
        edtCustPassReturn.Text, sMessage, bValid);

    if bValid then
      IsBookAndCustomerOut(sMessage, bValid);

    if bValid then
    begin { This checks the date entered by the user for the return
        if the date it was issued (shown in table) was bigger than in the
        datetimepicker's date, that means the user is lying because that isn't
        logically possible }

      if (trunc(dtpReturnBook.DateTime) - trunc(tblTransactions['BorrowDate']
        ) < 0) then
      begin
        bValid := false;
        sMessage := 'ERROR' + #13 +
          'Return date not valid (you cannnot return a book before receiving it)';
      end;
      if (trunc(dtpReturnBook.DateTime) - trunc(tblTransactions['BorrowDate'])
        >= 0) then
      begin
        bValid := true;
        ShowMessage(inttostr(trunc(dtpReturnBook.DateTime) -
          trunc(tblTransactions['BorrowDate'])) + 'calma');
      end;

    end;

    if sMessage <> '' then
    begin
      ShowMessage('ERROR: ' + #13 + sMessage);
    end;

    if bValid then // inputs are valid
    begin
      sBookID := edtBookIDReturn.Text;
      sCustomerID := Uppercase(edtCustomerIDReturn.Text);
      tblTransactions.First;

      while not(tblTransactions.Eof) do
      begin

        if (tblTransactions['CustomerID'] = sCustomerID) AND
          (tblTransactions['TransactionCompleted'] = false) then
        begin
          dtDateReturned := dtpReturnBook.DateTime;

          if dtDateReturned > tblTransactions['DueDate'] then
          begin // means book is overdue
            bIsbookOverdue := true;
            dtDateDifference := dtDateReturned - tblTransactions['DueDate'];
            iDaysOverDue := trunc(dtDateDifference);
            rFineAmount := iDaysOverDue * FineRatePerDay;
            ShowMessage('Book Overdue by ' + inttostr(iDaysOverDue) + ' days' +
              #13 + 'Amount owed: ' + floattostrf(rFineAmount,
              ffCurrency, 7, 2));

          end
          else
          begin

            bIsbookOverdue := false;
            rFineAmount := 0;
            ShowMessage('Book returned within allocated time');
          end;

          tblTransactions.edit; // editing record
          tblTransactions['TransactionCompleted'] := true;
          tblTransactions['IsBookOverDue'] := bIsbookOverdue;
          tblTransactions['DateReturned'] := dtDateReturned;
          tblTransactions['FineAmount'] := rFineAmount;
          tblTransactions.post;

          CreateTransactionTextFile(tblTransactions['TransactionNo'],
            tblTransactions['BookID'], tblTransactions['CustomerID'],
            tblTransactions['BorrowDate'], tblTransactions['DueDate'],
            tblTransactions['IsBookOverdue'],
            tblTransactions['TransactionCompleted'],
            tblTransactions['FineAmount']);

          tblBooks.First;
          tblBooks.locate('BookID', sBookID, []);
          tblBooks.edit;
          tblBooks['AvailabilityStatus'] := true;
          // book isn't available anymore
          tblBooks.post;
          // customer has a book out, therefore they can't take out another
          tblCustomers.First;
          tblCustomers.locate('CustomerID', sCustomerID, []);
          tblCustomers.edit;
          tblCustomers['IsBookOut'] := false;
          tblCustomers.post;

          tblTransactions.Next;
          ClearEdits(edtCustomerIDReturn, edtBookIDReturn, edtCustPassReturn);
        end
        else
        begin
          tblTransactions.Next;
        end;

      end;
    end;

  end;
end;

procedure TfrmCheckout.btnReturnCancelClick(Sender: TObject);
begin
  ClearEdits(edtCustomerIDReturn, edtBookIDReturn, edtCustPassReturn);
end;

procedure TfrmCheckout.CheckEditsAnswered(edit1, edit2, edit3: TEdit;
  var sMessage: string; var bValid: boolean);
begin
  if (edit1.Text = '') Or (edit1.Text = '') or (edit1.Text = '') then
  begin
    bValid := false;
    sMessage := sMessage + #13 + 'Please answer all fields';
  end;
end;

procedure TfrmCheckout.CheckIfCustomerValid(sCustomerID: string;
  var sMessage: string; var bValid: boolean);
begin
  { In order for the customer to be valid the following must be met:
    -the customerID must exist in the customer table
    -customer must not have an outstanding fine
    -customer must not already have a book taken out
    This procedure determines if these are met or not
  }
  with dmLibrary do
  begin

    if tblCustomers.locate('CustomerID', sCustomerID, []) = false then
    begin // not valid - customerID doesn't exist in customer table
      bValid := false;
      sMessage := sMessage + #13 + 'Customer does not exist';
    end
    else
    begin

      if tblCustomers['CustomerFine'] <> 0 then
      begin // not valid - outstanding fine
        bValid := false;
        sMessage := sMessage + #13 + 'Customer has an outstanding fine';
      end;
      if tblCustomers['IsBookOut'] = true then
      // not valid - already taken out book
      begin
        bValid := false;
        sMessage := sMessage + #13 + 'Customer has already taken out a book';
      end;
    end;

  end;
end;

procedure TfrmCheckout.CheckPasswordCorrect(sCustomer, sPassword: string;
  var sMessage: string; var bValid: boolean);
begin
  with dmLibrary do
  begin
    tblCustomers.First;
    tblCustomers.locate('CustomerID', sCustomer, []);
    if sPassword <> tblCustomers['Password'] then
    begin // password entered must be the same as password in table
      bValid := false;
      sMessage := 'Password is incorrect';
    end;

  end;
end;

procedure TfrmCheckout.ClearEdits(edtCustomerID, edtBookID, edtPassword: TEdit);
begin
  edtCustomerID.Clear;
  edtBookID.Clear;
  edtPassword.Clear;
end;

procedure TfrmCheckout.CreateTransactionTextFile(sTransacNo, sBookID,
  sCustomerID: string; dtBorrowDAte, dtDueDate: tDateTime;
  IsBookOD, bTransComplete: boolean; rFine: real);
var
  sFileName: string;
  tTransaction: textfile;
begin

  sFileName := 'Transac' + sTransacNo + '_' + sCustomerID + '.txt';
  assignFile(tTransaction, sFileName);
  with dmLibrary do
  begin
    rewrite(tTransaction);
    // '^' character used as a separator, so it can be entered into a richedit nicely
    writeln(tTransaction, 'TRANSACTION NO:^' + sTransacNo + #13);
    writeln(tTransaction, 'BookID:^' + sBookID);

    tblBooks.locate('BookID', sBookID, []);
    writeln(tTransaction, 'Book Name:^' + tblBooks['BookName']);
    tblCustomers.locate('CustomerID:', sCustomerID, []);
    writeln(tTransaction, 'Customer Name:^' + tblCustomers['FirstName']);
    writeln(tTransaction, 'Customer Surname:^' + tblCustomers['Surname']);
    writeln(tTransaction, 'Date Borrowed:^' + datetostr(dtBorrowDAte));
    writeln(tTransaction, 'Due Date:^' + datetostr(dtDueDate));
    if bTransComplete = false then
    begin
      writeln(tTransaction, 'Date Returned:^' + 'NOT RETURNED');
      writeln(tTransaction, 'Transaction Complete:^' + 'False');
    end
    else
    begin
      writeln(tTransaction, 'Date_Returned:^' +
        datetostr(tblTransactions['DateReturned']));
      writeln(tTransaction, 'Transaction Complete:^' + 'True');
    end;
    if IsBookOD = true then
    begin
      writeln(tTransaction, 'Book is overdue-Fine:^' + floattostrf(rFine,
        ffCurrency, 7, 2));
    end
    else
    begin
      writeln(tTransaction, 'Book is NOT overdue-Fine:^' + floattostrf(rFine,
        ffCurrency, 7, 2));
    end;

    CloseFile(tTransaction);

  end;

end;

procedure TfrmCheckout.DoesBookExist(sBookID: string; var sMessage: string;
  var bValid: boolean); // book must exist in table
begin
  with dmLibrary do
  begin
    if tblBooks.locate('BookID', sBookID, []) = false then
    begin
      bValid := false;
      sMessage := sMessage + #13 + 'Book does not exist';
    end;
  end;
end;

procedure TfrmCheckout.DoesCustomerExist(sCustomerID: string;
  var sMessage: string; var bValid: boolean);
begin // customer must exist in table
  with dmLibrary do
  begin
    if tblCustomers.locate('CustomerID', sCustomerID, []) = false then
    begin
      bValid := false;
      sMessage := sMessage + #13 + 'Customer does not exist';
    end;
  end;
end;

procedure TfrmCheckout.FormCreate(Sender: TObject);
var
  dtToday: tDate;
begin
  dtToday := date;
  dtpReturnBook.MaxDate := dtToday;
  dtpReturnBook.MinDate := (dtToday - 30);
  // LIMITING EXTREMITIES - user can't put in a date that doesn't make logical sense
  dtpReturnBook.date := dtToday;
end;

procedure TfrmCheckout.imgCheckOUTeyeClick(Sender: TObject);
begin
  SeePassword(edtCustomerPassOut, imgCheckOUTeye); // shows/hides password
end;

procedure TfrmCheckout.imgReturnsPasswordClick(Sender: TObject);
begin
  SeePassword(edtCustPassReturn, imgReturnsPassword); // shows/hides password
end;

procedure TfrmCheckout.IsBookAndCustomerOut(var sMessage: string;
  var bValid: boolean);
{ Makes sure that when a book is returned, the bookID and customerID entered,
  correlate - they must match the transaction found in the table
}
begin
  with dmLibrary do
  begin
    bValid := false;
    tblBooks.First;
    tblBooks.locate('BookID', edtBookIDReturn.Text, []);
    tblCustomers.First;
    tblCustomers.locate('CustomerID', edtCustomerIDReturn.Text, []);
    tblTransactions.First;
    while not(tblTransactions.Eof) AND (bValid = false) do
    begin
      { bValid must be false so it only 'looks' through incomplete
        transaction (ones that need books returning }
      if (tblTransactions['BookID'] <> tblBooks['BookID']) OR
        (tblTransactions['CustomerID'] <> tblCustomers['CustomerID']) then
      begin
        bValid := false;
        sMessage := 'This customer currently has not taken out this book';
      end;

      if (tblTransactions['BookID'] = tblBooks['BookID']) AND
        (tblTransactions['CustomerID'] = tblCustomers['CustomerID']) AND
        (tblTransactions['TransactionCompleted'] = true) then
      begin // transaction complete - no return is neccessary
        bValid := false;
        sMessage := 'Transaction already completed';
      end;

      if (tblTransactions['BookID'] = tblBooks['BookID']) AND
        (tblTransactions['CustomerID'] = tblCustomers['CustomerID']) AND
        (tblTransactions['TransactionCompleted'] = false) then
      begin // return is valid, BookID and CustomerID correlate, and transaction not finished
        bValid := true;
        sMessage := '';

      end;

      tblTransactions.Next;
    end;

  end;
end;

procedure TfrmCheckout.IsBookAvailable(sBookID: string; var sMessage: string;
  var bValid: boolean);
{ Book is available if:
  -BookID exists in Book table
  -BooK is not currently taken out by another customer
}
begin
  with dmLibrary do
  begin
    if tblBooks.locate('BookID', sBookID, []) = false then
    begin
      // Not available - not found in book table
      bValid := false;
      sMessage := sMessage + #13 + 'Book does not exist';
    end
    else
    begin
      if tblBooks['AvailabilityStatus'] = false then
      begin // Not available - Books taken out by another customer
        bValid := false;
        sMessage := sMessage + #13 +
          'Book has been taken out by another customer :/';
      end;

    end;
  end;
end;

procedure TfrmCheckout.SeePassword(edtPassword: TEdit; imgEye: TImage);
begin
  // shows/hides password
  if edtPassword.PasswordChar = '*' then
  begin
    edtPassword.PasswordChar := #0;
    imgEye.Picture.LoadFromFile('hide.png');
  end
  else if edtPassword.PasswordChar = #0 then
  begin
    edtPassword.PasswordChar := '*';
    imgEye.Picture.LoadFromFile('View.png');
  end;
end;

end.
