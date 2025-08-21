import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:edu_token_system_app/Export/export.dart';

class BranchInfoPage extends StatefulWidget {
  const BranchInfoPage({super.key});

  @override
  State<BranchInfoPage> createState() => _BranchInfoPageState();
}

class _BranchInfoPageState extends State<BranchInfoPage> {
  // Data for each branch
  Map<String, Map<String, String>> branchData = {
    '1st Branch': {
      'server': r'192.168.99.99:4936\instance',
      'password': 'abcdefghi',
      'port': '4936',
    },
    '2nd Branch': {
      'server': '',
      'password': '',
      'port': '',
    },
    '3rd Branch': {
      'server': '',
      'password': '',
      'port': '',
    },
  };

  // Function to show dialog for editing branch info
  void _showEditDialog(String branchKey, String field) {
    final controller = TextEditingController(
      text: branchData[branchKey]![field] ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field for $branchKey'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $field',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  branchData[branchKey]![field] = controller.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: CustomAppBarEduTokenSystem(
        title: 'Setting',
        titleStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.kWhite,
        ),
        size: size,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! 1st Branch
              _buildBranchCard('1st Branch'),
              const SizedBox(height: 20),

              //! 2nd Branch
              // _buildBranchCard('2nd Branch'),
              // const SizedBox(height: 20),

              //! 3rd Branch
              // _buildBranchCard('3rd Branch'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchCard(String branchKey) {
    return Card(
      elevation: 4,
      color: AppColors.kWhite,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Db Server Info For $branchKey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 20,
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
            const SizedBox(height: 16),

            // Local Server
            _buildInfoRow(
              label: 'Local Server',
              value: branchData[branchKey]!['server']!,
              onTap: () => _showEditDialog(branchKey, 'server'),
            ),
            const SizedBox(height: 12),

            // Port
            _buildInfoRow(
              label: 'Port',
              value: branchData[branchKey]!['port']!,
              onTap: () => _showEditDialog(branchKey, 'port'),
            ),
            const SizedBox(height: 12),

            // Db Password
            _buildInfoRow(
              label: 'Db Password',
              value: branchData[branchKey]!['password']!,
              onTap: () => _showEditDialog(branchKey, 'password'),
              isPassword: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isPassword = false,
    bool isEditable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: isEditable ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: isEditable ? Colors.white : Colors.grey[100],
            ),
            child: Text(
              isPassword && value.isNotEmpty ? '•' * value.length : value,
              style: TextStyle(
                fontSize: 16,
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
