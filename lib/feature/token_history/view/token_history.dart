import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';



class ThermalPrintFromMedium extends StatefulWidget {
  const ThermalPrintFromMedium({Key? key}) : super(key: key);

  @override
  State<ThermalPrintFromMedium> createState() => _ThermalPrintFromMediumState();
}

class _ThermalPrintFromMediumState extends State<ThermalPrintFromMedium> {
  // Use the real BluetoothInfo type from the package
  List<BluetoothInfo> paired = [];
  bool busy = false;
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

  Future<void> _loadPaired() async {
    setState(() => busy = true);
    try {
      // pairedBluetooth returns List<BluetoothInfo> according to package
      final List<BluetoothInfo>? list =
          await PrintBluetoothThermal.pairedBluetooths;
      setState(() => paired = list ?? []);
    } catch (e) {
      debugPrint('Error loading paired: $e');
      setState(() => paired = []);
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _connect(String mac) async {
    setState(() => busy = true);
    try {
      final res = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      if (res == true ||
          res == 'It is okay' ||
          res == 'true' ||
          res == 'connected') {
        setState(() => connectedMac = mac);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connected')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Connect returned: $res')));
      }
    } catch (e) {
      debugPrint('Connect error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connect error: $e')));
    } finally {
      setState(() => busy = false);
    }
  }

  Future<void> _disconnect() async {
    try {
      // <<-- important: call the function (parentheses)
      await PrintBluetoothThermal.disconnect;
      setState(() => connectedMac = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Disconnected')));
    } catch (e) {
      debugPrint('Disconnect error: $e');
    }
  }

  Future<List<int>> _buildBytes() async {
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];

    // Top stars line
    bytes += generator.text(
      '********************************',
      styles: PosStyles(bold: true, align: PosAlign.center),
    );

    // Big number in center (9800)
    bytes += generator.text(
      '9800',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    // Bottom stars line
    bytes += generator.text(
      '********************************',
      styles: PosStyles(bold: true, align: PosAlign.center),
    );

    // Parking title
    bytes += generator.text(
      'Fun Forest car Parking',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    // Date & Time
    bytes += generator.text(
      'Date: 2025-07-27  Time: 09:29 PM',
      styles: PosStyles(align: PosAlign.left),
    );

    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Date: 2025-07-27',
    //     width: 5,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'Time: 09:29 PM',
    //     width: 7,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);

    // Price & Ticket
    bytes += generator.text(
      'Price: 70 Rs   Ticket: SR-2892',
      styles: PosStyles(align: PosAlign.left),
    );
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Price: 70 Rs',
    //     width: 6,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'Ticket: SR-2892',
    //     width: 6,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);

    bytes += generator.feed(1);

    // Footer text
    bytes += generator.text(
      'Keep this ticket for exit.',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Thanks for visiting!',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();
    return bytes;
  }

  Future<void> _printText() async {
    if (connectedMac == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to a printer first')),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final bytes = await _buildBytes();
      final res = await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('writeBytes result: $res');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Print sent')));
    } catch (e) {
      debugPrint('Print error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Print error: $e')));
    } finally {
      setState(() => busy = false);
    }
  }

  // Use BluetoothInfo's properties directly (name and macAdress)
  Widget _deviceTile(BluetoothInfo d) {
    final name = d.name ?? 'Unknown';
    // note: package uses property 'macAdress' (single 'd' in Adress)
    final mac = d.macAdress ?? d.name ?? 'unknown_mac';
    final isConnected = connectedMac != null && connectedMac == mac.toString();

    return ListTile(
      title: Text(name.toString()),
      subtitle: Text(mac.toString()),
      trailing: isConnected
          ? TextButton(onPressed: _disconnect, child: const Text('Disconnect'))
          : TextButton(
              onPressed: () => _connect(mac.toString()),
              child: const Text('Connect'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Print (Article)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPaired),
        ],
      ),
      body: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _textController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Text to print',
              ),
            ),
          ),
          Expanded(
            child: paired.isEmpty
                ? Center(
                    child: Text(
                      busy
                          ? 'Loading paired devices...'
                          : 'No paired printers found. Pair printer first.',
                    ),
                  )
                : ListView.builder(
                    itemCount: paired.length,
                    itemBuilder: (_, i) => _deviceTile(paired[i]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    onPressed: (connectedMac != null && !busy)
                        ? _printText
                        : null,
                  ),
                ),
              ],
            ),
          ),
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
