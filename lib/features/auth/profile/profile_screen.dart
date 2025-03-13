import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/log/loggers.dart';
import '../../../common/styles/ElevatedButton.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../../../data/db/app_preferences.dart';
import './profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AppPreference.getUserData();
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _emailController.text = userData['email'] ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFFFF6339),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(_isEditing ? 'Done' : 'Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    enabled: _isEditing,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    enabled: _isEditing,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    enabled: _isEditing,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                if (viewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 80.0),
                    child: CustomElevatedButton(
                      text: 'VERIFY',
                      color: const Color(0xFFFF6339),
                      onPressed: () async {
                        if (!_isEditing) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please click Edit to modify details'),
                            ),
                          );
                          return;
                        }

                        AppLogger.logInfo('Attempting to update profile');

                        Map<String, dynamic> updatedData = {
                          'firstName': _firstNameController.text,
                          'lastName': _lastNameController.text,
                          'email': _emailController.text,
                        };

                        bool success =
                            await viewModel.updateProfile(updatedData);

                        if (success) {
                          AppLogger.logInfo('Profile updated successfully');
                          setState(() {
                            _isEditing = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                            ),
                          );
                        } else {
                          AppLogger.logError(
                              'Profile update failed: ${viewModel.error}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.error ??
                                  'Failed to update profile'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                if (viewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
