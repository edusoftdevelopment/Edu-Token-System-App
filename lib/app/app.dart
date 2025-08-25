import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/feature/auth/login_page/view/login_page.dart';
import 'package:edu_token_system_app/feature/new_token/add_new_token_page.dart';

class EduTokenSystem extends StatelessWidget {
  const EduTokenSystem({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Token System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AddNewTokenPage(),
    );
  }
}
