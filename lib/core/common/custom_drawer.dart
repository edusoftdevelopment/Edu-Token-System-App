import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/feature/history/view/history_page.dart';

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              const DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Edu Token System',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Token History
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text(
                  'Token History',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<HistoryTokenSystemPage>(
                      builder: (context) => const HistoryTokenSystemPage(),
                    ),
                  );
                },
              ),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // 👇 logout logic yahan likhna hai
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                },
              ),
            ],
          ).withGradientBlur(
            borderRadius: BorderRadius.zero,
          ),
    );
  }
}
