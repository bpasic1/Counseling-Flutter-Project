import 'package:counseling_flutter_app/screens/main_and_profile_screens/loading_screen.dart';
import 'package:counseling_flutter_app/screens/main_and_profile_screens/main_application_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:counseling_flutter_app/screens/main_and_profile_screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await analytics.logEvent(name: 'app_opened');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      title: 'Counsle project',
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
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
