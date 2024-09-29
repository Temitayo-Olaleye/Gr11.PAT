unit Customers_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Buttons,
  dmLibrary_U;

type
  TfrmCustomers = class(TForm)
    dbgCustomers: TDBGrid;
    btnAddCustomer: TButton;
    btnDeleteCustomer: TButton;
    btnEditcustomerinfo: TButton;
    btnOutstandingCustomers: TButton;
    redCustomerOutput: TRichEdit;
    btnCustomersHead: TLabel;
    imgCustomerfrmCustomer: TImage;
    bitCloseCustomerForm: TBitBtn;
    pnlAddCustomer: TPanel;
    lblcustomerNameAdd: TLabel;
    lblSurnameAdd: TLabel;
    lblAddCustomerpanel: TLabel;
    edtAddCustomerName: TEdit;
    edtAddCustomerSurname: TEdit;
    btnAddBookconfirm: TButton;
    lblCusCellNoAdd: TLabel;
    edtAddCustomerCellNo: TEdit;
    btnCancelAddBooks: TButton;
    btnDisplayCustomerInfo: TButton;
    cbxFinePaid: TCheckBox;
    lblSelectedRecord: TLabel;
    pnlPasswords: TPanel;
    edtAddCustomerPassword: TEdit;
    edtCustomerConfirmPassAdd: TEdit;
    lblCustomerconfirmPassAdd: TLabel;
    lblCustomerPasswordAdd: TLabel;
    btnChangePassword: TButton;
    imgCustomersFormss: TImage;
    procedure btnAddCustomerClick(Sender: TObject);
    procedure btnAddBookconfirmClick(Sender: TObject);
    procedure ConnectDatabase(Sender: TObject);
    procedure btnDeleteCustomerClick(Sender: TObject);
    procedure btnCancelAddBooksClick(Sender: TObject);
    procedure btnOutstandingCustomersClick(Sender: TObject);

    procedure btnDisplayCustomerInfoClick(Sender: TObject);
    procedure btnEditcustomerinfoClick(Sender: TObject);

    procedure btnChangePasswordClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    { Private declarations }
    function GenerateCustomerKey: string;
    // makes primary key for customer table
    procedure ClearEdits;
    procedure GetTotalFines;
    procedure AddCustomerTextFile(sCustomerName, sSurname, sPassword, sCellNo,
      sID: string; rFine: real);
    procedure DeleteCustomerTextFile(sFileName: string);
    procedure CheckValidName(sName, sMessage: string; var bAll: boolean);
    procedure CheckForEmptyEdits(edit1, edit2, edit3, edit4, edit5: TEdit;
      var bValid: boolean);
    procedure CheckforEmptyEditsWhenEditing(var bValid: boolean);
    procedure CheckValidCellNo(sNumber: string; var sCellMessage: string;
      var bValid: boolean);
    procedure CheckValidPassword(sPass, sConfirmNewPassword: string;
      var sMessage: string; var bValidNo: boolean);

  public
    { Public declarations }
  end;

var
  frmCustomers: TfrmCustomers;

implementation

{$R *.dfm}

procedure TfrmCustomers.AddCustomerTextFile(sCustomerName, sSurname, sPassword,
  sCellNo, sID: string; rFine: real);
var
  tCustomer: textfile;
  sFileName: string;
begin // Making Customer textfile
  with dmLibrary do
  begin
    sFileName := sID + '_' + sCustomerName + '.txt';
    assignfile(tCustomer, sFileName);

    rewrite(tCustomer);
    writeln(tCustomer, 'CUSTOMER ID: ' + sID);
    writeln(tCustomer, 'Name: ' + sCustomerName);
    writeln(tCustomer, 'Surame: ' + sSurname);
    writeln(tCustomer, 'Password: ' + sPassword);
    writeln(tCustomer, 'Phone Number: ' + sCellNo);
    writeln(tCustomer, 'Fine : ' + floattostrf(rFine, ffCurrency, 7, 2));

    Closefile(tCustomer);

  end;
end;

procedure TfrmCustomers.btnAddBookconfirmClick(Sender: TObject);
var
  bAll: boolean;
  sCustomerPrimaryKey, sMessage, sCellMessage: string;

