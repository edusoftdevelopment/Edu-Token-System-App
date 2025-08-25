import 'dart:convert';

import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/Helper/mssql_helper.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_dialog.dart';
import 'package:edu_token_system_app/core/network/network.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/history/model/history_edu_token_system_model.dart';
import 'package:edu_token_system_app/feature/history/widget/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryTokenSystemPage extends StatefulWidget {
  const HistoryTokenSystemPage({super.key});

  @override
  State<HistoryTokenSystemPage> createState() => _HistoryTokenSystemPageState();
}

class _HistoryTokenSystemPageState extends State<HistoryTokenSystemPage> {
  MssqlHelper mssqlHelper = MssqlHelper();
  String? currentDatabase;
  List<EduTokenSystemHistoryModel> historyData = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentDatabase = await _getSelectedDatabase();
      await _fetchHistoryDetails();
    });
  }

  Stream<DateTime> _timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  Future<String> _getSelectedDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'selectedDb';
    final selectedDb = prefs.getString(key);
    return selectedDb ?? 'Select Database'; // Default database if none selected
  }

  Future<void> _fetchHistoryDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      await mssqlHelper.connect(
        ip: AppConfig.dbHost,
        port: AppConfig.dbPort,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
        databaseName: currentDatabase.toString(),
      );

      final result = await mssqlHelper.query(
        queryStrig: '''
        select data_TokenInfo.*, gen_ProductsInfo.ProductName 
        from data_TokenInfo
        inner join gen_ProductsInfo 
        on gen_ProductsInfo.ProductID = data_TokenInfo.ProductID
        where data_TokenInfo.Posted=0
      ''',
      );

      final decoded = jsonDecode(result) as List<dynamic>;
      setState(() {
        historyData = decoded
            .map(
              (item) => EduTokenSystemHistoryModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
        isLoading = false;
      });
    } on Failure catch (e) {
      await DialogHelper.showErrorDialog(
        context: context,
        title: 'Error While Fetching Data',
        message: e.toString(),
      );
      setState(() {
        isLoading = false;
      });
    } finally {
      await mssqlHelper.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CustomAppBarEduTokenSystem(
        title: 'Token History',
        size: size,
        titleStyle:
            Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(
              color: AppColors.kWhite,
              fontSize: 24,
            ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyData.isEmpty
          ? const Center(
              child: Text(
                'No history found!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchHistoryDetails,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final item = historyData[index];
                  return HistoryCard(item: item);
                },
              ),
            ),
    );
  }
}
