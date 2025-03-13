import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/providers/app_multi_provider.dart';
import 'common/routes/app_routes.dart';
import 'common/styles/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //runApp(const MyApp());

  runApp(
    MultiProvider(
      providers: getProviders(),
      child: const MyApp(),
    ),
  );
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CW Food Ordering",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.splashScreen, // Add this
      routes: Routes.routes, // Add this
    );
  }
}

/*
class MyApp1 extends StatelessWidget {
  const MyApp1({super.key, required String initialRoute});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final bool isLoggedIn = snapshot.data ?? false;
          return MultiProvider(
            providers: getProviders(),
            child: MaterialApp(
              title: 'Phone Auth App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              initialRoute:
                  isLoggedIn ? Routes.mainScreen : Routes.signInScreen,
              routes: Routes.routes,
              onGenerateRoute: (settings) {
                if (settings.name == Routes.signUpScreen) {
                  final args = settings.arguments;
                  if (args is String && args.isNotEmpty) {
                    return MaterialPageRoute(
                      builder: (context) => SignUpScreen(phoneNumber: args),
                    );
                  } else {
                    // Handle the case where phone number is not provided
                    return MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    );
                  }
                }
                // If the requested route is not found, return a default route
                return MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                );
              },
            ),
          );
        }
        // While checking the login status, show a loading screen
        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
*/
