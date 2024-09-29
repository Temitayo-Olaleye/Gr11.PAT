unit PAT_U;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Menu_U,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Checkout_U;

type
  TfrmLogIn = class(TForm)
    edtLoginformPassword: TEdit;
    lblWelcomelogin: TLabel;
    lblloginPassword: TLabel;
    btnLogin: TButton;
    imgLogIn: TImage;
    imgPasswordMenu: TImage;
    procedure FormActivate(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure imgPasswordMenuClick(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  frmLogIn: TfrmLogIn;

implementation

{$R *.dfm}

procedure TfrmLogIn.btnLoginClick(Sender: TObject);
var
sAdminPassword : string;
begin

//To validate that the admin password is correct
   sAdminPassword := 'Go@tinelli#';
  if edtLoginformPassword.Text = sAdminPassword then
  begin
     frmMenu.showmodal;
  frmLogIn.close;
  end
  else
  begin
    edtLoginformPassword.Clear;
    ShowMessage('Password Incorrect :/') ;
  end;


end;

procedure TfrmLogIn.FormActivate(Sender: TObject);
begin

  edtLoginformPassword.SetFocus;

end;

procedure TfrmLogIn.imgPasswordMenuClick(Sender: TObject);
begin
//Procedure in checkout_U that shows/ hides passwords
  Checkout_U.frmCheckout.SeePassword(edtLoginformPassword, imgPasswordMenu);

end;



end.
