import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/login_reg_controller/registration_controller.dart';
import 'package:poketstore/controllers/product_search_controller/district_search_controller.dart';
import 'package:poketstore/controllers/product_search_controller/state_search_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Load states when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StateController>(context, listen: false).fetchStates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);
    final stateController = Provider.of<StateController>(context);
    final districtController = Provider.of<DistrictController>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0703C9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: provider.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Let's Get Started!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Create an account to get all features',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),

                        // Input fields
                        ..._buildInputFields(provider),

                        // State Dropdown
                        _buildLabel("State *"),
                        stateController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDropdown<String>(
                                "Select State",
                                provider.selectedState,
                                stateController.statesList,
                                (value) {
                                  provider.setSelectedState(value);
                                  // Clear district when state changes
                                  provider.setSelectedDistrict(null);
                                  if (value != null) {
                                    Provider.of<DistrictController>(
                                      context,
                                      listen: false,
                                    ).fetchDistricts(value);
                                  } else {
                                    Provider.of<DistrictController>(
                                      context,
                                      listen: false,
                                    ).clear();
                                  }
                                },
                                isRequired: true,
                              ),

                        // District Dropdown
                        _buildLabel("District *"),
                        Consumer<DistrictController>(
                          builder: (context, districtCtrl, _) {
                            if (provider.selectedState == null) {
                              return _buildDropdown<String>(
                                "Select State First",
                                null,
                                [],
                                (value) {},
                                isEnabled: false,
                                isRequired: true,
                              );
                            }

                            return districtCtrl.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _buildDropdown<String>(
                                    "Select District",
                                    provider.selectedDistrict,
                                    districtCtrl.districtList,
                                    (value) {
                                      provider.setSelectedDistrict(value);
                                      if (value != null) {
                                        // Auto-fill place with district name
                                        provider.placeController.text = value;
                                      }
                                    },
                                    isRequired: true,
                                  );
                          },
                        ),

                        // Password fields
                        if (!provider.otpSent) ...[
                          _buildPasswordField(
                            label: "Password",
                            controller: provider.passwordController,
                            hidden: _hidePassword,
                            toggleVisibility:
                                () => setState(
                                  () => _hidePassword = !_hidePassword,
                                ),
                          ),
                          _buildPasswordField(
                            label: "Confirm Password",
                            controller: provider.confirmPasswordController,
                            hidden: _hideConfirmPassword,
                            toggleVisibility:
                                () => setState(
                                  () =>
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword,
                                ),
                            validator: provider.validateConfirmPassword,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Register button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () async {
                                      FocusScope.of(context).unfocus();
                                      final success = await provider
                                          .registerUser(context);
                                      if (success) {
                                        // Navigation handled in provider
                                      }
                                    },
                            child:
                                provider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Login here",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build common input fields
  List<Widget> _buildInputFields(RegistrationProvider provider) {
    final List<Map<String, dynamic>> alwaysVisibleFields = [
      {
        'label': 'Full Name',
        'icon': Icons.person,
        'controller': provider.nameController,
        'isRequired': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Full Name";
          }
          if (value.length < 4) {
            return "Full Name must be at least 4 characters";
          }
          return null;
        },
      },
      {
        'label': 'Email',
        'icon': Icons.email,
        'controller': provider.emailController,
        'keyboardType': TextInputType.emailAddress,
        'isRequired': true,
        'validator': provider.validateEmail,
      },
      {
        'label': 'Mobile Number',
        'icon': Icons.phone_android,
        'controller': provider.mobileController,
        'keyboardType': TextInputType.number,
        'isRequired': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Mobile Number";
          }
          if (value.length < 10) {
            return "Mobile Number must be at least 10 digits";
          }
          return null;
        },
      },
      {
        'label': 'Referred Code (Optional)',
        'icon': Icons.people_outline,
        'controller': provider.referredCodeController,
        'isRequired': false,
        'validator': null,
      },
    ];

    return alwaysVisibleFields.map((field) {
      final FormFieldValidator<String>? customValidator =
          field['validator'] as FormFieldValidator<String>?;
      final bool isRequired = field['isRequired'] as bool? ?? true;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: field['controller'] as TextEditingController,
          keyboardType:
              field['keyboardType'] as TextInputType? ?? TextInputType.text,
          textCapitalization:
              (field['label'] == 'Email' || field['label'] == 'Referred Code (Optional)')
                  ? TextCapitalization.none
                  : TextCapitalization.words,
          decoration: InputDecoration(
            labelText: field['label'] as String,
            prefixIcon: Icon(field['icon'] as IconData),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator:
              customValidator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return "Please enter ${field['label']}";
                }
                return null;
              },
          readOnly: provider.otpSent && field['label'] != 'OTP',
        ),
      );
    }).toList();
  }

  // Helper method to build password fields
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggleVisibility,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) return "Please enter $label";
              if (label == "Password" && value.length < 6) {
                return "Password must be at least 6 characters";
              }
              return null;
            },
      ),
    );
  }

  // Dropdown widget
  Widget _buildDropdown<T>(
    String hint,
    T? selectedValue,
    List<T> items,
    void Function(T?) onChanged, {
    bool isEnabled = true,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          filled: !isEnabled,
          fillColor: Colors.grey.shade100,
        ),
        hint: Text(hint),
        items:
            items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
        onChanged: isEnabled ? onChanged : null,
        validator:
            isRequired
                ? (value) => value == null ? "This field is required" : null
                : null,
      ),
    );
  }

  // Label widget
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}