import 'package:flutter/material.dart';

class ForgotPasswordDialog extends StatefulWidget {
  final Function(String) onResetPassword;

  const ForgotPasswordDialog({Key? key, required this.onResetPassword})
      : super(key: key);

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  String email = '';
  bool isLoading = false;

  // Regular expression pattern to validate email format
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forgot Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  // Check if the entered email matches the email format
                  if (!emailRegex.hasMatch(email)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please enter a valid email.'),
                    ));
                    return;
                  }

                  // Set loading state
                  setState(() {
                    isLoading = true;
                  });

                  // Call the onResetPassword callback with the entered email
                  await widget.onResetPassword(email);

                  // Reset loading state
                  setState(() {
                    isLoading = false;
                  });

                  Navigator.pop(context); // Close the dialog
                },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('Reset Password'),
        ),
      ],
    );
  }
}
