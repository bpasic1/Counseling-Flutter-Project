import 'package:counseling_flutter_app/widgets/auth_profile_widgets/login_info.dart';
import 'package:counseling_flutter_app/widgets/auth_profile_widgets/signup_info.dart';
import 'package:flutter/material.dart';

class AuthenticationScreen extends StatelessWidget {
  final bool isLogin;

  const AuthenticationScreen({super.key, required this.isLogin});

  void _navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Sign In' : 'Sign Up'),
        backgroundColor: Colors.lightBlue.shade50,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade50,
        ),
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/counsle3.png',
                  height: 200,
                ),
                const SizedBox(height: 10),
                Text(
                  isLogin ? 'Sign in to your account' : 'Create Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 5),
                isLogin
                    ? LoginForm(navigateBack: () => _navigateBack(context))
                    : SignUpForm(navigateBack: () => _navigateBack(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
