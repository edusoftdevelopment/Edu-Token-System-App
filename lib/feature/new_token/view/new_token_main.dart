import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/common/common.dart';
import 'package:edu_token_system_app/core/common/custom_button.dart';
import 'package:edu_token_system_app/core/extension/extension.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NewTokenMain extends StatefulWidget {
  const NewTokenMain({super.key});

  @override
  State<NewTokenMain> createState() => _NewTokenMainState();
}

class _NewTokenMainState extends State<NewTokenMain> {
  String? selectedVehicle;
  final List<String> vehicles = ['Car', 'Motorcycle', 'Cycle', 'Truck'];
  late TextEditingController _numberController;
  DateTime? _currentDateTime;
  // Control width from yahan

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController();
  }

  Stream<DateTime> _timeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        double dropdownWidth = screenWidth;
        return LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            // final width = constraints.maxWidth;
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBarEduTokenSystem(
                backgroundColor: AppColors.kAppBarColor,
                title: 'New Token',
                titleStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  color: AppColors.kWhite,
                  fontWeight: FontWeight.bold,
                ),
                size: size,
              ),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  StreamBuilder<DateTime>(
                    stream: _timeStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Color(0xFF2c5364),
                            size: 50,
                          ),
                        );
                      }
                      final now = snapshot.data!;
                      _currentDateTime = now;
                      final date = "${now.day}-${now.month}-${now.year}";
                      final time =
                          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

                      return Row(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            "Date: $date",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            "Time: $time",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: height * 0.03),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      'Choose Vehicle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: height * 0.01),
                  // PopupMenuButton with same styling as dropdown
                  Container(
                    width: dropdownWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      constraints: BoxConstraints(
                        minWidth:
                            dropdownWidth, // 👈 dropdown button jitni width
                        maxWidth: dropdownWidth, // 👈 force same width
                      ),
                      onSelected: (value) {
                        setState(() {
                          selectedVehicle = value;
                        });
                      },
                      itemBuilder: (context) => vehicles.map((String vehicle) {
                        return PopupMenuItem<String>(
                          value: vehicle,
                          padding: EdgeInsets.zero, // 🔹 default padding hatao
                          child: SizedBox(
                            width: dropdownWidth, // 🔹 poore button jitni width
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              child: AutoSizeText(
                                vehicle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      offset: const Offset(
                        0,
                        50,
                      ), // Menu button ke neeche open hoga
                      elevation: 8,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
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
                  SizedBox(height: height * 0.01),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      'Enter Vehicle Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  CustomTextFormTokenSystem(
                    hintText: 'Vehicle Number',
                    controller: _numberController,
                    darkMode: darkMode,
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: height * 0.02),

                  Spacer(),
                  CustomButton(
                    name: 'Save',
                    onPressed: () {
                      if (_currentDateTime != null) {
                        String formattedDateTime =
                            '${_currentDateTime!.day}/${_currentDateTime!.month}/${_currentDateTime!.year} '
                            'at ${_currentDateTime!.hour}:${_currentDateTime!.minute.toString().padLeft(2, '0')}:${_currentDateTime!.second.toString().padLeft(2, '0')}';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: AutoSizeText(
                              'Current Date & Time: $formattedDateTime',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ).paddingHorizontal(20),
            );
          },
        );
      },
    );
  }
}
