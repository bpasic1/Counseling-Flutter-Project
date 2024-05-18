import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({Key? key}) : super(key: key);

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
                final requestText = data['request'] ?? 'No request text';
                final timestamp = data['timestamp']?.toDate() ?? DateTime.now();

                return ListTile(
                  title: Text(requestText),
                  subtitle: Text('Submitted on: ${timestamp.toString()}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
