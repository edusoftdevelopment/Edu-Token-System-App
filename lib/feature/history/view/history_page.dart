import 'dart:convert';

import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/Helper/mssql_helper.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/bluetooth_devices_page/view/bluetooth_devices_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // String? selectedVehicle;
  DateTime? currentDateTime;
  String? date;
  String? time;
  bool busy = false;
  String? connectedMac;
  MssqlHelper mssqlHelper = MssqlHelper();
  String? currentDatabase;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // currentDatabase = await _getSelectedDatabase();
      await _fetchHistoryDetails();
    });
  }

  Stream<DateTime> _timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  // Future<String> _getSelectedDatabase() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   const key = 'selectedDb';
  //   final selectedDb = prefs.getString(key);
  //   return selectedDb ?? 'Select Database'; // Default database if none selected
  // }

  Future<void> _fetchHistoryDetails() async {
    try {
      await mssqlHelper.connect(
        ip: AppConfig.dbHost,
        port: AppConfig.dbPort,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
        databaseName: currentDatabase ?? '',
      );
    } catch (e) {
      await _showErrorDialog(
        'Error While Connecting Database',
        e.toString(),
        false,
      );
    }

    try {
      final result = await mssqlHelper.query(
        queryStrig: '''
select data_TokenInfo.*,gen_ProductsInfo.ProductName from data_TokenInfo
inner join gen_ProductsInfo on gen_ProductsInfo.ProductID=data_TokenInfo.ProductID
where data_TokenInfo.Posted=0
''',
      );
      final decoded = jsonDecode(result) as List<dynamic>;
      // products = decoded
      //     .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
      //     .toList();
      debugPrint('Query Result: $result');
    } catch (e) {
      await _showErrorDialog('Error While Fetching Data', e.toString(), false);
    } finally {
      await mssqlHelper.close();
    }
  }

  Future<void> _showErrorDialog(
    String title,
    String message,
    bool forBluetooth,
  ) async {
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
          if (forBluetooth)
            TextButton(
              child: const Text(
                'Settings',
                style: TextStyle(color: AppColors.kWhite),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<BluetoothDevicesPage>(
                    builder: (context) {
                      return BluetoothDevicesPage();
                    },
                  ),
                ).then((_) => Navigator.of(context).pop());
              },
            )
          else
            const SizedBox(),
          TextButton(
            child: Text(
              forBluetooth ? 'ok' : 'Cancel',
              style: const TextStyle(color: AppColors.kWhite),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // This will close the dialog
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token History'),
      ),
      body: const Center(
        child: Text('No history available'),
      ),
    );
  }
}
