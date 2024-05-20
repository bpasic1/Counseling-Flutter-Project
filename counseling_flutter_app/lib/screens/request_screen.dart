import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'detailed_request_screen.dart';

class RequestsScreen extends StatelessWidget {
  RequestsScreen({Key? key}) : super(key: key);

  Future<Map<String, String>> _getUserName(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data();
    if (data != null) {
      final firstName = data['firstName'] ?? 'Unknown';
      final lastName = data['lastName'] ?? 'User';
      return {'firstName': firstName, 'lastName': lastName};
    }
    return {'firstName': 'Unknown', 'lastName': 'User'};
  }

  final Map<String, IconData> categoryIcons = {
    'Mental': Icons.psychology,
    'Career': Icons.business_center,
    'Family': Icons.family_restroom,
    'Academic': Icons.school,
    'Grief': Icons.sentiment_dissatisfied,
    'Animals': Icons.pets,
  };

  final Map<String, Color> categoryColors = {
    'Mental': Colors.purple,
    'Career': Colors.blue,
    'Family': Colors.red,
    'Academic': Colors.orange,
    'Grief': Colors.grey,
    'Animals': Colors.green,
  };

  String _truncateText(String text, int maxLines) {
    final lines = text.split('\n');
    if (lines.length <= maxLines) {
      return text;
    } else {
      return lines.take(maxLines).join('\n') + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('expertRequests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests found'));
          } else {
            final requests = snapshot.data!.docs;
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final data = request.data() as Map<String, dynamic>;
                final userId = data['userId'] ?? 'Unknown';
                final requestText = data['request'] ?? 'No request text';
                final category = data['category'] ?? 'No category';
                final timestamp = data['timestamp']?.toDate() ?? DateTime.now();
                final formattedTimestamp =
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(timestamp);

                return FutureBuilder<Map<String, String>>(
                  future: _getUserName(userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return const ListTile(
                          title: Text('Error fetching user data'));
                    } else {
                      final userName =
                          '${userSnapshot.data!['firstName']} ${userSnapshot.data!['lastName']}';
                      final shortRequestText = _truncateText(requestText, 3);
                      final categoryColor =
                          categoryColors[category] ?? Colors.lightBlue;
                      final categoryIcon =
                          categoryIcons[category] ?? Icons.category;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(categoryIcon, color: Colors.white),
                            title: Text(
                              userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(shortRequestText,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                const SizedBox(height: 5),
                                Text(
                                  'Submitted on: $formattedTimestamp',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedRequestScreen(
                                    userName: userName,
                                    requestText: requestText,
                                    formattedTimestamp: formattedTimestamp,
                                    category: category,
                                    categoryColor: categoryColor,
                                    categoryIcon: categoryIcon,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
