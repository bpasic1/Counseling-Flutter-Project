import 'package:flutter/material.dart';

class ReadOnlyTextField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyTextField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 250, // Set the desired width here
        child: TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
