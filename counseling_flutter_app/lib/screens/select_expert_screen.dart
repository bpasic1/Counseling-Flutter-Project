import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectExpertScreen extends StatelessWidget {
  final List<String> selectedExperts;

  const SelectExpertScreen({Key? key, required this.selectedExperts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Expert'),
      ),
      body: ExpertList(selectedExperts: selectedExperts),
    );
  }
}

class ExpertList extends StatelessWidget {
  final List<String> selectedExperts;

  const ExpertList({Key? key, required this.selectedExperts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'expert')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final experts = snapshot.data!.docs;
          if (experts.isEmpty) {
            return Center(child: Text('No experts found.'));
          }
          // Filter out selected experts
          final filteredExperts = experts
              .where((expert) => !selectedExperts
                  .contains('${expert['firstName']} ${expert['lastName']}'))
              .toList();
          if (filteredExperts.isEmpty) {
            return Center(child: Text('No experts found.'));
          }
          return ListView.builder(
            itemCount: filteredExperts.length,
            itemBuilder: (context, index) {
              final expertData =
                  filteredExperts[index].data() as Map<String, dynamic>;
              final expertName =
                  '${expertData['firstName']} ${expertData['lastName']}';
              return ListTile(
                title: Text(expertName),
                onTap: () {
                  Navigator.pop(context, expertName);
                },
              );
            },
          );
        }
      },
    );
  }
}
