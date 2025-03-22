import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../common/log/loggers.dart';
import '../../../data/db/app_preferences.dart';
import '../../store/cache/store_cache.dart';
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
  bool _isLoading = false;
  String _loadingMessage = 'Processing...';
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Load last used phone if available
    _loadLastUsedPhone();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadLastUsedPhone() async {
    try {
      final userData = await AppPreference.getUserData();
      if (userData.isNotEmpty && userData['phone'] != null) {
        final phone = userData['phone'] as String;
        // Only populate if it matches your country code format
        if (phone.startsWith(_selectedCountryCode)) {
          setState(() {
            _phoneController.text = phone.substring(_selectedCountryCode.length);
          });
        }
      }
    } catch (e) {
      AppLogger.logWarning('Failed to load last used phone: $e');
    }
  }

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
                    onPressed: _isLoading ? null : _verifyPhone,
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
          // Enhanced loading overlay with message
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6339)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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

    // Start loading with initial message
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Connecting to server...';
    });

    // Check for cached store data first to speed up subsequent flow
    try {
      // Pre-cache store data in the background
      StoreCache.getStoreData().then((cachedData) {
        if (cachedData == null) {
          // If no cached data, we'll just log it
          AppLogger.logInfo('No cached store data available');
        } else {
          AppLogger.logInfo('Found cached store data for faster loading');
        }
      });
    } catch (e) {
      // Just log the error, we'll still continue with authentication
      AppLogger.logError('Error checking cache: $e');
    }

    final fullPhoneNumber = '$_selectedCountryCode$phoneNumber';
    AppLogger.logInfo('Initiating phone verification for: $fullPhoneNumber');

    // Set timeout for Firebase verification
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification request timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    try {
      // Update message
      setState(() {
        _loadingMessage = 'Sending verification code...';
      });

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: _verificationCompleted,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      );
    } catch (e) {
      AppLogger.logError('Phone verification failed: $e');
      setState(() {
        _isLoading = false;
      });

      // Cancel timeout timer
      _timeoutTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verificationCompleted(PhoneAuthCredential credential) async {
    AppLogger.logInfo('Verification completed successfully.');

    // Cancel timeout timer
    _timeoutTimer?.cancel();

    setState(() {
      _loadingMessage = 'Verification successful, signing in...';
    });

    try {
      await _auth.signInWithCredential(credential);
      _navigateToMainScreen();
    } catch (e) {
      AppLogger.logError('Error signing in: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verificationFailed(FirebaseAuthException e) {
    AppLogger.logError('Verification failed: ${e.message}');

    // Cancel timeout timer
    _timeoutTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verification Failed: ${e.message}')),
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _codeSent(String verificationId, int? resendToken) {
    AppLogger.logInfo('Verification code sent. Verification ID: $verificationId');

    // Cancel timeout timer
    _timeoutTimer?.cancel();

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          verificationId: verificationId,
          phoneNumber: '$_selectedCountryCode${_phoneController.text}',
        ),
      ),
    );
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    AppLogger.logWarning('Auto-retrieval timeout for verification ID: $verificationId');

    // This is often called even after successful verification, so check if we're still loading
    if (_isLoading) {
      setState(() {
        _isLoading = false;
      });
    }
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

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  editBorderRadius(String colorCode, double radius, double width) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: HexColor(colorCode), width: width),
      borderRadius: BorderRadius.all(Radius.circular(radius)),
    );
  }
}
