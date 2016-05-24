unit TabbedFormwithNavigation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Gestures, System.Actions, FMX.ActnList, FMX.Colors, FMX.Layouts, BluetoothUnit,
  FMX.ListBox;

type
  TLEDTech = class(TForm)
    TabControl1: TTabControl;
    ConnectionTab: TTabItem;
    ConnectForm: TTabControl;
    TabItem5: TTabItem;
    ColorTab: TTabItem;
    GestureManager1: TGestureManager;
    ColorPicker: TColorPicker;
    ColorQuad: TColorQuad;
    ColorBox: TColorBox;
    TabItem6: TTabItem;
    lbDevices: TListBox;
    lblStatus: TLabel;
    procedure GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure lbDevicesChange(Sender: TObject);
    procedure ColorBoxClick(Sender: TObject);
  private
    Bluetooth: TBTMethod; //TBTMethod object
  public
  end;

var
  LEDTech: TLEDTech;

implementation

{$R *.fmx}


procedure TLEDTech.ColorBoxClick(Sender: TObject);  //Send new color to STM board
var
  R, G, B: Byte;
  RGB: Integer;
  Color: TColorRec;
begin
  RGB := Color.ColorToRGB(ColorBox.Color);
  R := (RGB and $00ff0000) shr 16;
  G := (RGB and $0000ff00) shr 8;
  B := RGB and $000000ff;

  Bluetooth.SendData(lbDevices.ItemIndex, R, G, B);
end;

procedure TLEDTech.FormCreate(Sender: TObject);
begin
  { This defines the default active tab at runtime }
  TabControl1.ActiveTab := ConnectionTab;
  Bluetooth := TBTMethod.Create;
  lbDevices.Items := Bluetooth.PairedDevices;
end;

procedure TLEDTech.GestureDone(Sender: TObject; const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
  case EventInfo.GestureID of
    sgiLeft:
      begin
        if TabControl1.ActiveTab <> TabControl1.Tabs[TabControl1.TabCount - 1] then
          TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex + 1];
        Handled := True;
      end;

    sgiRight:
      begin
        if TabControl1.ActiveTab <> TabControl1.Tabs[0] then
          TabControl1.ActiveTab := TabControl1.Tabs[TabControl1.TabIndex - 1];
        Handled := True;
      end;
  end;
end;

procedure TLEDTech.lbDevicesChange(Sender: TObject);
var
  DeviceInfo : DServiceListType;
begin
  if lbDevices.ItemIndex > -1 then
    begin
      lblStatus.Text := 'Connecting....';
      DeviceInfo := Bluetooth.Find_ServicesList(lbDevices.ItemIndex);
      Bluetooth.FServiceGUID := DeviceInfo.DServiceGUID[0];
      Bluetooth.MyDeviceName := DeviceInfo.DServiceName.Text;

      ColorTab.Enabled := True;


      lblStatus.Text := 'Connected';
      lblStatus.FontColor := $FF00FF00;

    end else ShowMessage('No selected device');
end;

end.

