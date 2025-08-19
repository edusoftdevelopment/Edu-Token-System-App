import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:edu_token_system_app/feature/new_token/view/new_token_main.dart';

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

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // final width = constraints.maxWidth;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.02),

                  SizedBox(height: height * 0.04),
                  AutoSizeText(
                    'Edu Token System',
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(fontSize: 24),
                  ),
                  SizedBox(height: height * 0.01),

                  SizedBox(height: height * 0.04),
                  CustomTextFormTokenSystem(
                    sameBorder: (authenticationPass == 'false') ? true : false,

                    borderColor: (authenticationPass == 'false')
                        ? AppColors.kDarkRed
                        : null,
                    darkMode: darkMode,
                    textStyle: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(
                          fontSize: 18,
                          color: darkMode
                              ? AppColors.kWhite
                              : AppColors.kCustomBlueColor,
                        ),
                    hintText: 'Email',
                    controller: _emailController,
                    onChanged: (p0) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: height * 0.02),
                  CustomTextFormTokenSystem(
                    sameBorder: (authenticationPass == 'false') ? true : false,

                    borderColor: (authenticationPass == 'false')
                        ? AppColors.kDarkRed
                        : null,
                    darkMode: darkMode,
                    textStyle: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(
                          fontSize: 18,
                          color: darkMode
                              ? AppColors.kWhite
                              : AppColors.kCustomBlueColor,
                        ),
                    isPassword: true,
                    hintText: 'Password',
                    controller: _passwordController,
                    onChanged: (p0) {
                      setState(() {});
                    },
                  ),
                  if (authenticationPass == 'false')
                    SizedBox(height: height * 0.015),
                  if (authenticationPass == 'false')
                    AutoSizeText(
                      'Incorrect Email & Password',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.kDarkRed,
                      ),
                    ),
                  SizedBox(
                    height: (authenticationPass == 'false')
                        ? height * 0.015
                        : height * 0.039,
                  ),
                  //   CustomNewTextButton(
                  //     onTap: () async {
                  //       return NavigationMethod.navigateTo(
                  //         RoutesName.forgotPasswordScreen,
                  //       );
                  //     },
                  //     text: 'Forgot Password?',
                  //   ),
                  SizedBox(height: height * 0.039),
                  CustomButton(
                    backgroundColor: (darkMode)
                        ? AppColors.kCustomButtonsColor
                        : ((_emailController.text) != '')
                        ? AppColors.kCustomButtonsColor
                        : AppColors.kCustomGrayButtonColor,
                    textColor: (darkMode)
                        ? AppColors.kWhite
                        : (_emailController.text != '')
                        ? AppColors.kWhite
                        : AppColors.kCustomBlueColor,
                    name: 'Sign In',
                    onPressed: () {
                      //   if (_passwordController.text != '') {
                      //     if (_emailController.text != '') {
                      //       setState(() {
                      //         if (firstTimeClick == true) {
                      //           authenticationPass = 'false';
                      //           firstTimeClick = false;
                      //         } else {
                      //           authenticationPass = 'true';
                      //         }
                      //       });
                      //       if (authenticationPass == 'true') {

                      //       }
                      //     }
                      //   }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NewTokenMain();
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: height * 0.04),

                  SizedBox(height: height * 0.04),

                  SizedBox(
                    height: (authenticationPass == 'false')
                        ? height * 0.05
                        : height * 0.10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //   AutoSizeText(
                      //     'Don’t have an account?',
                      //     style: Theme.of(context).textTheme.displayMedium
                      //         ?.copyWith(
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w400,

                      //           color: darkMode
                      //               ? AppColors.kWhite
                      //               : AppColors.kCustomLight2TextColor,
                      //         ),
                      //   ),
                      //   SizedBox(width: width * 0.01),
                      //   CustomNewTextButton(
                      //     onTap: () async {
                      //       return NavigationMethod.navigateTo(
                      //         RoutesName.signUpScreen,
                      //       );
                      //     },
                      //     text: 'Sign Up',
                      //     textColor: AppColors.kCustomStatusGreenTextColor,
                      //   ),
                    ],
                  ),
                  // SizedBox(
                  //   height: height * 0.04,
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
