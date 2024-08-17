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
            enabled: !isLoading,
          ),
          TextField(
            controller: confirmNewPasswordController,
            decoration:
                const InputDecoration(labelText: 'Confirm New Password'),
            obscureText: true,
            enabled: !isLoading,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  String newPassword = newPasswordController.text.trim();
                  String confirmNewPassword =
                      confirmNewPasswordController.text.trim();

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
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Password must be at least 6 characters long'),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });

                  await _changePassword(context, newPassword);

                  setState(() {
                    isLoading = false;
                  });
                },
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
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
