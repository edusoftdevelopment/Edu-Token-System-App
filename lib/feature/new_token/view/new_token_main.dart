import 'package:edu_token_system_app/feature/auth/login_page/widget/custom_button.dart';
import 'package:edu_token_system_app/feature/auth/login_page/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class NewTokenMain extends StatefulWidget {
  const NewTokenMain({super.key});

  @override
  State<NewTokenMain> createState() => _NewTokenMainState();
}

class _NewTokenMainState extends State<NewTokenMain> {
  String? selectedVehicle;
  final List<String> vehicles = ['Car', 'Motorcycle', 'Cycle', 'Truck'];
  late TextEditingController _numberController;

  // Control width from yahan
  double dropdownWidth = 350;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    // agar responsive width chahte ho to uncomment:
    // dropdownWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Choose vehicle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // PopupMenuButton with same styling as dropdown
            Container(
              width: dropdownWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    selectedVehicle = value;
                  });
                },
                itemBuilder: (context) => vehicles.map((String vehicle) {
                  return PopupMenuItem<String>(
                    value: vehicle,
                    child: Container(
                      width: dropdownWidth - 40, // Adjust for padding
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        vehicle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                offset: const Offset(0, 50), // Menu button ke neeche open hoga
                elevation: 8,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedVehicle ?? 'Select Vehicle',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedVehicle == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 26),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextFormTokenSystem(
              hintText: 'Enter Number',
              controller: _numberController,
              darkMode: darkMode,
            ),
            const SizedBox(height: 16),
            Text(
              selectedVehicle == null
                  ? 'No vehicle selected'
                  : 'Selected: $selectedVehicle',
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),
            CustomButton(
              name: 'Save',
              onPressed: () {
                // Current date and time
                DateTime now = DateTime.now();
                String formattedDateTime =
                    '${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

                // Show current date and time
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Current Date & Time: $formattedDateTime'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
