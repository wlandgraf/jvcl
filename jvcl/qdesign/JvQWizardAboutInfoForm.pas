{**************************************************************************************************}
{  WARNING:  JEDI preprocessor generated unit. Manual modifications will be lost on next release.  }
{**************************************************************************************************}

{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvWizardAboutInfoForm.PAS, released on 2002-01-25.

The Initial Developer of the Original Code is William Yu Wei.
Portions created by William Yu Wei are Copyright (C) 2001 William Yu Wei.
All Rights Reserved.

Contributor(s):
Peter Th�rnqvist - converted to JVCL naming conventions on 2003-07-11

Last Modified: 2002-02-25

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}
{*****************************************************************************
  Purpose:      a wizard about form to display copyright,
                author, version information.

  History:
  ---------------------------------------------------------------------------
  Date(mm/dd/yy)   Comments
  ---------------------------------------------------------------------------
  01/25/2002       Initial create
******************************************************************************}

unit JvQWizardAboutInfoForm;

interface

{$I jvcl.inc}

uses
  
  
  QStdCtrls, QExtCtrls, QGraphics, QControls, QForms, QDialogs,
  
  
  DesignIntf, DesignEditors,
  
  SysUtils, Classes;

const
  JvWizard_VERSIONSTRING = 'Version 1.70';

type
  TJvWizardAboutDialogProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

  TJvWizardAboutDialog = class(TForm)
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblVersion: TLabel;
    Image1: TImage;
    Bevel1: TBevel;
    lblCopyRight: TLabel;
    Label3: TLabel;
    btnOK: TButton;
    Panel1: TPanel;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    protected
      procedure CreateParams(var Params: TCreateParams); override;
    end;

implementation



{$R *.xfm}


//=== TJvWizardAboutDialogProperty ===========================================

procedure TJvWizardAboutDialogProperty.Edit;
begin
  with TJvWizardAboutDialog.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

function TJvWizardAboutDialogProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TJvWizardAboutDialogProperty.GetValue: string;
begin
  Result := JvWizard_VERSIONSTRING;
end;

//=== TJvWizardAboutDialog ===================================================

procedure TJvWizardAboutDialog.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TJvWizardAboutDialog.FormShow(Sender: TObject);
begin
  lblVersion.Caption := JvWizard_VERSIONSTRING;
  lblCopyRight.Caption := 'Copyright � yuwei, 2001 - ' + FormatDateTime('yyyy', Now);
end;



procedure TJvWizardAboutDialog.Panel1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  ReleaseCapture;
//  Perform(WM_SYSCOMMAND, SC_MOVE + 2, 0);
end;

end.