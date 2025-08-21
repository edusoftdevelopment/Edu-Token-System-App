import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/Helper/mssql_helper.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/model/db_lists_model.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widgets/resolve_sql_instance_port.dart';
import 'package:edu_token_system_app/feature/new_token/add_new_token_page.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;

import 'package:flutter/foundation.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// Replaced MySQL package with MSSQL package
import 'package:mssql_connection/mssql_connection.dart';

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

  final _mssqlPort =
      1433; // change if your instance uses a different static port

  Future<String?> getSerialNo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // ANDROID_ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error getting device ID: $e');
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

  Future<void> _attemptLogin() async {
    final _db = MssqlConnection.getInstance();
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
      int retry = 0;
      const maxRetries = 1;

      while (retry < maxRetries) {
        try {
          await _db.connect(
            ip: '192.168.7.3',
            port: '4914',
            databaseName: 'eduConnectionDB',
            username: 'sa',
            password: '2MSZXGYTUOM4',
            timeoutInSeconds: 15,
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
      if (_db.isConnected == false) {
        throw Exception('Connection failed');
      }
      log('Connection attempt finished');
      // Step 1: Query execute karo
      String? jsonResDbList;
      await _db
          .getData(
            "Select DefaultDB, Alias From gen_SingleConnections where ApplicationCodeName='eduRestaurantManagerEnterprise'",
          )
          .then((value) {
            jsonResDbList = value;
          });

      // Step 2: decode karo aur model list banao
      final List<dynamic> decoded = jsonDecode(jsonResDbList!) as List<dynamic>;

      // Step 3: har ek map ko model me convert karo
      List<DbListsModel> dbLists = decoded
          .map<DbListsModel>(
            (json) => DbListsModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      // Step 4: ab use kar sakte ho
      for (var db in dbLists) {
        print("DefaultDB: ${db.defaultDB}, Alias: ${db.alias}");
      }

      log(
        'JSON   ${jsonResDbList}',
      );
      if (jsonResDbList == null) {
        throw Exception('No databases found');
      }

      // Step 3: Check if initialDatabase exists
      // final initialDbExists = resDbList.any(
      //   (db) => db['name'].toString().toLowerCase() == 'edu2k8',
      // );

      // if (!initialDbExists) {
      //   throw Exception('Initial database EDU2K8 not found');
      // }

      // Step 4: Attempt login
      final encryptedPassword = encrypt_pkg.Encrypted.fromBase64(
        AppConfig.aesKey,
      );
      // final decryptedPassword = tryAesDecrypt(
      //   encryptedPassword.base64,
      //   AppConfig.aesKey,
      //   AppConfig.aesIv,
      // );

      // if (decryptedPassword == null ||
      //     decryptedPassword != vbDecrypt(password)) {
      //   throw Exception('Invalid credentials');
      // }

      // Step 5: Set runtime values
      AppConfig.loginId = username;
      AppConfig.employeeName = username; // Assuming username is employee name
      AppConfig.currentDatabase = 'EDU2K8';

      // Navigate to AddNewTokenPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddNewTokenPage()),
      );
    } catch (e) {
      if (mounted) {
        // Add this check
        await _showErrorDialog(
          'Connection Error',
          'Failed to connect to database: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        // Add this check
        setState(() => _isLoading = false);
      }
    }
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
              SizedBox(height: height * 0.05),
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
