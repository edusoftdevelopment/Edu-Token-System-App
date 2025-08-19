import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/feature/auth/login_page/view/login_page.dart';

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

      home: const LoginPage(),
    );
  }
}


class DateTimeTimerWidget extends StatelessWidget {
  const DateTimeTimerWidget({super.key});

  Stream<DateTime> _timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timeStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text("Loading...");
        }

        final now = snapshot.data!;
        final date = "${now.day}-${now.month}-${now.year}";
        final time =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Date: $date",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Time: $time",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      },
    );
  }
}
