// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:flutter/material.dart';

// class BluetoothPrintExample extends StatefulWidget {
//   const BluetoothPrintExample({super.key});

//   @override
//   State<BluetoothPrintExample> createState() => _BluetoothPrintExampleState();
// }

// class _BluetoothPrintExampleState extends State<BluetoothPrintExample> {
//   BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
//   List<BluetoothDevice> devices = [];
//   BluetoothDevice? selectedDevice;

//   @override
//   void initState() {
//     super.initState();
//     _getDevices();
//   }

//   /// Scan available Bluetooth devices
//   Future<void> _getDevices() async {
//     List<BluetoothDevice> availableDevices = await bluetooth.getBondedDevices();
//     setState(() {
//       devices = availableDevices;
//     });
//   }

//   /// Connect to selected device
//   Future<void> _connectPrinter() async {
//     if (selectedDevice != null) {
//       await bluetooth.connect(selectedDevice!);
//     }
//   }

//   /// Print test text
//   Future<void> _printSample() async {
//     await bluetooth.printNewLine();
//     await bluetooth.printCustom("Hello from Flutter!", 1, 1);
//     await bluetooth.printNewLine();
//     await bluetooth.paperCut();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Bluetooth Printer Example")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButton<BluetoothDevice>(
//               hint: const Text("Select Printer"),
//               value: selectedDevice,
//               onChanged: (BluetoothDevice? device) {
//                 setState(() {
//                   selectedDevice = device;
//                 });
//               },
//               items: devices
//                   .map((device) => DropdownMenuItem(
//                         value: device,
//                         child: Text(device.name ?? "Unknown"),
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _connectPrinter,
//               child: const Text("Connect"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _printSample,
//               child: const Text("Print Test"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
