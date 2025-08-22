import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/feature/setting/view/setting_page.dart';

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({required this.onPasswordValidated, super.key});
  final void Function(bool) onPasswordValidated;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _validatePassword() {
    final password = _passwordController.text;

    if (password == 'bismillah') {
      // Password is correct
      widget.onPasswordValidated(true);
      Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (context) => const BranchInfoPage(),
        ),
      ).then((_) {
        // Clear the password field after successful navigation
        _passwordController.clear();
        Navigator.of(context).pop();
      });
    } else {
      // Password is incorrect
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            onChanged: (value) {
              // Clear error when user starts typing again
              if (_errorMessage.isNotEmpty) {
                setState(() {
                  _errorMessage = '';
                });
              }
            },
          ),
          const SizedBox(height: 10),
          if (_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onPasswordValidated(false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _validatePassword,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
