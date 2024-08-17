import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counseling_flutter_app/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectExpertScreen extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final List<String> existingChats;
  final Function refreshUI;

  const SelectExpertScreen(
      {Key? key,
      required this.category,
      required this.categoryColor,
      required this.categoryIcon,
      required this.existingChats,
      required this.refreshUI})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: categoryColor,
        title: Row(
          children: [
            Icon(categoryIcon),
            const SizedBox(width: 8),
            Text('Select Expert - $category'),
          ],
        ),
      ),
      body: ExpertList(
        category: category,
        categoryColor: categoryColor,
        selectedExperts: existingChats,
        refreshUI: refreshUI,
      ),
    );
  }
}

class ExpertList extends StatelessWidget {
  final String category;
  final Color categoryColor;
  final List<String> selectedExperts;
  final Function refreshUI;

  const ExpertList(
      {Key? key,
      required this.category,
      required this.categoryColor,
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
          final existingExpertIds = selectedExperts;

          final availableExperts = experts.where((expert) {
            final expertId = expert.id;
            return !existingExpertIds.contains(expertId);
          }).toList();

          if (availableExperts.isEmpty) {
            return const Center(
                child: Text('No experts available in this category.'));
          }

          return ListView.builder(
            itemCount: availableExperts.length,
            itemBuilder: (context, index) {
              final expertData =
                  availableExperts[index].data() as Map<String, dynamic>;
              final expertId = availableExperts[index].id;
              final expertName =
                  '${expertData['firstName']} ${expertData['lastName']}';

              return Card(
                elevation: 4, // Adds a shadow effect
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: categoryColor
                    .withOpacity(0.4), // Set background color based on category
                child: ListTile(
                  contentPadding: const EdgeInsets.only(
                      left: 16.0,
                      top: 10.0,
                      bottom: 10.0,
                      right: 10.0), // Padding inside the card
                  title: Text(
                    expertName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    expertData['information'] ?? 'No bio available',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: expertData['profilePicture'] != null
                        ? NetworkImage(expertData['profilePicture'])
                        : null,
                    child: expertData['profilePicture'] == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userId = user.uid;
                      // Start conversation between user and expert
                      await FirestoreService()
                          .startConversation(userId, expertId);

                      int count = 0;
                      Navigator.of(context).popUntil((_) => count++ >= 2);
                      refreshUI();
                    } else {
                      print('User not logged in');
                    }
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
