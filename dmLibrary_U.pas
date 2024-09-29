unit dmLibrary_U;

interface

uses
  System.SysUtils, System.Classes, ADODB, DB;

type
  TdmLibrary = class(TDataModule)
    procedure DataModuleSetup(Sender: TObject);

  private
    { Private declarations }
    procedure ConnectTablez(sTableName: TADOtable; sDatasource : TDataSource; sName: string);
  public
    { Public declarations }
    // Declaring database objects
    conLibrary: TADOconnection;
    tblBooks, tblCustomers, tblTransactions: TADOtable;
    dsrLibraryBooks, dsrLibraryCustomers, dsrLibraryTransactions: TDataSource;
  end;

var
  dmLibrary: TdmLibrary;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TdmLibrary.ConnectTablez(sTableName: TADOtable; sDatasource : TDataSource; sName: string);
begin
  sTableName.Connection := conLibrary;
  sTableName.TableName := sName;

  sDataSource.DataSet := sTableName;
  sTableName.Open;
end;

procedure TdmLibrary.DataModuleSetup(Sender: TObject);
begin
  // creating objects
  conLibrary := TADOconnection.Create(dmLibrary);

  tblBooks := TADOtable.Create(dmLibrary);
  tblCustomers := TADOtable.Create(dmLibrary);
  tblTransactions := TADOtable.Create(dmLibrary);

  dsrLibraryBooks := TDataSource.Create(dmLibrary);
  dsrLibraryCustomers := TDataSource.Create(dmLibrary);
  dsrLibraryTransactions := TDataSource.Create(dmLibrary);


  // making connection
  conLibrary.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;Data Source= Library.mdb;Mode=ReadWrite;Persist Security Info=False';
  conLibrary.LoginPrompt := false;
  conLibrary.Open;

  ConnectTablez(tblBooks,dsrLibraryBooks, 'Books');
  ConnectTablez(tblCustomers, dsrLibraryCustomers, 'Customers');
  ConnectTablez(tblTransactions, dsrLibraryTransactions, 'Transactions');

end;

end.
