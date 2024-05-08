import 'package:counseling_flutter_app/screens/main_and_profile_screens/loading_screen.dart';
import 'package:counseling_flutter_app/screens/main_and_profile_screens/main_application_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:counseling_flutter_app/screens/main_and_profile_screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counsle project',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            print('Auth state changed: ${snapshot.connectionState}');

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (snapshot.hasData) {
              User? user = snapshot.data;
              if (user != null) {
                bool isNewUser = FirebaseAuth
                        .instance.currentUser!.metadata.creationTime ==
                    FirebaseAuth.instance.currentUser!.metadata.lastSignInTime;
                return MainApplicationScreen(isNewUser: isNewUser);
              }
            }

            return const WelcomeScreen();
          }),
    );
  }
}
