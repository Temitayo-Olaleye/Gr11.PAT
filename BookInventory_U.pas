unit BookInventory_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.Buttons,
  dmLibrary_U, ADODB;

type
  TfrmBookInventory = class(TForm)
    btnAddBook: TButton;
    btnDeleteBook: TButton;
    btnEditBook: TButton;
    dbgBooks: TDBGrid;
    lblBookInventory: TLabel;
    redOutput: TRichEdit;
    btnFindPopularBooks: TButton;
    imgbookfrmBook: TImage;
    pnlAddBook: TPanel;
    lblTitleInventory: TLabel;
    lblAuthorInventory: TLabel;
    lblgenreInventory: TLabel;
    edtAddbookTitle: TEdit;
    edtAddBookAuthor: TEdit;
    edtAddBookGenre: TEdit;
    lblAddbookpanel: TLabel;
    bitCloseBookForm: TBitBtn;
    btnAddBookconfirm: TButton;
    lblBookEditCurrent: TLabel;
    btnCancelBook: TButton;
    Image1: TImage;
    imgShelf: TImage;
    procedure ConnectDatabase(Sender: TObject);
    procedure btnAddBookClick(Sender: TObject);
    procedure btnEditBookClick(Sender: TObject);
    procedure btnAddBookconfirmClick(Sender: TObject);
    procedure btnDeleteBookClick(Sender: TObject);
    procedure btnCancelBookClick(Sender: TObject);
    procedure btnFindPopularBooksClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    // parallel arrays of books taken out the most
    arrPopularBooksNames: array [1 .. 5] of string;
    arrPopularBooksCount: array [1 .. 5] of integer;

    procedure EditsAnswered(var bValid: boolean); // Ensures edits are not blank
    procedure ClearEdits; // clears contents of edits

    { Private declarations }

  public
    { Public declarations }
    function GetPrimaryKey(tblTable: TADOtable; sField: string): integer;
    // Function that creats primary key for records in the Transaction and Book Tables
  end;

var
  frmBookInventory: TfrmBookInventory;

implementation

{$R *.dfm}

procedure TfrmBookInventory.btnAddBookClick(Sender: TObject);
begin
  pnlAddBook.Visible := true;
  lblAddbookpanel.Caption := 'ADD';
  lblBookEditCurrent.Caption := '';
  ClearEdits;
  redOutput.Width := 225;
  redOutput.Clear;
end;

procedure TfrmBookInventory.btnAddBookconfirmClick(Sender: TObject);
var
  iBookKey: integer; // primary key
  bValid: boolean; // boolean to determine if all inputs are valid
begin
  with dmLibrary do
  begin
    bValid := true;
    EditsAnswered(bValid);

    if (bValid = true) AND (lblAddbookpanel.Caption = 'ADD') then
    begin
      // Inserting record
      iBookKey := GetPrimaryKey(tblBooks, 'BookID');
      tblBooks.Last;
      tblBooks.Insert;
      tblBooks['BookID'] := iBookKey;
      tblBooks['BookName'] := edtAddbookTitle.Text;
      tblBooks['Author'] := edtAddBookAuthor.Text;
      tblBooks['Genre'] := edtAddBookGenre.Text;
      tblBooks['AvailabilityStatus'] := true;
      tblBooks['BorrowedCount'] := 0;
      tblBooks.Post;
      ShowMessage('Book Added');
      ClearEdits;
      pnlAddBook.Visible := false;
    end;

    if (bValid = true) AND (lblAddbookpanel.Caption = 'EDIT') then
    begin
      // editing/updating records
      tblBooks.Edit;
      tblBooks['BookName'] := edtAddbookTitle.Text;
      tblBooks['Author'] := edtAddBookAuthor.Text;
      tblBooks['Genre'] := edtAddBookGenre.Text;
      tblBooks.Post;
      ShowMessage('Book Edited');
      ClearEdits;
      pnlAddBook.Visible := false;
    end;

  end;
end;

procedure TfrmBookInventory.btnCancelBookClick(Sender: TObject);
begin
  lblBookEditCurrent.Caption := '';

  pnlAddBook.Visible := false;
  ClearEdits;

