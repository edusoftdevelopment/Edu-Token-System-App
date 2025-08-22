// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

// class PrintingMethod {
//     Future<List<int>> _buildBytes({required String date, required String time}) async {
//     final CapabilityProfile profile = await CapabilityProfile.load();
//     final Generator generator = Generator(PaperSize.mm80, profile);

//     List<int> bytes = [];

//     // Top stars line
//     bytes += generator.text(
//       '********************************',
//       styles: PosStyles(bold: true, align: PosAlign.center),
//     );

//     // Big number in center (9800)
//     bytes += generator.text(
//       '9800',
//       styles: const PosStyles(
//         align: PosAlign.center,
//         bold: true,
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//     );

//     // Bottom stars line
//     bytes += generator.text(
//       '********************************',
//       styles: PosStyles(bold: true, align: PosAlign.center),
//     );

//     // Parking title
//     bytes += generator.text(
//       'Fun Forest car Parking',
//       styles: PosStyles(align: PosAlign.center),
//     );

//     bytes += generator.feed(1);

//     // Date & Time
//     bytes += generator.text(
//       'Date:${date}  Time:${time}',
//       styles: PosStyles(align: PosAlign.left),
//     );

//     bytes += generator.text(
//       'Price: 70 Rs   Ticket: SR-2892',
//       styles: PosStyles(align: PosAlign.left),
//     );

//     bytes += generator.feed(1);

//     // Footer text
//     bytes += generator.text(
//       'Keep this ticket for exit.',
//       styles: PosStyles(align: PosAlign.center),
//     );
//     bytes += generator.text(
//       'Thanks for visiting!',
//       styles: PosStyles(align: PosAlign.center),
//     );

//     bytes += generator.cut();
//     return bytes;
//   }

//   Future<void> _printText() async {
//     if (connectedMac == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please connect to a printer first')),
//       );
//       return;
//     }

//     setState(() => busy = true);
//     try {
//       final bytes = await _buildBytes();
//       final res = await PrintBluetoothThermal.writeBytes(bytes);
//       debugPrint('writeBytes result: $res');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Print sent')));
//     } catch (e) {
//       debugPrint('Print error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Print error: $e')));
//     } finally {
//       setState(() => busy = false);
//     }
//   }
// }