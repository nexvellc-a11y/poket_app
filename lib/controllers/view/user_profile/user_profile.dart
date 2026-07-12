import 'package:flutter/material.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // TextEditingControllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // Add controllers for other editable fields if needed, e.g.:
  // late TextEditingController _mobileNumberController;
  // late TextEditingController _stateController;

  bool _isEditing = false; // To toggle between view and edit mode

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userProfileController = Provider.of<UserProfileController>(
        context,
        listen: false,
      );

      userProfileController.addListener(() {
        if (!mounted) return;
        final userProfile = userProfileController.userProfile;
        if (userProfile != null) {
          _nameController.text = userProfile.name;
          _emailController.text = userProfile.email;
        }
      });

      // userProfileController.loadUserProfileFromPrefs();
    });
  }

  // Method to update TextEditingControllers when the profile data changes in the controller
  void _updateControllersFromProfile() {
    if (!mounted) return; // ⬅️ prevents calling Provider on disposed widget
    final userProfile =
        Provider.of<UserProfileController>(context, listen: false).userProfile;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
      _emailController.text = userProfile.email;
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    // _mobileNumberController.dispose();
    // _stateController.dispose();

    // Remove the listener to prevent errors when the widget is disposed
    Provider.of<UserProfileController>(
      context,
      listen: false,
    ).removeListener(_updateControllersFromProfile);
    super.dispose();
  }

  // Function to handle saving profile changes
  Future<void> _saveProfileChanges() async {
    final userProfileController = Provider.of<UserProfileController>(
      context,
      listen: false,
    );

    if (userProfileController.userProfile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user data to update.')));
      return;
    }

    final String newName = _nameController.text;
    final String newEmail = _emailController.text;

    // You can add validation here before calling the service
    // if (newName.isEmpty || newEmail.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Name and Email cannot be empty.')),
    //   );
    //   return;
    // }

    // Call the update method from the controller
    bool success = await userProfileController.updateUserProfile(
      newName: newName,
      newEmail: newEmail,
      // Pass other fields if you add them to the controller's update method
      // newMobileNumber: int.tryParse(_mobileNumberController.text),
      // newState: _stateController.text,
    );

    if (success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() {
        _isEditing = false; // Exit edit mode on success
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProfileController.error ?? 'Failed to update profile.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for a clean look
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 7, 3, 201), // Consistent primary color
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "User Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Slightly larger title
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(
              color: Colors.white,
            ), // Ensure icons are white
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    _saveProfileChanges(); // Save changes if in edit mode
                  } else {
                    // Enter edit mode
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          final profile = controller.userProfile;

          if (profile == null) {
            return const Center(
              child: Text(
                "No profile data found. Please ensure you are logged in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // If profile is available, ensure controllers are updated for initial display
          // This ensures that when the data loads, the text fields reflect it.
          // We call this here to ensure it's called even if the userProfile was already loaded
          // before the listener was added (e.g., if the screen is rebuilt).
          _updateControllersFromProfile();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(
              20.0,
            ), // Consistent padding around the card
            child: Card(
              elevation: 8, // Increased elevation for more depth
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // More rounded card
              ),
              color: Colors.white,
              // ignore: deprecated_member_use
              shadowColor: Colors.black.withOpacity(0.15), // Softer shadow
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25, // Increased horizontal padding
                  vertical: 40, // Increased vertical padding
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Make column take minimum space
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 55, // Slightly larger avatar
                        backgroundColor: const Color.fromARGB(
                          255,
                          7,
                          3,
                          201,
                          // ignore: deprecated_member_use
                        ).withOpacity(0.9), // Slightly more opaque
                        child: const Icon(
                          Icons.person,
                          size: 65, // Larger icon
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ), // Increased spacing after avatar
                    // Editable fields
                    _buildEditableProfileInfo(
                      "Name",
                      _nameController,
                      Icons.person,
                    ),
                    // _buildEditableProfileInfo(
                    //   "Email",
                    //   _emailController,
                    //   Icons.email,
                    // ),
                    // Non-editable (for now) or other editable fields
                    _buildProfileInfoRow(
                      "Mobile Number",
                      profile.mobileNumber.toString(),
                      Icons.phone,
                    ),
                    // Add more editable fields as needed with _buildEditableProfileInfo
                    // Add more non-editable fields as needed with _buildProfileInfoRow
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build each profile information row for VIEW mode
  Widget _buildProfileInfoRow(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:
                    15, // Slightly smaller title font for better hierarchy
                color: Colors.grey[600], // Softer title color
              ),
            ),
          ],
        ),
        const SizedBox(height: 4), // Small space between title and value
        Padding(
          padding: const EdgeInsets.only(left: 26.0), // Align value
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 17, // Larger value font for readability
              color: Colors.black87, // Stronger value color
            ),
          ),
        ),
        const Divider(
          height: 25,
          thickness: 1,
          color: Colors.black12,
        ), // Subtle divider
      ],
    );
  }

  // Helper widget to build each profile information row for EDITABLE mode
  Widget _buildEditableProfileInfo(
    String labelText,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: _isEditing, // Enable/disable editing
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            labelStyle: TextStyle(color: Colors.grey[600]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 7, 3, 201),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
            filled: true,
          ),
          style: const TextStyle(fontSize: 17, color: Colors.black87),
        ),
        const SizedBox(height: 20), // Spacing between editable fields
      ],
    );
  }
}
