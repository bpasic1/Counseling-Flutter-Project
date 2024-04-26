import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Text(''),
      ), */
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade50],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Advice Haven',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Unlock the Power of Community!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/counsle3.png', // Path to your welcome image
                height: 200,
                width: 200,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                },
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to sign up screen
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
