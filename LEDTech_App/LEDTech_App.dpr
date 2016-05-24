program LEDTech_App;

uses
  System.StartUpCopy,
  FMX.Forms,
  TabbedFormwithNavigation in 'TabbedFormwithNavigation.pas' {LEDTech},
  BluetoothUnit in 'BluetoothUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TLEDTech, LEDTech);
  Application.Run;
end.
