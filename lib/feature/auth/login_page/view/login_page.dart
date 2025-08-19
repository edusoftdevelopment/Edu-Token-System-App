import 'dart:developer';

import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/new_token/view/new_token_main.dart';
import 'package:edu_token_system_app/service/permission_service.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String authenticationPass = 'true';
  bool firstTimeClick = true;

  Future<String?> getSerialNo() async {
    try {
      final isAllowed = await PermissionService.checkPhonePermission();

      if (isAllowed) {
        const platform = MethodChannel(
          'com.example.salman_food_app/device_info',
        );
        try {
          final serial =
              await platform.invokeMethod('getSerialNumber') as String;

          return serial;
        } on PlatformException catch (e) {
          return "Failed to get serial number: '${e.message}'";
        }
      }
      return null;
    } on PlatformException catch (e) {
      log("Failed to get device serial number: '${e.message}'.");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.05),

                Container(),

                ///! App Title
                AutoSizeText(
                  "Edu Token System",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF0f2027), // Dark Navy
                          Color(0xFF203a43), // Deep Blue
                          Color(0xFF2c5364), // Blue-Gray
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),

                SizedBox(height: height * 0.04),

                ///! Welcome AutoSizeText
                AutoSizeText(
                  " Welcome Back 👋",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [
                          Color(0xFF0f2027), // Dark Navy
                          Color(0xFF203a43), // Deep Blue
                          Color(0xFF2c5364), // Blue-Gray
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),

                const SizedBox(height: 6),
                AutoSizeText(
                  "Login to continue",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),

                SizedBox(height: height * 0.06),

                ///! Email Field
                CustomTextFormTokenSystem(
                  sameBorder: (authenticationPass == 'false'),
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

                ///! Password Field
                CustomTextFormTokenSystem(
                  sameBorder: (authenticationPass == 'false'),
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
                  AutoSizeText(
                    'Incorrect Email & Password ❌',
                    style: TextStyle(fontSize: 14, color: AppColors.kDarkRed),
                  ),
                ],

                SizedBox(height: height * 0.05),

                ///! Login Button
                CustomButton(
                  // backgroundColor:
                  //     (_emailController.text.isNotEmpty &&
                  //         _passwordController.text.isNotEmpty)
                  //     ? AppColors.kCustomButtonsColor
                  // //     : AppColors.kCustomGrayButtonColor,
                  // textColor:
                  //     (_emailController.text.isNotEmpty &&
                  //         _passwordController.text.isNotEmpty)
                  //     ? Colors.white
                  //     : AppColors.kCustomBlueColor,
                  name: "Login In",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewTokenMain()),
                    );
                  },
                ),

                const Spacer(),

                ///! Bottom Section with Emojis
                Center(
                  child: AutoSizeText(
                    "🔐 Secure Login | 🚀 Fast Access",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),

                SizedBox(height: height * 0.03),
              ],
            ).paddingHorizontal(width * 0.05).paddingVertical(height * 0.05);
          },
        ),
      ),
    );
  }
}
