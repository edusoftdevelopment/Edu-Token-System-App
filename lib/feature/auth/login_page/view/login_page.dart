import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/core/model/db_lists_model.dart';
import 'package:edu_token_system_app/core/model/login_info_model.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widgets/custom_db_drop_down.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widgets/settings_icon_dialog_design_widget.dart';
import 'package:edu_token_system_app/feature/setting/view/setting_page.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
// Replaced MySQL package with MSSQL package
import 'package:mssql_connection/mssql_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String authenticationPass = 'true';
  String? _serialNo;
  bool _isLoading = false;
  List<DbListsModel> dbList = [];
  DbListsModel? selectedDb;
  bool loadingDbList = false;
  final _mssqlPort = 1433;
  String?
  selectedDatabase; // change if your instance uses a different static port
  List<LoginInfoModel>? loginInfoList;
  bool? loginMatched;

  Future<String?> getSerialNo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Ye Android ID hai, permission nahi chahiye
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return null;
    } catch (e) {
      print('Error getting device ID: $e');
      return null;
    }
  }

  Future<void> _fetchSerialNumber() async {
    final serial = await getSerialNo();
    if (serial != null) {
      setState(() {
        _serialNo = serial;
        AppConfig.mobileSerialNumber = _serialNo!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSerialNumber();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dbList = await _getDatabsesList();

      selectedDatabase = await _getSelectedDatabase();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Centralized error dialog + state cleanup
  Future<void> _showErrorDialog(String title, String message) async {
    setState(() {
      _isLoading = false;
      authenticationPass = 'false';
    });

    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // This will close the dialog
            },
          ),
        ],
      ),
    );
  }

  Future<List<DbListsModel>> _getDatabsesList() async {
    setState(() {
      loadingDbList = true;
    });
    final db = MssqlConnection.getInstance();
    const maxRetries = 1;
    var retry = 0;

    while (retry < maxRetries) {
      try {
        await db.connect(
          ip: '192.168.7.3',
          port: '4914',
          databaseName: 'eduConnectionDB',
          username: 'sa',
          password: '2MSZXGYTUOM4',
        );
        break;
      } catch (e) {
        retry++;
        if (retry >= maxRetries) {
          throw Exception('Failed to connect after $maxRetries attempts: $e');
        }

        await Future.delayed(const Duration(seconds: 1));
      }
    }
    if (db.isConnected == false) {
      throw Exception('Connection failed');
    }
    log('Connection attempt finished');
    // Step 1: Query execute karo
    String? jsonResDbList;
    await db
        .getData(
          "Select DefaultDB, Alias From gen_SingleConnections where ApplicationCodeName='eduRestaurantManagerEnterprise'",
        )
        .then((value) {
          jsonResDbList = value;
        });

    // Step 2: decode karo aur model list banao
    final decoded = jsonDecode(jsonResDbList!) as List<dynamic>;

    // Step 3: har ek map ko model me convert karo
    final dbLists = decoded
        .map<DbListsModel>(
          (json) => DbListsModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    if (jsonResDbList == null) {
      throw Exception('No databases found');
    }
    setState(() {
      loadingDbList = false;
    });
    return dbLists;
  }

  Future<void> _attemptLogin() async {
    final db1 = MssqlConnection.getInstance();
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => authenticationPass = 'false');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      authenticationPass = 'true';
    });

    try {
      try {
        await db1.connect(
          ip: '192.168.7.3',
          port: '4914',
          databaseName: selectedDatabase ?? '',
          username: 'sa',
          password: '2MSZXGYTUOM4',
        );
      } catch (e) {
        throw Exception('Failed to connect: $e');
      }

      if (!db1.isConnected) {
        throw Exception('Connection failed - database is not connected');
      }

      log('2nd Connection established successfully');

      //! get login info
      String? loginInfo;
      try {
        final result = await db1.getData(
          'Select LoginId, LoginInfo.EmployeeCode, LoginName, Password, StopNegativeKOT, Employees.EmployeeName From LoginInfo inner join Employees on LoginInfo.EmployeeCode=Employees.EmployeeCode',
        );
        loginInfo = result;
        log('Login Info: $loginInfo');

        List<dynamic> decoded2 = jsonDecode(loginInfo) as List<dynamic>;
        loginInfoList = decoded2
            .map<LoginInfoModel>(
              (json) => LoginInfoModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch login info: $e');
      }

      loginMatched = isLoginMatch(
        loginInfoList: loginInfoList!,
        inputUsername: _emailController.text,
        inputPassword: _passwordController.text,
      );
      if (!loginMatched!) {
        throw Exception('Invalid email or password');
      }


      // Set runtime values if login successful
      AppConfig.loginId = username;
      AppConfig.employeeName = username;
      AppConfig.currentDatabase = 'EDU2K8';

      // TODO: Add navigation after successful login
    } catch (e) {
      log('Login error: $e'); // Add logging
      if (mounted) {
        await _showErrorDialog(
          'Login Error',
          e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Returns true if any entry in the list matches the provided credentials.
  /// Username comparison is case-insensitive (like your Java code), password is case-sensitive.
  bool isLoginMatch({
    required List<LoginInfoModel> loginInfoList,
    required String inputUsername,
    required String inputPassword,
  }) {
    final u = inputUsername.trim().toLowerCase();
    final p = inputPassword; // case-sensitive

    for (final item in loginInfoList) {
      final decUser = vbDecrypt(item.loginName).trim().toLowerCase();
      final decPass = vbDecrypt(item.password);

      if (decUser == u && decPass == p) {
        return true;
      }
    }
    return false;
  }

  String vbDecrypt(String? input) {
    if (input == null) return '';

    // Agar '€' mojood ho toh us se pehle ka part lo
    int idx = input.indexOf('€');
    String part = idx >= 0 ? input.substring(0, idx) : input;

    if (part.isEmpty) return '';

    final buffer = StringBuffer();
    const int key = 3; // XOR key

    for (int i = 0; i < part.length; i++) {
      int code = part.codeUnitAt(i);
      int decoded = code ^ key;
      buffer.writeCharCode(decoded);
    }

    return buffer.toString();
  }

  bool matchesCredentials({
    required String inputUsername,
    required String inputPassword,
    required String dbLoginName, // value from DB row's LoginName
    required String dbPassword, // value from DB row's Password
  }) {
    final decryptedUsername = vbDecrypt(dbLoginName);
    final decryptedPassword = vbDecrypt(dbPassword);

    final usernameMatches =
        inputUsername.trim().toLowerCase() ==
        decryptedUsername.trim().toLowerCase();
    final passwordMatches = inputPassword == decryptedPassword;

    return usernameMatches && passwordMatches;
  }

  Future<void> _setDatabse({required String seectedDatabase}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'selectedDb';
    await prefs.setString(key, seectedDatabase);
  }

  Future<String> _getSelectedDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'selectedDb';
    final selectedDb = prefs.getString(key);
    return selectedDb ?? ''; // Default database if none selected
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.05,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    var status = 'No password entered yet';
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return PasswordDialog(
                          onPasswordValidated: (isValid) {
                            setState(() {
                              status = isValid
                                  ? 'Password accepted! Access granted.'
                                  : 'Invalid password. Try again.';
                            });
                          },
                        );
                      },
                    );
                  },
                  icon: Icons.settings.toCustomIcon(
                    color: AppColors.kCustomBlueColor,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(height: height * 0.05),
              AutoSizeText(
                'Edu Token System',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF0f2027),
                        Color(0xFF203a43),
                        Color(0xFF2c5364),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              SizedBox(height: height * 0.04),
              AutoSizeText(
                ' Welcome Back 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF0f2027),
                        Color(0xFF203a43),
                        Color(0xFF2c5364),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
              const SizedBox(height: 6),
              AutoSizeText(
                'Login to continue',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),

              SizedBox(height: height * 0.06),
              CustomTextFormTokenSystem(
                sameBorder: authenticationPass == 'false',
                borderColor: (authenticationPass == 'false')
                    ? AppColors.kDarkRed
                    : null,
                darkMode: darkMode,
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: AppColors.kCustomBlueColor,
                ),
                hintText: 'Email',
                controller: _emailController,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: height * 0.02),
              CustomTextFormTokenSystem(
                sameBorder: authenticationPass == 'false',
                borderColor: (authenticationPass == 'false')
                    ? AppColors.kDarkRed
                    : null,
                darkMode: darkMode,
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: AppColors.kCustomBlueColor,
                ),
                isPassword: true,
                hintText: 'Password',
                controller: _passwordController,
                onChanged: (_) => setState(() {}),
              ),
              if (authenticationPass == 'false') ...[
                const SizedBox(height: 10),
                const AutoSizeText(
                  'Incorrect Email & Password ❌',
                  style: TextStyle(fontSize: 14, color: AppColors.kDarkRed),
                ),
              ],
              SizedBox(height: height * 0.02),
              CustomDbDropdown(
                width: width,
                items: dbList,
                hintText: loadingDbList
                    ? 'Loading Databses...'
                    : selectedDatabase ?? 'Select Database',
                selectedItem: selectedDb,
                onSelected: (value) {
                  setState(() {
                    selectedDb = value;

                    _setDatabse(seectedDatabase: value.defaultDB!);
                  });
                },
              ),
              SizedBox(height: height * 0.02),
              // FIXED: now onPressed will call the function (not return it)
              if (_isLoading)
                CustomButton(
                  widget: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColors.kWhite,
                      size: 28,
                    ),
                  ),
                  onPressed: () {},
                )
              else
                CustomButton(
                  name: 'Login In',
                  onPressed: _attemptLogin,
                ),
              const SizedBox(height: 24),
              Center(
                child: AutoSizeText(
                  '🔐 Secure Login | 🚀 Fast Access',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
