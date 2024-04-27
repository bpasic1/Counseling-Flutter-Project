import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'First Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                // Set initial border color
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Last Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 30,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
