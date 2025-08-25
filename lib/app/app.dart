// ignore_for_file: use_if_null_to_convert_nulls_to_bools

import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/feature/auth/login_page/view/login_page.dart';
import 'package:edu_token_system_app/feature/new_token/add_new_token_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EduTokenSystem extends StatelessWidget {
  const EduTokenSystem({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Token System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data == true) {
              return const AddNewTokenPage();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
  
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('saved_password');
    return savedPassword != null && savedPassword.isNotEmpty;
  }
}
