import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_printer_manager/pos_printer_manager.dart';
import 'package:test_printer_final/printer_manager_custom.dart';
import 'package:test_printer_final/resume_ticket.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  List<BluetoothPrinter> _printers = [];
  PrinterManagerCustom manager = PrinterManagerCustom();
  String messageConnection = '';
  bool blueState = false;

  Future<bool> checkStateBlue() async {
    return await manager.bluetoothState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ElevatedButton(
              onPressed: () async {
                await manager.disconnectDevice();
              },
              child: Icon(Icons.close))
        ],
      ),
      body: ListView.builder(
        itemCount: _printers.length,
        itemBuilder: (_, index) {
          return ListTile(
              trailing: Icon(Icons.bluetooth_disabled),
              title: Text(_printers[index].name ?? ''),
              onTap: () async {
                if (await manager.isConnected() == false) {
                  messageConnection =
                      await manager.connectDevice(printer: _printers[index]);

                            if(messageConnection != 'Success'){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Ocorreu um erro de conexão'),
                                        Text('Clique em ok e tente novamente'),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 3),
                                ),
                              );
                            }

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ja esta conectado'),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                }
              });
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              if (await manager.isConnected()) {
                await manager.startPrinter(ticket: ResumeTicket.resumeTicket());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ocorreu um erro de conexão'),
                        Text('Tente se conectar novamente'),
                      ],
                    ),
                    duration: const Duration(milliseconds: 2000),
                  ),
                );
              }
            },
            child: Icon(Icons.print),
          ),

          const SizedBox(
            width: 100,
          ),
          FloatingActionButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
                _printers = [];
              });
              if (await checkStateBlue()) {
                _printers = await manager.starScanDevices();
              } else {
                print('Ligue seu bluetooth');
              }
              setState(() {
                _isLoading = false;
              });
            },
            child: _isLoading ? Icon(Icons.stop) : Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
