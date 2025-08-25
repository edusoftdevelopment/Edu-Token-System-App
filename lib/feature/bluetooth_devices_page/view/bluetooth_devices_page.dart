import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/network/network.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class BluetoothDevicesPage extends ConsumerStatefulWidget {
  BluetoothDevicesPage({super.key, this.time, this.date});

  String? time;
  String? date;

  @override
  ConsumerState<BluetoothDevicesPage> createState() =>
      _BluetoothDevicesPageState();
}

class _BluetoothDevicesPageState extends ConsumerState<BluetoothDevicesPage> {
  // Use the real BluetoothInfo type from the package
  List<BluetoothInfo> paired = [];

  String? connectedMac;
  final TextEditingController _textController = TextEditingController(
    text:
        'Sample Receipt\nItem 1 - PKR 100\nItem 2 - PKR 50\n----------------\nTOTAL - PKR 150',
  );

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    await _loadPaired();
  }

  Future<void> _showErrorDialog(String title, String message) async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.kWhite),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.kWhite),
        ),
        actions: [
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.kWhite),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // This will close the dialog
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadPaired() async {
    ref.read(isBusyProvider.notifier).state = true;
    try {
      final List<BluetoothInfo>? list =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() => paired = list ?? []);

      // Inspect devices in console
      for (final d in paired) {
        debugPrint('--- Device ---');
        debugPrint('runtimeType: ${d.runtimeType}');
        debugPrint('toString(): $d');
        // Common properties (name & mac used earlier)
        debugPrint('name: ${d.name}');
        debugPrint('mac: ${d.macAdress}');

        //       try {
        //        BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
        //   BluetoothDevice? device = await bluetooth.;
        //   if (device != null) {
        //     print("Device name: ${device.name}");
        //     print("Device address: ${device.address}");
        //   } else {
        //     print("No device connected");
        //   }
        // } catch (e) {
        //   print("Error: $e");
        // }
      }
    }on Failure catch (e) {
      debugPrint('Error loading paired: $e');
      await _showErrorDialog('Error', 'Failed to load paired devices: $e');
      setState(() => paired = []);
    } finally {
      ref.read(isBusyProvider.notifier).state = false;
    }
  }

  Future<void> _connect(String mac) async {
    ref.read(isBusyProvider.notifier).state = true;
    try {
      final res = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      if (res == true ||
          res == 'It is okay' ||
          res == 'true' ||
          res == 'connected') {
        connectedMac = mac;
        // update provider here — OK because this is not during build
        ref.read(connectedMacProvider.notifier).state = mac;

        await _showErrorDialog('Successfully Connected', 'Connected to $mac');
      } else {
        await _showErrorDialog('Message', 'Connect returned: $res');
      }
    } catch (e) {
      debugPrint('Connect error: $e');
      await _showErrorDialog('Connect error!', 'Failed to connect: $e');
    } finally {
      ref.read(isBusyProvider.notifier).state = false;
    }
  }

  Future<void> _disconnect() async {
    try {
      await PrintBluetoothThermal
          .disconnect; // ensure this is a function/call if required
      connectedMac = null;
      // update provider here too
      ref.read(connectedMacProvider.notifier).state = null;

      await _showErrorDialog(
        'Disconnected!',
        'Successfully disconnected from device.',
      );
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disconnected')));
    } on Failure catch (e) {
      debugPrint('Disconnect error: $e');
      await _showErrorDialog('Error', 'Failed to disconnect: $e');
    }
  }

  // Future<void> _connect(String mac) async {
  //   ref.read(isBusyProvider.notifier).state = true;
  //   try {
  //     final res = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
  //     if (res == true ||
  //         res == 'It is okay' ||
  //         res == 'true' ||
  //         res == 'connected') {
  //       connectedMac = mac;
  //       ref.read(connectedMacProvider.notifier).state = mac;

  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Connected')));
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Connect returned: $res')));
  //     }
  //   } catch (e) {
  //     debugPrint('Connect error: $e');
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Connect error: $e')));
  //   } finally {
  //     ref.read(isBusyProvider.notifier).state = false;
  //   }
  // }

  // Future<void> _disconnect() async {
  //   try {
  //     // <<-- important: call the function (parentheses)
  //     await PrintBluetoothThermal.disconnect;

  //     connectedMac = null;
  //     ref.read(connectedMacProvider.notifier).state = null;

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Disconnected')));
  //   } catch (e) {
  //     debugPrint('Disconnect error: $e');
  //   }
  // }

  Future<List<int>> _buildBytes() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    var bytes = <int>[];

    // Top stars line
    bytes += generator.text(
      '********************************',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );

    // Big number in center (9800)
    bytes += generator.text(
      '9800',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Bottom stars line
    bytes += generator.text(
      '********************************',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );

    // Parking title
    bytes += generator.text(
      'Fun Forest car Parking',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    // Date & Time
    bytes += generator.text(
      'Date:${widget.date}  Time:${widget.time}',
      styles: const PosStyles(align: PosAlign.left),
    );

    bytes += generator.text(
      'Price: 70 Rs   Ticket: SR-2892',
      styles: const PosStyles(align: PosAlign.left),
    );

    bytes += generator.feed(1);

    // Footer text
    bytes += generator.text(
      'Keep this ticket for exit.',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Thanks for visiting!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();
    return bytes;
  }

  Future<void> _printText() async {
    if (connectedMac == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect to a printer'),
        ),
      );
      return;
    }

    ref.read(isBusyProvider.notifier).state = true;
    try {
      final bytes = await _buildBytes();
      final res = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('writeBytes result: $res');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Print sent')));
    } on Failure catch (e) {
      debugPrint('Print error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Print error: $e')));
    } finally {
      ref.read(isBusyProvider.notifier).state = false;
    }
  }

  // Use BluetoothInfo's properties directly (name and macAdress)
  // Use BluetoothInfo's properties directly (name and macAdress)
  Widget _deviceTile(BluetoothInfo d, int index) {
    final name = d.name;
    final mac = d.macAdress;

    // read provider (or use connectedMac variable) — this is safe in build
    final currentConnectedMac = ref.watch(connectedMacProvider);
    final isConnected =
        currentConnectedMac != null && currentConnectedMac == mac;

    return ListTile(
      title: Text(name),
      subtitle: Text(mac),
      trailing: isConnected
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: _disconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            )
          : TextButton(
              onPressed: () => _connect(mac),
              child: const Text('Connect'),
            ),
    );
  }

  // Widget _deviceTile(BluetoothInfo d) {
  //   final name = d.name ?? 'Unknown';
  //   // note: package uses property 'macAdress' (single 'd' in Adress)
  //   final mac = d.macAdress ?? 'unknown_mac';

  //   ref.read(isDeviceConnectedProvider.notifier).state =
  //       connectedMac != null && connectedMac == mac.toString();
  //   final isConnected = ref.watch(isDeviceConnectedProvider);
  //   return ListTile(
  //     title: Text(name.toString()),
  //     subtitle: Text(mac.toString()),
  //     trailing: isConnected
  //         ? TextButton(onPressed: _disconnect, child: const Text('Disconnect'))
  //         : TextButton(
  //             onPressed: () => _connect(mac.toString()),
  //             child: const Text('Connect'),
  //           ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(isBusyProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBarEduTokenSystem(
        title: 'Available Devices',
        size: size,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPaired),
        ],
      ),
      body: Column(
        children: [
          if (isBusy) ...{
            SizedBox(
              height: size.height * 0.01,
            ),
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.kBlueGrayDark,
                size: 50,
              ),
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
          },
          Expanded(
            child: paired.isEmpty
                ? Center(
                    child: Text(
                      isBusy
                          ? 'Loading paired devices...'
                          : 'No paired printers found. Pair correct printer device first.',
                    ),
                  )
                : ListView.builder(
                    itemCount: paired.length,
                    itemBuilder: (ctx, index) {
                      final currentConnectedMac = ref.watch(
                        connectedMacProvider,
                      );

                      // connected device ko top par show karne ke liye sorting
                      final sortedList = List<BluetoothInfo>.from(paired);
                      if (currentConnectedMac != null) {
                        sortedList.sort((a, b) {
                          if (a.macAdress == currentConnectedMac) return -1;
                          if (b.macAdress == currentConnectedMac) return 1;
                          return 0;
                        });
                      }

                      return _deviceTile(sortedList[index], index);
                    },
                  ),
          ),

          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: ElevatedButton.icon(
          //           icon: const Icon(Icons.print),
          //           label: const Text('Print'),
          //           onPressed: (connectedMac != null && !busy)
          //               ? _printText
          //               : null,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

final connectedMacProvider = StateProvider<String?>((ref) => null);
final isDeviceConnectedProvider = StateProvider<bool>((ref) {
  return false;
});
final isBusyProvider = StateProvider<bool>((ref) {
  return false;
});
