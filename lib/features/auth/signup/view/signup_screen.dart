import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/log/loggers.dart';
import '../../../../common/styles/ElevatedButton.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../viewmodel/sign_up_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;

  const SignUpScreen({super.key, required this.phoneNumber});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        logoPath: 'assets/images/cw_image.png',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<SignUpViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Phone number
                    TextFormField(
                      controller: phoneController,
                      enabled: false,
                      style: const TextStyle(
                        color: Color(0xFFFF6339),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // First Name
                    TextFormField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'John',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Last Name
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Doe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@mail.com',
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
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 80.0),
                        child: CustomElevatedButton(
                          text: 'Submit',
                          color: const Color(0xFFFF6339),
                          onPressed: () async {
                            AppLogger.logInfo('Attempting to complete sign-up');

                            Map<String, dynamic> userData = {
                              'firstName': firstNameController.text,
                              'lastName': lastNameController.text,
                              'email': emailController.text,
                              'mobileNo': widget.phoneNumber,
                            };
                            AppLogger.logInfo('User data: $userData');

                            bool success =
                                await viewModel.completeSignUp(userData);
                            if (success) {
                              AppLogger.logInfo(
                                  'Sign-up successful, navigating to home');
                              Navigator.of(context)
                                  .pushReplacementNamed('/main');
                            } else if (viewModel.error != null &&
                                viewModel.error!.contains('already exists')) {
                              AppLogger.logInfo(
                                  'User already exists, navigating to home');
                              Navigator.of(context)
                                  .pushReplacementNamed('/main');
                            } else {
                              AppLogger.logError(
                                  'Sign-up failed: ${viewModel.error}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      viewModel.error ?? 'An error occurred'),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../common/log/loggers.dart';
// import '../viewmodel/sign_up_viewmodel.dart';
//
// class SignUpScreen extends StatefulWidget {
//   final String phoneNumber;
//
//   const SignUpScreen({super.key, required this.phoneNumber});
//
//   @override
//   SignUpScreenState createState() => SignUpScreenState();
// }
//
// class SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Complete Sign Up')),
//       body: Consumer<SignUpViewModel>(
//         builder: (context, viewModel, child) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // First Name Field
//                 TextField(
//                   controller: firstNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'First Name',
//                     hintText: 'John',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Last Name Field
//                 TextField(
//                   controller: lastNameController,
//                   decoration: const InputDecoration(
//                     labelText: 'Last Name',
//                     hintText: 'Doe',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Email Field
//                 TextField(
//                   controller: emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'example@mail.com',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Phone Number Display
//                 Text(
//                   'Phone Number: ${widget.phoneNumber}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Loading Indicator or Complete Sign Up Button
//                 if (viewModel.isLoading)
//                   const CircularProgressIndicator()
//                 else
//                   ElevatedButton(
//                     onPressed: () async {
//                       // Log the attempt to complete sign-up
//                       AppLogger.logInfo('Attempting to complete sign-up');
//
//                       Map<String, dynamic> userData = {
//                         'firstName': firstNameController.text,
//                         'lastName': lastNameController.text,
//                         'email': emailController.text,
//                         'mobileNo': widget.phoneNumber,
//                       };
//                       // Log user data
//                       AppLogger.logInfo('User data: $userData');
//
//                       bool success = await viewModel.completeSignUp(userData);
//                       if (success) {
//                         // Log success
//                         AppLogger.logInfo(
//                             'Sign-up successful, navigating to home');
//                         Navigator.of(context).pushReplacementNamed('/home');
//                       } else {
//                         // Log error
//                         AppLogger.logError(
//                             'Sign-up failed: ${viewModel.error}');
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content:
//                                 Text(viewModel.error ?? 'An error occurred'),
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text('Complete Sign Up'),
//                   ),
//
//                 // Error Message Display
//                 if (viewModel.error != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 20),
//                     child: Text(
//                       viewModel.error!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
