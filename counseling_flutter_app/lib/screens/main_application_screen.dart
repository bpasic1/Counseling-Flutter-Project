import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainApplicationScreen extends StatelessWidget {
  final bool isNewUser;

  const MainApplicationScreen({super.key, required this.isNewUser});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text('Advice Haven'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User data not found');
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String username = userData['username'];
              String email = userData['email'];
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(username),
                    accountEmail: Text(email),
                    currentAccountPicture: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text('Profile'),
                    onTap: () {
                      // Navigate to the Profile screen
                      Navigator.pop(context); // Close the drawer
                      // You can implement navigation to the Profile screen here
                    },
                  ),
                  ListTile(
                    title: Text('Reviews'),
                    onTap: () {
                      // Navigate to the Reviews screen
                      Navigator.pop(context); // Close the drawer
                      // You can implement navigation to the Reviews screen here
                    },
                  ),
                  ListTile(
                    title: Text('Advices'),
                    onTap: () {
                      // Navigate to the Advices screen
                      Navigator.pop(context); // Close the drawer
                      // You can implement navigation to the Advices screen here
                    },
                  ),
                  // Add more ListTile widgets for additional options as needed
                ],
              );
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              isNewUser ? 'Welcome, new user!' : 'Welcome back!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
