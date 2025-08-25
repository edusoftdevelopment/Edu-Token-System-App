import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/Helper/mssql_helper.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/common/custom_drawer.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/bluetooth_devices_page/view/bluetooth_devices_page.dart';
import 'package:edu_token_system_app/feature/history/view/history_page.dart';
import 'package:edu_token_system_app/feature/new_token/model/company_name_model.dart';
import 'package:edu_token_system_app/feature/new_token/model/product_model.dart';
import 'package:edu_token_system_app/feature/new_token/model/single_product_model.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewTokenPage extends ConsumerStatefulWidget {
  const AddNewTokenPage({super.key});

  @override
  ConsumerState<AddNewTokenPage> createState() => _AddNewTokenPageState();
}

class _AddNewTokenPageState extends ConsumerState<AddNewTokenPage> {
  // String? selectedVehicle;
  final List<String> vehicles = ['Car', 'Motorcycle', 'Cycle', 'Truck'];
  late TextEditingController _numberController;
  DateTime? currentDateTime;
  String? date;
  String? time;
  String? connectedMac;
  MssqlHelper mssqlHelper = MssqlHelper();
  String? currentDatabase;
  List<ProductModel> products = [];
  ProductModel? selectedProduct = null;
  int? tokenID;
  SingleProductModel? singleProductModel;
  CompanyNameModel? companyNameModel;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentDatabase = await _getSelectedDatabase();
      await _fetchProductDetails();
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

  Future<void> _fetchProductDetails() async {
    try {
      await mssqlHelper.connect(
        ip: AppConfig.dbHost,
        port: AppConfig.dbPort,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
        databaseName: currentDatabase ?? '',
      );
    } catch (e) {
      _showErrorDialog('Error While Connecting Database', e.toString(), false);
    }

    try {
      final result = await mssqlHelper.query(
        queryStrig: '''
SELECT
  pro.ProductID,
  pro.ProductName,
  pro.UnitPrice
FROM gen_ProductsInfo AS pro
INNER JOIN gen_RestaurantProductCategoryInfo AS cat
  ON pro.CategoryID = cat.ProductCategoryID
WHERE cat.IsTokan = 1
''',
      );
      final decoded = jsonDecode(result) as List<dynamic>;
      products = decoded
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
      debugPrint('Query Result: $result');
    } catch (e) {
      _showErrorDialog('Error While Fetching Data', e.toString(), false);
    } finally {
      await mssqlHelper.close();
    }
  }

