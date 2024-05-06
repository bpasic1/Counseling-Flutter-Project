import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final _firebaseAuth = FirebaseAuth.instance;

class LoginForm extends StatelessWidget {
  final VoidCallback navigateBack;

  const LoginForm({super.key, required this.navigateBack});

  void _signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User signed in: $userCredentials');

      navigateBack();
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed.'),
      ));
    }
  }

  Future<String?> _resetPassword(String email) async {
    try {
      final url = Uri.parse(
          'https://us-central1-bpasic1-firebase-msc.cloudfunctions.net/forgotPassword');
      final response = await http.post(
        url,
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return 'Password reset email sent successfully.';
      } else {
        return 'Failed to send password reset email.';
      }
    } catch (error) {
      return 'An error occurred: $error';
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(
        onResetPassword: (email) async {
          final message = await _resetPassword(email);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message ?? ''),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value.trim(),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (value) => password = value,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                _signInWithEmailAndPassword(context, email, password),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => _showForgotPasswordDialog(context),
            child: Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }
}
