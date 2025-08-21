import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:edu_token_system_app/Config/app_config.dart';
import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/new_token/add_new_token_page.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;

import 'package:flutter/foundation.dart';
// Replaced MySQL package with MSSQL package
import 'package:mssql_connection/mssql_connection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Simple MSSQL wrapper to approximate mysql1's connect/query/close usage in this file.
/// NOTE: This wrapper assumes the `mssql_connection` package exposes
/// `MssqlConnection.getInstance()`, `connect(...)`, `readData(query, params?)`, and `close()` methods.
/// If your MSSQL package exposes different method names, adjust the wrapper accordingly.
class MssqlHelper {
  final _db = MssqlConnection.getInstance();

  Future<void> connect({
    required String ip,
    required String port,
    required String username,
    required String password,
    required String databaseName,
  }) async {
    await _db.connect(
      ip: ip,
      port: port,
      username: username,
      password: password,
      databaseName: databaseName,
    );
  }

  Future<void> close() async {
    await _db.disconnect();
  }

  /// Executes a query where the SQL uses `?` placeholders (same style as mysql1).
  /// This function replaces each `?` with `@p0,@p1,...` and passes a parameter map to the underlying driver.
  Future<List<List<dynamic>>> query(String sql, [List<dynamic>? params]) async {
    params ??= [];

    // Replace '?' with '@p0', '@p1', ... and build param map
    var newSql = sql;
    final paramMap = <String, dynamic>{};
    for (var i = 0; i < params.length; i++) {
      newSql = newSql.replaceFirst('?', '@p$i');
      paramMap['p$i'] = params[i];
    }

    // The assumed API: readData(sql, paramsMap) -> returns List<Map<String,dynamic>>
    final raw = await _db.getData(
      newSql,
    );

    // Convert result (List<Map<..>>) to List<List<dynamic>> to mimic mysql1.Results row access by index
    final rows = <List<dynamic>>[];
    if (raw is List) {
      for (final r in raw as List) {
        if (r is Map<String, dynamic>) {
          rows.add(r.values.toList());
        } else if (r is List) {
          rows.add(List<dynamic>.from(r));
        } else {
          rows.add([r]);
        }
      }
    }
    return rows;
  }
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

  // VBDecrypt ported from Java: XOR each char with 3, strip after '€'
  String vbDecrypt(String? input) {
    if (input == null || input.isEmpty) return '';
    final idx = input.indexOf('€');
    if (idx >= 0) {
      input = input.substring(0, idx);
    }
    final sb = StringBuffer();
    const power = 3;
    for (var i = 0; i < input.length; i++) {
      final ascii = input.codeUnitAt(i);
      final result = ascii ^ power;
      sb.writeCharCode(result);
    }
    return sb.toString();
  }