begin
  bAll := true;
  sMessage := '';
  sCellMessage := '';
  { this if statement checks if all edits are answered, there has to be
    two different procedures because, when editing and inserting,
    there are different amounts of edits }
  if lblAddCustomerpanel.Caption = 'ADD' then
    CheckForEmptyEdits(edtAddCustomerName, edtAddCustomerSurname,
      edtAddCustomerPassword, edtCustomerConfirmPassAdd,
      edtAddCustomerCellNo, bAll)
  else
    CheckforEmptyEditsWhenEditing(bAll);
  if bAll then
  begin
    CheckValidName(edtAddCustomerName.Text, 'Names', bAll);
    CheckValidName(edtAddCustomerName.Text, 'Surnames', bAll);
    CheckValidCellNo(edtAddCustomerCellNo.Text, sCellMessage, bAll);
    if lblAddCustomerpanel.Caption = 'ADD' then
      CheckValidPassword(edtAddCustomerPassword.Text,
        edtCustomerConfirmPassAdd.Text, sMessage, bAll);
  end;

  if (sMessage <> '') then
  begin
    showmessage('PASSWORD INVALID:' + #13 + sMessage);
  end;

  if sCellMessage <> '' then
  BEGIN
    showmessage('PHONE NUMBER INVALID:' + #13 + sCellMessage);
  END;

  if bAll = true then // all input is valid, thus can be inserted or edited
  begin

    with dmLibrary do
    begin
      if lblAddCustomerpanel.Caption = 'ADD' then // inserting
      begin
        sCustomerPrimaryKey := GenerateCustomerKey;
        tblCustomers.Last;
        tblCustomers.insert;
        tblCustomers['CustomerID'] := sCustomerPrimaryKey;
        tblCustomers['FirstName'] := edtAddCustomerName.Text;
        tblCustomers['Surname'] := edtAddCustomerSurname.Text;
        tblCustomers['Password'] := edtAddCustomerPassword.Text;
        tblCustomers['PhoneNumber'] := edtAddCustomerCellNo.Text;
        tblCustomers['CustomerFine'] := 0;
        tblCustomers['IsBookOut'] := false;
        tblCustomers.Post;
        AddCustomerTextFile(tblCustomers['FirstName'], tblCustomers['Surname'],
          tblCustomers['Password'], tblCustomers['PhoneNumber'],
          tblCustomers['CustomerID'], tblCustomers['CustomerFine']);
        ClearEdits;
        showmessage('Customer Added');
      end;

      if lblAddCustomerpanel.Caption = 'EDIT' then // editing
      begin
        lblSelectedRecord.Caption := '';
        tblCustomers.edit;

        tblCustomers['FirstName'] := edtAddCustomerName.Text;
        tblCustomers['Surname'] := edtAddCustomerSurname.Text;
        tblCustomers['PhoneNumber'] := edtAddCustomerCellNo.Text;
        if cbxFinePaid.Checked = true then
          tblCustomers['CustomerFine'] := 0;

        tblCustomers.Post;
        showmessage('Customer Information Edited');
        lblSelectedRecord.Caption := '';
        ClearEdits;
      end;

    end;
    pnlAddCustomer.Visible := false;
  end;

end;

procedure TfrmCustomers.btnAddCustomerClick(Sender: TObject);
begin
  with dmLibrary do
  begin
    pnlAddCustomer.Visible := true;
    pnlPasswords.Visible := true;
    lblAddCustomerpanel.Caption := 'ADD';
    cbxFinePaid.Visible := false;
    pnlAddCustomer.Visible := true;
  end;

end;

procedure TfrmCustomers.btnCancelAddBooksClick(Sender: TObject);
begin
  ClearEdits;
  pnlAddCustomer.Visible := false;
  lblSelectedRecord.Caption := '';
end;

procedure TfrmCustomers.btnChangePasswordClick(Sender: TObject);
var
  sNewPassword, sConfirmNewPassword, sMessage: string;
  bValidPassword: boolean;
begin
  sNewPassword := inputbox('New Password', 'Enter New Password', '');
  // user must type in new password correctly twice
  sConfirmNewPassword := inputbox('New Password', 'Confirm New Password', '');
  bValidPassword := true;
  CheckValidPassword(sNewPassword, sConfirmNewPassword, sMessage,
    bValidPassword); // password must be valid

  if sNewPassword = dmLibrary.tblCustomers['Password'] then
  begin // New password cannot be the same at the old password
    bValidPassword := false;
    sMessage := sMessage + #13 +
      'New password cannot be the same as the previous';
  end;

  if (bValidPassword = true) then
  begin
    showmessage('Password Updated');
    with dmLibrary do
    begin
      tblCustomers.edit;
      tblCustomers['Password'] := sNewPassword; // updating table
      tblCustomers.Post;
    end;
  end
  else
  begin
    showmessage('INVALID: ' + #13 + sMessage);
    // tells user why password isn't valid
  end;

end;

procedure TfrmCustomers.btnDeleteCustomerClick(Sender: TObject);
var
  sName, sSurname, sFileName, sCustomerID: string;
begin
  with dmLibrary do
  begin
    sName := tblCustomers['FirstName'];
    sSurname := tblCustomers['Surname'];
    sFileName := tblCustomers['CustomerID'] + '_' + tblCustomers
      ['FirstName'] + '.txt';
    sCustomerID := tblCustomers['CustomerID'];
    if Messagedlg('Are you sure you want to delete ' + sName + ' ' + sSurname +
      ('''') + 's account?', mtWarning, [mbOk, mbCancel], 0) = mrOk then
    begin
      tblTransactions.First;

      tblCustomers.Delete;
      DeleteCustomerTextFile(sFileName);
      showmessage('Record Deleted');
      // Makes sure that if an account is deleted, the book is also returned
      while not(tblTransactions.Eof) do
      begin
        if (sCustomerID = tblTransactions['CustomerID']) AND
          (tblTransactions['TransactionCompleted'] = false) then
        begin
          tblBooks.First;
          tblBooks.Locate('BookID', tblTransactions['BookID'], []);
          tblBooks.edit;
          tblBooks['AvailabilityStatus'] := true;
          tblBooks.Post;
        end;
        tblTransactions.Next;
      end;
    end;
  end;

end;

procedure TfrmCustomers.btnDisplayCustomerInfoClick(Sender: TObject);
var
  sID, sFileName: string;
  tCustomer: textfile;
begin
  redCustomerOutput.Clear;
  with dmLibrary do
  begin
    sID := inputbox('Find Customer', 'Enter Customer ID:', '');

    if tblCustomers.Locate('CustomerID', sID, []) = true then
    begin

      sFileName := tblCustomers['CustomerID'] + '_' + tblCustomers['FirstName']
        + '.txt'; // finds textfile
      assignfile(tCustomer, sFileName);

      try
        reset(tCustomer)
      except
        showmessage('file not found');
        exit;
      end;
      redCustomerOutput.Lines.LoadFromFile(sFileName);
    end
    else
    begin
      showmessage('Customer does not exist >W<');
    end;
  end;

end;

procedure TfrmCustomers.btnEditcustomerinfoClick(Sender: TObject);
var
  sUserPassword: string;

begin

  with dmLibrary do
  begin
    pnlAddCustomer.Visible := true;
    lblAddCustomerpanel.Caption := 'EDIT';
    pnlPasswords.Visible := false;
    sUserPassword := inputbox('Edit Customer Info', 'Enter password for ' +
      tblCustomers['FirstName'] + ' ' + tblCustomers['Surname'] + ' (' +
      tblCustomers['CustomerID'] + ')', '');

    if sUserPassword = tblCustomers['Password'] then
    // User can only edit their own information
    begin

      lblSelectedRecord.Caption := 'Selected Customer:' + #13 + tblCustomers
        ['FirstName'] + ' ' + tblCustomers['Surname'] + ' (' + tblCustomers
        ['CustomerID'] + ')'; // shows which customer is getting edited

      edtAddCustomerName.Text := tblCustomers['FirstName'];
      edtAddCustomerSurname.Text := tblCustomers['Surname'];
      edtAddCustomerCellNo.Text := tblCustomers['PhoneNumber'];
    end
    else
    begin
      showmessage('Incorrect Password');
      pnlAddCustomer.Visible := false;
    end;

  end;

  cbxFinePaid.Visible := true; // allows customer to pay fine
end;

procedure TfrmCustomers.btnOutstandingCustomersClick(Sender: TObject);
begin
  with dmLibrary do
  begin
    GetTotalFines;
  end;
end;

procedure TfrmCustomers.CheckForEmptyEdits(edit1, edit2, edit3, edit4,
  edit5: TEdit; var bValid: boolean); // ensures edits aren't empty
begin
  if (edit1.Text = '') or (edit1.Text = '') or (edit1.Text = '') or
    (edit1.Text = '') or (edit1.Text = '') then
  begin
    showmessage('Please answer all edits');
    bValid := false;
  end;

end;

procedure TfrmCustomers.CheckforEmptyEditsWhenEditing(var bValid: boolean);
begin // ensures edits aren't empty
  if (edtAddCustomerName.Text = '') OR (edtAddCustomerSurname.Text = '') OR
    (edtAddCustomerCellNo.Text = '') then
  begin
    showmessage('Please answer all fields');
    bValid := false;
  end;

end;

procedure TfrmCustomers.CheckValidCellNo(sNumber: string;
  var sCellMessage: string; var bValid: boolean);
var
  X: Integer;
begin
  if length(sNumber) <> 10 then // number must be 10 digits
  begin
    bValid := false;
    sCellMessage := sCellMessage + #13 + 'Phone number must be 10 digits long';

  end;

  if (sNumber = '') OR (sNumber[1] <> '0') then // must start with 0
  begin
    bValid := false;
    sCellMessage := sCellMessage + #13 + 'Phone number must begin with ' +
      ('''') + '0' + ('''');
  end;

  for X := 1 to length(sNumber) do
  begin
    if Not(CharInSet(sNumber[X], ['0' .. '9'])) then // only contain numbers
    begin
      bValid := false;
      sCellMessage := sCellMessage + #13 +
        'Phone number must only contain digits';
      exit;
    end;

  end;

end;

procedure TfrmCustomers.CheckValidName(sName, sMessage: string;
  var bAll: boolean); // name must only have letters
var
  k: Integer;
begin
  for k := 1 to length(sName) do
  begin
    if Not CharInSet(upcase(sName[k]), ['A' .. 'Z']) then
    begin
      bAll := false;
      showmessage(sMessage + ' should only contain letters of the alphabet');
      exit;
    end;

  end;

end;

procedure TfrmCustomers.CheckValidPassword(sPass, sConfirmNewPassword: string;
  var sMessage: string; var bValidNo: boolean);
var
  k, iSpecialCharCount, iCapitalCount: Integer;
begin
  iSpecialCharCount := 0;
  iCapitalCount := 0;
  if sPass <> sConfirmNewPassword then
  begin
    bValidNo := false;
    sMessage := sMessage + #13 + 'Passwords do not match';
  end;

  if length(sPass) < 8 then
  begin
    bValidNo := false;
    sMessage := sMessage + #13 + 'Password must be at least 8 characters long';
  end;

  for k := 1 to length(sPass) do
  begin
    if CharInSet(sPass[k], ['!', '#', '%', '&', '*', '@']) then
    begin
      inc(iSpecialCharCount);
    end;
    if CharInSet(sPass[k], ['A' .. 'Z']) then
    begin
      inc(iCapitalCount);
    end;

  end;

  if iSpecialCharCount < 1 then
  begin
    bValidNo := false;
    sMessage := sMessage + #13 +
      'Password Must contain at least one of the following characters: !,#,%,&,*,@';
  end;
  if iCapitalCount < 1 then
  begin
    bValidNo := false;
    sMessage := sMessage + #13 +
      'Password Must contain at least one capital letter';
  end;
end;

procedure TfrmCustomers.ClearEdits;
begin
  edtAddCustomerName.Clear;
  edtAddCustomerSurname.Clear;
  edtAddCustomerPassword.Clear;
  edtCustomerConfirmPassAdd.Clear;
  edtAddCustomerCellNo.Clear;
end;

procedure TfrmCustomers.ConnectDatabase(Sender: TObject);
begin
  dbgCustomers.DataSource := dmLibrary.dsrLibraryCustomers;
  // linking to datasource
end;

procedure TfrmCustomers.DeleteCustomerTextFile(sFileName: string);
var // deletes textfile of customer whos account has been deleted
  tCustomer: textfile;
begin
  assignfile(tCustomer, sFileName);
  DeleteFile(sFileName);
end;

procedure TfrmCustomers.FormActivate(Sender: TObject);
begin
  redCustomerOutput.Clear;
end;

function TfrmCustomers.GenerateCustomerKey: string;
var
  bKeyExists: boolean;
  sCode: string;
begin
  with dmLibrary do
  begin
    tblCustomers.open;
    bKeyExists := true;
    repeat
      sCode := uppercase(edtAddCustomerName.Text[1] + edtAddCustomerSurname.Text
        [1]) + inttostr(random(900) + 100);
      bKeyExists := tblCustomers.Locate('CustomerID', sCode, []);
    until not(bKeyExists);
    Result := sCode;
  end;

end;

procedure TfrmCustomers.GetTotalFines;
// SUMMARY - gets the total fines owed by all customers
var
  iCustomerCount: Integer;
  rTotalFine: real;
begin
  with dmLibrary do
  begin
    iCustomerCount := 0;
    rTotalFine := 0;
    tblCustomers.First;
    redCustomerOutput.Lines.Add('CUSTOMERS:');
    while not(tblCustomers.Eof) do
    begin
      if tblCustomers['CustomerFine'] > 0 then
      begin
        inc(iCustomerCount);
        rTotalFine := rTotalFine + tblCustomers['CustomerFine'];

        redCustomerOutput.Lines.Add(tblCustomers['FirstName'] + ' ' +
          tblCustomers['Surname'] + ' (' + tblCustomers['CustomerID'] + ')' + #9
          + floattostrf(tblCustomers['CustomerFine'], ffCurrency, 7, 2));
      end;

      tblCustomers.Next;
    end;

    if rTotalFine = 0 then
    begin
      redCustomerOutput.Clear;
      redCustomerOutput.Lines.Add('NO FINES OUTSTANDING :)');
    end
    else
    begin
      redCustomerOutput.Lines.Add(#13 + inttostr(iCustomerCount) +
        ' Customers Owe Fines');
      redCustomerOutput.Lines.Add(#13 + 'TOTAL FINES ACCUMULATED: ' +
        floattostrf(rTotalFine, ffCurrency, 7, 2));
    end;

  end;
end;

end.
