﻿unit BluetoothUnit;

interface

Uses
  System.SysUtils, System.Classes, System.Bluetooth,
  FMX.Dialogs;

type
  DServiceListType = Record    // Service List of Paired Devices.
  DServiceName : TStringList;
  DServiceGUID : TStringList;
end;

type
  TBTMethod = class(TObject)
  private
    FBluetoothManager: TBluetoothManager;    //Delphi Bluetooth module
    FPairedDevices: TBluetoothDeviceList;    //List of paired devices
    FAdapter: TBluetoothAdapter;             //Bluetooth adapter
    ItemIndex: Integer;

  public
    MyDeviceName : string;                                      //Devuce Name
    FServiceGUID : string;                                      //GUID
    FSocket: TBluetoothSocket;                                  //Socket for Bluetooth comunication

    constructor Create;
    destructor Destroy; override;

    function ManagerConnected() :Boolean;
    function PairedDevices : TStringList;                              //Get list of paired devices
    function Find_ServicesList( nPair : integer ) : DServiceListType;   //Get service list
    function SendData( nPair: Integer; LEDNumber, Option, R, G, B: Byte) : Boolean;        //Send color of LED to STM
   end;

implementation


//----------------------------------------------------
constructor TBTMethod.Create;
begin
  inherited;
end;


destructor TBTMethod.Destroy;
begin
  inherited;
end;

//-------------------------------------------------------------------------------
function TBTMethod.ManagerConnected() :Boolean;
begin
  if FBluetoothManager.ConnectionState = TBluetoothConnectionState.Connected then
     Result := True
  else
    Result := False;
end;



function TBTMethod.PairedDevices() : TStringList;
var
  i : Integer;
  pDList : TStringList;
begin
  pDList := TStringList.Create;

  try
    FBluetoothManager := TBluetoothManager.Current;
    FAdapter := FBluetoothManager.CurrentAdapter;

    MyDeviceName := FBluetoothManager.CurrentAdapter.AdapterName;

    if ManagerConnected then
    begin
      FPairedDevices := FBluetoothManager.GetPairedDevices;

      if FPairedDevices.Count > 0 then
         for i:= 0 to FPairedDevices.Count - 1 do
             pDList.Add( FPairedDevices[i].DeviceName );
    end;

  except
    on E : Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;

  result := pDList;
end;


//-------------------------------------------------------------------------------------
// nPair : Paired Device List No
function TBTMethod.Find_ServicesList( nPair : integer ) : DServiceListType;
var
  LServices: TBluetoothServiceList;
  LDevice: TBluetoothDevice;
  i : Integer;
  pSList : DServiceListType;
begin
  pSList.DServiceName := TStringList.Create;
  pSList.DServiceGUID := TStringList.Create;

  if ManagerConnected then
    if nPair > -1 then
    begin
      LDevice :=  FPairedDevices[ nPair ] as TBluetoothDevice;
      LServices := LDevice.GetServices;

      for i := 0 to LServices.Count - 1 do
      begin
        if LServices[ i ].Name = '' then
           pSList.DServiceName.Add( 'Unknown Service Name' )
        else
          pSList.DServiceName.Add( LServices[ i ].Name );
        pSList.DServiceGUID.Add( GUIDToString( LServices[ i ].UUID ));
      end;

    end
    else
      ShowMessage('No paired device selected');

  result := pSList;
end;

//---------------------------------------------------------------------------------------
// nPair : Paired Device List No
function TBTMethod.SendData( nPair: Integer; LEDNumber, Option, R, G, B: Byte) : Boolean;
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
          SetLength(ToSend,1);
          ToSend[0] := LEDNumber;
          FSocket.SendData(ToSend);
          sleep(300);
          ToSend[0] := Option;
          FSocket.SendData(ToSend);
          sleep(300);
          ToSend[0] := R;
          FSocket.SendData(ToSend);
          sleep(300);
          ToSend[0] := G;
          FSocket.SendData(ToSend);
          sleep(300);
          ToSend[0] := B;
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
      SetLength(ToSend,1);
      ToSend[0] := LEDNumber;
      FSocket.SendData(ToSend);
      sleep(300);
      ToSend[0] := Option;
      FSocket.SendData(ToSend);
      sleep(300);
      ToSend[0] := R;
      FSocket.SendData(ToSend);
      sleep(300);
      ToSend[0] := G;
      FSocket.SendData(ToSend);
      sleep(300);
      ToSend[0] := B;
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
end;



end.
