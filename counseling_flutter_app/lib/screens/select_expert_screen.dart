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
          if (experts.isEmpty) {
            return const Center(child: Text('No experts found.'));
          }

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    expertData['information'] ??
                        'No bio available', // Replace with available field if you have it
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage: expertData['profilePicture'] != null
                        ? NetworkImage(expertData[
                            'profilePicture']) // Use this when you have a URL
                        : null, // Placeholder or default image if no picture is available
                    child: expertData['profilePicture'] == null
                        ? Icon(Icons.person, color: Colors.grey) // Default icon
                        : null,
                  ),
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