end;

procedure TfrmBookInventory.btnDeleteBookClick(Sender: TObject);
var
  sBookID, sBookName: string;

begin
  redOutput.Width := 225;
  redOutput.Clear;
  with dmLibrary do
  begin
    // deleting records
    sBookID := inttostr(tblBooks['BookID']);
    sBookName := tblBooks['BookName'];
    if MessageDlg('Are you sure you want to delete Book ' + sBookID + ': ' +
      sBookName + '?', mtWarning, [mbOk, mbCancel], 0) = mrOk then
    begin
      tblBooks.Delete;
      ShowMessage('Book Deleted');

    end;

  end;
end;

procedure TfrmBookInventory.btnEditBookClick(Sender: TObject);
begin
  redOutput.Clear;
  redOutput.Width := 225;
  lblAddbookpanel.Caption := 'EDIT';
  pnlAddBook.Visible := true;
  lblBookEditCurrent.Caption := 'Selected Book ID:  ' +
    inttostr(dmLibrary.tblBooks['BookID']);

  with dmLibrary do
  begin
    // puts per-edited info in the edits, them the user can change them
    edtAddbookTitle.Text := tblBooks['BookName'];
    edtAddBookAuthor.Text := tblBooks['Author'];
    edtAddBookGenre.Text := tblBooks['Genre'];
    edtAddbookTitle.SetFocus;

  end;
end;

procedure TfrmBookInventory.btnFindPopularBooksClick(Sender: TObject);
var
  iBookCount, L, K: integer;
  sBook: string;

begin
  pnlAddBook.Visible := false;
  with dmLibrary do
  begin
    tblBooks.Sort := 'BorrowedCount DESC';
    // sorts table so the arrays can be populated
    tblBooks.First;
    redOutput.Width := 689;
    redOutput.Lines.Clear;
    redOutput.Paragraph.TabCount := 2;
    redOutput.Paragraph.Tab[0] := 20;
    redOutput.Paragraph.Tab[1] := 200;

    for L := 1 to 5 do
    begin
      // Populated with books that have been taken out the most
      arrPopularBooksNames[L] := tblBooks['BookName'];
      arrPopularBooksCount[L] := tblBooks['BorrowedCount'];
      tblBooks.Next;
    end;

    redOutput.Lines.Add('MOST POPULAR BOOKS:' + #9 + 'Times Borrowed:' + #13);
    for K := 1 to 5 do
    begin
      redOutput.Lines.Add(inttostr(K) + '.  ' + arrPopularBooksNames[K] + #9 +
        inttostr(arrPopularBooksCount[K]) + #13);
    end;
  end;

end;

procedure TfrmBookInventory.ClearEdits;
begin
  edtAddbookTitle.Clear;
  edtAddBookAuthor.Clear;
  edtAddBookGenre.Clear;
end;

procedure TfrmBookInventory.ConnectDatabase(Sender: TObject);
begin
  dbgBooks.DataSource := dmLibrary.dsrLibraryBooks;
  // linking datasource to dgbGrid
end;

procedure TfrmBookInventory.EditsAnswered(var bValid: boolean);
begin
  if (edtAddbookTitle.Text = '') Or (edtAddBookAuthor.Text = '') Or
    (edtAddBookGenre.Text = '') then
  begin
    ShowMessage('Please answer all fields :/');
    bValid := false;
  end;

end;

procedure TfrmBookInventory.FormActivate(Sender: TObject);
begin
  redOutput.Lines.Clear;
  redOutput.Width := 225;
end;

function TfrmBookInventory.GetPrimaryKey(tblTable: TADOtable;
  sField: string): integer;
var
  iLargest: integer;
begin
//Finds unique number that has not been used before
  iLargest := 0;
  with dmLibrary do
  begin
    tblTable.First;
    while not(tblTable.Eof) do
    begin
      if tblTable[sField] > iLargest then
        iLargest := tblTable[sField];

      tblTable.Next;
    end;
    Result := iLargest + 1;
  end;
end;

end.
