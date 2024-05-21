import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counseling_flutter_app/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectExpertScreen extends StatelessWidget {
  final String category;
  final List<String> existingChats;
  final Function refreshUI;

  const SelectExpertScreen(
      {Key? key,
      required this.category,
      required this.existingChats,
      required this.refreshUI})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Expert'),
      ),
      body: ExpertList(
          category: category,
          selectedExperts: existingChats,
          refreshUI: refreshUI),
    );
  }
}

class ExpertList extends StatelessWidget {
  final String category;
  final List<String> selectedExperts;
  final Function refreshUI;

  const ExpertList(
      {Key? key,
      required this.category,
      required this.selectedExperts,
      required this.refreshUI})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'expert')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final experts = snapshot.data!.docs;
          if (experts.isEmpty) {
            return const Center(child: Text('No experts found.'));
          }

          /* final existingExpertIds = selectedExperts.map((chat) {
            final ids = chat.split(' - ');
            return ids[
                1]; // Assuming the expert ID is the second part of the chat string
          }).toList(); */

          final existingExpertIds = selectedExperts;

          return ListView.builder(
            itemCount: experts.length,
            itemBuilder: (context, index) {
              final expertData = experts[index].data() as Map<String, dynamic>;
              final expertId = experts[index].id;
              if (existingExpertIds.contains(expertId)) {
                // If the expert is already in the chat list, don't display them
                return const SizedBox.shrink();
              }
              final expertName =
                  '${expertData['firstName']} ${expertData['lastName']}';
              return ListTile(
                title: Text(expertName),
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final userId = user.uid;
                    // Start conversation between user and expert
                    await FirestoreService()
                        .startConversation(userId, expertId);
                    Navigator.pop(context, expertName);
                    refreshUI();
                  } else {
                    // Handle the case where the user is not logged in
                    print('User not logged in');
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
