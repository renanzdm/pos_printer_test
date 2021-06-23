import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:test_printer_final/ticket_service.dart';
import 'package:webcontent_converter/webcontent_converter.dart';
import 'package:flutter_blue/flutter_blue.dart';

class PrinterManagerCustom {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothPrinter? printerDevice;


  BluetoothPrinterManager? manager;

  Future<List<BluetoothPrinter>> starScanDevices() async {
    print("init scan");
    List<BluetoothPrinter> printers = await BluetoothPrinterManager.discover();
    return printers;
  }

  Future<String> connectDevice(
      {required BluetoothPrinter printer,
      PaperSize paperSize = PaperSize.mm80,
      Duration duration = const Duration(seconds: 5)}) async {
    if(printerDevice == null) printerDevice = printer;
    CapabilityProfile profile = await CapabilityProfile.load();
    manager = BluetoothPrinterManager(printerDevice!, paperSize, profile);
    ConnectionResponse res = await manager!.connect();
    if (res.value == ConnectionResponse.success.value) {
      return 'Success';
    } else if (res.value == ConnectionResponse.timeout.value) {
      return 'Error. Printer connection timeout';
    } else if (res.value == ConnectionResponse.printerNotSelected.value) {
      return 'Error. Printer not selected';
    } else if (res.value == ConnectionResponse.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (res.value == ConnectionResponse.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (res.value == ConnectionResponse.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else {
      return 'Unknown error';
    }
  }

  Future<bool> bluetoothState() async {
   bool state = await flutterBlue.isOn;
    return state;
  }

  Future<bool> isConnected() async {
    if(Platform.isIOS){
    var listOfDevicesConnected = await flutterBlue.connectedDevices;
    var deviceConnected = listOfDevicesConnected.firstWhere((element) => element.name == printerDevice?.name);
    if(deviceConnected !=null){
      return true;
    }else{
      return false;
    }
}if(Platform.isAndroid){
      bool? state = await bluetooth.isConnected;
      return state ?? false;
    }
    return false;

  }

  Future startPrinter({required String ticket}) async {
    Uint8List bytes = await WebcontentConverter.contentToImage(content: ticket);
    ESCPrinterService service = ESCPrinterService(bytes);
    List<int> data = await service.getBytes();
    if (manager != null) {
      print("isConnected ${manager!.isConnected}");
      manager!.writeBytes(data, isDisconnect: false);
    }
  }

  Future disconnectDevice() async {
    await manager?.disconnect();
  }




}
