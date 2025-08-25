import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart' hide Key;
import 'package:edu_token_system_app/Helper/mssql_helper.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/core/model/db_lists_model.dart';
import 'package:edu_token_system_app/core/model/login_info_model.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widgets/custom_db_drop_down.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widgets/settings_icon_dialog_design_widget.dart';
import 'package:edu_token_system_app/feature/new_token/add_new_token_page.dart';
import 'package:encrypt/encrypt.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dbList = await _getDatabsesList();

      await _fetchSerialNumber();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

  Future<List<DbListsModel>> _getDatabsesList() async {
    try {
      setState(() {
        loadingDbList = true;
      });
      final db = MssqlConnection.getInstance();
      final conn = MssqlHelper();
      const maxRetries = 1;
      var retry = 0;

      while (retry < maxRetries) {
        try {
          await conn.connect(
            ip: AppConfig.dbHost,
            port: AppConfig.dbPort,
            username: AppConfig.dbUser,
            password: AppConfig.dbPassword,
            databaseName: AppConfig.initialDatabase,
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
      String? jsonResDbList;
      try {
        jsonResDbList = await conn.query(
          queryStrig:
              "Select DefaultDB, Alias From gen_SingleConnections where ApplicationCodeName='eduRestaurantManagerEnterprise'",
        );
      } catch (e) {
        throw Exception('Failed to fetch databases List: $e');
      }

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
      await conn.close();
      setState(() {
        loadingDbList = false;
      });
      return dbLists;
    } catch (e) {
      if (mounted) {
        if (selectedDatabase == null || selectedDatabase == 'Select Database') {
          await _showErrorDialog(
            'Error Accurred while fetching databases',
            '${e.toString()}',
          );
        }
      }
      return [];
    }
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
          ip: AppConfig.dbHost,
          port: AppConfig.dbPort,
          databaseName: selectedDatabase ?? '',
          username: AppConfig.dbUser,
          password: AppConfig.dbPassword,
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

        final decoded2 = jsonDecode(loginInfo) as List<dynamic>;
        loginInfoList = decoded2
            .map<LoginInfoModel>(
              (json) => LoginInfoModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch login info: $e');
      }

      loginMatched = await isLoginMatch(
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

      // TODO: Add navigation after successful login
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<AddNewTokenPage>(
          builder: (context) => const AddNewTokenPage(),
        ),
      );
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
  Future<bool> isLoginMatch({
  required List<LoginInfoModel> loginInfoList,
  required String inputUsername,
  required String inputPassword,
}) async {
  final u = inputUsername.trim().toLowerCase();
  final p = inputPassword; // case-sensitive

  for (final item in loginInfoList) {
    final decUser = vbDecrypt(item.loginName).trim().toLowerCase();
    final decPass = vbDecrypt(item.password);

    if (decUser == u && decPass == p) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_password', p);

      return true;
    }
  }
  return false;
}

  String vbDecrypt(String input) {
    if (input.isEmpty) return '';
    if (input.contains('€')) {
      input = input.substring(0, input.indexOf('€'));
    }
    final sb = StringBuffer();
    const int power = 3;
    for (int i = 0; i < input.length; i++) {
      final int ascii = input.codeUnitAt(i);
      final int resultAfterPower = ascii ^ power; // XOR with 3
      sb.write(String.fromCharCode(resultAfterPower));
    }
    return sb.toString();
  }

  /// AES-CBC-PKCS7 decrypt helper.
  /// - `base64Cipher` is the encrypted text in Base64 (as commonly produced by Java + CryptLib).
  /// - `keyStr` and `ivStr` should be UTF-8 strings of the correct length:
  ///    * For AES-128 use 16-char key and 16-char iv
  ///    * For AES-256 use 32-char key (encrypt package supports 32 bytes keys).
  ///
  /// Returns plaintext (UTF-8).
  String aesDecryptBase64(String base64Cipher, String keyStr, String ivStr) {
    if (base64Cipher.isEmpty) return '';
    // Validate key/iv length
    final keyBytes = utf8.encode(keyStr);
    final ivBytes = utf8.encode(ivStr);
    if (!(keyBytes.length == 16 ||
        keyBytes.length == 24 ||
        keyBytes.length == 32)) {
      throw ArgumentError(
        'Key must be 16/24/32 bytes long (UTF-8 chars). Current length: ${keyBytes.length}',
      );
    }
    if (ivBytes.length != 16) {
      throw ArgumentError(
        'IV must be 16 bytes long (UTF-8 chars). Current length: ${ivBytes.length}',
      );
    }

    final key = Key(Uint8List.fromList(keyBytes));
    final iv = IV(Uint8List.fromList(ivBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));

    // If base64Cipher includes newlines/spaces, trim them
    final cleanBase64 = base64Cipher
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    // encrypt.Encrypted.fromBase64 expects a valid base64
    final encrypted = Encrypted.fromBase64(cleanBase64);

    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  /// Try decrypt with AES; if it fails (bad base64 or invalid key/iv),
  /// this helper catches and returns null so caller can try alternatives.
  String? tryAesDecryptBase64(
    String base64Cipher,
    String keyStr,
    String ivStr,
  ) {
    try {
      return aesDecryptBase64(base64Cipher, keyStr, ivStr);
    } catch (e) {
      return null;
    }
  }

  // String vbDecrypt(String? input) {
  //   if (input == null) return '';

  //   // Agar '€' mojood ho toh us se pehle ka part lo
  //   final idx = input.indexOf('€');
  //   final part = idx >= 0 ? input.substring(0, idx) : input;

  //   if (part.isEmpty) return '';

  //   final buffer = StringBuffer();
  //   const key = 3; // XOR key

  //   for (var i = 0; i < part.length; i++) {
  //     final code = part.codeUnitAt(i);
  //     final decoded = code ^ key;
  //     buffer.writeCharCode(decoded);
  //   }

  //   return buffer.toString();
  // }

  Future<void> _setDatabse({required String seectedDatabase}) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'selectedDb';
    await prefs.setString(key, seectedDatabase);
  }

  Future<String> _getSelectedDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'selectedDb';
    final selectedDb = prefs.getString(key);
    return selectedDb ?? 'Select Database'; // Default database if none selected
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
                  onPressed:() => _isLoading ? null : _attemptLogin(),
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
