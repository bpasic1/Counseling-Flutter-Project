import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BecomeExpertScreen extends StatefulWidget {
  const BecomeExpertScreen({Key? key}) : super(key: key);

  @override
  State<BecomeExpertScreen> createState() => _BecomeExpertScreenState();
}

class _BecomeExpertScreenState extends State<BecomeExpertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoading = true; // Add a loading state
  String? _selectedCategory;
  bool _hasPendingRequest = false;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Mental', 'color': Colors.purple, 'icon': Icons.psychology},
    {'name': 'Career', 'color': Colors.blue, 'icon': Icons.business_center},
    {'name': 'Family', 'color': Colors.red, 'icon': Icons.family_restroom},
    {'name': 'Academic', 'color': Colors.orange, 'icon': Icons.school},
    {
      'name': 'Grief',
      'color': Colors.grey,
      'icon': Icons.sentiment_dissatisfied
    },
    {'name': 'Animals', 'color': Colors.green, 'icon': Icons.pets},
  ];

  @override
  void initState() {
    super.initState();
    _checkForExistingRequest();
  }

  Future<void> _checkForExistingRequest() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (userId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('expertRequests')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _hasPendingRequest = true;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

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

      if (userId != null && _selectedCategory != null) {
        await FirebaseFirestore.instance.collection('expertRequests').add({
          'userId': userId,
          'request': _requestController.text,
          'category': _selectedCategory,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isSubmitting = false;
          _hasPendingRequest = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
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
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator(), // Show a loader while checking
            )
          : _hasPendingRequest
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.hourglass_empty,
                            size: 100, color: Colors.orange),
                        SizedBox(height: 20),
                        Text(
                          'Your request is being processed.\nPlease wait for the administrator\'s decision.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submit Your Request',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Please provide detailed information about your expertise. '
                          'Include links to your work (e.g., Google Drive, portfolio, publications) and explain why you believe you are qualified to become an expert.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            hintText: 'Select Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['name'],
                              child: Row(
                                children: [
                                  Icon(category['icon'],
                                      color: category['color']),
                                  const SizedBox(width: 10),
                                  Text(category['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _requestController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Explain why you should be an expert...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.all(16.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your request';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _isSubmitting
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitRequest,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    backgroundColor: Colors.lightBlue,
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child: const Text('Submit Request'),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
