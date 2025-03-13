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

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    final apiBaseService = ApiBaseService(dio: dio);
    _verifyService = VerifyService(apiBaseService: apiBaseService);
    _verifyViewModel = VerifyViewModel(
      verifyRepository: VerifyRepository(
        verifyService: _verifyService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              const SizedBox(height: 20),
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
                    constraints: BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // OtpTextField(
              //   numberOfFields: 6,
              //   keyboardType: TextInputType.number,
              //   borderColor: HexColor("#BBBBBB"),
              //   enabledBorderColor: HexColor("#BBBBBB"),
              //   focusedBorderColor: HexColor("#000000"),
              //   showFieldAsBox: true,
              //   borderWidth: 1.5,
              //   onCodeChanged: (String code) {
              //     // Handle validation or checks here
              //   },
              //   onSubmit: (String verificationCode) {
              //     enteredOtp = verificationCode;
              //   },
              // ),
              // OtpInputWidget(
              //   onCodeComplete: (String verificationCode) {
              //     setState(() {
              //       enteredOtp = verificationCode;
              //     });
              //   },
              //   activeColor: HexColor("#000000"),
              //   inactiveColor: HexColor("#BBBBBB"),
              // ),
              OtpPinInput(
                onCompleted: (String verificationCode) {
                  setState(() {
                    enteredOtp = verificationCode;
                  });
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
                    onPressed: () {
                      // Resend OTP logic here
                    },
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  const Text(" | "),
                  TextButton(
                    onPressed: () {
                      // Verify via call logic here
                    },
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
                ),
                onPressed: () {
                  _logger.i('$tag: Verify OTP button pressed');
                  verifyOTP();
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
    );
  }

  Future<void> verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: enteredOtp,
    );

    try {
      _logger.i('$tag: Verifying OTP: $enteredOtp');
      await _auth.signInWithCredential(credential);
      await verifyCustomerAndSaveData();
    } catch (e) {
      _logger.e('$tag: Error verifying OTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  // Future<void> verifyCustomerAndSaveData() async {
  //   try {
  //     AppLogger.logInfo('$tag: Verifying customer and fetching data');
  //     await _verifyViewModel.verifyCustomer(widget.phoneNumber);
  //
  //     if (_verifyViewModel.error != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(_verifyViewModel.error!)),
  //       );
  //       return;
  //     }
  //
  //     if (_verifyViewModel.customerData != null) {
  //       AppLogger.logInfo('$tag: Customer data fetched successfully');
  //       await AppPreference.setLoginStatus(true);
  //       await AppPreference.setPhoneNumber(widget.phoneNumber);
  //       await AppPreference.setCustomerData(
  //           _verifyViewModel.customerData!.toJson());
  //
  //       if (_verifyViewModel.isNewCustomer) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 SignUpScreen(phoneNumber: widget.phoneNumber),
  //           ),
  //         );
  //       } else {
  //         navigateToMainScreen();
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //             content: Text('Unable to verify customer. Please try again.')),
  //       );
  //     }
  //   } catch (e) {
  //     AppLogger.logError('$tag: Error while verifying customer: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred. Please try again.')),
  //     );
  //   }
  // }

  Future<void> verifyCustomerAndSaveData() async {
    try {
      AppLogger.logInfo('$tag: Verifying customer and fetching data');
      await _verifyViewModel.verifyCustomer(widget.phoneNumber);

      if (_verifyViewModel.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_verifyViewModel.error!)),
          );
        }
        return;
      }

      if (_verifyViewModel.customerData != null) {
        AppLogger.logInfo('$tag: Customer data fetched successfully');

        // Prepare user data for saving
        Map<String, dynamic> userData = _verifyViewModel.customerData!.toJson();
        userData['phone'] = widget.phoneNumber;

        // Save the user data
        await AppPreference.saveUserData(userData);

        if (!_verifyViewModel.customerData!.newCustomer!) {
          // Existing user - go to main screen
          AppLogger.logInfo(
              '$tag: Existing user detected, navigating to main screen');
          if (mounted) {
            navigateToMainScreen();
          }
        } else {
          // New user - go to signup screen
          AppLogger.logInfo(
              '$tag: New user detected, navigating to signup screen');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    SignUpScreen(phoneNumber: widget.phoneNumber),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to verify customer. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.logError('$tag: Error while verifying customer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    }
  }

  void navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  }
}