  Future<int?> insertTokenInfo({
    required DateTime tokenDate,
    required int productID,
    required String vahicleNo,
    required double rate,
    required int userEmployeeID,
  }) async {
    try {
      ref.read(loadWhilesavingProvider.notifier).state = true;
      await mssqlHelper.connect(
        ip: AppConfig.dbHost,
        port: AppConfig.dbPort,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
        databaseName: currentDatabase ?? '',
      );
    } catch (e) {
      ref.read(loadWhilesavingProvider.notifier).state = false;
      _showErrorDialog('Error While Connecting Database', e.toString(), false);
      return null;
    }

    try {
      // --- DATE ONLY: "yyyy-MM-dd"
      final tokenDateStr = tokenDate.toIso8601String().split('T').first;

      final sql =
          '''
DECLARE @TokenID BIGINT;
EXEC sp_TokenInfoInsert
  @TokenDate = N'$tokenDateStr',
  @ProductID = $productID,
  @Quantity = 1,
  @Rate = $rate,
  @UserEmployeeID = $userEmployeeID,
  @TokenID = @TokenID OUTPUT,
  @VehicleNo = $vahicleNo;
SELECT @TokenID AS TokenID;
''';

      final result = await mssqlHelper.query(
        queryStrig: sql,
      );

      debugPrint('InsertTokenInfo raw result: $result');

      final decoded = jsonDecode(result);

      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded[0] as Map<String, dynamic>;
        final tokenVal = first['TokenID'];

        if (tokenVal == null) return null;

        final tokenId = tokenVal is int
            ? tokenVal
            : int.tryParse(tokenVal.toString());

        tokenID = tokenId;
        return tokenId;
      } else {
        return null;
      }
    } catch (e) {
      ref.read(loadWhilesavingProvider.notifier).state = false;
      _showErrorDialog('Error While Inserting Token', e.toString(), false);
      return null;
    } finally {
      await mssqlHelper.close();
    }
  }

  Future<void> _getDataFromTokenID() async {
    try {
      // Connect to DB
      await mssqlHelper.connect(
        ip: AppConfig.dbHost,
        port: AppConfig.dbPort,
        username: AppConfig.dbUser,
        password: AppConfig.dbPassword,
        databaseName: currentDatabase ?? '',
      );
    } catch (e) {
      ref.read(loadWhilesavingProvider.notifier).state = false;
      _showErrorDialog('Error While Connecting Database', e.toString(), false);
    }

    try {
      // Your query
      final sql =
          '''
SELECT data_TokenInfo.*, gen_ProductsInfo.ProductName
FROM data_TokenInfo
INNER JOIN gen_ProductsInfo 
  ON gen_ProductsInfo.ProductID = data_TokenInfo.ProductID
WHERE data_TokenInfo.TokenID = $tokenID

''';

      final result = await mssqlHelper.query(queryStrig: sql);

      log('result: $result');
      final sql2 = '''
select top 1 CompanyName from CompanyInfo

''';

      final result2 = await mssqlHelper.query(queryStrig: sql2);
      log('result2: $result2');

      final decoded = jsonDecode(result);
      final decoded2 = jsonDecode(result2);
      if (decoded2 is List && decoded2.isNotEmpty) {
        final first = decoded2[0] as Map<String, dynamic>;
        final companyModel = CompanyNameModel.fromJson(first);
        log('Company Model: ${companyModel.toJson()}');
        companyNameModel = companyModel;
      } else {
        log('No Company Name found');
      }
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded[0] as Map<String, dynamic>;
        final tokenModel = SingleProductModel.fromJson(first);
        log('Token Model: ${tokenModel.toJson()}');
        singleProductModel = tokenModel;
        await _printText(
          quantity: singleProductModel!.vehicleNo ?? '',
          tokenDate: singleProductModel?.tokenDate ?? '',
          rate: singleProductModel!.rate.toString(),
          tokenId: singleProductModel!.tokenID.toString(),
        );
        ref.read(loadWhilesavingProvider.notifier).state = false;
      } else {
        ref.read(loadWhilesavingProvider.notifier).state = false;
        _showErrorDialog(
          'No Data',
          'No data found for TokenID: $tokenID',
          false,
        );
        log('No data found for TokenID: $tokenID');
      }
      ref.read(loadWhilesavingProvider.notifier).state = false;
    } catch (e) {
      _showErrorDialog('Error While Fetching Token Info', e.toString(), false);
    } finally {
      await mssqlHelper.close();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
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
            SizedBox(),
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

  Future<List<int>> _buildBytes({
    required String quantity,
    required String tokenDate,
    required String rate,
    required String tokenId,
  }) async {
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
      quantity,
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
      styles: PosStyles(bold: true, align: PosAlign.center),
    );

    // Parking title
    bytes += generator.text(
      companyNameModel?.companyName ?? '',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    // Date & Time
    bytes += generator.text(
      'Date:${tokenDate}  ',
      styles: PosStyles(align: PosAlign.left),
    );

    bytes += generator.text(
      'Price: $rate Rs   Ticket: $tokenId',
      styles: PosStyles(align: PosAlign.left),
    );

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

  Future<void> _printText({
    required String quantity,
    required String tokenDate,
    required String rate,
    required String tokenId,
  }) async {
    final connectedMacAddress = ref.watch(connectedMacProvider);
    if (connectedMacAddress == null) {
      await _showErrorDialog(
        'Message',
        'No printer connected! Please connect first from the settings.',
        true,
      );
      return;
    }

    try {
      final bytes = await _buildBytes(
        quantity: quantity,
        tokenDate: tokenDate,
        rate: rate,
        tokenId: tokenId,
      );
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
      ref.read(loadWhilesavingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(loadWhilesavingProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final dropdownWidth = screenWidth;
        return LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            // final width = constraints.maxWidth;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBarEduTokenSystem(
                // backgroundColor: AppColors.kAppBarColor,
                title: 'New Token',
                titleStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  color: AppColors.kWhite,
                  fontWeight: FontWeight.bold,
                ),

                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return BluetoothDevicesPage();
                          },
                        ),
                      );
                    },
                    child: Icon(Icons.settings),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                ],
                size: size,
              ),
              drawer: CustomAppDrawer(),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  StreamBuilder<DateTime>(
                    stream: _timeStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.kBlueGrayDark,
                            size: 50,
                          ),
                        );
                      }
                      final now = snapshot.data!;
                      currentDateTime = now;
                      date = '${now.day}-${now.month}-${now.year}';
                      time =
                          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

                      return Row(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'Date: $date',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            'Time: $time',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: height * 0.03),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      'Choose Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.01),
                  // PopupMenuButton with same styling as dropdown
                  Container(
                    width: dropdownWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.kBlack12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<ProductModel>(
                      constraints: BoxConstraints(
                        minWidth:
                            dropdownWidth, // 👈 dropdown button jitni width
                        maxWidth: dropdownWidth, // 👈 force same width
                      ),
                      onSelected: (value) {
                        setState(() {
                          selectedProduct = value;
                        });
                      },
                      itemBuilder: (context) => products.map((
                        ProductModel vehicle,
                      ) {
                        return PopupMenuItem<ProductModel>(
                          value: vehicle,
                          padding: EdgeInsets.zero, // 🔹 default padding hatao
                          child: SizedBox(
                            width: dropdownWidth, // 🔹 poore button jitni width
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              child: AutoSizeText(
                                vehicle.productName ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      offset: const Offset(
                        0,
                        50,
                      ), // Menu button ke neeche open hoga
                      elevation: 8,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              selectedProduct?.productName ?? 'Select Vehicle',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedProduct == null
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, size: 26),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      'Price',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Container(
                    width: dropdownWidth,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kGrey.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              '${selectedProduct?.unitPrice ?? '0'} Rs',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      'Enter Vehicle Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  CustomTextFormTokenSystem(
                    hintText: 'Vehicle Number',
                    controller: _numberController,
                    darkMode: darkMode,

                    textCapitalization: TextCapitalization.characters,
                  ),

                  SizedBox(height: height * 0.02),

                  const Spacer(),
                  if (isLoading)
                    CustomButton(
                      onPressed: () {},
                      widget: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppColors.kWhite,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    CustomButton(
                      name: 'Save',
                      onPressed: () async {
                        if (_numberController.text.isEmpty ||
                            selectedProduct == null ||
                            selectedProduct?.unitPrice == null) {
                          _showErrorDialog(
                            'Enter Data First',
                            'Please fill all the fileds!',
                            false,
                          );
                          return;
                        } else {
                          await insertTokenInfo(
                            tokenDate: DateTime.now(),
                            productID: selectedProduct!.productID!,
                            vahicleNo: _numberController.text,
                            rate: selectedProduct!.unitPrice!,
                            userEmployeeID: 45,
                          );
                          await _getDataFromTokenID();
                        }
                      },
                    ),
                  const SizedBox(height: 50),
                ],
              ).paddingHorizontal(20),
            );
          },
        );
      },
    );
  }
}

final loadWhilesavingProvider = StateProvider<bool>((ref) => false);
