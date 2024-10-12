// ignore_for_file: prefer_const_constructors

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(const MyApp());
// }

void main() => runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(), // Wrap your app
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth Beacon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    scanForBluetooth();
    checkPermissions();
  }

  // Request necessary permissions
  Future<void> checkPermissions() async {
    var bluetoothScanStatus = await Permission.bluetoothScan.request();
    var locationStatus = await Permission.location.request();

    if (bluetoothScanStatus.isGranted && locationStatus.isGranted) {
      scanForBluetooth();
    } else {
      // Handle denied permissions
      print("Permissions not granted");
    }
  }

  void scanForBluetooth() async {
    // Start scanning
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'For Marshee',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                scanResults.clear();
                scanForBluetooth();
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade400,
                  minimumSize: Size(300, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  )),
              child: const Text(
                "Scan",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;
                return ListTile(
                  title: Text(device.platformName.isEmpty
                      ? 'Unknown Device'
                      : device.platformName),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: Text('${scanResults[index].rssi} dBm'),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
