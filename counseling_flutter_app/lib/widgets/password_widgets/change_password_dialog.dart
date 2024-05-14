import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});
  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newPasswordController,
            decoration: const InputDecoration(labelText: 'New Password'),
            obscureText: true,
            enabled: !isLoading, // Disable text field while loading
          ),
          TextField(
            controller: confirmNewPasswordController,
            decoration:
                const InputDecoration(labelText: 'Confirm New Password'),
            obscureText: true,
            enabled: !isLoading, // Disable text field while loading
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null // Disable the button while loading
              : () {
                  Navigator.pop(context); // Close the dialog
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null // Disable the button while loading
              : () async {
                  String newPassword = newPasswordController.text.trim();
                  String confirmNewPassword =
                      confirmNewPasswordController.text.trim();

                  // Validate if new password and confirm new password match
                  if (newPassword != confirmNewPassword) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'New password and confirm password do not match'),
                      ),
                    );
                    return;
                  }

                  if (newPassword.length < 6) {
                    // Password too short, display error message
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Password must be at least 6 characters long'),
                      ),
                    );
                    return;
                  }

                  // Set loading state
                  setState(() {
                    isLoading = true;
                  });

                  // Call the function to change password
                  await _changePassword(context, newPassword);

                  // Reset loading state
                  setState(() {
                    isLoading = false;
                  });
                },
          child: isLoading
              ? const CircularProgressIndicator() // Show circular progress indicator
              : const Text('Change'),
        ),
      ],
    );
  }

  Future<void> _changePassword(BuildContext context, String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    final url = Uri.parse(
        'https://us-central1-bpasic1-firebase-msc.cloudfunctions.net/changePassword');
    final response = await http.post(
      url,
      body: jsonEncode({'userId': userId, 'newPassword': newPassword}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change password')),
      );
    }
  }
}
