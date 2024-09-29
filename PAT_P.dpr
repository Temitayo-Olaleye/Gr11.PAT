program PAT_P;

uses
  Vcl.Forms,
  PAT_U in 'PAT_U.pas' {frmLogIn},
  Menu_U in 'Menu_U.pas' {frmMenu},
  BookInventory_U in 'BookInventory_U.pas' {frmBookInventory},
  Customers_U in 'Customers_U.pas' {frmCustomers},
  Checkout_U in 'Checkout_U.pas' {frmCheckout},
  TransactionHistory_U in 'TransactionHistory_U.pas' {frmTransactionHistory},
  dmLibrary_U in 'dmLibrary_U.pas' {dmLibrary: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogIn, frmLogIn);
  Application.CreateForm(TfrmMenu, frmMenu);
  Application.CreateForm(TfrmBookInventory, frmBookInventory);
  Application.CreateForm(TfrmCustomers, frmCustomers);
  Application.CreateForm(TfrmCheckout, frmCheckout);
  Application.CreateForm(TfrmTransactionHistory, frmTransactionHistory);
  Application.CreateForm(TdmLibrary, dmLibrary);
  Application.Run;
end.
