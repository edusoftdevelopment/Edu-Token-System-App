import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

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
      // pairedBluetooths returns List<BluetoothInfo> according to package
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

  Future<List<int>> _buildBytes(String text) async {
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = [];
    bytes += generator.text(
      'My Shop',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();

    final lines = text.split('\n');
    for (final l in lines) {
      bytes += generator.text(l);
    }

    bytes += generator.feed(2);
    bytes += generator.text(
      'Powered by Flutter',
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
      final bytes = await _buildBytes(_textController.text);
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
