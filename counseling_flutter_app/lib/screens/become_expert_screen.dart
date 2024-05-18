import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeExpertScreen extends StatefulWidget {
  const BecomeExpertScreen({Key? key}) : super(key: key);

  @override
  _BecomeExpertScreenState createState() => _BecomeExpertScreenState();
}

class _BecomeExpertScreenState extends State<BecomeExpertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      User? user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance.collection('expertRequests').add({
          'userId': userId,
          'request': _requestController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isSubmitting = false;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become an Expert'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Why do you want to become an expert?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _requestController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Explain why you should be an expert...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your request';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitRequest,
                      child: const Text('Submit Request'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
