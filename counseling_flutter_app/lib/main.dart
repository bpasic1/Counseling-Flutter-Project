import 'package:flutter/material.dart';

import 'package:counseling_flutter_app/screens/welcome_screen.dart';

void main() {
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
      home: const WelcomeScreen(),
    );
  }
}
