import 'package:counseling_flutter_app/widgets/password_widgets/change_password_dialog.dart';
import 'package:counseling_flutter_app/widgets/auth_profile_widgets/read_only_text_field.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final String firstName;
  final String lastName;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ReadOnlyTextField(label: 'Username', value: username),
              ReadOnlyTextField(label: 'Email', value: email),
              ReadOnlyTextField(label: 'First Name', value: firstName),
              ReadOnlyTextField(label: 'Last Name', value: lastName),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordDialog();
                    },
                  );
                },
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
