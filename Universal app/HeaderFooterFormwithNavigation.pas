unit HeaderFooterFormwithNavigation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs, FMX.TabControl, System.Actions, FMX.ActnList,
  FMX.Objects, FMX.StdCtrls, FMX.Colors, FMX.Controls.Presentation, FMX.Edit,
  System.Bluetooth, System.Bluetooth.Components, FMX.Layouts, FMX.ListBox,
  FMX.Effects, FMX.Filter.Effects;

type
  THeaderFooterwithNavigation = class(TForm)
    ActionList1: TActionList;
    PreviousTabAction1: TPreviousTabAction;
    TitleAction: TControlAction;
    NextTabAction1: TNextTabAction;
    TopToolBar: TToolBar;
    btnBack: TSpeedButton;
    ToolBarLabel: TLabel;
    btnNext: TSpeedButton;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    BottomToolBar: TToolBar;
    GroupBox1: TGroupBox;
    ColorBox: TColorBox;
    tbR: TTrackBar;
    edtR: TEdit;
    Label1: TLabel;
    tbG: TTrackBar;
    edtG: TEdit;
    Label2: TLabel;
    tbB: TTrackBar;
    edtB: TEdit;
    Label3: TLabel;
    btnSend: TButton;
    lbBluetoothDevices: TListBox;
    btnSearch: TButton;
    DirectionalBlurEffect1: TDirectionalBlurEffect;
    procedure FormCreate(Sender: TObject);
    procedure TitleActionUpdate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure tbRChange(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
  private
    Color : TAlphaColorRec;
    FBluetoothManager: TBluetoothManager;
    FPairedDevices: TBluetoothDeviceList;
    FAdapter: TBluetoothAdapter;
    ItemIndex: Integer;
  public
    MyDeviceName : string;
    FServiceGUID : string;
    FSocket: TBluetoothSocket;

    function PairedDevices() : TStringList;
    function SendData( nPair:integer; sData:string ) : Boolean;
  end;

var
  HeaderFooterwithNavigation: THeaderFooterwithNavigation;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.iPhone4in.fmx IOS}
{$R *.NmXhdpiPh.fmx ANDROID}

function THeaderFooterwithNavigation.PairedDevices() : TStringList;
var
  i : Integer;
  pDList : TStringList;
begin
  pDList := TStringList.Create;

  try
    FBluetoothManager := TBluetoothManager.Current;
    FAdapter := FBluetoothManager.CurrentAdapter;

    MyDeviceName := FBluetoothManager.CurrentAdapter.AdapterName;

      FPairedDevices := FBluetoothManager.GetPairedDevices;
      if FPairedDevices.Count > 0 then
         for i:= 0 to FPairedDevices.Count - 1 do
             pDList.Add( FPairedDevices[i].DeviceName );

  except
    on E : Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;

  result := pDList;
end;



function THeaderFooterwithNavigation.SendData( nPair:integer; sData:string ) : Boolean;
var
  ToSend: TBytes;
  LDevice: TBluetoothDevice;
begin
  result := FALSE;
  if ManagerConnected then
  try
    if (FSocket = nil) or ( ItemIndex <> nPair ) then
    begin
      if nPair > -1 then
      begin
        LDevice := FPairedDevices[ nPair ] as TBluetoothDevice;
        FSocket := LDevice.CreateClientSocket( StringToGUID( FServiceGUID ), False);
        if FSocket <> nil then
        begin
          ItemIndex := nPair;
          FSocket.Connect;
          ToSend := TEncoding.UTF8.GetBytes( sData );
          FSocket.SendData(ToSend);
          result := TRUE;
        end
        else
          ShowMessage('Out of time -15s-');
      end
      else
        ShowMessage('No paired device selected');
    end

    else
    begin
      ToSend := TEncoding.UTF8.GetBytes( sData );
      FSocket.SendData(ToSend);
      result := TRUE;
    end;

  except
      on E : Exception do
      begin
        ShowMessage(E.Message);
        FreeAndNil(FSocket);
      end;
    end;

procedure THeaderFooterwithNavigation.TitleActionUpdate(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    if TabControl1.ActiveTab <> nil then
      TCustomAction(Sender).Text := TabControl1.ActiveTab.Text
    else
      TCustomAction(Sender).Text := '';
  end;
end;

procedure THeaderFooterwithNavigation.btnSearchClick(Sender: TObject);
begin
  lbBluetoothDevices.Items := PairedDevices();
end;

procedure THeaderFooterwithNavigation.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.First(TTabTransition.None);
end;

procedure THeaderFooterwithNavigation.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) and (TabControl1.TabIndex <> 0) then
  begin
    TabControl1.First;
    Key := 0;
  end;
end;

procedure THeaderFooterwithNavigation.tbRChange(Sender: TObject);
var
R, G, B: Integer;
begin
  if TTrackBar(Sender).Name = 'tbR' then edtR.Text := FormatFloat('0',tbR.Value);
  if TTrackBar(Sender).Name = 'tbG' then edtG.Text := FormatFloat('0',tbG.Value);
  if TTrackBar(Sender).Name = 'tbB' then edtB.Text := FormatFloat('0',tbB.Value);

  R := StrToInt(edtR.Text);
  G := StrToInt(edtG.Text);
  B := StrToInt(edtB.Text);

  Color.R := R;
  Color.G := G;
  Color.B := B;
  Color.A := $FF;
  ColorBox.Color := Color.Color;


end;

end.
