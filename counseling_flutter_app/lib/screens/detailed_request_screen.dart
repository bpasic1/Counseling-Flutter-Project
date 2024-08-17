import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DetailedRequestScreen extends StatelessWidget {
  final String userName;
  final String requestText;
  final String formattedTimestamp;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final String requestId;
  final String userId;

  const DetailedRequestScreen({
    Key? key,
    required this.userName,
    required this.requestText,
    required this.formattedTimestamp,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.requestId,
    required this.userId,
  }) : super(key: key);

  Future<void> _approveRequest(BuildContext context) async {
    try {
      User? adminUser = FirebaseAuth.instance.currentUser;
      if (adminUser == null) {
        throw Exception('No authenticated administrator');
      }

      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(adminUser.uid)
          .get();
      if (!adminDoc.exists || adminDoc['role'] != 'administrator') {
        throw Exception('Authenticated user is not an administrator');
      }

      String expertiseInfo = '';
      bool isSubmitting = false;

      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent closing the dialog when tapping outside
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Enter Expertise Information'),
                content: TextField(
                  onChanged: (value) {
                    expertiseInfo = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Expertise Information',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: isSubmitting
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                  ),
                  TextButton(
                    child: isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text('Submit'),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setState(() {
                              isSubmitting = true;
                            });

                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .update({
                                'role': 'expert',
                                'category': category,
                                'information': expertiseInfo,
                              });

                              // Delete existing conversations for the user
                              QuerySnapshot conversationSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('conversations')
                                      .where('user_id', isEqualTo: userId)
                                      .get();

                              for (var doc in conversationSnapshot.docs) {
                                await doc.reference.delete();
                              }

                              // Delete the request
                              await FirebaseFirestore.instance
                                  .collection('expertRequests')
                                  .doc(requestId)
                                  .delete();

                              // Show the snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'User has been promoted to expert')),
                              );

                              // Close the dialog and the DetailedRequestScreen
                              Navigator.of(dialogContext).pop();
                              Navigator.of(context).pop();
                            } catch (error) {
                              setState(() {
                                isSubmitting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to promote user: $error')),
                              );
                            }
                          },
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to promote user: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: categoryColor, size: 30),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Submitted on: $formattedTimestamp',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Category: $category',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                requestText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement approve functionality
                    _approveRequest(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('expertRequests')
                        .doc(requestId)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Request has been canceled')),
                    );

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
