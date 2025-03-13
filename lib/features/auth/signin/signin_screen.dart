import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';
import '../otp/otp_screen.dart';
import '../utils/formatters/phone_number_formatter.dart';
import '../utils/widgets/country_code_picker_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCountryCode = '+91';
  bool _isLoading = false; // Loading flag

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image at the top
                  Center(
                    child: Image.asset(
                      'assets/images/ic_user_28.png',
                      width: 140,
                      height: 140,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Enter your mobile number to start ordering',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      height: 1,
                      color: HexColor("#000000"),
                      fontSize: 22,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'We will send you a confirmation code',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      height: 1,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: HexColor("#B7B4B9"),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      hintText: 'Enter Mobile Number',
                      focusedBorder: editBorderRadius("#E2E2E2", 10, 1),
                      enabledBorder: editBorderRadius("#E2E2E2", 10, 1),
                      prefixIcon: CountryCodePickerWidget(
                        selectedCountryCode: _selectedCountryCode,
                        onChanged: (countryCode) {
                          setState(() {
                            _selectedCountryCode = countryCode;
                          });
                        },
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [PhoneNumberFormatter()],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6339),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      fixedSize: const Size(double.maxFinite, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _verifyPhone, // Disable button during loading
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Show loading indicator while phone verification is in progress
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Circular progress bar
            ),
        ],
      ),
    );
  }

  Future<void> _verifyPhone() async {
    final phoneNumber = _phoneController.text;

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    final fullPhoneNumber = '$_selectedCountryCode$phoneNumber';
    AppLogger.logInfo('Initiating phone verification for: $fullPhoneNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      );
    } catch (e) {
      AppLogger.logError('Phone verification failed: $e');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  void _verificationCompleted(PhoneAuthCredential credential) async {
    AppLogger.logInfo('Verification completed successfully.');
    await _auth.signInWithCredential(credential);
    _navigateToMainScreen();
    setState(() {
      _isLoading = false; // Stop loading on success
    });
  }

  void _verificationFailed(FirebaseAuthException e) {
    AppLogger.logError('Verification failed: ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification Failed: ${e.message}')),
    );
    setState(() {
      _isLoading = false; // Stop loading on failure
    });
  }

  void _codeSent(String verificationId, int? resendToken) {
    AppLogger.logInfo(
        'Verification code sent. Verification ID: $verificationId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
          phoneNumber: '$_selectedCountryCode${_phoneController.text}',
          // phoneNumber: _phoneController.text,
        ),
      ),
    );
    setState(() {
      _isLoading = false; // Stop loading after navigating to OTP screen
    });
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    AppLogger.logWarning(
        'Auto-retrieval timeout for verification ID: $verificationId');
    setState(() {
      _isLoading = false; // Stop loading on timeout
    });
  }

  void _navigateToMainScreen() async {
    AppLogger.logInfo('Navigating to the main screen.');

    // Prepare user data
    Map<String, dynamic> userData = {
      'phone': '$_selectedCountryCode${_phoneController.text}',
      'isLoggedIn': true,
    };

    // Save user data
    await AppPreference.saveUserData(userData);

    Navigator.of(context).pushReplacementNamed('/home');
  }

  editBorderRadius(String colorCode, double radius, double width) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: HexColor(colorCode), width: width),
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:logger/logger.dart';
//
// import '../../../data/db/app_preferences.dart';
// import '../otp/otp_screen.dart';
// import '../utils/formatters/phone_number_formatter.dart';
// import '../utils/widgets/country_code_picker_widget.dart';
//
// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});
//
//   @override
//   SignInScreenState createState() => SignInScreenState();
// }
//
// class SignInScreenState extends State<SignInScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String _selectedCountryCode = '+91';
//   final Logger _logger = Logger();
//   static const String tag = 'SignInScreen';
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "",
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Image at the top
//                 Center(
//                   child: Image.asset(
//                     'assets/images/ic_user_28.png',
//                     width: 140,
//                     height: 140,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Text(
//                   'Enter your mobile number to start ordering',
//                   textAlign: TextAlign.start,
//                   style: TextStyle(
//                       height: 1,
//                       color: HexColor("#000000"),
//                       fontSize: 22,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'We will send you a confirmation code',
//                   textAlign: TextAlign.left,
//                   style: const TextStyle(
//                       height: 1,
//                       fontSize: 14,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: phoneController,
//                   style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 15,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w500),
//                   decoration: InputDecoration(
//                     labelText: 'Phone Number',
//                     labelStyle: TextStyle(
//                         color: HexColor("#B7B4B9"),
//                         fontSize: 14,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w400),
//                     hintText: 'Enter Mobile Number',
//                     focusedBorder: editBorderRadius("#E2E2E2", 10, 1),
//                     enabledBorder: editBorderRadius("#E2E2E2", 10, 1),
//                     prefixIcon: CountryCodePickerWidget(
//                       selectedCountryCode: _selectedCountryCode,
//                       onChanged: (countryCode) {
//                         setState(() {
//                           _selectedCountryCode = countryCode;
//                           _logger.i(
//                               '$tag: Country code selected: $_selectedCountryCode');
//                         });
//                       },
//                     ),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     PhoneNumberFormatter(),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 // Button at the bottom
//                 ElevatedButton(
//                   /* style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFF6339), // #FF6339
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 12.0,
//                     horizontal: 80.0,
//                   ),
//                 ),*/
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFFF6339),
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       fixedSize: const Size(double.maxFinite, 40),
//                       // specify width, height
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                         30,
//                       ))),
//                   onPressed: () {
//                     _logger.i('$tag: Send OTP button pressed');
//                     verifyPhone();
//                   },
//                   child: const Text(
//                     'Next',
//                     style: TextStyle(
//                         color: Colors.white,
//                         height: 1,
//                         fontSize: 16,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> verifyPhone() async {
//     final phoneNumber = phoneController.text;
//
//     // Check if the phone number is exactly 10 digits
//     if (phoneNumber.isEmpty || phoneNumber.length != 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please enter a valid 10-digit phone number')),
//       );
//       return;
//     }
//
//     final fullPhoneNumber = '$_selectedCountryCode$phoneNumber';
//     _logger.d('$tag: Full phone number for verification: $fullPhoneNumber');
//
//     await _auth.verifyPhoneNumber(
//       phoneNumber: fullPhoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         _logger.d('$tag: Verification completed automatically');
//         await _auth.signInWithCredential(credential);
//         navigateToMainScreen();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         _logger.e('$tag: Verification failed: ${e.message}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Verification Failed: ${e.message}')),
//         );
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         _logger.i('$tag: Code sent: $verificationId');
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => OTPScreen(
//               verificationId: verificationId,
//               phoneNumber: fullPhoneNumber,
//             ),
//           ),
//         );
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         _logger.w('$tag: Code auto-retrieval timeout: $verificationId');
//       },
//     );
//   }
//
//   void navigateToMainScreen() async {
//     _logger.i('$tag: Navigating to main screen');
//     await AppPreference.setLoginStatus(true);
//     await AppPreference.setPhoneNumber(
//         '$_selectedCountryCode${phoneController.text}');
//     Navigator.of(context).pushReplacementNamed('/home');
//   }
//
//   editBorderRadius(String colorCode, double radius, double width) {
//     return OutlineInputBorder(
//         borderSide: BorderSide(color: HexColor(colorCode), width: width),
//         borderRadius: BorderRadius.all(Radius.circular(radius)));
//   }
// }
