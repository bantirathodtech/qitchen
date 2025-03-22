// OTPScreen.dart - with optimized verification flow
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:logger/logger.dart';

import '../../../common/log/loggers.dart';
import '../../../core/api/api_base_service.dart';
import '../../../data/db/app_preferences.dart';
import '../../main/main_screen.dart';
import '../signin/signin_screen.dart';
import '../signup/view/signup_screen.dart';
import '../utils/widgets/otp_pin_input.dart';
import '../verify/repository/verify_repository.dart';
import '../verify/service/verify_service.dart';
import '../verify/viewmodel/verify_viewmodel.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => OTPScreenState();
}

class OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  static const String tag = 'OTPScreen';
  String enteredOtp = '';
  late VerifyService _verifyService;
  late VerifyViewModel _verifyViewModel;
  bool _isVerifying = false;
  String _loadingMessage = 'Verifying OTP...';
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startResendTimer();
  }

  // Initialize services with faster timeout settings
  void _initializeServices() {
    // Short timeouts for Dio
    final dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 4)
      ..options.receiveTimeout = const Duration(seconds: 4)
      ..options.sendTimeout = const Duration(seconds: 4);

    final apiBaseService = ApiBaseService(dio: dio);
    _verifyService = VerifyService(apiBaseService: apiBaseService);
    _verifyViewModel = VerifyViewModel(
      verifyRepository: VerifyRepository(
        verifyService: _verifyService,
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendSeconds = 30;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
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
                  const SizedBox(height: 30),
                  Text(
                    'Enter code sent to your number',
                    style: TextStyle(
                        color: HexColor("#000000"),
                        fontSize: 22,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We sent it to your mobile number',
                    style: TextStyle(
                        color: HexColor("#000000"),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.phoneNumber,
                        style: TextStyle(
                            color: HexColor("#000000"),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 22,
                          color: HexColor("#3754D3"),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OtpPinInput(
                    onCompleted: (String verificationCode) {
                      setState(() {
                        enteredOtp = verificationCode;
                      });
                      // Auto verify when complete OTP is entered
                      if (verificationCode.length == 6) {
                        verifyOTP();
                      }
                    },
                    activeColor: HexColor("#000000"),
                    inactiveColor: HexColor("#BBBBBB"),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text("Didn't receive an OTP?",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400)),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _canResend ? _resendOTP : null,
                        style: TextButton.styleFrom(
                          foregroundColor: _canResend
                              ? HexColor("#3754D3")
                              : Colors.grey,
                        ),
                        child: Text(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend in $_resendSeconds s',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const Text(" | "),
                      TextButton(
                        onPressed: _canResend ? _verifyViaCall : null,
                        style: TextButton.styleFrom(
                          foregroundColor: _canResend
                              ? HexColor("#3754D3")
                              : Colors.grey,
                        ),
                        child: Text(
                          'Verify via Call',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6339),
                      fixedSize: const Size(double.maxFinite, 40),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    onPressed: _isVerifying ? null : () {
                      if (enteredOtp.length == 6) {
                        verifyOTP();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid 6-digit OTP'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Verify OTP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isVerifying)
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

  void _resendOTP() {
    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resending verification code...'),
      ),
    );

    // Shorter timeout for resend
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 8),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _handleCustomerVerification();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification Failed: ${e.message}')),
          );
        },
        codeSent: (String verId, int? resendToken) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A new verification code has been sent!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _verifyViaCall() {
    _startResendTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification via call will be initiated shortly.'),
      ),
    );
  }

  Future<void> verifyOTP() async {
    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _loadingMessage = 'Verifying OTP...';
    });

    // Set a short timeout (5 seconds max)
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_isVerifying) {
        // If still verifying after 5 seconds, cancel and show error
        setState(() {
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    try {
      _logger.i('$tag: Verifying OTP: $enteredOtp');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: enteredOtp,
      );

      // OPTIMIZATION 1: Save basic login state immediately while auth is happening
      unawaited(_saveBasicLoginState());

      // OPTIMIZATION 2: Set timeout for Firebase auth
      await _auth.signInWithCredential(credential)
          .timeout(const Duration(seconds: 3), onTimeout: () {
        throw Exception('Firebase authentication timed out');
      });

      // Cancel timeout timer
      _timeoutTimer?.cancel();

      // Update UI
      setState(() {
        _loadingMessage = 'OTP verified!';
      });

      // OPTIMIZATION 3: Perform customer verification and navigate without waiting
      _handleCustomerVerification();
    } catch (e) {
      _logger.e('$tag: Error verifying OTP: $e');

      // Cancel timeout timer
      _timeoutTimer?.cancel();

      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to immediately save basic login data
  Future<void> _saveBasicLoginState() async {
    try {
      Map<String, dynamic> basicData = {
        'phone': widget.phoneNumber,
        'isLoggedIn': true,
      };
      await AppPreference.saveUserData(basicData);
      AppLogger.logInfo('$tag: Saved basic login state immediately');
    } catch (e) {
      AppLogger.logError('$tag: Error saving basic login state: $e');
      // Continue anyway
    }
  }

  void _handleCustomerVerification() async {
    try {
      setState(() {
        _loadingMessage = "Checking account details...";
      });

      AppLogger.logInfo('$tag: Verifying user account status for: ${widget.phoneNumber}');

      // Log any existing saved data for comparison
      try {
        final savedData = await AppPreference.getUserData();
        if (savedData.isNotEmpty) {
          AppLogger.logInfo('$tag: Previously saved user data: b2cCustomerId=${savedData['b2cCustomerId']}, ' +
              'newCustomer=${savedData['newCustomer']}');
        }
      } catch (e) {
        // Just log, don't interrupt flow
        AppLogger.logWarning('$tag: Could not load previous user data: $e');
      }

      // Verify the customer with the provided phone number
      await _verifyViewModel.verifyCustomer(widget.phoneNumber)
          .timeout(const Duration(seconds: 4), onTimeout: () {
        throw TimeoutException('Customer verification timed out');
      });

      if (_verifyViewModel.customerData != null) {
        // Log the response data with more details
        final customerData = _verifyViewModel.customerData!;
        AppLogger.logInfo('$tag: VERIFICATION RESPONSE: ' +
            'phone: ${widget.phoneNumber}, ' +
            'b2cCustomerId: ${customerData.b2cCustomerId}, ' +
            'newCustomer: ${customerData.newCustomer}, ' +
            'firstName: ${customerData.firstName}, ' +
            'lastName: ${customerData.lastName}, ' +
            'email: ${customerData.email}');

        // Save complete user data
        Map<String, dynamic> userData = customerData.toJson();
        userData['phone'] = widget.phoneNumber;
        await AppPreference.saveUserData(userData);
        AppLogger.logInfo('$tag: Saved complete user data to preferences');

        // CRITICAL CHECK: Is this an existing user who has already signed up?
        // More robust check to handle various data types
        bool isExistingUser = false;
        if (customerData.b2cCustomerId != null &&
            customerData.b2cCustomerId!.isNotEmpty &&
            customerData.newCustomer == false) {
          isExistingUser = true;
        }

        bool isNewUser = !isExistingUser;

        AppLogger.logInfo('$tag: FINAL USER DETERMINATION: ' +
            (isNewUser ? 'NEW USER - needs signup' : 'EXISTING USER - go to main screen'));

        if (!isNewUser) {
          // EXISTING user - go to main screen
          AppLogger.logInfo('$tag: Redirecting existing user to main screen');
          navigateToMainScreen();
        } else {
          // NEW user - go to signup screen
          AppLogger.logInfo('$tag: Redirecting new user to signup screen');
          if (mounted) {
            setState(() {
              _isVerifying = false;
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SignUpScreen(phoneNumber: widget.phoneNumber),
              ),
            );
          }
        }
      } else {
        // Default to signup if no data
        AppLogger.logWarning('$tag: No customer data returned for ${widget.phoneNumber}, defaulting to signup');
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SignUpScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.logError('$tag: Error in customer verification process: $e');
      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );

        // Default to signup on error
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignUpScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      }
    }
  }
  // Navigate to main screen
  void navigateToMainScreen() {
    setState(() {
      _isVerifying = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }
}

// This helper function marks a future as "fire and forget"
void unawaited(Future<void> future) {}