  // AES decrypt (attempt) - handles conversion to Uint8List to avoid type errors
  String? tryAesDecrypt(String base64Cipher, String key, String iv) {
    try {
      if (base64Cipher.isEmpty) return '';

      final cipherBytes = Uint8List.fromList(base64.decode(base64Cipher));

      // prepare key bytes (ensure length 16/24/32)
      final List<int> rawKeyBytes = utf8.encode(key);
      final keyBytesList =
          (rawKeyBytes.length == 16 ||
              rawKeyBytes.length == 24 ||
              rawKeyBytes.length == 32)
          ? rawKeyBytes
          : (rawKeyBytes + List<int>.filled(32 - rawKeyBytes.length, 0))
                .sublist(0, 32);
      final keyBytes = Uint8List.fromList(keyBytesList);

      // prepare iv bytes (ensure length 16)
      final List<int> rawIvBytes = utf8.encode(iv);
      final ivBytesList = rawIvBytes.length >= 16
          ? rawIvBytes.sublist(0, 16)
          : (rawIvBytes + List<int>.filled(16 - rawIvBytes.length, 0));
      final ivBytes = Uint8List.fromList(ivBytesList);

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(
          encrypt_pkg.Key(keyBytes),
          mode: encrypt_pkg.AESMode.cbc,
        ),
      );
      final ivObj = encrypt_pkg.IV(ivBytes);

      final decryptedBytes = encrypter.decryptBytes(
        encrypt_pkg.Encrypted(cipherBytes),
        iv: ivObj,
      );
      return utf8.decode(decryptedBytes);
    } catch (e) {
      if (kDebugMode) print('AES decrypt failed: $e');
      return null;
    }
  }

  // Centralized error dialog + state cleanup
  Future<void> _showErrorDialog(String title, String message) async {
    // ensure any loading dialogs are closed
    try {
      Navigator.of(context).pop(); // attempt to close loading dialog if present
    } catch (_) {}
    setState(() {
      _isLoading = false;
      authenticationPass = 'false';
    });

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Resolve named SQL Server instance to TCP port using SQL Browser (UDP 1434).
  /// Returns port as int on success, or null on failure/timeout.
  Future<int?> resolveSqlInstancePort({
    required String host, // e.g. '192.168.7.3'
    required String instanceName, // e.g. 'EDU2K8'
    Duration timeout = const Duration(seconds: 3),
  }) async {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.readEventsEnabled = true;

      // Request payload (0x02 = enumerate instances)
      final request = Uint8List.fromList([0x02]);

      // Send request to SQL Browser Service (UDP 1434)
      final remote = InternetAddress(host);
      socket.send(request, remote, 1434);

      final completer = Completer<int?>();
      Timer? watch;

      // Timeout safety
      watch = Timer(timeout, () {
        if (!completer.isCompleted) completer.complete(null);
        socket?.close();
      });

      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram == null) return;

          final resp = utf8.decode(datagram.data, allowMalformed: true);
          // print('SQL Browser Response: $resp');

          // Normalize lowercase
          final lower = resp.toLowerCase();
          final needle = instanceName.toLowerCase();

          if (lower.contains(needle)) {
            // Find "tcp" + port
            final broadMatch = RegExp(
              '$needle.*?tcp[^0-9]*([0-9]{2,5})',
              caseSensitive: false,
              dotAll: true,
            ).firstMatch(lower);

            if (broadMatch != null) {
              final port = int.tryParse(broadMatch.group(1)!);
              if (port != null && !completer.isCompleted) {
                completer.complete(port);
                watch?.cancel();
                socket?.close();
              }
            }
          }
        }
      });

      return await completer.future;
    } catch (e) {
      // Agar error aa jaye to null return karein
      return null;
    } finally {
      socket?.close();
    }
  }

  Future<void> _attemptLogin() async {
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Step 1: Connect to LoginMainDB (eduConnectionDB) with retry logic
      MssqlHelper? conn;
      int retry = 0;
      String? connectionError;

      while (retry < 3) {
        try {
          conn = MssqlHelper();

          final port = await resolveSqlInstancePort(
            host: '192.168.7.3',
            instanceName: 'EDU2K8',
          );
          if (port == null) {
          } else {
            // use port.toString() when calling your MSSQL connect
            // try to resolve port first
            final instance = 'EDU2K8';
            int? port = await resolveSqlInstancePort(
              host: '192.168.7.3',
              instanceName: instance,
            );

            // proceed with authenticated session...

            await conn.connect(
              
              ip: '192.168.7.3',
              // port: port.toString(),
              port: '1433',
              username: 'sa',
              password: '2MSZXGYTUOM4',
              databaseName: 'EDU2K8',
            );
          }

          // connectionError = null;
          // break;
        } catch (e) {
          retry++;
          connectionError = e.toString();

          if (retry >= 3) {
            await _showErrorDialog(
              'Connection Error',
              'Unable to connect to database server after 3 attempts: $connectionError',
            );

            return;
          }
          // Wait before retry
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (conn!._db.isConnected) return;
    } catch (e) {
      await _showErrorDialog(
        'Connection Error',
        'Failed to connect to database: ${e.toString()}',
      );
      return;
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
              CustomButton(
                name: _isLoading ? 'Logging in...' : 'Login In',
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
